import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:permission_handler/permission_handler.dart';

/// STT State enum
enum SttState {
  idle,
  listening,
  processing,
  error,
  notAvailable,
  noPermission,
}

/// Speech recognition result
class SttResult {
  final String text;
  final bool isFinal;
  final double confidence;
  final DateTime timestamp;

  const SttResult({
    required this.text,
    required this.isFinal,
    this.confidence = 0.0,
    required this.timestamp,
  });

  @override
  String toString() =>
      'SttResult(text: "$text", final: $isFinal, conf: ${(confidence * 100).toStringAsFixed(1)}%)';
}

/// STT Service Configuration
class SttConfig {
  final String languageCode;
  final Duration listenTimeout;
  final Duration pauseTimeout;
  final bool partialResults;
  final bool onDevice;
  final bool allowCloudFallback;

  const SttConfig({
    this.languageCode = 'de-DE',
    this.listenTimeout = const Duration(seconds: 30),
    this.pauseTimeout = const Duration(seconds: 3),
    this.partialResults = true,
    this.onDevice = true,
    this.allowCloudFallback = false,
  });

  SttConfig copyWith({
    String? languageCode,
    Duration? listenTimeout,
    Duration? pauseTimeout,
    bool? partialResults,
    bool? onDevice,
    bool? allowCloudFallback,
  }) {
    return SttConfig(
      languageCode: languageCode ?? this.languageCode,
      listenTimeout: listenTimeout ?? this.listenTimeout,
      pauseTimeout: pauseTimeout ?? this.pauseTimeout,
      partialResults: partialResults ?? this.partialResults,
      onDevice: onDevice ?? this.onDevice,
      allowCloudFallback: allowCloudFallback ?? this.allowCloudFallback,
    );
  }
}

/// Speech-to-Text Service
/// 
/// Provides cross-platform speech recognition with multi-language support.
/// 
/// Usage:
/// ```dart
/// final stt = SttService();
/// await stt.initialize();
/// 
/// stt.resultStream.listen((result) {
///   print('Recognized: ${result.text}');
/// });
/// 
/// await stt.startListening();
/// ```
class SttService {
  final SpeechToText _speech = SpeechToText();

  SttState _state = SttState.idle;
  SttConfig _config = const SttConfig();
  bool _isAvailable = false;
  List<LocaleName> _availableLocales = [];

  final _stateController = StreamController<SttState>.broadcast();
  final _resultController = StreamController<SttResult>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  /// Current STT state
  SttState get state => _state;

  /// Stream of state changes
  Stream<SttState> get stateStream => _stateController.stream;

  /// Stream of recognition results
  Stream<SttResult> get resultStream => _resultController.stream;

  /// Stream of error messages
  Stream<String> get errorStream => _errorController.stream;

  /// Current configuration
  SttConfig get config => _config;

  /// Whether speech recognition is available
  bool get isAvailable => _isAvailable;

  /// Available locales for speech recognition
  List<LocaleName> get availableLocales => List.unmodifiable(_availableLocales);

  /// Initialize the STT engine
  Future<bool> initialize({SttConfig? config}) async {
    try {
      if (config != null) {
        _config = config;
      }

      // Check and request microphone permission
      final hasPermission = await _checkPermission();
      if (!hasPermission) {
        _setState(SttState.noPermission);
        return false;
      }

      // Initialize speech recognition
      _isAvailable = await _speech.initialize(
        onError: _onError,
        onStatus: _onStatus,
        debugLogging: kDebugMode,
      );

      if (!_isAvailable) {
        _setState(SttState.notAvailable);
        _errorController.add('Speech recognition not available on this device');
        return false;
      }

      // Load available locales
      _availableLocales = await _speech.locales();
      debugPrint('Loaded ${_availableLocales.length} STT locales');

      _setState(SttState.idle);
      return true;
    } catch (e) {
      _setState(SttState.error);
      _errorController.add('STT initialization failed: $e');
      debugPrint('STT init error: $e');
      return false;
    }
  }

  /// Check and request microphone permission
  Future<bool> _checkPermission() async {
    var status = await Permission.microphone.status;
    
    if (status.isDenied) {
      status = await Permission.microphone.request();
    }

    if (status.isPermanentlyDenied) {
      _errorController.add('Microphone permission permanently denied');
      return false;
    }

    return status.isGranted;
  }

  /// Check if microphone permission is granted
  Future<bool> hasPermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  /// Request microphone permission
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      _setState(SttState.idle);
      return true;
    }
    return false;
  }

  /// Open app settings for permission
  Future<void> openSettings() async {
    await openAppSettings();
  }

  /// Start listening for speech
  Future<void> startListening({String? localeId}) async {
    if (!_isAvailable) {
      _errorController.add('Speech recognition not available');
      return;
    }

    if (_state == SttState.listening) {
      return; // Already listening
    }

    try {
      final locale = localeId ?? _config.languageCode;
      
      _setState(SttState.listening);

      await _speech.listen(
        onResult: _onResult,
        listenFor: _config.listenTimeout,
        pauseFor: _config.pauseTimeout,
        partialResults: _config.partialResults,
        localeId: locale,
        onDevice: _config.onDevice,
        listenMode: ListenMode.confirmation,
      );
    } catch (e) {
      if (_config.onDevice && _config.allowCloudFallback) {
        try {
          await _speech.listen(
            onResult: _onResult,
            listenFor: _config.listenTimeout,
            pauseFor: _config.pauseTimeout,
            partialResults: _config.partialResults,
            localeId: localeId ?? _config.languageCode,
            onDevice: false,
            listenMode: ListenMode.confirmation,
          );
          return;
        } catch (fallbackError) {
          _setState(SttState.error);
          _errorController.add('Failed to start listening: $fallbackError');
          debugPrint('STT listen fallback error: $fallbackError');
          return;
        }
      }

      _setState(SttState.notAvailable);
      _errorController.add(
        _config.onDevice
            ? 'On-device speech recognition not available. Voice input disabled.'
            : 'Failed to start listening: $e',
      );
      debugPrint('STT listen error: $e');
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    try {
      await _speech.stop();
      _setState(SttState.idle);
    } catch (e) {
      debugPrint('STT stop error: $e');
    }
  }

  /// Cancel listening (no result)
  Future<void> cancel() async {
    try {
      await _speech.cancel();
      _setState(SttState.idle);
    } catch (e) {
      debugPrint('STT cancel error: $e');
    }
  }

  /// Set the language
  void setLanguage(String languageCode) {
    _config = _config.copyWith(languageCode: languageCode);
  }

  /// Check if a language is available
  bool isLanguageAvailable(String languageCode) {
    return _availableLocales.any((l) => 
        l.localeId.toLowerCase().startsWith(languageCode.split('-').first.toLowerCase())
    );
  }

  /// Handle recognition result
  void _onResult(SpeechRecognitionResult result) {
    final sttResult = SttResult(
      text: result.recognizedWords,
      isFinal: result.finalResult,
      confidence: result.hasConfidenceRating ? result.confidence : 0.0,
      timestamp: DateTime.now(),
    );

    _resultController.add(sttResult);
    
    if (result.finalResult) {
      _setState(SttState.processing);
      // Will transition to idle after processing
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_state == SttState.processing) {
          _setState(SttState.idle);
        }
      });
    }
  }

  /// Handle error
  void _onError(SpeechRecognitionError error) {
    _setState(SttState.error);
    _errorController.add(error.errorMsg);
    debugPrint('STT error: ${error.errorMsg}');
    
    // Auto-recover to idle after error
    Future.delayed(const Duration(seconds: 2), () {
      if (_state == SttState.error) {
        _setState(SttState.idle);
      }
    });
  }

  /// Handle status change
  void _onStatus(String status) {
    debugPrint('STT status: $status');
    
    switch (status) {
      case 'listening':
        _setState(SttState.listening);
        break;
      case 'notListening':
        if (_state == SttState.listening) {
          _setState(SttState.processing);
        }
        break;
      case 'done':
        _setState(SttState.idle);
        break;
    }
  }

  /// Update state and notify listeners
  void _setState(SttState newState) {
    if (_state != newState) {
      _state = newState;
      _stateController.add(newState);
    }
  }

  /// Dispose resources
  void dispose() {
    _speech.stop();
    _stateController.close();
    _resultController.close();
    _errorController.close();
  }
}
