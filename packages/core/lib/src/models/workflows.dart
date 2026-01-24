/// Models for workflow automation.

enum TriggerType {
  appointmentBooked,
  appointmentReminder,
  appointmentMissed,
  labResultReady,
  prescriptionDue,
  vaccinationDue,
  checkupReminder,
  documentReady,
  birthday,
  manual,
}

TriggerType triggerTypeFromJson(String value) {
  switch (value) {
    case 'appointment_booked':
      return TriggerType.appointmentBooked;
    case 'appointment_reminder':
      return TriggerType.appointmentReminder;
    case 'appointment_missed':
      return TriggerType.appointmentMissed;
    case 'lab_result_ready':
      return TriggerType.labResultReady;
    case 'prescription_due':
      return TriggerType.prescriptionDue;
    case 'vaccination_due':
      return TriggerType.vaccinationDue;
    case 'checkup_reminder':
      return TriggerType.checkupReminder;
    case 'document_ready':
      return TriggerType.documentReady;
    case 'birthday':
      return TriggerType.birthday;
    case 'manual':
      return TriggerType.manual;
    default:
      throw ArgumentError('Unknown TriggerType: $value');
  }
}

String triggerTypeToJson(TriggerType type) {
  switch (type) {
    case TriggerType.appointmentBooked:
      return 'appointment_booked';
    case TriggerType.appointmentReminder:
      return 'appointment_reminder';
    case TriggerType.appointmentMissed:
      return 'appointment_missed';
    case TriggerType.labResultReady:
      return 'lab_result_ready';
    case TriggerType.prescriptionDue:
      return 'prescription_due';
    case TriggerType.vaccinationDue:
      return 'vaccination_due';
    case TriggerType.checkupReminder:
      return 'checkup_reminder';
    case TriggerType.documentReady:
      return 'document_ready';
    case TriggerType.birthday:
      return 'birthday';
    case TriggerType.manual:
      return 'manual';
  }
}

enum ActionType {
  sendEmail,
  sendSms,
  sendPush,
  createTask,
  updateRecord,
  generateDocument,
  webhook,
}

ActionType actionTypeFromJson(String value) {
  switch (value) {
    case 'send_email':
      return ActionType.sendEmail;
    case 'send_sms':
      return ActionType.sendSms;
    case 'send_push':
      return ActionType.sendPush;
    case 'create_task':
      return ActionType.createTask;
    case 'update_record':
      return ActionType.updateRecord;
    case 'generate_document':
      return ActionType.generateDocument;
    case 'webhook':
      return ActionType.webhook;
    default:
      throw ArgumentError('Unknown ActionType: $value');
  }
}

enum WorkflowStatus {
  active,
  paused,
  disabled,
}

WorkflowStatus workflowStatusFromJson(String value) {
  switch (value) {
    case 'active':
      return WorkflowStatus.active;
    case 'paused':
      return WorkflowStatus.paused;
    case 'disabled':
      return WorkflowStatus.disabled;
    default:
      throw ArgumentError('Unknown WorkflowStatus: $value');
  }
}

String workflowStatusToJson(WorkflowStatus status) {
  switch (status) {
    case WorkflowStatus.active:
      return 'active';
    case WorkflowStatus.paused:
      return 'paused';
    case WorkflowStatus.disabled:
      return 'disabled';
  }
}

class WorkflowAction {
  final String id;
  final ActionType type;
  final Map<String, dynamic> config;
  final int delayMinutes;
  final String? condition;

  const WorkflowAction({
    required this.id,
    required this.type,
    required this.config,
    required this.delayMinutes,
    this.condition,
  });

  factory WorkflowAction.fromJson(Map<String, dynamic> json) {
    return WorkflowAction(
      id: json['id'] as String,
      type: actionTypeFromJson(json['type'] as String),
      config: Map<String, dynamic>.from(json['config'] as Map),
      delayMinutes: json['delay_minutes'] as int? ?? 0,
      condition: json['condition'] as String?,
    );
  }
}

class Workflow {
  final String id;
  final String name;
  final String description;
  final TriggerType trigger;
  final Map<String, dynamic> triggerConfig;
  final List<WorkflowAction> actions;
  final WorkflowStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int runCount;
  final DateTime? lastRun;

  const Workflow({
    required this.id,
    required this.name,
    required this.description,
    required this.trigger,
    required this.triggerConfig,
    required this.actions,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.runCount,
    this.lastRun,
  });

  factory Workflow.fromJson(Map<String, dynamic> json) {
    final actions = (json['actions'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(WorkflowAction.fromJson)
        .toList();

    return Workflow(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      trigger: triggerTypeFromJson(json['trigger'] as String),
      triggerConfig: Map<String, dynamic>.from(
        (json['trigger_config'] as Map?) ?? {},
      ),
      actions: actions,
      status: workflowStatusFromJson(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      runCount: json['run_count'] as int? ?? 0,
      lastRun: json['last_run'] == null
          ? null
          : DateTime.parse(json['last_run'] as String),
    );
  }
}

class WorkflowTriggerResponse {
  final String runId;
  final String status;

  const WorkflowTriggerResponse({
    required this.runId,
    required this.status,
  });

  factory WorkflowTriggerResponse.fromJson(Map<String, dynamic> json) {
    return WorkflowTriggerResponse(
      runId: json['run_id'] as String,
      status: json['status'] as String,
    );
  }
}

class WorkflowStatusUpdate {
  final String status;
  final String newStatus;

  const WorkflowStatusUpdate({
    required this.status,
    required this.newStatus,
  });

  factory WorkflowStatusUpdate.fromJson(Map<String, dynamic> json) {
    return WorkflowStatusUpdate(
      status: json['status'] as String,
      newStatus: json['new_status'].toString(),
    );
  }
}

enum WorkflowTaskPriority {
  low,
  medium,
  high,
  urgent,
}

WorkflowTaskPriority workflowTaskPriorityFromJson(String value) {
  switch (value) {
    case 'low':
      return WorkflowTaskPriority.low;
    case 'medium':
      return WorkflowTaskPriority.medium;
    case 'high':
      return WorkflowTaskPriority.high;
    case 'urgent':
      return WorkflowTaskPriority.urgent;
    default:
      throw ArgumentError('Unknown WorkflowTaskPriority: $value');
  }
}

String workflowTaskPriorityToJson(WorkflowTaskPriority priority) {
  switch (priority) {
    case WorkflowTaskPriority.low:
      return 'low';
    case WorkflowTaskPriority.medium:
      return 'medium';
    case WorkflowTaskPriority.high:
      return 'high';
    case WorkflowTaskPriority.urgent:
      return 'urgent';
  }
}

class PracticeTask {
  final String id;
  final String title;
  final String? description;
  final String? patientId;
  final String? assignedTo;
  final WorkflowTaskPriority priority;
  final DateTime? dueDate;
  final bool completed;
  final DateTime? completedAt;
  final String createdBy;
  final DateTime createdAt;
  final String? workflowRunId;

  const PracticeTask({
    required this.id,
    required this.title,
    required this.priority,
    required this.completed,
    required this.createdBy,
    required this.createdAt,
    this.description,
    this.patientId,
    this.assignedTo,
    this.dueDate,
    this.completedAt,
    this.workflowRunId,
  });

  factory PracticeTask.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    return PracticeTask(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      patientId: json['patient_id'] as String?,
      assignedTo: json['assigned_to'] as String?,
      priority: workflowTaskPriorityFromJson(json['priority'] as String),
      dueDate: parseDate(json['due_date']),
      completed: json['completed'] as bool? ?? false,
      completedAt: parseDate(json['completed_at']),
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      workflowRunId: json['workflow_run_id'] as String?,
    );
  }
}

class TaskCreateRequest {
  final String title;
  final String? description;
  final String? patientId;
  final String? assignedTo;
  final WorkflowTaskPriority priority;
  final DateTime? dueDate;

  const TaskCreateRequest({
    required this.title,
    this.description,
    this.patientId,
    this.assignedTo,
    this.priority = WorkflowTaskPriority.medium,
    this.dueDate,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        if (description != null) 'description': description,
        if (patientId != null) 'patient_id': patientId,
        if (assignedTo != null) 'assigned_to': assignedTo,
        'priority': workflowTaskPriorityToJson(priority),
        if (dueDate != null) 'due_date': dueDate!.toIso8601String(),
      };
}

class TaskCompleteResponse {
  final String status;

  const TaskCompleteResponse({required this.status});

  factory TaskCompleteResponse.fromJson(Map<String, dynamic> json) {
    return TaskCompleteResponse(status: json['status'] as String);
  }
}

class WorkflowRunDueResponse {
  final DateTime checkedAt;
  final int workflowsTriggered;
  final List<dynamic> details;

  const WorkflowRunDueResponse({
    required this.checkedAt,
    required this.workflowsTriggered,
    required this.details,
  });

  factory WorkflowRunDueResponse.fromJson(Map<String, dynamic> json) {
    return WorkflowRunDueResponse(
      checkedAt: DateTime.parse(json['checked_at'] as String),
      workflowsTriggered: json['workflows_triggered'] as int? ?? 0,
      details: json['details'] as List<dynamic>? ?? [],
    );
  }
}
