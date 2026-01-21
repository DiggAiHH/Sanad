import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'wayfinding_models.dart';

/// Service for LED wayfinding and visualization.
/// 
/// Handles:
/// - Zone management
/// - Route triggering
/// - Direct LED control
/// - Wait time visualization
class WayfindingService {
  /// Creates wayfinding service.
  WayfindingService(this._dio, {this.baseUrl = ''});
  
  final Dio _dio;
  final String baseUrl;
  
  // ========== Zones ==========
  
  /// Get all zones.
  Future<List<Zone>> getZones() async {
    final response = await _dio.get('$baseUrl/api/v1/led/zones');
    final items = response.data['items'] as List;
    return items.map((e) => Zone.fromJson(e)).toList();
  }
  
  /// Create a new zone.
  Future<Zone> createZone({
    required String zoneName,
    required String zoneCode,
    required String zoneType,
    String defaultColor = '#0066CC',
  }) async {
    final response = await _dio.post(
      '$baseUrl/api/v1/led/zones',
      data: {
        'zone_name': zoneName,
        'zone_code': zoneCode,
        'zone_type': zoneType,
        'default_color': defaultColor,
      },
    );
    return Zone.fromJson(response.data);
  }
  
  // ========== Routes ==========
  
  /// Get all wayfinding routes.
  Future<List<WayfindingRoute>> getRoutes() async {
    final response = await _dio.get('$baseUrl/api/v1/led/routes');
    final items = response.data['items'] as List;
    return items.map((e) => WayfindingRoute.fromJson(e)).toList();
  }
  
  /// Trigger a wayfinding route.
  /// 
  /// Lights up the LED path from entrance to destination.
  Future<TriggerRouteResponse> triggerRoute(TriggerRouteRequest request) async {
    final response = await _dio.post(
      '$baseUrl/api/v1/led/routes/trigger',
      data: {
        'route_id': request.routeId,
        'duration_seconds': request.durationSeconds,
        if (request.patientTicketId != null)
          'patient_ticket_id': request.patientTicketId,
      },
    );
    return TriggerRouteResponse.fromJson(response.data);
  }
  
  /// Find route by destination zone.
  Future<WayfindingRoute?> findRouteToZone(String toZoneId) async {
    final routes = await getRoutes();
    try {
      return routes.firstWhere((r) => r.toZoneId == toZoneId);
    } catch (_) {
      return null;
    }
  }
  
  // ========== Direct LED Control ==========
  
  /// Send direct command to LED controller.
  Future<bool> sendCommand(LEDCommand command) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/v1/led/command',
        data: {
          'controller_id': command.controllerId,
          'segment_id': command.segmentId,
          'color': command.color,
          'brightness': command.brightness,
          'pattern': command.pattern.name,
          if (command.durationSeconds != null)
            'duration_seconds': command.durationSeconds,
        },
      );
      return response.data['success'] as bool;
    } catch (e) {
      debugPrint('LED command failed: $e');
      return false;
    }
  }
  
  /// Turn off a segment.
  Future<bool> turnOffSegment({
    required String controllerId,
    required int segmentId,
  }) async {
    return sendCommand(LEDCommand(
      controllerId: controllerId,
      segmentId: segmentId,
      color: '#000000',
      brightness: 0,
    ));
  }
  
  // ========== Wait Time Visualization ==========
  
  /// Get current wait time overview.
  Future<WaitTimeOverview> getWaitTimeOverview() async {
    final response = await _dio.get('$baseUrl/api/v1/led/wait-times');
    return WaitTimeOverview.fromJson(response.data);
  }
  
  /// Get color for wait time.
  /// 
  /// Returns hex color based on wait time:
  /// - Green: < 10 min
  /// - Yellow: 10-20 min
  /// - Red: > 20 min
  static String getWaitTimeColor(int waitMinutes) {
    if (waitMinutes < 10) {
      return '#00FF00'; // Green
    } else if (waitMinutes < 20) {
      // Gradient from green to yellow to red
      final ratio = (waitMinutes - 10) / 10;
      final r = (255 * ratio).round();
      final g = 255;
      return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}00';
    } else {
      // Red with intensity based on severity
      final intensity = (waitMinutes - 20).clamp(0, 40) / 40;
      final g = (255 * (1 - intensity)).round();
      return '#FF${g.toRadixString(16).padLeft(2, '0')}00';
    }
  }
  
  /// Get wait time status.
  static WaitTimeStatus getWaitTimeStatus(int waitMinutes) {
    if (waitMinutes < 10) return WaitTimeStatus.ok;
    if (waitMinutes < 20) return WaitTimeStatus.warning;
    return WaitTimeStatus.critical;
  }
}
