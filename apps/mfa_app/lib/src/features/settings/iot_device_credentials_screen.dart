import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanad_core/sanad_core.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// Settings screen to configure IoT device credentials for NFC check-in.
///
/// Stores credentials in secure storage (FlutterSecureStorage via `StorageService`).
///
/// Security:
/// - Secrets are never hardcoded.
/// - Secret is stored only in secure storage.
class IotDeviceCredentialsScreen extends ConsumerStatefulWidget {
  const IotDeviceCredentialsScreen({super.key});

  static const deviceIdKey = 'sanad_iot.device_id';
  static const deviceSecretKey = 'sanad_iot.device_secret';

  @override
  ConsumerState<IotDeviceCredentialsScreen> createState() =>
      _IotDeviceCredentialsScreenState();
}

class _IotDeviceCredentialsScreenState
    extends ConsumerState<IotDeviceCredentialsScreen> {
  final _deviceIdController = TextEditingController();
  final _deviceSecretController = TextEditingController();

  bool _loading = true;
  bool _showSecret = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  @override
  void dispose() {
    _deviceIdController.dispose();
    _deviceSecretController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final storage = ref.read(storageServiceProvider);

    final deviceId = await storage.getSecure(IotDeviceCredentialsScreen.deviceIdKey);
    final deviceSecret =
        await storage.getSecure(IotDeviceCredentialsScreen.deviceSecretKey);

    _deviceIdController.text = deviceId ?? '';
    _deviceSecretController.text = deviceSecret ?? '';

    if (mounted) setState(() => _loading = false);
  }

  String? _validateDeviceId(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Device ID ist erforderlich.';

    // UUID v4-ish validation (accept any UUID variant format).
    final uuid = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    if (!uuid.hasMatch(trimmed)) {
      return 'Device ID muss ein UUID sein (z.B. 550e8400-e29b-41d4-a716-446655440000).';
    }

    return null;
  }

  String? _validateSecret(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Device Secret ist erforderlich.';
    if (trimmed.length < 12) return 'Device Secret ist zu kurz.';
    return null;
  }

  Future<void> _save() async {
    final deviceId = _deviceIdController.text;
    final deviceSecret = _deviceSecretController.text;

    final idError = _validateDeviceId(deviceId);
    final secretError = _validateSecret(deviceSecret);

    if (idError != null || secretError != null) {
      final msg = [idError, secretError].whereType<String>().join('\n');
      if (!mounted) return;
      ModernSnackBar.show(
        context,
        message: msg,
        type: SnackBarType.error,
      );
      return;
    }

    setState(() => _loading = true);
    final storage = ref.read(storageServiceProvider);

    await storage.setSecure(
      IotDeviceCredentialsScreen.deviceIdKey,
      deviceId.trim(),
    );
    await storage.setSecure(
      IotDeviceCredentialsScreen.deviceSecretKey,
      deviceSecret.trim(),
    );

    if (!mounted) return;
    setState(() => _loading = false);
    ModernSnackBar.show(
      context,
      message: 'IoT Geräte-Credentials gespeichert.',
      type: SnackBarType.success,
    );
  }

  Future<void> _clear() async {
    setState(() => _loading = true);
    final storage = ref.read(storageServiceProvider);

    await storage.deleteSecure(IotDeviceCredentialsScreen.deviceIdKey);
    await storage.deleteSecure(IotDeviceCredentialsScreen.deviceSecretKey);

    _deviceIdController.clear();
    _deviceSecretController.clear();

    if (!mounted) return;
    setState(() => _loading = false);
    ModernSnackBar.show(
      context,
      message: 'IoT Geräte-Credentials gelöscht.',
      type: SnackBarType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Gerät (NFC)'),
      ),
      body: ScreenState(
        isLoading: _loading,
        loadingMessage: 'Lade Geräte-Credentials...',
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Geräte-Credentials', style: AppTextStyles.h5),
                    const SizedBox(height: 8),
                    Text(
                      'Diese Werte identifizieren und autorisieren das Lesegerät gegenüber dem Backend.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _deviceIdController,
                      decoration: const InputDecoration(
                        labelText: 'Device ID (UUID)',
                        hintText:
                            '550e8400-e29b-41d4-a716-446655440000',
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _deviceSecretController,
                      decoration: InputDecoration(
                        labelText: 'Device Secret',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showSecret
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() => _showSecret = !_showSecret);
                          },
                        ),
                      ),
                      obscureText: !_showSecret,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            label: 'Speichern',
                            icon: Icons.save,
                            onPressed: _save,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _clear,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Löschen'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hinweis', style: AppTextStyles.h6),
                    const SizedBox(height: 8),
                    Text(
                      'Keys in Secure Storage:\n'
                      '- ${IotDeviceCredentialsScreen.deviceIdKey}\n'
                      '- ${IotDeviceCredentialsScreen.deviceSecretKey}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
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
