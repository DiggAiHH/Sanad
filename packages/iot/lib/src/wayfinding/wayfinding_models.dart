/// Plain Dart models for LED wayfinding.
///
/// This package intentionally avoids build_runner generated code.

/// LED animation patterns for wayfinding.
enum LEDPattern {
  solid('solid'),
  pulse('pulse'),
  chase('chase'),
  rainbow('rainbow'),
  breathe('breathe'),
  wipe('wipe');

  const LEDPattern(this.wireValue);
  final String wireValue;

  static LEDPattern fromWire(String? value) {
    return LEDPattern.values
        .firstWhere((e) => e.wireValue == value, orElse: () => LEDPattern.solid);
  }
}

/// Zone information.
class Zone {
  const Zone({
    required this.id,
    required this.practiceId,
    required this.zoneName,
    required this.zoneCode,
    required this.zoneType,
    required this.defaultColor,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String practiceId;
  final String zoneName;
  final String zoneCode;
  final String zoneType;
  final String defaultColor;
  final bool isActive;
  final DateTime createdAt;

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id']?.toString() ?? '',
      practiceId: json['practice_id']?.toString() ?? json['practiceId']?.toString() ?? '',
      zoneName: json['zone_name']?.toString() ?? json['zoneName']?.toString() ?? '',
      zoneCode: json['zone_code']?.toString() ?? json['zoneCode']?.toString() ?? '',
      zoneType: json['zone_type']?.toString() ?? json['zoneType']?.toString() ?? '',
      defaultColor: json['default_color']?.toString() ?? json['defaultColor']?.toString() ?? '#0066CC',
      isActive: (json['is_active'] as bool?) ?? (json['isActive'] as bool?) ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// LED segment configuration.
class LEDSegment {
  const LEDSegment({
    required this.id,
    required this.zoneId,
    required this.controllerId,
    required this.segmentId,
    required this.startLed,
    required this.endLed,
    required this.defaultColor,
    required this.defaultBrightness,
    required this.isActive,
  });

  final String id;
  final String zoneId;
  final String controllerId;
  final int segmentId;
  final int startLed;
  final int endLed;
  final String defaultColor;
  final int defaultBrightness;
  final bool isActive;

  factory LEDSegment.fromJson(Map<String, dynamic> json) {
    return LEDSegment(
      id: json['id']?.toString() ?? '',
      zoneId: json['zone_id']?.toString() ?? json['zoneId']?.toString() ?? '',
      controllerId: json['controller_id']?.toString() ?? json['controllerId']?.toString() ?? '',
      segmentId: (json['segment_id'] as num?)?.toInt() ?? (json['segmentId'] as num?)?.toInt() ?? 0,
      startLed: (json['start_led'] as num?)?.toInt() ?? (json['startLed'] as num?)?.toInt() ?? 0,
      endLed: (json['end_led'] as num?)?.toInt() ?? (json['endLed'] as num?)?.toInt() ?? 0,
      defaultColor: json['default_color']?.toString() ?? json['defaultColor']?.toString() ?? '#0066CC',
      defaultBrightness: (json['default_brightness'] as num?)?.toInt() ??
          (json['defaultBrightness'] as num?)?.toInt() ??
          255,
      isActive: (json['is_active'] as bool?) ?? (json['isActive'] as bool?) ?? true,
    );
  }
}

/// Wayfinding route definition.
class WayfindingRoute {
  const WayfindingRoute({
    required this.id,
    required this.practiceId,
    required this.routeName,
    required this.fromZoneId,
    required this.toZoneId,
    required this.ledPattern,
    required this.routeColor,
    required this.animationSpeed,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String practiceId;
  final String routeName;
  final String fromZoneId;
  final String toZoneId;
  final LEDPattern ledPattern;
  final String routeColor;
  final int animationSpeed;
  final bool isActive;
  final DateTime createdAt;

  factory WayfindingRoute.fromJson(Map<String, dynamic> json) {
    return WayfindingRoute(
      id: json['id']?.toString() ?? '',
      practiceId: json['practice_id']?.toString() ?? json['practiceId']?.toString() ?? '',
      routeName: json['route_name']?.toString() ?? json['routeName']?.toString() ?? '',
      fromZoneId: json['from_zone_id']?.toString() ?? json['fromZoneId']?.toString() ?? '',
      toZoneId: json['to_zone_id']?.toString() ?? json['toZoneId']?.toString() ?? '',
      ledPattern: LEDPattern.fromWire(
        json['led_pattern']?.toString() ?? json['ledPattern']?.toString(),
      ),
      routeColor: json['route_color']?.toString() ?? json['routeColor']?.toString() ?? '#0066CC',
      animationSpeed: (json['animation_speed'] as num?)?.toInt() ??
          (json['animationSpeed'] as num?)?.toInt() ??
          100,
      isActive: (json['is_active'] as bool?) ?? (json['isActive'] as bool?) ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// Request to trigger a wayfinding route.
class TriggerRouteRequest {
  const TriggerRouteRequest({
    required this.routeId,
    this.durationSeconds = 30,
    this.patientTicketId,
  });

  final String routeId;
  final int durationSeconds;
  final String? patientTicketId;

  Map<String, dynamic> toJson() => {
        'route_id': routeId,
        'duration_seconds': durationSeconds,
        if (patientTicketId != null) 'patient_ticket_id': patientTicketId,
      };
}

/// Response after triggering a route.
class TriggerRouteResponse {
  const TriggerRouteResponse({
    required this.success,
    required this.message,
    required this.routeId,
    required this.expiresAt,
  });

  final bool success;
  final String message;
  final String routeId;
  final DateTime expiresAt;

  factory TriggerRouteResponse.fromJson(Map<String, dynamic> json) {
    return TriggerRouteResponse(
      success: (json['success'] as bool?) ?? false,
      message: json['message']?.toString() ?? '',
      routeId: json['route_id']?.toString() ?? json['routeId']?.toString() ?? '',
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }
}

/// Direct LED command.
class LEDCommand {
  const LEDCommand({
    required this.controllerId,
    required this.segmentId,
    required this.color,
    this.brightness = 255,
    this.pattern = LEDPattern.solid,
    this.durationSeconds,
  });

  final String controllerId;
  final int segmentId;
  final String color;
  final int brightness;
  final LEDPattern pattern;
  final int? durationSeconds;
}

/// Wait time status for visualization.
enum WaitTimeStatus {
  ok('ok'),
  warning('warning'),
  critical('critical');

  const WaitTimeStatus(this.wireValue);
  final String wireValue;

  static WaitTimeStatus fromWire(String? value) {
    return WaitTimeStatus.values
        .firstWhere((e) => e.wireValue == value, orElse: () => WaitTimeStatus.ok);
  }
}

/// Wait time visualization data.
class WaitTimeVisualization {
  const WaitTimeVisualization({
    required this.zoneId,
    required this.zoneName,
    required this.currentWaitMinutes,
    required this.status,
    required this.color,
    required this.patientCount,
  });

  final String zoneId;
  final String zoneName;
  final int currentWaitMinutes;
  final WaitTimeStatus status;
  final String color;
  final int patientCount;

  factory WaitTimeVisualization.fromJson(Map<String, dynamic> json) {
    return WaitTimeVisualization(
      zoneId: json['zone_id']?.toString() ?? json['zoneId']?.toString() ?? '',
      zoneName: json['zone_name']?.toString() ?? json['zoneName']?.toString() ?? '',
      currentWaitMinutes: (json['current_wait_minutes'] as num?)?.toInt() ??
          (json['currentWaitMinutes'] as num?)?.toInt() ??
          0,
      status: WaitTimeStatus.fromWire(json['status']?.toString()),
      color: json['color']?.toString() ?? '#00FF00',
      patientCount: (json['patient_count'] as num?)?.toInt() ??
          (json['patientCount'] as num?)?.toInt() ??
          0,
    );
  }
}

/// Wait time overview response.
class WaitTimeOverview {
  const WaitTimeOverview({
    required this.zones,
    required this.totalWaiting,
    required this.averageWaitMinutes,
    required this.updatedAt,
  });

  final List<WaitTimeVisualization> zones;
  final int totalWaiting;
  final double averageWaitMinutes;
  final DateTime updatedAt;

  factory WaitTimeOverview.fromJson(Map<String, dynamic> json) {
    final zonesRaw = (json['zones'] as List?) ?? const [];
    return WaitTimeOverview(
      zones: zonesRaw
          .whereType<Map>()
          .map((e) => WaitTimeVisualization.fromJson(e.cast<String, dynamic>()))
          .toList(),
      totalWaiting: (json['total_waiting'] as num?)?.toInt() ??
          (json['totalWaiting'] as num?)?.toInt() ??
          0,
      averageWaitMinutes: (json['average_wait_minutes'] as num?)?.toDouble() ??
          (json['averageWaitMinutes'] as num?)?.toDouble() ??
          0.0,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
