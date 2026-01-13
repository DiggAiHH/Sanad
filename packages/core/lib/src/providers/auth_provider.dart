import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_state.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'core_providers.dart';

/// Auth state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState.initial());

  Future<void> checkAuthState() async {
    state = const AuthState.loading();
    final isAuth = await _authService.isAuthenticated();
    if (isAuth) {
      // TODO: Fetch user profile
      state = const AuthState.unauthenticated();
    } else {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AuthState.loading();
    state = await _authService.login(email: email, password: password);
  }

  Future<void> loginWithQr(String qrToken) async {
    state = const AuthState.loading();
    state = await _authService.loginWithQrCode(qrToken);
  }

  Future<void> loginWithNfc(String nfcId) async {
    state = const AuthState.loading();
    state = await _authService.loginWithNfc(nfcId);
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState.unauthenticated();
  }
}

/// Auth state provider
final authStateProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

/// Current user provider (convenience)
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    authenticated: (user, _, __) => user,
    orElse: () => null,
  );
});

/// Is authenticated provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    authenticated: (_, __, ___) => true,
    orElse: () => false,
  );
});
