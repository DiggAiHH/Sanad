import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// Anamnese-Bogen ausfüllen Screen
/// 
/// Dynamischer Fragebogen basierend auf Template vom Backend.
/// Unterstützt alle Fragetypen und bedingte Logik.
class FillAnamnesisScreen extends ConsumerStatefulWidget {
  final String templateId;
  final String? appointmentId;
  
  const FillAnamnesisScreen({
    super.key,
    required this.templateId,
    this.appointmentId,
  });

  @override
  ConsumerState<FillAnamnesisScreen> createState() => _FillAnamnesisScreenState();
}

class _FillAnamnesisScreenState extends ConsumerState<FillAnamnesisScreen> {
  int _currentSection = 0;
  final Map<String, dynamic> _answers = {};
  bool _isLoading = false;
  bool _isSubmitting = false;
  
  // Mock-Template - wird durch API ersetzt
  late AnamnesisTemplate _template;
  
  @override
  void initState() {
    super.initState();
    _loadTemplate();
  }
  
  void _loadTemplate() {
    // TODO: Echten API-Call implementieren
    _template = _createMockTemplate();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    
    final currentSectionData = _template.sections[_currentSection];
    final progress = (_currentSection + 1) / _template.sections.length;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_template.name),
        actions: [
          TextButton.icon(
            onPressed: _saveDraft,
            icon: const Icon(Icons.save_outlined),
            label: Text(l10n.buttonSaveDraft),
          ),
        ],
      ),
      body: Column(
        children: [
          // Fortschrittsanzeige
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.divider,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${l10n.anamnesisSection} ${_currentSection + 1} ${l10n.of_} ${_template.sections.length}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                Text(
                  '~${_template.estimatedMinutes} ${l10n.minutesAbbrev}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          
          // Abschnitts-Inhalt
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Abschnitts-Titel
                  Text(
                    currentSectionData.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (currentSectionData.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      currentSectionData.description!,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                  const SizedBox(height: 24),
                  
                  // Fragen
                  ...currentSectionData.questions
                      .where((q) => _shouldShowQuestion(q))
                      .map((question) => _buildQuestion(question)),
                ],
              ),
            ),
          ),
          
          // Navigation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  if (_currentSection > 0)
                    OutlinedButton.icon(
                      onPressed: () => setState(() => _currentSection--),
                      icon: const Icon(Icons.arrow_back),
                      label: Text(l10n.buttonBack),
                    ),
                  const Spacer(),
                  if (_currentSection < _template.sections.length - 1)
                    ElevatedButton.icon(
                      onPressed: _canProceed() 
                          ? () => setState(() => _currentSection++)
                          : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(l10n.buttonNext),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: _canProceed() ? _submitAnamnesis : null,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                      label: Text(l10n.buttonSubmit),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(AnamnesisQuestion question) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Frage-Text
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  question.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (question.required)
                const Text(
                  ' *',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
            ],
          ),
          if (question.description != null) ...[
            const SizedBox(height: 4),
            Text(
              question.description!,
              style: const TextStyle(color: AppColors.textHint, fontSize: 14),
            ),
          ],
          const SizedBox(height: 12),
          
          // Eingabefeld basierend auf Typ
          _buildQuestionInput(question),
        ],
      ),
    );
  }

  Widget _buildQuestionInput(AnamnesisQuestion question) {
    switch (question.type) {
      case QuestionType.text:
        return TextField(
          decoration: InputDecoration(
            hintText: question.placeholder,
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) => _setAnswer(question.id, value),
        );
        
      case QuestionType.textarea:
        return TextField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: question.placeholder,
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) => _setAnswer(question.id, value),
        );
        
      case QuestionType.number:
        return TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: question.placeholder,
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) => _setAnswer(question.id, int.tryParse(value)),
        );
        
      case QuestionType.date:
        return _DatePickerField(
          value: _answers[question.id] as DateTime?,
          onChanged: (date) => _setAnswer(question.id, date),
        );
        
      case QuestionType.singleChoice:
        return Column(
          children: question.options!.map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: _answers[question.id] as String?,
              onChanged: (value) => _setAnswer(question.id, value),
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
        );
        
      case QuestionType.multipleChoice:
        final selected = (_answers[question.id] as List<String>?) ?? [];
        return Column(
          children: question.options!.map((option) {
            return CheckboxListTile(
              title: Text(option),
              value: selected.contains(option),
              onChanged: (checked) {
                final newList = List<String>.from(selected);
                if (checked == true) {
                  newList.add(option);
                } else {
                  newList.remove(option);
                }
                _setAnswer(question.id, newList);
              },
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
        );
        
      case QuestionType.scale:
        final value = (_answers[question.id] as int?) ?? question.minValue ?? 1;
        final min = question.minValue ?? 1;
        final max = question.maxValue ?? 10;
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$min', style: const TextStyle(color: AppColors.textSecondary)),
                Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('$max', style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
            Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: max - min,
              onChanged: (v) => _setAnswer(question.id, v.round()),
            ),
          ],
        );
        
      case QuestionType.yesNo:
        return Row(
          children: [
            Expanded(
              child: _SelectableButton(
                label: context.l10n.buttonYes,
                isSelected: _answers[question.id] == true,
                onTap: () => _setAnswer(question.id, true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _SelectableButton(
                label: context.l10n.buttonNo,
                isSelected: _answers[question.id] == false,
                onTap: () => _setAnswer(question.id, false),
              ),
            ),
          ],
        );
        
      case QuestionType.bodyMap:
        return _BodyMapSelector(
          selectedParts: (_answers[question.id] as List<String>?) ?? [],
          onChanged: (parts) => _setAnswer(question.id, parts),
        );
    }
  }

  bool _shouldShowQuestion(AnamnesisQuestion question) {
    if (question.condition == null) return true;
    
    final condition = question.condition!;
    final answerValue = _answers[condition.questionId];
    
    switch (condition.operator) {
      case 'equals':
        return answerValue == condition.value;
      case 'not_equals':
        return answerValue != condition.value;
      case 'contains':
        if (answerValue is List) {
          return answerValue.contains(condition.value);
        }
        return false;
      case 'greater_than':
        if (answerValue is num && condition.value is num) {
          return answerValue > condition.value;
        }
        return false;
      case 'less_than':
        if (answerValue is num && condition.value is num) {
          return answerValue < condition.value;
        }
        return false;
      default:
        return true;
    }
  }

  void _setAnswer(String questionId, dynamic value) {
    setState(() {
      _answers[questionId] = value;
    });
  }

  bool _canProceed() {
    final currentSectionData = _template.sections[_currentSection];
    for (final question in currentSectionData.questions) {
      if (!_shouldShowQuestion(question)) continue;
      if (question.required && !_answers.containsKey(question.id)) {
        return false;
      }
      if (question.required && _answers[question.id] == null) {
        return false;
      }
      // Leere Listen/Strings prüfen
      final answer = _answers[question.id];
      if (question.required) {
        if (answer is String && answer.isEmpty) return false;
        if (answer is List && answer.isEmpty) return false;
      }
    }
    return true;
  }

  void _saveDraft() {
    final l10n = context.l10n;
    // TODO: Speichern im lokalen Storage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.anamnesisDraftSaved)),
    );
  }

  Future<void> _submitAnamnesis() async {
    final l10n = context.l10n;
    setState(() => _isSubmitting = true);
    
    try {
      // TODO: API-Call
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            title: Text(l10n.anamnesisSubmitSuccess),
            content: Text(l10n.anamnesisSubmitSuccessMessage),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text(l10n.buttonOk),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.anamnesisSubmitError),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
  
  AnamnesisTemplate _createMockTemplate() {
    return AnamnesisTemplate(
      id: 'general',
      name: 'Allgemeine Anamnese',
      description: 'Erstaufnahme-Fragebogen',
      estimatedMinutes: 15,
      sections: [
        AnamnesisSection(
          id: 'current',
          title: 'Aktuelle Beschwerden',
          description: 'Beschreiben Sie Ihre aktuellen Symptome',
          questions: [
            AnamnesisQuestion(
              id: 'main_complaint',
              text: 'Was führt Sie heute zu uns?',
              type: QuestionType.textarea,
              required: true,
              placeholder: 'Beschreiben Sie Ihre Beschwerden...',
            ),
            AnamnesisQuestion(
              id: 'duration',
              text: 'Seit wann bestehen die Beschwerden?',
              type: QuestionType.singleChoice,
              required: true,
              options: ['Seit heute', 'Seit einigen Tagen', 'Seit einer Woche', 'Seit Monaten'],
            ),
            AnamnesisQuestion(
              id: 'pain_level',
              text: 'Wie stark sind Ihre Beschwerden (1-10)?',
              type: QuestionType.scale,
              minValue: 1,
              maxValue: 10,
            ),
          ],
        ),
        AnamnesisSection(
          id: 'history',
          title: 'Vorerkrankungen',
          questions: [
            AnamnesisQuestion(
              id: 'chronic',
              text: 'Haben Sie chronische Erkrankungen?',
              type: QuestionType.multipleChoice,
              required: true,
              options: ['Diabetes', 'Bluthochdruck', 'Herzerkrankung', 'Asthma/COPD', 'Keine', 'Andere'],
            ),
            AnamnesisQuestion(
              id: 'surgeries',
              text: 'Hatten Sie Operationen?',
              type: QuestionType.textarea,
              placeholder: 'z.B. Blinddarm 2015',
            ),
          ],
        ),
        AnamnesisSection(
          id: 'allergies',
          title: 'Allergien',
          questions: [
            AnamnesisQuestion(
              id: 'has_allergies',
              text: 'Haben Sie Allergien?',
              type: QuestionType.yesNo,
              required: true,
            ),
            AnamnesisQuestion(
              id: 'allergy_list',
              text: 'Welche Allergien?',
              type: QuestionType.multipleChoice,
              options: ['Penicillin', 'Schmerzmittel', 'Pollen', 'Nahrungsmittel', 'Andere'],
              condition: QuestionCondition(questionId: 'has_allergies', operator: 'equals', value: true),
            ),
          ],
        ),
        AnamnesisSection(
          id: 'medications',
          title: 'Medikamente',
          questions: [
            AnamnesisQuestion(
              id: 'current_meds',
              text: 'Welche Medikamente nehmen Sie regelmäßig?',
              type: QuestionType.textarea,
              placeholder: 'Name, Dosierung (z.B. Metformin 500mg, 2x täglich)',
            ),
          ],
        ),
      ],
    );
  }
}

// Hilfs-Widgets

class _SelectableButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _SelectableButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected 
          ? Theme.of(context).colorScheme.primaryContainer
          : AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  
  const _DatePickerField({
    this.value,
    required this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          onChanged(date);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          value != null 
              ? '${value!.day}.${value!.month}.${value!.year}'
              : l10n.selectDate,
        ),
      ),
    );
  }
}

class _BodyMapSelector extends StatelessWidget {
  final List<String> selectedParts;
  final ValueChanged<List<String>> onChanged;
  
  const _BodyMapSelector({
    required this.selectedParts,
    required this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    final bodyParts = [
      'Kopf', 'Hals', 'Schulter links', 'Schulter rechts',
      'Brust', 'Bauch', 'Rücken oben', 'Rücken unten',
      'Arm links', 'Arm rechts', 'Hand links', 'Hand rechts',
      'Bein links', 'Bein rechts', 'Fuß links', 'Fuß rechts',
    ];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: bodyParts.map((part) {
        final isSelected = selectedParts.contains(part);
        return FilterChip(
          label: Text(part),
          selected: isSelected,
          onSelected: (selected) {
            final newList = List<String>.from(selectedParts);
            if (selected) {
              newList.add(part);
            } else {
              newList.remove(part);
            }
            onChanged(newList);
          },
        );
      }).toList(),
    );
  }
}

// Datenmodelle

class AnamnesisTemplate {
  final String id;
  final String name;
  final String description;
  final int estimatedMinutes;
  final List<AnamnesisSection> sections;
  
  const AnamnesisTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.estimatedMinutes,
    required this.sections,
  });
}

class AnamnesisSection {
  final String id;
  final String title;
  final String? description;
  final List<AnamnesisQuestion> questions;
  
  const AnamnesisSection({
    required this.id,
    required this.title,
    this.description,
    required this.questions,
  });
}

class AnamnesisQuestion {
  final String id;
  final String text;
  final String? description;
  final QuestionType type;
  final bool required;
  final List<String>? options;
  final int? minValue;
  final int? maxValue;
  final String? placeholder;
  final QuestionCondition? condition;
  
  const AnamnesisQuestion({
    required this.id,
    required this.text,
    this.description,
    required this.type,
    this.required = false,
    this.options,
    this.minValue,
    this.maxValue,
    this.placeholder,
    this.condition,
  });
}

enum QuestionType {
  text,
  textarea,
  number,
  date,
  singleChoice,
  multipleChoice,
  scale,
  yesNo,
  bodyMap,
}

class QuestionCondition {
  final String questionId;
  final String operator;
  final dynamic value;
  
  const QuestionCondition({
    required this.questionId,
    required this.operator,
    required this.value,
  });
}
