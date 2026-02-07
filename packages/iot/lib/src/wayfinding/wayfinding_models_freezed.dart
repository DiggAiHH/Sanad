import 'package:freezed_annotation/freezed_annotation.dart';

part 'wayfinding_models_freezed.freezed.dart';
part 'wayfinding_models_freezed.g.dart';

/// LED animation patterns for wayfinding.
@JsonEnum(valueField: 'value')
enum LEDPattern {
  @JsonValue('solid')
  solid('solid'),
  @JsonValue('pulse')
  pulse('pulse'),
  @JsonValue('chase')
  chase('chase'),
  @JsonValue('rainbow')
  rainbow('rainbow'),
  @JsonValue('breathe')
  breathe('breathe'),
  @JsonValue('wipe')
  wipe('wipe');

  const LEDPattern(this.value);
  final String value;
}

/// Zone type enumeration.
@JsonEnum(valueField: 'value')
enum ZoneType {
  @JsonValue('entrance')
  entrance('entrance'),
  @JsonValue('waiting_room')
  waitingRoom('waiting_room'),
  @JsonValue('treatment_room')
  treatmentRoom('treatment_room'),
  @JsonValue('corridor')
  corridor('corridor'),
  @JsonValue('exit')
  exit('exit');

  const ZoneType(this.value);
  final String value;
}

/// Zone information.
@freezed
class Zone with _$Zone {
  const factory Zone({
    required String id,
    @JsonKey(name: 'practice_id') required String practiceId,
    @JsonKey(name: 'zone_name') required String zoneName,
    @JsonKey(name: 'zone_code') required String zoneCode,
    @JsonKey(name: 'zone_type') required String zoneType,
    @JsonKey(name: 'default_color') @Default('#0066CC') String defaultColor,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Zone;

  factory Zone.fromJson(Map<String, dynamic> json) => _$ZoneFromJson(json);
}

/// LED segment configuration.
@freezed
class LEDSegment with _$LEDSegment {
  const factory LEDSegment({
    required String id,
    @JsonKey(name: 'zone_id') required String zoneId,
    @JsonKey(name: 'controller_id') required String controllerId,
    @JsonKey(name: 'segment_id') required int segmentId,
    @JsonKey(name: 'start_led') required int startLed,
    @JsonKey(name: 'end_led') required int endLed,
    @JsonKey(name: 'default_color') @Default('#0066CC') String defaultColor,
    @JsonKey(name: 'default_brightness') @Default(255) int defaultBrightness,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _LEDSegment;

  factory LEDSegment.fromJson(Map<String, dynamic> json) =>
      _$LEDSegmentFromJson(json);
}

/// Wayfinding route definition.
@freezed
class WayfindingRoute with _$WayfindingRoute {
  const factory WayfindingRoute({
    required String id,
    @JsonKey(name: 'practice_id') required String practiceId,
    @JsonKey(name: 'route_name') required String routeName,
    @JsonKey(name: 'from_zone_id') required String fromZoneId,
    @JsonKey(name: 'to_zone_id') required String toZoneId,
    @JsonKey(name: 'color') @Default('#00FF00') String color,
    @JsonKey(name: 'pattern') @Default(LEDPattern.chase) LEDPattern pattern,
    @JsonKey(name: 'duration_seconds') @Default(30) int durationSeconds,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'segment_ids') @Default([]) List<String> segmentIds,
  }) = _WayfindingRoute;

  factory WayfindingRoute.fromJson(Map<String, dynamic> json) =>
      _$WayfindingRouteFromJson(json);
}

/// Route activation request.
@freezed
class ActivateRouteRequest with _$ActivateRouteRequest {
  const factory ActivateRouteRequest({
    @JsonKey(name: 'route_id') required String routeId,
    @JsonKey(name: 'patient_id') String? patientId,
    @JsonKey(name: 'duration_override') int? durationOverride,
  }) = _ActivateRouteRequest;

  factory ActivateRouteRequest.fromJson(Map<String, dynamic> json) =>
      _$ActivateRouteRequestFromJson(json);
}

/// Route activation response.
@freezed
class ActivateRouteResponse with _$ActivateRouteResponse {
  const factory ActivateRouteResponse({
    required bool success,
    required String message,
    @JsonKey(name: 'route_id') String? routeId,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
  }) = _ActivateRouteResponse;

  factory ActivateRouteResponse.fromJson(Map<String, dynamic> json) =>
      _$ActivateRouteResponseFromJson(json);
}

/// LED command for direct control.
@freezed
class LEDCommand with _$LEDCommand {
  const factory LEDCommand({
    @JsonKey(name: 'device_id') required String deviceId,
    @JsonKey(name: 'segment_id') int? segmentId,
    required String color,
    @Default(255) int brightness,
    @Default(LEDPattern.solid) LEDPattern pattern,
    @JsonKey(name: 'duration_ms') int? durationMs,
  }) = _LEDCommand;

  factory LEDCommand.fromJson(Map<String, dynamic> json) =>
      _$LEDCommandFromJson(json);
}

/// Wait time visualization data.
@freezed
class WaitTimeVisualization with _$WaitTimeVisualization {
  const factory WaitTimeVisualization({
    @JsonKey(name: 'zone_id') required String zoneId,
    @JsonKey(name: 'zone_name') required String zoneName,
    @JsonKey(name: 'current_wait_minutes') required int currentWaitMinutes,
    required String status, // 'ok', 'warning', 'critical'
    required String color, // Hex color for LED
    @JsonKey(name: 'patient_count') required int patientCount,
  }) = _WaitTimeVisualization;

  factory WaitTimeVisualization.fromJson(Map<String, dynamic> json) =>
      _$WaitTimeVisualizationFromJson(json);
}

/// Wait time overview response.
@freezed
class WaitTimeOverviewResponse with _$WaitTimeOverviewResponse {
  const factory WaitTimeOverviewResponse({
    required List<WaitTimeVisualization> zones,
    @JsonKey(name: 'total_waiting') required int totalWaiting,
    @JsonKey(name: 'average_wait_minutes') required double averageWaitMinutes,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _WaitTimeOverviewResponse;

  factory WaitTimeOverviewResponse.fromJson(Map<String, dynamic> json) =>
      _$WaitTimeOverviewResponseFromJson(json);
}
