import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';
import '../models/workflows.dart';

/// Service for workflow automation APIs.
class WorkflowsService {
  final Dio _dio;

  /// Creates the service with a shared Dio instance.
  WorkflowsService(this._dio);

  /// Lists workflows with optional filters.
  Future<List<Workflow>> listWorkflows({
    WorkflowStatus? status,
    TriggerType? trigger,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.workflows,
      queryParameters: {
        if (status != null) 'status': workflowStatusToJson(status),
        if (trigger != null) 'trigger': triggerTypeToJson(trigger),
      },
    );
    final items = response.data as List<dynamic>? ?? [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(Workflow.fromJson)
        .toList();
  }

  /// Loads a single workflow.
  Future<Workflow> getWorkflow(String workflowId) async {
    final response = await _dio.get(ApiEndpoints.workflow(workflowId));
    return Workflow.fromJson(response.data as Map<String, dynamic>);
  }

  /// Updates workflow status.
  Future<WorkflowStatusUpdate> updateWorkflowStatus({
    required String workflowId,
    required WorkflowStatus status,
  }) async {
    final response = await _dio.put(
      ApiEndpoints.workflowStatus(workflowId),
      queryParameters: {'status': workflowStatusToJson(status)},
    );
    return WorkflowStatusUpdate.fromJson(response.data as Map<String, dynamic>);
  }

  /// Triggers a workflow manually.
  Future<WorkflowTriggerResponse> triggerWorkflow({
    required String workflowId,
    required Map<String, dynamic> triggerData,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.workflowTrigger(workflowId),
      data: triggerData,
    );
    return WorkflowTriggerResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Lists practice tasks.
  Future<List<PracticeTask>> listTasks({
    String? assignedTo,
    bool? completed,
    TaskPriority? priority,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.workflowTasks,
      queryParameters: {
        if (assignedTo != null) 'assigned_to': assignedTo,
        if (completed != null) 'completed': completed,
        if (priority != null) 'priority': taskPriorityToJson(priority),
      },
    );
    final items = response.data as List<dynamic>? ?? [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(PracticeTask.fromJson)
        .toList();
  }

  /// Creates a new task.
  Future<PracticeTask> createTask(TaskCreateRequest request) async {
    final response = await _dio.post(
      ApiEndpoints.workflowTasks,
      queryParameters: request.toJson(),
    );
    return PracticeTask.fromJson(response.data as Map<String, dynamic>);
  }

  /// Completes a task.
  Future<TaskCompleteResponse> completeTask(String taskId) async {
    final response = await _dio.put(ApiEndpoints.workflowCompleteTask(taskId));
    return TaskCompleteResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Runs due workflows (internal).
  Future<WorkflowRunDueResponse> runDueWorkflows() async {
    final response = await _dio.post(ApiEndpoints.workflowRunDue);
    return WorkflowRunDueResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
