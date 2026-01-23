import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanad_core/sanad_core.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// Schritt 12: Verbindungsstatus für UI-Feedback.
enum VoiceCallConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  failed,
}

/// Screen für Telefonsprechstunde mit dem Arzt.
class VoiceCallScreen extends ConsumerStatefulWidget {
  final String? consultationId;

  const VoiceCallScreen({super.key, this.consultationId});

  @override
  ConsumerState<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends ConsumerState<VoiceCallScreen> {
  // Schritt 12: Erweiterte Connection States
  VoiceCallConnectionState _connectionState = VoiceCallConnectionState.disconnected;
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  int _callDuration = 0;
  
  // Schritt 11: Reconnect tracking
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  bool _signalingActive = false;
  
  WebRTCRoom? _roomInfo;
  Consultation? _consultation;
  
  // Schritt 9: Legacy compatibility
  bool get _isConnecting => _connectionState == VoiceCallConnectionState.connecting;
  bool get _isConnected => _connectionState == VoiceCallConnectionState.connected;

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

  void _startDurationTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _isConnected) {
        setState(() => _callDuration++);
        return true;
      }
      return false;
    });
  }

  /// Schritt 9: Improved Init Flow mit State Management.
  Future<void> _initializeCall() async {
    if (widget.consultationId == null) {
      setState(() => _connectionState = VoiceCallConnectionState.failed);
      return;
    }

    setState(() => _connectionState = VoiceCallConnectionState.connecting);

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
          _connectionState = VoiceCallConnectionState.connected;
          _reconnectAttempts = 0;
        });
        
        // Start duration timer after connected
        _startDurationTimer();
        
        // TODO: Initialize actual WebRTC audio-only connection
        _startSignalingLoop();
      }
    } catch (e) {
      if (mounted) {
        // Schritt 11: Retry logic
        if (_reconnectAttempts < _maxReconnectAttempts) {
          _reconnectAttempts++;
          setState(() => _connectionState = VoiceCallConnectionState.reconnecting);
          await Future.delayed(Duration(seconds: _reconnectAttempts * 2));
          return _initializeCall();
        }
        
        setState(() => _connectionState = VoiceCallConnectionState.failed);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verbindungsfehler: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Schritt 11: Signaling Loop mit Reconnect-Logic (audio-only).
  Future<void> _startSignalingLoop() async {
    if (widget.consultationId == null || !mounted) return;
    
    _signalingActive = true;
    final service = ref.read(consultationServiceProvider);
    DateTime? lastPollTime;
    int consecutiveErrors = 0;
    
    // Poll every 500ms for new signals
    while (mounted && _signalingActive && _connectionState != VoiceCallConnectionState.failed) {
      try {
        final signals = await service.pollSignals(
          widget.consultationId!,
          since: lastPollTime,
        );
        
        consecutiveErrors = 0;
        
        for (final signal in signals) {
          lastPollTime = signal.timestamp;
          await _processSignal(signal);
        }
      } catch (e) {
        consecutiveErrors++;
        debugPrint('Signal poll error ($consecutiveErrors): $e');
        
        if (consecutiveErrors >= 3 && _connectionState == VoiceCallConnectionState.connected) {
          setState(() => _connectionState = VoiceCallConnectionState.reconnecting);
        }
        
        if (consecutiveErrors >= 10) {
          setState(() => _connectionState = VoiceCallConnectionState.failed);
          break;
        }
        
        await Future.delayed(Duration(milliseconds: 500 * consecutiveErrors.clamp(1, 5)));
        continue;
      }
      
      if (_connectionState == VoiceCallConnectionState.reconnecting) {
        setState(() => _connectionState = VoiceCallConnectionState.connected);
      }
      
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
  
  /// Processes an incoming WebRTC signal for audio call.
  Future<void> _processSignal(WebRTCSignal signal) async {
    // TODO: Implement with flutter_webrtc (audio-only)
    switch (signal.signalType) {
      case 'offer':
        final offer = WebRTCOffer.fromJson(signal.payload);
        debugPrint('Received audio offer: ${offer.type}');
        // Set remote description, create answer, send answer
        break;
        
      case 'answer':
        final answer = WebRTCAnswer.fromJson(signal.payload);
        debugPrint('Received audio answer: ${answer.type}');
        // Set remote description
        break;
        
      case 'ice-candidate':
        final candidate = WebRTCIceCandidate.fromJson(signal.payload);
        debugPrint('Received ICE: ${candidate.candidate}');
        // Add ICE candidate
        break;
    }
  }

  /// Schritt 10: Mikrofon stumm schalten / aktivieren.
  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    // flutter_webrtc: _localStream?.getAudioTracks().forEach((t) => t.enabled = !_isMuted);
  }

  /// Schritt 10: Lautsprecher umschalten.
  void _toggleSpeaker() {
    setState(() => _isSpeakerOn = !_isSpeakerOn);
    // flutter_webrtc: Helper.setSpeakerphoneOn(_isSpeakerOn);
  }

  /// Schritt 13: Call beenden mit vollständigem Cleanup.
  void _endCall() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Anruf beenden?'),
        content: const Text('Möchten Sie das Telefonat wirklich beenden?'),
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
  
  /// Schritt 13: Vollständiger Cleanup.
  Future<void> _performCleanup() async {
    _signalingActive = false;
    setState(() => _connectionState = VoiceCallConnectionState.disconnected);
    
    if (widget.consultationId != null) {
      try {
        final service = ref.read(consultationServiceProvider);
        await service.endCall(widget.consultationId!);
        await service.clearSignals(widget.consultationId!);
      } catch (e) {
        debugPrint('Cleanup error: $e');
      }
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final doctorName = _consultation?.doctorName ?? 'Dr. med. Schmidt';
    
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: _endCall,
                  ),
                  const Expanded(
                    child: Text(
                      'Telefonsprechstunde',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
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
                          'Sicher',
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

            // Main Content
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: AppColors.primary,
                      child: const Icon(
                        Icons.person,
                        size: 70,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Doctor Name
                  const Text(
                    'Dr. med. Schmidt',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Status
                  Text(
                    _isConnecting
                        ? 'Verbindung wird hergestellt...'
                        : _isConnected
                            ? 'Verbunden'
                            : 'Anruf beendet',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Duration
                  if (_isConnected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _formatDuration(_callDuration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),

                  // Connecting animation
                  if (_isConnecting)
                    Column(
                      children: [
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 100,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.white24,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Sound Wave Animation (when connected)
            if (_isConnected)
              SizedBox(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => _SoundBar(
                      delay: index * 100,
                      isMuted: _isMuted,
                    ),
                  ),
                ),
              ),

            // Controls
            Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  // Secondary Controls
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
                        icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                        label: _isSpeakerOn ? 'Lautsprecher' : 'Hörer',
                        isActive: _isSpeakerOn,
                        onTap: _toggleSpeaker,
                      ),
                      _ControlButton(
                        icon: Icons.dialpad,
                        label: 'Tastatur',
                        isActive: true,
                        onTap: () {
                          // TODO: Show dialpad
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

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

class _SoundBar extends StatefulWidget {
  final int delay;
  final bool isMuted;

  const _SoundBar({required this.delay, required this.isMuted});

  @override
  State<_SoundBar> createState() => _SoundBarState();
}

class _SoundBarState extends State<_SoundBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isMuted) {
      return Container(
        width: 6,
        height: 20,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(3),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 6,
          height: 20 + (_animation.value * 30),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5 + (_animation.value * 0.3)),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      },
    );
  }
}


/// Screen zum Anfragen einer Telefonsprechstunde oder eines Rueckrufs.
class RequestCallbackScreen extends ConsumerStatefulWidget {
  final ConsultationType requestType;

  const RequestCallbackScreen({
    super.key,
    this.requestType = ConsultationType.callbackRequest,
  });

  @override
  ConsumerState<RequestCallbackScreen> createState() => _RequestCallbackScreenState();
}

class _RequestCallbackScreenState extends ConsumerState<RequestCallbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _reasonController = TextEditingController();
  String _preferredTimeSlot = 'morning';
  String _priority = 'normal';
  bool _isSubmitting = false;
  bool _acceptedPrivacy = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _reasonController.dispose();
    super.dispose();
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
      final service = ref.read(consultationServiceProvider);
      final details =
          'Telefon: ${_phoneController.text.trim()} | Zeitfenster: ${_timeSlotLabel(_preferredTimeSlot)}';

      if (widget.requestType == ConsultationType.voiceCall) {
        await service.requestVoiceCall(
          reason: _reasonController.text.trim(),
          symptoms: details,
          priority: _mapPriority(_priority),
        );
      } else {
        await service.requestCallback(
          reason: _reasonController.text.trim(),
          symptoms: details,
          priority: _mapPriority(_priority),
        );
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            icon: Icon(Icons.check_circle, color: AppColors.success, size: 48),
            title: Text(_successTitle()),
            content: Text(
              _successMessage(),
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
    final isVoiceCall = widget.requestType == ConsultationType.voiceCall;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isVoiceCall ? 'Telefonsprechstunde anfragen' : 'Rückruf anfordern'),
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
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      isVoiceCall ? Icons.phone_in_talk : Icons.phone_callback,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isVoiceCall
                            ? 'Fordern Sie eine Telefonsprechstunde an '
                                'und sprechen Sie direkt mit Ihrem Arzt.'
                            : 'Fordern Sie einen Rückruf an und wir melden uns '
                                'telefonisch bei Ihnen.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.secondaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Phone Number
              Text(
                'Telefonnummer *',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  hintText: '+49 123 456789',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Bitte geben Sie Ihre Telefonnummer an.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Reason
              Text(
                isVoiceCall
                    ? 'Grund für die Telefonsprechstunde *'
                    : 'Grund für den Rückruf *',
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
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Bitte geben Sie einen Grund an.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Preferred Time
              Text(
                'Bevorzugte Zeit für den Rückruf',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _TimeSlotChip(
                    label: 'Vormittags\n(8-12 Uhr)',
                    value: 'morning',
                    selected: _preferredTimeSlot == 'morning',
                    onSelected: () => setState(() => _preferredTimeSlot = 'morning'),
                  ),
                  _TimeSlotChip(
                    label: 'Nachmittags\n(12-16 Uhr)',
                    value: 'afternoon',
                    selected: _preferredTimeSlot == 'afternoon',
                    onSelected: () => setState(() => _preferredTimeSlot = 'afternoon'),
                  ),
                  _TimeSlotChip(
                    label: 'Spät\n(16-18 Uhr)',
                    value: 'evening',
                    selected: _preferredTimeSlot == 'evening',
                    onSelected: () => setState(() => _preferredTimeSlot = 'evening'),
                  ),
                  _TimeSlotChip(
                    label: 'Jederzeit\nmöglich',
                    value: 'anytime',
                    selected: _preferredTimeSlot == 'anytime',
                    onSelected: () => setState(() => _preferredTimeSlot = 'anytime'),
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
                  ),
                  ButtonSegment(
                    value: 'normal',
                    label: Text('Normal'),
                  ),
                  ButtonSegment(
                    value: 'high',
                    label: Text('Dringend'),
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
                child: CheckboxListTile(
                  value: _acceptedPrivacy,
                  onChanged: (value) {
                    setState(() => _acceptedPrivacy = value ?? false);
                  },
                  title: Text(
                    'Ich bin einverstanden, dass meine Telefonnummer und '
                    'Anfrage für den Rückruf gespeichert werden.',
                    style: AppTextStyles.bodySmall,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
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
                  _isSubmitting
                      ? 'Wird gesendet...'
                      : (isVoiceCall ? 'Telefontermin anfragen' : 'Rückruf anfordern'),
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

  String _timeSlotLabel(String slot) {
    switch (slot) {
      case 'morning':
        return 'Morgens (08-12 Uhr)';
      case 'noon':
        return 'Mittags (12-14 Uhr)';
      case 'afternoon':
        return 'Nachmittags (14-18 Uhr)';
      case 'evening':
        return 'Abends (18-20 Uhr)';
      default:
        return 'Beliebig';
    }
  }

  ConsultationPriority _mapPriority(String value) {
    switch (value) {
      case 'high':
        return ConsultationPriority.urgent;
      case 'normal':
        return ConsultationPriority.sameDay;
      case 'low':
      default:
        return ConsultationPriority.routine;
    }
  }

  String _successTitle() {
    return widget.requestType == ConsultationType.voiceCall
        ? 'Telefonsprechstunde angefragt'
        : 'Rückruf angefordert';
  }

  String _successMessage() {
    return widget.requestType == ConsultationType.voiceCall
        ? 'Ihre Anfrage wurde übermittelt. Sie erhalten eine Benachrichtigung, '
            'sobald ein Termin bestätigt wurde.'
        : 'Ihre Rückrufanfrage wurde erfolgreich übermittelt. '
            'Wir werden Sie schnellstmöglich zurückrufen.';
  }
}

class _TimeSlotChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onSelected;

  const _TimeSlotChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        width: (MediaQuery.of(context).size.width - 48) / 2,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
