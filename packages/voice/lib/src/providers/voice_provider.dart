import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../tts/tts_service.dart';
import '../stt/stt_service.dart';
import '../localization/supported_languages.dart';
import '../localization/voice_strings.dart';
import '../commands/command_parser.dart';
import '../announcements/announcement_builder.dart';

part 'voice_provider.g.dart';

/// Voice feature state
class VoiceState {
  final bool isEnabled;
  final String languageCode;
  final TtsState ttsState;
  final SttState sttState;
  final double speechRate;
  final double volume;
  final double pitch;
  final String? lastSpokenText;
  final String? lastRecognizedText;
  final String? errorMessage;

  const VoiceState({
    this.isEnabled = true,
    this.languageCode = 'de',
    this.ttsState = TtsState.idle,
    this.sttState = SttState.idle,
    this.speechRate = 1.0,
    this.volume = 1.0,
    this.pitch = 1.0,
    this.lastSpokenText,
    this.lastRecognizedText,
    this.errorMessage,
  });

  VoiceState copyWith({
    bool? isEnabled,
    String? languageCode,
    TtsState? ttsState,
    SttState? sttState,
    double? speechRate,
    double? volume,
    double? pitch,
    String? lastSpokenText,
    String? lastRecognizedText,
    String? errorMessage,
  }) {
    return VoiceState(
      isEnabled: isEnabled ?? this.isEnabled,
      languageCode: languageCode ?? this.languageCode,
      ttsState: ttsState ?? this.ttsState,
      sttState: sttState ?? this.sttState,
      speechRate: speechRate ?? this.speechRate,
      volume: volume ?? this.volume,
      pitch: pitch ?? this.pitch,
      lastSpokenText: lastSpokenText ?? this.lastSpokenText,
      lastRecognizedText: lastRecognizedText ?? this.lastRecognizedText,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isSpeaking => ttsState == TtsState.playing;
  bool get isListening => sttState == SttState.listening;
  bool get hasError => errorMessage != null;

  VoiceStrings get strings => SupportedLanguages.getStrings(languageCode);
}

/// TTS Service Provider
@riverpod
TtsService ttsService(Ref ref) {
  final service = TtsService();
  ref.onDispose(() => service.dispose());
  return service;
}

/// STT Service Provider
@riverpod
SttService sttService(Ref ref) {
  final service = SttService();
  ref.onDispose(() => service.dispose());
  return service;
}

/// Command Parser Provider
@riverpod
CommandParser commandParser(Ref ref, String languageCode) {
  final strings = SupportedLanguages.getStrings(languageCode);
  return CommandParser(strings);
}

/// Announcement Builder Provider
@riverpod
AnnouncementBuilder announcementBuilder(Ref ref, String languageCode) {
  final strings = SupportedLanguages.getStrings(languageCode);
  return AnnouncementBuilder(strings);
}

/// Main Voice Notifier
@riverpod
class VoiceNotifier extends _$VoiceNotifier {
  TtsService? _ttsService;
  SttService? _sttService;
  StreamSubscription? _ttsStateSubscription;
  StreamSubscription? _sttStateSubscription;
  StreamSubscription? _sttResultSubscription;
  StreamSubscription? _sttErrorSubscription;

  @override
  VoiceState build() {
    ref.onDispose(_dispose);
    return const VoiceState();
  }

  void _dispose() {
    _ttsStateSubscription?.cancel();
    _sttStateSubscription?.cancel();
    _sttResultSubscription?.cancel();
    _sttErrorSubscription?.cancel();
  }

  /// Initialize voice services
  Future<void> initialize() async {
    _ttsService = ref.read(ttsServiceProvider);
    _sttService = ref.read(sttServiceProvider);

    // Initialize services
    await _ttsService!.initialize();
    await _sttService!.initialize(
      config: const SttConfig(
        onDevice: true,
        allowCloudFallback: false,
      ),
    );

    // Configure TTS
    await _ttsService!.setLanguage(
      SupportedLanguages.getTtsLocale(state.languageCode),
    );
    await _ttsService!.setRate(state.speechRate);
    await _ttsService!.setVolume(state.volume);
    await _ttsService!.setPitch(state.pitch);

    // Subscribe to state changes
    _ttsStateSubscription = _ttsService!.stateStream.listen((ttsState) {
      state = state.copyWith(ttsState: ttsState);
    });

    _sttStateSubscription = _sttService!.stateStream.listen((sttState) {
      state = state.copyWith(sttState: sttState);
    });

    _sttResultSubscription = _sttService!.resultStream.listen((result) {
      if (result.isFinal) {
        state = state.copyWith(lastRecognizedText: result.text);
      }
    });

    _sttErrorSubscription = _sttService!.errorStream.listen((error) {
      state = state.copyWith(errorMessage: error);
    });
  }

  /// Enable/disable voice features
  void setEnabled(bool enabled) {
    state = state.copyWith(isEnabled: enabled);
    if (!enabled) {
      _ttsService?.stop();
      _sttService?.stopListening();
    }
  }

  /// Change language
  Future<void> setLanguage(String languageCode) async {
    if (!SupportedLanguages.isSupported(languageCode)) {
      state = state.copyWith(
        errorMessage: 'Language not supported: $languageCode',
      );
      return;
    }

    state = state.copyWith(languageCode: languageCode);
    await _ttsService?.setLanguage(
      SupportedLanguages.getTtsLocale(languageCode),
    );
  }

  /// Set speech rate
  Future<void> setSpeechRate(double rate) async {
    state = state.copyWith(speechRate: rate);
    await _ttsService?.setRate(rate);
  }

  /// Set volume
  Future<void> setVolume(double volume) async {
    state = state.copyWith(volume: volume);
    await _ttsService?.setVolume(volume);
  }

  /// Set pitch
  Future<void> setPitch(double pitch) async {
    state = state.copyWith(pitch: pitch);
    await _ttsService?.setPitch(pitch);
  }

  /// Speak text
  Future<void> speak(String text) async {
    if (!state.isEnabled) return;

    state = state.copyWith(lastSpokenText: text, errorMessage: null);
    await _ttsService?.speak(text);
  }

  /// Stop speaking
  Future<void> stopSpeaking() async {
    await _ttsService?.stop();
  }

  /// Start listening
  Future<void> startListening() async {
    if (!state.isEnabled) return;

    state = state.copyWith(errorMessage: null);
    await _sttService?.startListening(
      localeId: SupportedLanguages.getTtsLocale(state.languageCode),
    );
  }

  /// Stop listening
  Future<void> stopListening() async {
    await _sttService?.stopListening();
  }

  /// Cancel listening
  Future<void> cancelListening() async {
    await _sttService?.cancel();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Check if microphone permission is granted
  Future<bool> hasMicrophonePermission() async {
    return await _sttService?.hasPermission() ?? false;
  }

  /// Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    return await _sttService?.requestPermission() ?? false;
  }
}

/// Convenience provider for current voice strings
@riverpod
VoiceStrings voiceStrings(Ref ref) {
  final state = ref.watch(voiceNotifierProvider);
  return state.strings;
}

/// Provider for checking if voice is speaking
@riverpod
bool isSpeaking(Ref ref) {
  final state = ref.watch(voiceNotifierProvider);
  return state.isSpeaking;
}

/// Provider for checking if voice is listening
@riverpod
bool isListening(Ref ref) {
  final state = ref.watch(voiceNotifierProvider);
  return state.isListening;
}
