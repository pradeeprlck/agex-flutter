import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_service.dart';

part 'auth_provider.g.dart';

class AuthState {
  final Map<String, dynamic>? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({Map<String, dynamic>? user, bool? isLoading, String? error, bool clearUser = false}) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isAuthenticated => user != null;
  String get displayName => user?['name']?.toString().split(' ').first ?? 'Farmer';
  String get phone => user?['phone']?.toString() ?? '';
}

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  late final ApiService _api;
  late final FlutterSecureStorage _storage;

  @override
  AuthState build() {
    _api = ref.watch(apiServiceProvider);
    _storage = ref.watch(secureStorageProvider);
    _init();
    return const AuthState(isLoading: true);
  }

  Future<void> _init() async {
    try {
      final token = await _storage.read(key: 'accessToken');
      if (token != null) {
        final res = await _api.getMe();
        state = AuthState(user: res.data['user'] as Map<String, dynamic>);
      } else {
        state = const AuthState();
      }
    } catch (_) {
      await _storage.delete(key: 'accessToken');
      state = const AuthState();
    }
  }

  Future<void> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final fullPhone = phone.startsWith('+') ? phone : '+91$phone';
      await _api.sendOtp(fullPhone);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to send OTP');
      rethrow;
    }
  }

  Future<void> verifyOtp(String phone, String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final fullPhone = phone.startsWith('+') ? phone : '+91$phone';
      final res = await _api.verifyOtp(fullPhone, otp);
      await _storage.write(key: 'accessToken', value: res.data['accessToken']);
      state = AuthState(user: res.data['user'] as Map<String, dynamic>);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Verification failed');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {}
    await _storage.delete(key: 'accessToken');
    state = const AuthState();
  }

  void updateUser(Map<String, dynamic> user) {
    state = state.copyWith(user: user);
  }
}

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) => const FlutterSecureStorage());
