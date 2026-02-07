import 'package:flutter/material.dart';
import 'package:sanad_ui/sanad_ui.dart';

import '../tts/tts_service.dart';
import '../stt/stt_service.dart';
import '../localization/supported_languages.dart';

/// Voice settings tile for settings screen
class VoiceSettingsTile extends StatelessWidget {
  final TtsService ttsService;
  final SttService sttService;
  final bool isEnabled;
  final String currentLanguage;
  final double speechRate;
  final double volume;
  final void Function(bool) onEnabledChanged;
  final void Function(String) onLanguageChanged;
  final void Function(double) onSpeechRateChanged;
  final void Function(double) onVolumeChanged;

  const VoiceSettingsTile({
    super.key,
    required this.ttsService,
    required this.sttService,
    required this.isEnabled,
    required this.currentLanguage,
    required this.speechRate,
    required this.volume,
    required this.onEnabledChanged,
    required this.onLanguageChanged,
    required this.onSpeechRateChanged,
    required this.onVolumeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with toggle
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.mic,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Sprachfunktionen',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Switch.adaptive(
                value: isEnabled,
                onChanged: onEnabledChanged,
                activeColor: AppColors.primary,
              ),
            ],
          ),

          if (isEnabled) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),

            // Language selector
            const Text(
              'Sprache',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                value: currentLanguage,
                isExpanded: true,
                underline: const SizedBox(),
                items: SupportedLanguages.all.map((lang) {
                  return DropdownMenuItem(
                    value: lang.code,
                    child: Row(
                      children: [
                        Text(
                          lang.flag,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(lang.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    onLanguageChanged(value);
                  }
                },
              ),
            ),

            const SizedBox(height: 20),

            // Speech rate slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Geschwindigkeit',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${speechRate.toStringAsFixed(1)}x',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            Slider(
              value: speechRate,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              activeColor: AppColors.primary,
              onChanged: onSpeechRateChanged,
            ),

            // Volume slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lautstärke',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${(volume * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            Slider(
              value: volume,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              activeColor: AppColors.primary,
              onChanged: onVolumeChanged,
            ),

            const SizedBox(height: 8),

            // Test button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  final strings = SupportedLanguages.getStrings(currentLanguage);
                  ttsService.speak(strings.voiceEnabled);
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Test-Ansage abspielen'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Waveform visualization for active listening
class WaveformIndicator extends StatefulWidget {
  final bool isActive;
  final Color? color;
  final double height;

  const WaveformIndicator({
    super.key,
    required this.isActive,
    this.color,
    this.height = 40,
  });

  @override
  State<WaveformIndicator> createState() => _WaveformIndicatorState();
}

class _WaveformIndicatorState extends State<WaveformIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(5, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300 + (index * 100)),
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    if (widget.isActive) {
      _startAnimations();
    }
  }

  @override
  void didUpdateWidget(WaveformIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  void _startAnimations() {
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 50), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  void _stopAnimations() {
    for (var controller in _controllers) {
      controller.stop();
      controller.animateTo(0.3);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;

    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 4,
                height: widget.height * _animations[index].value,
                decoration: BoxDecoration(
                  color: color.withOpacity(widget.isActive ? 1 : 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
