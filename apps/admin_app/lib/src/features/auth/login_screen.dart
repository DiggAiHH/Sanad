import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanad_core/sanad_core.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// Login screen for admin app
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateCanSubmit);
    _passwordController.addListener(_updateCanSubmit);
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      next.maybeWhen(
        authenticated: (user, _, __) {
          if (!mounted) return;
          context.go('/dashboard');
        },
        error: (message) {
          if (!mounted) return;
          ModernSnackBar.show(
            context,
            message: message,
            type: SnackBarType.error,
            actionLabel: 'Erneut',
            onAction: _handleLogin,
          );
        },
        orElse: () {},
      );
    });
  }

  @override
  void dispose() {
    _emailController.removeListener(_updateCanSubmit);
    _passwordController.removeListener(_updateCanSubmit);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text('Sanad Admin', style: AppTextStyles.h2),
                const SizedBox(height: 8),
                Text(
                  'Melden Sie sich an, um fortzufahren',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 48),
                // Email field
                TextInput(
                  controller: _emailController,
                  label: 'E-Mail',
                  hint: 'admin@praxis.de',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                // Password field
                TextInput(
                  controller: _passwordController,
                  label: 'Passwort',
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outlined,
                  obscureText: _obscurePassword,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Passwort vergessen?'),
                  ),
                ),
                const SizedBox(height: 24),
                // Login button
                PrimaryButton(
                  label: 'Anmelden',
                  isLoading: isLoading,
                  isFullWidth: true,
                  onPressed: isLoading || !_canSubmit ? null : _handleLogin,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ModernSnackBar.show(
        context,
        message: 'Bitte E-Mail und Passwort eingeben',
        type: SnackBarType.warning,
      );
      return;
    }

    ref.read(authStateProvider.notifier).login(
      email: email,
      password: password,
    );
  }

  void _updateCanSubmit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final canSubmit = email.isNotEmpty && password.isNotEmpty;
    if (canSubmit != _canSubmit) {
      setState(() => _canSubmit = canSubmit);
    }
  }
}
