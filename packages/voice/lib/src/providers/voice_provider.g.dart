// GENERATED CODE - DO NOT MODIFY BY HAND
// Run `dart run build_runner build` to regenerate

part of 'voice_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ttsServiceHash() => r'tts_service_hash';

/// TTS Service Provider
@ProviderFor(ttsService)
final ttsServiceProvider = AutoDisposeProvider<TtsService>.internal(
  ttsService,
  name: r'ttsServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ttsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TtsServiceRef = AutoDisposeProviderRef<TtsService>;

String _$sttServiceHash() => r'stt_service_hash';

/// STT Service Provider
@ProviderFor(sttService)
final sttServiceProvider = AutoDisposeProvider<SttService>.internal(
  sttService,
  name: r'sttServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sttServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SttServiceRef = AutoDisposeProviderRef<SttService>;

String _$commandParserHash() => r'command_parser_hash';

/// Command Parser Provider
@ProviderFor(commandParser)
final commandParserProvider = AutoDisposeProviderFamily<CommandParser, String>.internal(
  commandParser,
  name: r'commandParserProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$commandParserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CommandParserRef = AutoDisposeProviderRef<CommandParser>;

String _$announcementBuilderHash() => r'announcement_builder_hash';

/// Announcement Builder Provider
@ProviderFor(announcementBuilder)
final announcementBuilderProvider = AutoDisposeProviderFamily<AnnouncementBuilder, String>.internal(
  announcementBuilder,
  name: r'announcementBuilderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$announcementBuilderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AnnouncementBuilderRef = AutoDisposeProviderRef<AnnouncementBuilder>;

String _$voiceNotifierHash() => r'voice_notifier_hash';

/// Main Voice Notifier
@ProviderFor(VoiceNotifier)
final voiceNotifierProvider = AutoDisposeNotifierProvider<VoiceNotifier, VoiceState>.internal(
  VoiceNotifier.new,
  name: r'voiceNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$voiceNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$VoiceNotifier = AutoDisposeNotifier<VoiceState>;

String _$voiceStringsHash() => r'voice_strings_hash';

/// Convenience provider for current voice strings
@ProviderFor(voiceStrings)
final voiceStringsProvider = AutoDisposeProvider<VoiceStrings>.internal(
  voiceStrings,
  name: r'voiceStringsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$voiceStringsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef VoiceStringsRef = AutoDisposeProviderRef<VoiceStrings>;

String _$isSpeakingHash() => r'is_speaking_hash';

/// Provider for checking if voice is speaking
@ProviderFor(isSpeaking)
final isSpeakingProvider = AutoDisposeProvider<bool>.internal(
  isSpeaking,
  name: r'isSpeakingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isSpeakingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IsSpeakingRef = AutoDisposeProviderRef<bool>;

String _$isListeningHash() => r'is_listening_hash';

/// Provider for checking if voice is listening
@ProviderFor(isListening)
final isListeningProvider = AutoDisposeProvider<bool>.internal(
  isListening,
  name: r'isListeningProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isListeningHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IsListeningRef = AutoDisposeProviderRef<bool>;
