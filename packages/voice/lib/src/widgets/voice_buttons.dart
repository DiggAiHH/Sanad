import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sanad_ui/sanad_ui.dart';

import '../tts/tts_service.dart';
import '../stt/stt_service.dart';

/// Hold-to-talk voice button with visual feedback
class VoiceButton extends StatefulWidget {
  final SttService sttService;
  final void Function(String text) onResult;
  final void Function(SttState state)? onStateChange;
  final VoidCallback? onError;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final String? hintText;

  const VoiceButton({
    super.key,
    required this.sttService,
    required this.onResult,
    this.onStateChange,
    this.onError,
    this.size = 72,
    this.activeColor,
    this.inactiveColor,
    this.hintText,
  });

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    widget.sttService.stateStream.listen((state) {
      widget.onStateChange?.call(state);
      if (state == SttState.listening) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    });

    widget.sttService.resultStream.listen((result) {
      if (result.isFinal && result.text.isNotEmpty) {
        widget.onResult(result.text);
      }
    });

    widget.sttService.errorStream.listen((_) {
      widget.onError?.call();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    HapticFeedback.mediumImpact();
    widget.sttService.startListening();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.sttService.stopListening();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    widget.sttService.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? AppColors.primary;
    final inactiveColor = widget.inactiveColor ?? AppColors.textSecondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder<SttState>(
          stream: widget.sttService.stateStream,
          initialData: widget.sttService.state,
          builder: (context, snapshot) {
            final state = snapshot.data ?? SttState.idle;
            final isActive = state == SttState.listening;
            final isProcessing = state == SttState.processing;
            final hasError = state == SttState.error || 
                             state == SttState.noPermission ||
                             state == SttState.notAvailable;

            return GestureDetector(
              onTapDown: hasError ? null : _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isActive ? _pulseAnimation.value : (_isPressed ? 0.95 : 1.0),
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasError
                            ? AppColors.error.withOpacity(0.1)
                            : isActive
                                ? activeColor.withOpacity(0.15)
                                : inactiveColor.withOpacity(0.1),
                        border: Border.all(
                          color: hasError
                              ? AppColors.error
                              : isActive
                                  ? activeColor
                                  : inactiveColor.withOpacity(0.5),
                          width: isActive ? 3 : 2,
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: activeColor.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: isProcessing
                            ? SizedBox(
                                width: widget.size * 0.4,
                                height: widget.size * 0.4,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: activeColor,
                                ),
                              )
                            : Icon(
                                hasError
                                    ? Icons.mic_off
                                    : isActive
                                        ? Icons.mic
                                        : Icons.mic_none,
                                size: widget.size * 0.4,
                                color: hasError
                                    ? AppColors.error
                                    : isActive
                                        ? activeColor
                                        : inactiveColor,
                              ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        if (widget.hintText != null) ...[
          const SizedBox(height: 8),
          StreamBuilder<SttState>(
            stream: widget.sttService.stateStream,
            builder: (context, snapshot) {
              final state = snapshot.data ?? SttState.idle;
              String text;
              switch (state) {
                case SttState.listening:
                  text = 'Höre zu...';
                case SttState.processing:
                  text = 'Verarbeite...';
                case SttState.error:
                  text = 'Fehler aufgetreten';
                case SttState.noPermission:
                  text = 'Berechtigung erforderlich';
                case SttState.notAvailable:
                  text = 'Nicht verfügbar';
                default:
                  text = widget.hintText!;
              }
              return Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  color: state == SttState.error
                      ? AppColors.error
                      : AppColors.textSecondary,
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

/// Button to trigger text-to-speech
class SpeakButton extends StatefulWidget {
  final TtsService ttsService;
  final String text;
  final double size;
  final Color? color;

  const SpeakButton({
    super.key,
    required this.ttsService,
    required this.text,
    this.size = 48,
    this.color,
  });

  @override
  State<SpeakButton> createState() => _SpeakButtonState();
}

class _SpeakButtonState extends State<SpeakButton> {
  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;

    return StreamBuilder<TtsState>(
      stream: widget.ttsService.stateStream,
      initialData: widget.ttsService.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? TtsState.idle;
        final isSpeaking = state == TtsState.playing;

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            if (isSpeaking) {
              widget.ttsService.stop();
            } else {
              widget.ttsService.speak(widget.text);
            }
          },
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSpeaking ? color : color.withOpacity(0.1),
            ),
            child: Center(
              child: Icon(
                isSpeaking ? Icons.stop : Icons.volume_up,
                size: widget.size * 0.5,
                color: isSpeaking ? Colors.white : color,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Inline speak button for text
class InlineSpeakButton extends StatelessWidget {
  final TtsService ttsService;
  final String text;

  const InlineSpeakButton({
    super.key,
    required this.ttsService,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: StreamBuilder<TtsState>(
        stream: ttsService.stateStream,
        builder: (context, snapshot) {
          final isSpeaking = snapshot.data == TtsState.playing;
          return Icon(
            isSpeaking ? Icons.stop : Icons.volume_up_outlined,
            size: 20,
            color: isSpeaking ? AppColors.primary : AppColors.textSecondary,
          );
        },
      ),
      onPressed: () {
        HapticFeedback.selectionClick();
        if (ttsService.state == TtsState.playing) {
          ttsService.stop();
        } else {
          ttsService.speak(text);
        }
      },
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }
}
