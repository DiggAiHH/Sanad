import 'package:flutter/material.dart';
import 'package:sanad_core/sanad_core.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Card displaying task information
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final String? assigneeName;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onComplete,
    this.assigneeName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildPriorityIndicator(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      task.title,
                      style: AppTextStyles.h6,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (task.status != TaskStatus.completed && onComplete != null)
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline),
                      onPressed: onComplete,
                      color: AppColors.success,
                    ),
                ],
              ),
              if (task.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  task.description!,
                  style: AppTextStyles.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatusChip(),
                  const Spacer(),
                  if (task.dueAt != null) _buildDueDate(),
                ],
              ),
              if (assigneeName != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(assigneeName!, style: AppTextStyles.bodySmall),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator() {
    Color color;
    switch (task.priority) {
      case TaskPriority.critical:
        color = AppColors.priorityEmergency;
        break;
      case TaskPriority.high:
        color = AppColors.priorityUrgent;
        break;
      case TaskPriority.medium:
        color = AppColors.warning;
        break;
      case TaskPriority.low:
        color = AppColors.priorityNormal;
        break;
    }

    return Container(
      width: 4,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    String text;
    switch (task.status) {
      case TaskStatus.pending:
        color = AppColors.warning;
        text = 'Offen';
        break;
      case TaskStatus.inProgress:
        color = AppColors.info;
        text = 'In Bearbeitung';
        break;
      case TaskStatus.completed:
        color = AppColors.success;
        text = 'Erledigt';
        break;
      case TaskStatus.cancelled:
        color = AppColors.textSecondary;
        text = 'Abgebrochen';
        break;
    }

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

  Widget _buildDueDate() {
    final isOverdue = task.isOverdue;
    final color = isOverdue ? AppColors.error : AppColors.textSecondary;

    return Row(
      children: [
        Icon(Icons.schedule, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          Formatters.formatDateTime(task.dueAt!),
          style: AppTextStyles.bodySmall.copyWith(color: color),
        ),
      ],
    );
  }
}
