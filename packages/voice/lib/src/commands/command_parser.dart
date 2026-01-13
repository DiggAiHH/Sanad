import '../localization/voice_strings.dart';

/// Voice command types
enum VoiceCommandType {
  status,
  waitTime,
  position,
  cancel,
  help,
  nextPatient,
  patientDone,
  unknown,
}

/// Parsed voice command result
class VoiceCommand {
  final VoiceCommandType type;
  final String rawText;
  final double confidence;
  final Map<String, dynamic> parameters;

  const VoiceCommand({
    required this.type,
    required this.rawText,
    this.confidence = 1.0,
    this.parameters = const {},
  });

  bool get isKnown => type != VoiceCommandType.unknown;

  @override
  String toString() =>
      'VoiceCommand(type: $type, text: "$rawText", conf: ${(confidence * 100).toStringAsFixed(0)}%)';
}

/// Parses spoken text into structured voice commands
/// 
/// Uses fuzzy matching to handle speech recognition errors.
/// 
/// Usage:
/// ```dart
/// final parser = CommandParser(voiceStrings);
/// final command = parser.parse('wie ist mein status');
/// if (command.type == VoiceCommandType.status) {
///   // Handle status request
/// }
/// ```
class CommandParser {
  final VoiceStrings _strings;
  final double _minMatchScore;

  CommandParser(
    this._strings, {
    double minMatchScore = 0.6,
  }) : _minMatchScore = minMatchScore;

  /// Parse spoken text into a VoiceCommand
  VoiceCommand parse(String text) {
    final normalizedText = _normalize(text);
    
    // Try exact matches first
    var result = _tryExactMatch(normalizedText);
    if (result != null) return result;

    // Try fuzzy matching
    result = _tryFuzzyMatch(normalizedText);
    if (result != null) return result;

    // Unknown command
    return VoiceCommand(
      type: VoiceCommandType.unknown,
      rawText: text,
      confidence: 0.0,
    );
  }

  /// Normalize text for matching
  String _normalize(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove punctuation
        .replaceAll(RegExp(r'\s+'), ' '); // Normalize whitespace
  }

  /// Try exact command matching
  VoiceCommand? _tryExactMatch(String text) {
    final commandMappings = _getCommandMappings();

    for (final entry in commandMappings.entries) {
      for (final command in entry.value) {
        if (_normalize(command) == text) {
          return VoiceCommand(
            type: entry.key,
            rawText: text,
            confidence: 1.0,
          );
        }
      }
    }

    return null;
  }

  /// Try fuzzy command matching
  VoiceCommand? _tryFuzzyMatch(String text) {
    final commandMappings = _getCommandMappings();
    
    VoiceCommandType? bestType;
    double bestScore = 0.0;
    String? bestCommand;

    for (final entry in commandMappings.entries) {
      for (final command in entry.value) {
        final score = _calculateSimilarity(text, _normalize(command));
        if (score > bestScore && score >= _minMatchScore) {
          bestScore = score;
          bestType = entry.key;
          bestCommand = command;
        }
      }
    }

    if (bestType != null) {
      return VoiceCommand(
        type: bestType,
        rawText: text,
        confidence: bestScore,
      );
    }

    return null;
  }

  /// Get all command mappings from voice strings
  Map<VoiceCommandType, List<String>> _getCommandMappings() {
    return {
      VoiceCommandType.status: _strings.statusCommands,
      VoiceCommandType.waitTime: _strings.waitTimeCommands,
      VoiceCommandType.position: _strings.positionCommands,
      VoiceCommandType.cancel: _strings.cancelCommands,
      VoiceCommandType.help: _strings.helpCommands,
      VoiceCommandType.nextPatient: _strings.nextPatientCommands,
      VoiceCommandType.patientDone: _strings.patientDoneCommands,
    };
  }

  /// Calculate similarity between two strings (Levenshtein-based)
  double _calculateSimilarity(String a, String b) {
    if (a.isEmpty || b.isEmpty) return 0.0;
    if (a == b) return 1.0;

    // Check if one contains the other
    if (a.contains(b) || b.contains(a)) {
      final shorter = a.length < b.length ? a : b;
      final longer = a.length >= b.length ? a : b;
      return shorter.length / longer.length;
    }

    // Levenshtein distance
    final distance = _levenshteinDistance(a, b);
    final maxLength = a.length > b.length ? a.length : b.length;
    return 1.0 - (distance / maxLength);
  }

  /// Calculate Levenshtein distance between two strings
  int _levenshteinDistance(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    List<int> previousRow = List.generate(b.length + 1, (i) => i);
    List<int> currentRow = List.filled(b.length + 1, 0);

    for (int i = 0; i < a.length; i++) {
      currentRow[0] = i + 1;

      for (int j = 0; j < b.length; j++) {
        final insertCost = currentRow[j] + 1;
        final deleteCost = previousRow[j + 1] + 1;
        final replaceCost = a[i] == b[j] ? previousRow[j] : previousRow[j] + 1;

        currentRow[j + 1] = [insertCost, deleteCost, replaceCost].reduce(
          (min, val) => val < min ? val : min,
        );
      }

      final temp = previousRow;
      previousRow = currentRow;
      currentRow = temp;
    }

    return previousRow[b.length];
  }

  /// Check if text contains a cancel confirmation
  bool isConfirmation(String text) {
    final normalized = _normalize(text);
    final yesWords = [
      'ja', 'yes', 'evet', 'نعم', 'да', 'tak', 'oui', 'sí', 'si',
      'sim', 'так', 'بله', 'ہاں', 'có', 'da', 'ναι'
    ];
    return yesWords.any((word) => normalized.contains(word));
  }

  /// Check if text contains a denial
  bool isDenial(String text) {
    final normalized = _normalize(text);
    final noWords = [
      'nein', 'no', 'hayır', 'لا', 'нет', 'nie', 'non', 
      'não', 'ні', 'خیر', 'نہیں', 'không', 'nu', 'όχι'
    ];
    return noWords.any((word) => normalized.contains(word));
  }
}
