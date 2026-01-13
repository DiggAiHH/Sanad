import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';

/// Large animated ticket number display with pulse effect
class TicketNumberDisplay extends StatefulWidget {
  final String ticketNumber;
  final String status;
  final bool showPulse;
  final double size;

  const TicketNumberDisplay({
    super.key,
    required this.ticketNumber,
    this.status = 'waiting',
    this.showPulse = false,
    this.size = 180,
  });

  @override
  State<TicketNumberDisplay> createState() => _TicketNumberDisplayState();
}

class _TicketNumberDisplayState extends State<TicketNumberDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    if (widget.showPulse || widget.status == 'called') {
      _pulseController.repeat(reverse: true);
      HapticFeedback.heavyImpact();
    }
  }

  @override
  void didUpdateWidget(TicketNumberDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status == 'called' && oldWidget.status != 'called') {
      _pulseController.repeat(reverse: true);
      HapticFeedback.heavyImpact();
    } else if (widget.status != 'called') {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (widget.status) {
      case 'called':
        return AppColors.success;
      case 'in_progress':
        return AppColors.info;
      case 'completed':
        return AppColors.textSecondary;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = widget.status == 'called' ? _pulseAnimation.value : 1.0;
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              _statusColor.withOpacity(0.15),
              _statusColor.withOpacity(0.05),
            ],
          ),
          border: Border.all(
            color: _statusColor,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: _statusColor.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.ticketNumber.split('-').first,
                style: TextStyle(
                  fontSize: widget.size * 0.2,
                  fontWeight: FontWeight.w300,
                  color: _statusColor,
                  letterSpacing: 2,
                ),
              ),
              Text(
                widget.ticketNumber.split('-').last,
                style: TextStyle(
                  fontSize: widget.size * 0.35,
                  fontWeight: FontWeight.bold,
                  color: _statusColor,
                  height: 0.9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
