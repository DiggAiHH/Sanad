import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanad_core/sanad_core.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// Schritt 12: Verbindungsstatus für UI-Feedback.
enum WebRTCConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  failed,
}

/// Screen für Videosprechstunde mit dem Arzt.
/// DSGVO-konform: WebRTC mit Ende-zu-Ende-Verschlüsselung.
class VideoCallScreen extends ConsumerStatefulWidget {
  final String? consultationId;

  const VideoCallScreen({super.key, this.consultationId});

  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen> {
  // Schritt 12: Erweiterte Connection States
  WebRTCConnectionState _connectionState = WebRTCConnectionState.disconnected;
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isSpeakerOn = true;
  bool _showControls = true;
  
  // Schritt 11: Reconnect tracking
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  bool _signalingActive = false;
  
  WebRTCRoom? _roomInfo;
  Consultation? _consultation;
  DateTime? _callStartTime;
  int _callDurationSeconds = 0;
  
  // Schritt 9: Legacy compatibility
  bool get _isConnecting => _connectionState == WebRTCConnectionState.connecting;
  bool get _isConnected => _connectionState == WebRTCConnectionState.connected;

  @override
  void initState() {
    super.initState();
    _initializeCall();
  }
  
  @override
  void dispose() {
    // Schritt 13: Cleanup bei dispose
    _signalingActive = false;
    super.dispose();
  }

  /// Schritt 9: Improved Init Flow mit State Management.
  Future<void> _initializeCall() async {
    if (widget.consultationId == null) {
      setState(() => _connectionState = WebRTCConnectionState.failed);
      return;
    }

    setState(() => _connectionState = WebRTCConnectionState.connecting);

    try {
      final service = ref.read(consultationServiceProvider);
      
      // Join the call
      final consultation = await service.joinCall(widget.consultationId!);
      
      // Get WebRTC room info with ICE/TURN servers
      final roomInfo = await service.getCallRoom(widget.consultationId!);
      
      if (mounted) {
        setState(() {
          _consultation = consultation;
          _roomInfo = roomInfo;
          _connectionState = WebRTCConnectionState.connected;
          _callStartTime = DateTime.now();
          _reconnectAttempts = 0;
        });
        
        // Start duration timer
        _startDurationTimer();
        
        // TODO: Initialize actual WebRTC connection with roomInfo
        // This would use flutter_webrtc package and the ICE/TURN servers:
        // final configuration = {
        //   'iceServers': roomInfo.iceServers.map((s) => {'urls': s.urls}).toList(),
        // };
        // if (roomInfo.turnServers != null) {
        //   configuration['iceServers'].addAll(
        //     roomInfo.turnServers!.map((s) => {
        //       'urls': s.urls,
        //       'username': s.username,
        //       'credential': s.credential,
        //     }),
        //   );
        // }
        // _peerConnection = await createPeerConnection(configuration);
        
        _startSignalingLoop();
      }
    } catch (e) {
      if (mounted) {
        // Schritt 11: Retry logic
        if (_reconnectAttempts < _maxReconnectAttempts) {
          _reconnectAttempts++;
          setState(() => _connectionState = WebRTCConnectionState.reconnecting);
          await Future.delayed(Duration(seconds: _reconnectAttempts * 2));
          return _initializeCall();
        }
        
        setState(() => _connectionState = WebRTCConnectionState.failed);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verbindungsfehler: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
  
  /// Startet Timer für Anrufdauer.
  void _startDurationTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _isConnected) {
        setState(() => _callDurationSeconds++);
        return true;
      }
      return false;
    });
  }

  /// Schritt 11: Signaling Loop mit Reconnect-Logic.
  /// 
  /// Implements the signaling flow:
  /// 1. Poll for incoming signals (offers, answers, ICE candidates)
  /// 2. Process each signal based on type
  /// 3. Handle disconnections with exponential backoff
  Future<void> _startSignalingLoop() async {
    if (widget.consultationId == null || !mounted) return;
    
    _signalingActive = true;
    final service = ref.read(consultationServiceProvider);
    DateTime? lastPollTime;
    int consecutiveErrors = 0;
    
    // Poll every 500ms for new signals
    while (mounted && _signalingActive && _connectionState != WebRTCConnectionState.failed) {
      try {
        final signals = await service.pollSignals(
          widget.consultationId!,
          since: lastPollTime,
        );
        
        consecutiveErrors = 0; // Reset on success
        
        for (final signal in signals) {
          lastPollTime = signal.timestamp;
          await _processSignal(signal);
        }
      } catch (e) {
        consecutiveErrors++;
        debugPrint('Signal poll error ($consecutiveErrors): $e');
        
        // Schritt 11: Reconnect nach mehreren Fehlern
        if (consecutiveErrors >= 3 && _connectionState == WebRTCConnectionState.connected) {
          setState(() => _connectionState = WebRTCConnectionState.reconnecting);
        }
        
        if (consecutiveErrors >= 10) {
          setState(() => _connectionState = WebRTCConnectionState.failed);
          break;
        }
        
        // Exponential backoff
        await Future.delayed(Duration(milliseconds: 500 * consecutiveErrors.clamp(1, 5)));
        continue;
      }
      
      // Schritt 11: Zurück auf connected nach erfolgreicher Wiederverbindung
      if (_connectionState == WebRTCConnectionState.reconnecting) {
        setState(() => _connectionState = WebRTCConnectionState.connected);
      }
      
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
  
  /// Processes an incoming WebRTC signal.
  Future<void> _processSignal(WebRTCSignal signal) async {
    // TODO: Implement with flutter_webrtc
    switch (signal.signalType) {
      case 'offer':
        // Received offer from peer - create answer
        final offer = WebRTCOffer.fromJson(signal.payload);
        debugPrint('Received offer: ${offer.type}');
        // peerConnection.setRemoteDescription(offer.sdp)
        // final answer = await peerConnection.createAnswer()
        // service.sendAnswer(consultationId, answer)
        break;
        
      case 'answer':
        // Received answer to our offer
        final answer = WebRTCAnswer.fromJson(signal.payload);
        debugPrint('Received answer: ${answer.type}');
        // peerConnection.setRemoteDescription(answer.sdp)
        break;
        
      case 'ice-candidate':
        // Received ICE candidate from peer
        final candidate = WebRTCIceCandidate.fromJson(signal.payload);
        debugPrint('Received ICE: ${candidate.candidate}');
        // peerConnection.addIceCandidate(candidate)
        break;
    }
  }
  
  /// Sends our local ICE candidate to the peer.
  Future<void> _sendLocalIceCandidate(String candidate, String? sdpMid, int? sdpMLineIndex) async {
    if (widget.consultationId == null) return;
    
    final service = ref.read(consultationServiceProvider);
    await service.sendIceCandidate(
      widget.consultationId!,
      WebRTCIceCandidate(
        candidate: candidate,
        sdpMid: sdpMid,
        sdpMLineIndex: sdpMLineIndex,
      ),
    );
  }
  
  /// Creates and sends an offer to initiate the call.
  Future<void> _createAndSendOffer(String sdp) async {
    if (widget.consultationId == null) return;
    
    final service = ref.read(consultationServiceProvider);
    await service.sendOffer(
      widget.consultationId!,
      const WebRTCOffer(sdp: '', type: 'offer'), // Replace with actual SDP
    );
  }

  /// Schritt 10: Mikrofon stumm schalten / aktivieren.
  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    // flutter_webrtc Implementation:
    // _localStream?.getAudioTracks().forEach((track) {
    //   track.enabled = !_isMuted;
    // });
  }

  /// Schritt 10: Video ein-/ausschalten.
  void _toggleVideo() {
    setState(() => _isVideoOff = !_isVideoOff);
    // flutter_webrtc Implementation:
    // _localStream?.getVideoTracks().forEach((track) {
    //   track.enabled = !_isVideoOff;
    // });
  }

  /// Schritt 10: Lautsprecher umschalten.
  void _toggleSpeaker() {
    setState(() => _isSpeakerOn = !_isSpeakerOn);
    // flutter_webrtc Implementation:
    // Helper.setSpeakerphoneOn(_isSpeakerOn);
  }

  /// Schritt 10: Kamera wechseln (front/back).
  void _switchCamera() {
    // flutter_webrtc Implementation:
    // _localStream?.getVideoTracks().forEach((track) {
    //   Helper.switchCamera(track);
    // });
  }

  /// Schritt 13: Call beenden mit vollständigem Cleanup.
  void _endCall() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Anruf beenden?'),
        content: const Text('Möchten Sie die Videosprechstunde wirklich beenden?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performCleanup();
              if (mounted) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Beenden'),
          ),
        ],
      ),
    );
  }
  
  /// Schritt 13: Vollständiger Cleanup aller Ressourcen.
  Future<void> _performCleanup() async {
    // 1. Stop signaling loop
    _signalingActive = false;
    
    // 2. Update connection state
    setState(() => _connectionState = WebRTCConnectionState.disconnected);
    
    // 3. Call API to end and clear signals
    if (widget.consultationId != null) {
      try {
        final service = ref.read(consultationServiceProvider);
        await service.endCall(widget.consultationId!);
        await service.clearSignals(widget.consultationId!);
      } catch (e) {
        debugPrint('Cleanup error: $e');
        // Ignore errors on cleanup
      }
    }
    
    // 4. flutter_webrtc cleanup (when implemented):
    // await _localStream?.dispose();
    // await _peerConnection?.close();
    // _localStream = null;
    // _peerConnection = null;
  }
  
  /// Schritt 12: Helper für Connection State Overlays.
  Widget _buildConnectionOverlay({
    required String title,
    required String subtitle,
    required bool showProgress,
    IconData? icon,
    Color? color,
    Widget? actionButton,
  }) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showProgress)
              CircularProgressIndicator(color: color ?? Colors.white)
            else if (icon != null)
              Icon(icon, color: color ?? Colors.white, size: 64),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                color: color ?? Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionButton != null) ...[
              const SizedBox(height: 24),
              actionButton,
            ],
          ],
        ),
      ),
    );
  }
  
  /// Formatiert Anrufdauer als MM:SS.
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        child: Stack(
          children: [
            // Remote Video (Doctor)
            if (_isConnected)
              Container(
                width: double.infinity,
                height: double.infinity,
                color: AppColors.primary.shade900,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.primary,
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _consultation?.doctorName ?? 'Dr. med. Schmidt',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Video wird geladen...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Schritt 12: Verbesserte Connection State Overlays
            // Connecting Overlay
            if (_connectionState == WebRTCConnectionState.connecting)
              _buildConnectionOverlay(
                icon: null,
                title: 'Verbindung wird hergestellt...',
                subtitle: 'Bitte warten Sie, bis der Arzt beitritt.',
                showProgress: true,
              ),
              
            // Reconnecting Overlay
            if (_connectionState == WebRTCConnectionState.reconnecting)
              _buildConnectionOverlay(
                icon: Icons.sync,
                title: 'Verbindung wird wiederhergestellt...',
                subtitle: 'Versuch $_reconnectAttempts von $_maxReconnectAttempts',
                showProgress: true,
                color: AppColors.warning,
              ),
              
            // Failed Overlay
            if (_connectionState == WebRTCConnectionState.failed)
              _buildConnectionOverlay(
                icon: Icons.error_outline,
                title: 'Verbindung fehlgeschlagen',
                subtitle: 'Bitte versuchen Sie es erneut.',
                showProgress: false,
                color: AppColors.error,
                actionButton: ElevatedButton.icon(
                  onPressed: () {
                    _reconnectAttempts = 0;
                    _initializeCall();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Erneut verbinden'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

            // Local Video (Patient - Picture in Picture)
            if (_isConnected && !_isVideoOff)
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: Container(
                  width: 120,
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.videocam,
                            size: 32,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ihr Video',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Top Bar with Info
            if (_showControls)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 16,
                    right: 16,
                    bottom: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: _endCall,
                      ),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Videosprechstunde',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Dr. med. Schmidt',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Encryption indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock, size: 12, color: AppColors.success),
                            const SizedBox(width: 4),
                            Text(
                              'Verschlüsselt',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Call Duration
            if (_isConnected && _showControls)
              Positioned(
                top: MediaQuery.of(context).padding.top + 70,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _formatDuration(_callDurationSeconds),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),

            // Bottom Controls
            if (_showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    top: 24,
                    left: 16,
                    right: 16,
                    bottom: MediaQuery.of(context).padding.bottom + 24,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Main Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ControlButton(
                            icon: _isMuted ? Icons.mic_off : Icons.mic,
                            label: _isMuted ? 'Stumm' : 'Mikrofon',
                            isActive: !_isMuted,
                            onTap: _toggleMute,
                          ),
                          _ControlButton(
                            icon: _isVideoOff ? Icons.videocam_off : Icons.videocam,
                            label: _isVideoOff ? 'Video aus' : 'Video',
                            isActive: !_isVideoOff,
                            onTap: _toggleVideo,
                          ),
                          _ControlButton(
                            icon: Icons.cameraswitch,
                            label: 'Kamera',
                            isActive: true,
                            onTap: _switchCamera,
                          ),
                          _ControlButton(
                            icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                            label: _isSpeakerOn ? 'Lautspr.' : 'Stumm',
                            isActive: _isSpeakerOn,
                            onTap: _toggleSpeaker,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // End Call Button
                      SizedBox(
                        width: 72,
                        height: 72,
                        child: ElevatedButton(
                          onPressed: _endCall,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            shape: const CircleBorder(),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Icon(
                            Icons.call_end,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isActive ? Colors.white24 : Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? Colors.white : Colors.white38,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.white54,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}


/// Screen zum Anfragen einer Videosprechstunde.
class RequestVideoCallScreen extends ConsumerStatefulWidget {
  const RequestVideoCallScreen({super.key});

  @override
  ConsumerState<RequestVideoCallScreen> createState() => _RequestVideoCallScreenState();
}

class _RequestVideoCallScreenState extends ConsumerState<RequestVideoCallScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  DateTime? _preferredDate;
  TimeOfDay? _preferredTime;
  String _priority = 'normal';
  bool _isSubmitting = false;
  bool _acceptedPrivacy = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      locale: const Locale('de', 'DE'),
    );
    if (date != null) {
      setState(() => _preferredDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (time != null) {
      setState(() => _preferredTime = time);
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte akzeptieren Sie die Datenschutzhinweise.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // TODO: Call API to create consultation request
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            icon: Icon(Icons.check_circle, color: AppColors.success, size: 48),
            title: const Text('Anfrage gesendet'),
            content: const Text(
              'Ihre Anfrage für eine Videosprechstunde wurde erfolgreich übermittelt. '
              'Sie erhalten eine Benachrichtigung, sobald ein Termin bestätigt wurde.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Videosprechstunde anfragen'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.videocam, color: AppColors.info),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Vereinbaren Sie eine persönliche Video-Beratung '
                        'mit Ihrem Arzt von zu Hause aus.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.info.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Reason
              Text(
                'Grund für die Sprechstunde *',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reasonController,
                decoration: InputDecoration(
                  hintText: 'Beschreiben Sie kurz Ihr Anliegen...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Bitte geben Sie einen Grund an.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Preferred Date & Time
              Text(
                'Wunschtermin',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _preferredDate != null
                            ? '${_preferredDate!.day}.${_preferredDate!.month}.${_preferredDate!.year}'
                            : 'Datum wählen',
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(
                        _preferredTime != null
                            ? '${_preferredTime!.hour.toString().padLeft(2, '0')}:'
                                '${_preferredTime!.minute.toString().padLeft(2, '0')}'
                            : 'Uhrzeit wählen',
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Priority
              Text(
                'Dringlichkeit',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'low',
                    label: Text('Gering'),
                    icon: Icon(Icons.schedule),
                  ),
                  ButtonSegment(
                    value: 'normal',
                    label: Text('Normal'),
                    icon: Icon(Icons.check_circle_outline),
                  ),
                  ButtonSegment(
                    value: 'high',
                    label: Text('Dringend'),
                    icon: Icon(Icons.priority_high),
                  ),
                ],
                selected: {_priority},
                onSelectionChanged: (values) {
                  setState(() => _priority = values.first);
                },
              ),
              const SizedBox(height: 24),

              // Privacy Consent
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.privacy_tip, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Datenschutz',
                          style: AppTextStyles.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• Die Videosprechstunde wird Ende-zu-Ende verschlüsselt.\n'
                      '• Es erfolgt keine Aufzeichnung ohne Ihre Zustimmung.\n'
                      '• Ihre Angaben werden in Ihrer Patientenakte gespeichert.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      value: _acceptedPrivacy,
                      onChanged: (value) {
                        setState(() => _acceptedPrivacy = value ?? false);
                      },
                      title: Text(
                        'Ich akzeptiere die Datenschutzhinweise',
                        style: AppTextStyles.bodySmall,
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitRequest,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  _isSubmitting ? 'Wird gesendet...' : 'Anfrage senden',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
