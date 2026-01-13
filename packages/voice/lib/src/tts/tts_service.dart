import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// TTS State enum
enum TtsState {
  idle,
  playing,
  paused,
  loading,
  error,
}

/// Voice profile configuration
class VoiceProfile {
  final String name;
  final String languageCode;
  final String? voiceId;
  final double pitch;
  final double rate;

  const VoiceProfile({
    required this.name,
    required this.languageCode,
    this.voiceId,
    this.pitch = 1.0,
    this.rate = 0.5,
  });

  VoiceProfile copyWith({
    String? name,
    String? languageCode,
    String? voiceId,
    double? pitch,
    double? rate,
  }) {
    return VoiceProfile(
      name: name ?? this.name,
      languageCode: languageCode ?? this.languageCode,
      voiceId: voiceId ?? this.voiceId,
      pitch: pitch ?? this.pitch,
      rate: rate ?? this.rate,
    );
  }

  @override
  String toString() =>
      'VoiceProfile(name: $name, lang: $languageCode, rate: $rate)';
}

/// TTS Service Configuration
class TtsConfig {
  final double volume;
  final double pitch;
  final double rate;
  final String languageCode;
  final bool enableQueue;

  const TtsConfig({
    this.volume = 1.0,
    this.pitch = 1.0,
    this.rate = 0.5,
    this.languageCode = 'de-DE',
    this.enableQueue = true,
  });

  TtsConfig copyWith({
    double? volume,
    double? pitch,
    double? rate,
    String? languageCode,
    bool? enableQueue,
  }) {
    return TtsConfig(
      volume: volume ?? this.volume,
      pitch: pitch ?? this.pitch,
      rate: rate ?? this.rate,
      languageCode: languageCode ?? this.languageCode,
      enableQueue: enableQueue ?? this.enableQueue,
    );
  }
}

/// Text-to-Speech Service
/// 
/// Provides cross-platform text-to-speech functionality with 
/// multi-language support.
/// 
/// Usage:
/// ```dart
/// final tts = TtsService();
/// await tts.initialize();
/// await tts.speak('Hallo Welt');
/// ```
class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  
  TtsState _state = TtsState.idle;
  TtsConfig _config = const TtsConfig();
  List<VoiceProfile> _availableVoices = [];
  VoiceProfile? _currentVoice;
  
  final _stateController = StreamController<TtsState>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  /// Current TTS state
  TtsState get state => _state;

  /// Stream of state changes
  Stream<TtsState> get stateStream => _stateController.stream;

  /// Stream of error messages
  Stream<String> get errorStream => _errorController.stream;

  /// Current configuration
  TtsConfig get config => _config;

  /// Available voices
  List<VoiceProfile> get availableVoices => List.unmodifiable(_availableVoices);

  /// Current selected voice
  VoiceProfile? get currentVoice => _currentVoice;

  /// Initialize the TTS engine
  Future<bool> initialize({TtsConfig? config}) async {
    try {
      _setState(TtsState.loading);

      if (config != null) {
        _config = config;
      }

      // Set up callbacks
      _flutterTts.setStartHandler(() {
        _setState(TtsState.playing);
      });

      _flutterTts.setCompletionHandler(() {
        _setState(TtsState.idle);
      });

      _flutterTts.setErrorHandler((message) {
        _setState(TtsState.error);
        _errorController.add(message.toString());
        debugPrint('TTS Error: $message');
      });

      _flutterTts.setCancelHandler(() {
        _setState(TtsState.idle);
      });

      _flutterTts.setPauseHandler(() {
        _setState(TtsState.paused);
      });

      _flutterTts.setContinueHandler(() {
        _setState(TtsState.playing);
      });

      // Configure engine
      await _applyConfig();

      // Load available voices
      await _loadVoices();

      _setState(TtsState.idle);
      return true;
    } catch (e) {
      _setState(TtsState.error);
      _errorController.add('TTS initialization failed: $e');
      debugPrint('TTS init error: $e');
      return false;
    }
  }

  /// Apply current configuration to TTS engine
  Future<void> _applyConfig() async {
    await _flutterTts.setVolume(_config.volume);
    await _flutterTts.setPitch(_config.pitch);
    await _flutterTts.setSpeechRate(_config.rate);
    await _flutterTts.setLanguage(_config.languageCode);
  }

  /// Load available voices
  Future<void> _loadVoices() async {
    try {
      final voices = await _flutterTts.getVoices;
      if (voices is List) {
        _availableVoices = voices.map((v) {
          final map = v as Map;
          return VoiceProfile(
            name: map['name']?.toString() ?? 'Unknown',
            languageCode: map['locale']?.toString() ?? 'en-US',
            voiceId: map['name']?.toString(),
          );
        }).toList();
        debugPrint('Loaded ${_availableVoices.length} voices');
      }
    } catch (e) {
      debugPrint('Failed to load voices: $e');
    }
  }

  /// Speak the given text
  /// 
  /// [text] - The text to speak
  /// [languageCode] - Optional language code override
  /// [flush] - If true, stops current speech before speaking
  Future<void> speak(
    String text, {
    String? languageCode,
    bool flush = false,
  }) async {
    if (text.isEmpty) return;

    try {
      if (flush) {
        await stop();
      }

      if (languageCode != null && languageCode != _config.languageCode) {
        await setLanguage(languageCode);
      }

      _setState(TtsState.loading);
      await _flutterTts.speak(text);
    } catch (e) {
      _setState(TtsState.error);
      _errorController.add('Failed to speak: $e');
      debugPrint('TTS speak error: $e');
    }
  }

  /// Stop current speech
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _setState(TtsState.idle);
    } catch (e) {
      debugPrint('TTS stop error: $e');
    }
  }

  /// Pause current speech (if supported)
  Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      debugPrint('TTS pause error: $e');
    }
  }

  /// Set the language
  Future<void> setLanguage(String languageCode) async {
    try {
      await _flutterTts.setLanguage(languageCode);
      _config = _config.copyWith(languageCode: languageCode);
    } catch (e) {
      _errorController.add('Language not available: $languageCode');
      debugPrint('Failed to set language: $e');
    }
  }

  /// Set the speech rate (0.0 - 1.0)
  Future<void> setRate(double rate) async {
    final clampedRate = rate.clamp(0.0, 1.0);
    await _flutterTts.setSpeechRate(clampedRate);
    _config = _config.copyWith(rate: clampedRate);
  }

  /// Set the pitch (0.5 - 2.0)
  Future<void> setPitch(double pitch) async {
    final clampedPitch = pitch.clamp(0.5, 2.0);
    await _flutterTts.setPitch(clampedPitch);
    _config = _config.copyWith(pitch: clampedPitch);
  }

  /// Set the volume (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    final clampedVolume = volume.clamp(0.0, 1.0);
    await _flutterTts.setVolume(clampedVolume);
    _config = _config.copyWith(volume: clampedVolume);
  }

  /// Set a specific voice
  Future<void> setVoice(VoiceProfile voice) async {
    try {
      await _flutterTts.setVoice({
        'name': voice.voiceId ?? voice.name,
        'locale': voice.languageCode,
      });
      _currentVoice = voice;
      _config = _config.copyWith(languageCode: voice.languageCode);
    } catch (e) {
      debugPrint('Failed to set voice: $e');
    }
  }

  /// Get voices for a specific language
  List<VoiceProfile> getVoicesForLanguage(String languageCode) {
    return _availableVoices
        .where((v) => v.languageCode.startsWith(languageCode.split('-').first))
        .toList();
  }

  /// Check if a language is supported
  Future<bool> isLanguageAvailable(String languageCode) async {
    try {
      final result = await _flutterTts.isLanguageAvailable(languageCode);
      return result == 1 || result == true;
    } catch (e) {
      return false;
    }
  }

  /// Update state and notify listeners
  void _setState(TtsState newState) {
    if (_state != newState) {
      _state = newState;
      _stateController.add(newState);
    }
  }

  /// Dispose resources
  void dispose() {
    _flutterTts.stop();
    _stateController.close();
    _errorController.close();
  }
}
