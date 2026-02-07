/// Sanad IoT Package
/// 
/// Provides NFC check-in, LED wayfinding control, and WebSocket real-time events
/// for the Zero-Touch Reception system.
/// 
/// Features:
/// - NFC card reading and check-in
/// - WebSocket connection for real-time updates
/// - LED wayfinding visualization
/// - Device management
library sanad_iot;

// NFC
export 'src/nfc/nfc_service.dart';
export 'src/nfc/nfc_models.dart';

// WebSocket
export 'src/websocket/websocket_service.dart';
export 'src/websocket/event_models.dart';

// LED / Wayfinding
export 'src/wayfinding/wayfinding_service.dart';
export 'src/wayfinding/wayfinding_models.dart';

// Providers
export 'src/providers/iot_providers.dart';
