import 'package:flutter/material.dart';
import 'package:sanad_core/sanad_core.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Card displaying ticket information
class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback? onTap;
  final VoidCallback? onCallPressed;
  final bool showActions;

  const TicketCard({
    super.key,
    required this.ticket,
    this.onTap,
    this.onCallPressed,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ticket number
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getStatusColor(), width: 2),
                ),
                child: Center(
                  child: Text(
                    ticket.displayNumber,
                    style: AppTextStyles.h4.copyWith(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildStatusBadge(),
                        if (ticket.priority != TicketPriority.normal) ...[
                          const SizedBox(width: 8),
                          _buildPriorityBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (ticket.visitReason != null)
                      Text(
                        ticket.visitReason!,
                        style: AppTextStyles.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      _getWaitTimeText(),
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              // Actions
              if (showActions && ticket.status == TicketStatus.waiting)
                IconButton(
                  icon: const Icon(Icons.campaign, color: AppColors.primary),
                  onPressed: onCallPressed,
                  tooltip: 'Aufrufen',
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (ticket.status) {
      case TicketStatus.waiting:
        return AppColors.waiting;
      case TicketStatus.called:
        return AppColors.called;
      case TicketStatus.inProgress:
        return AppColors.inProgress;
      case TicketStatus.completed:
        return AppColors.completed;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _getStatusText(),
        style: AppTextStyles.labelSmall.copyWith(color: _getStatusColor()),
      ),
    );
  }

  String _getStatusText() {
    switch (ticket.status) {
      case TicketStatus.waiting:
        return 'Wartend';
      case TicketStatus.called:
        return 'Aufgerufen';
      case TicketStatus.inProgress:
        return 'In Behandlung';
      case TicketStatus.completed:
        return 'Abgeschlossen';
      case TicketStatus.cancelled:
        return 'Abgebrochen';
      case TicketStatus.noShow:
        return 'Nicht erschienen';
    }
  }

  Widget _buildPriorityBadge() {
    final color = ticket.priority == TicketPriority.emergency
        ? AppColors.priorityEmergency
        : AppColors.priorityUrgent;
    final text =
        ticket.priority == TicketPriority.emergency ? 'Notfall' : 'Dringend';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }

  String _getWaitTimeText() {
    if (ticket.estimatedWaitMinutes != null) {
      return 'Wartezeit: ca. ${ticket.estimatedWaitMinutes} Min.';
    }
    final waitTime = DateTime.now().difference(ticket.issuedAt).inMinutes;
    return 'Wartet seit $waitTime Min.';
  }
}
