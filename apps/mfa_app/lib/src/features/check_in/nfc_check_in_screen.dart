import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanad_core/sanad_core.dart';
import 'package:sanad_ui/sanad_ui.dart';
import 'package:sanad_iot/sanad_iot.dart';

/// NFC Check-in Screen - Automatisches Einchecken via NFC-Karte
class NfcCheckInScreen extends ConsumerStatefulWidget {
  const NfcCheckInScreen({super.key});

  @override
  ConsumerState<NfcCheckInScreen> createState() => _NfcCheckInScreenState();
}

class _NfcCheckInScreenState extends ConsumerState<NfcCheckInScreen>
    with SingleTickerProviderStateMixin {
  static const _deviceIdKey = 'sanad_iot.device_id';
  static const _deviceSecretKey = 'sanad_iot.device_secret';

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isStartingScan = false;
  bool _handledSuccess = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // NFC-Scan automatisch starten
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startNfcScan();
    });
  }

  @override
  void dispose() {
    // Best-effort cleanup; avoid leaving NFC sessions open.
    // ignore: discarded_futures
    ref.read(nfcStateNotifierProvider.notifier).stopScanning();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startNfcScan() async {
    if (_isStartingScan) {
      return;
    }
    _isStartingScan = true;
    final nfcNotifier = ref.read(nfcStateNotifierProvider.notifier);

    final storage = ref.read(storageServiceProvider);
    final deviceId = await storage.getSecure(_deviceIdKey);
    final deviceSecret = await storage.getSecure(_deviceSecretKey);

    if (deviceId == null || deviceId.isEmpty || deviceSecret == null || deviceSecret.isEmpty) {
      nfcNotifier.markUnavailable(
        'Geräte-Credentials fehlen. Bitte in Secure Storage setzen: $_deviceIdKey / $_deviceSecretKey',
      );
      _isStartingScan = false;
      return;
    }

    await nfcNotifier.startScanning(deviceId: deviceId, deviceSecret: deviceSecret);
    _isStartingScan = false;
  }

  void _handleCheckInResult(NFCCheckInResponse response) {
    if (_handledSuccess) {
      return;
    }
    final ticketNumber = response.ticketNumber;
    if (ticketNumber == null || ticketNumber.isEmpty) {
      ModernSnackBar.show(
        context,
        message: 'Check-In erfolgreich, aber Ticketnummer fehlt.',
        type: SnackBarType.error,
      );
      return;
    }

    _handledSuccess = true;
    // Erfolgreicher Check-in - zur Bestätigung navigieren
    context.push('/ticket/$ticketNumber', extra: {
      'patientName': response.patientName,
      'room': response.assignedRoom,
      'queueName': response.queueName,
      'waitTime': response.estimatedWaitMinutes,
    });
  }

  @override
  Widget build(BuildContext context) {
    final nfcState = ref.watch(nfcStateNotifierProvider);

    // Auf Check-in-Ergebnis reagieren
    ref.listen<NFCState>(nfcStateNotifierProvider, (previous, next) {
      next.maybeWhen(
        success: (response) => _handleCheckInResult(response),
        error: (message) {
          ModernSnackBar.show(
            context,
            message: message,
            type: SnackBarType.error,
            actionLabel: 'Erneut',
            onAction: _startNfcScan,
          );
        },
        orElse: () {},
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC Check-In'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // NFC Animation
              nfcState.when(
                idle: () => _buildIdleState(),
                scanning: () => _buildScanningState(),
                processing: (_) => _buildProcessingState(),
                success: (response) => _buildSuccessState(response),
                error: (message) => _buildErrorState(message),
                unavailable: (reason) => _buildUnavailableState(reason),
              ),
              const SizedBox(height: 48),
              // Anweisungen
              nfcState.maybeWhen(
                idle: () => Column(
                  children: [
                    Text(
                      'Bereit zum Scannen',
                      style: AppTextStyles.h4,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: 'Scan starten',
                      icon: Icons.nfc,
                      onPressed: _startNfcScan,
                    ),
                  ],
                ),
                scanning: () => Column(
                  children: [
                    Text(
                      'Bitte Karte an das Lesegerät halten',
                      style: AppTextStyles.h4,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Die NFC-Karte kurz an das Symbol halten',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                processing: (_) => Text(
                  'Wird verarbeitet...',
                  style: AppTextStyles.h4,
                  textAlign: TextAlign.center,
                ),
                error: (message) => Column(
                  children: [
                    Text(
                      'Fehler beim Check-In',
                      style: AppTextStyles.h4.copyWith(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Erneut versuchen',
                      icon: Icons.refresh,
                      onPressed: _startNfcScan,
                    ),
                  ],
                ),
                unavailable: (reason) => Column(
                  children: [
                    Text(
                      'NFC nicht verfügbar',
                      style: AppTextStyles.h4.copyWith(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      reason,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            label: 'Erneut versuchen',
                            icon: Icons.refresh,
                            onPressed: _startNfcScan,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => context.push('/settings/iot-device'),
                            icon: const Icon(Icons.settings),
                            label: const Text('Gerät konfigurieren'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                orElse: () => const SizedBox.shrink(),
              ),
              const SizedBox(height: 48),
              // Alternative Check-in Methoden
              OutlinedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.keyboard),
                label: const Text('Manuelle Eingabe'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.push('/check-in/qr'),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('QR-Code scannen'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdleState() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.border, width: 3),
      ),
      child: Icon(
        Icons.nfc,
        size: 80,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildScanningState() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.3),
                  AppColors.primary.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppColors.primary, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.nfc,
              size: 80,
              color: AppColors.primary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildProcessingState() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.primary, width: 3),
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 4),
      ),
    );
  }

  Widget _buildSuccessState(NFCCheckInResponse response) {
    final ticketNumber = response.ticketNumber ?? '';
    final hasWayfinding = response.wayfindingRouteId != null && response.wayfindingRouteId!.isNotEmpty;
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.success, width: 3),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            size: 48,
            color: AppColors.success,
          ),
          const SizedBox(height: 6),
          Text(
            ticketNumber,
            style: AppTextStyles.h3.copyWith(color: AppColors.success),
          ),
          if (hasWayfinding) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.route, size: 18, color: AppColors.success.withOpacity(0.8)),
                const SizedBox(width: 4),
                Text(
                  'LED-Route aktiv',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.success),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.error, width: 3),
      ),
      child: const Icon(
        Icons.error_outline,
        size: 80,
        color: AppColors.error,
      ),
    );
  }

  Widget _buildUnavailableState(String reason) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.error, width: 3),
      ),
      child: const Icon(
        Icons.nfc,
        size: 80,
        color: AppColors.error,
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('NFC Check-In Hilfe'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('So funktioniert der NFC Check-In:'),
            SizedBox(height: 16),
            _HelpItem(
              icon: Icons.credit_card,
              text: '1. NFC-Patientenkarte bereithalten',
            ),
            SizedBox(height: 8),
            _HelpItem(
              icon: Icons.phone_android,
              text: '2. Karte an Rückseite des Geräts halten',
            ),
            SizedBox(height: 8),
            _HelpItem(
              icon: Icons.check,
              text: '3. Warten bis Bestätigung erscheint',
            ),
            SizedBox(height: 16),
            Text(
              'Bei Problemen wenden Sie sich an den IT-Support.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Verstanden'),
          ),
        ],
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HelpItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    );
  }
}
