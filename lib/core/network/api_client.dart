import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

final secureStorageProvider = Provider((_) => const FlutterSecureStorage());

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.read(secureStorageProvider);
  final dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await storage.read(key: 'accessToken');
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
    onError: (error, handler) async {
      if (error.response?.statusCode == 401 &&
          !(error.requestOptions.extra['_retry'] == true)) {
        error.requestOptions.extra['_retry'] = true;
        try {
          final refreshDio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
          final res = await refreshDio.post('/auth/refresh');
          final newToken = res.data['accessToken'] as String;
          await storage.write(key: 'accessToken', value: newToken);

          error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final retryResponse = await dio.fetch(error.requestOptions);
          return handler.resolve(retryResponse);
        } catch (_) {
          await storage.delete(key: 'accessToken');
          return handler.reject(error);
        }
      }
      handler.next(error);
    },
  ));

  return dio;
});
