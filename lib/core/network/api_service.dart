import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref.read(dioProvider));
});

class ApiService {
  final Dio _dio;
  ApiService(this._dio);

  // ── Auth ──
  Future<Response> sendOtp(String phone) =>
      _dio.post('/auth/phone/send-otp', data: {'phone': phone});

  Future<Response> verifyOtp(String phone, String otp) =>
      _dio.post('/auth/phone/verify-otp', data: {'phone': phone, 'otp': otp});

  Future<Response> getMe() => _dio.get('/auth/me');

  Future<Response> logout() => _dio.post('/auth/logout');

  // ── Diagnosis ──
  Future<Response> createDiagnosis(FormData formData) =>
      _dio.post('/diagnoses', data: formData,
          options: Options(
            contentType: 'multipart/form-data',
            sendTimeout: const Duration(seconds: 60),
          ));

  Future<Response> getDiagnosis(String id) => _dio.get('/diagnoses/$id');

  Future<Response> listDiagnoses({int page = 1, int limit = 10, String? cropName}) =>
      _dio.get('/diagnoses', queryParameters: {
        'page': page, 'limit': limit,
        if (cropName != null && cropName.isNotEmpty) 'cropName': cropName,
      });

  Future<Response> deleteDiagnosis(String id) => _dio.delete('/diagnoses/$id');

  Future<Response> getDiagnosisStats() => _dio.get('/diagnoses/stats/summary');

  // ── Profile ──
  Future<Response> getProfile() => _dio.get('/profile');
  Future<Response> updateProfile(Map<String, dynamic> data) => _dio.put('/profile', data: data);
  Future<Response> getFarm() => _dio.get('/profile/farm');
  Future<Response> updateFarm(Map<String, dynamic> data) => _dio.put('/profile/farm', data: data);

  // ── Weather ──
  Future<Response> getCurrentWeather({Map<String, dynamic>? params}) =>
      _dio.get('/weather/current', queryParameters: params);

  // ── Alerts ──
  Future<Response> getAlerts() => _dio.get('/alerts');

  // ── Soil Tests ──
  Future<Response> createSoilTest(Map<String, dynamic> data) =>
      _dio.post('/soil-tests', data: data);

  Future<Response> listSoilTests({int page = 1, int limit = 10}) =>
      _dio.get('/soil-tests', queryParameters: {'page': page, 'limit': limit});

  Future<Response> getSoilTest(String id) => _dio.get('/soil-tests/$id');

  Future<Response> deleteSoilTest(String id) => _dio.delete('/soil-tests/$id');

  // ── Mandi ──
  Future<Response> listMandiPrices({
    String? commodity, String? state, int page = 1, int limit = 20,
  }) => _dio.get('/mandi/prices', queryParameters: {
    'page': page, 'limit': limit,
    if (commodity != null && commodity.isNotEmpty) 'commodity': commodity,
    if (state != null && state.isNotEmpty) 'state': state,
  });

  Future<Response> getMyCropPrices() => _dio.get('/mandi/prices/my-crops');

  Future<Response> getMandiTrends({
    required String commodity, String? market, int days = 7,
  }) => _dio.get('/mandi/prices/trends', queryParameters: {
    'commodity': commodity, 'days': days,
    if (market != null && market.isNotEmpty) 'market': market,
  });

  Future<Response> getPricePrediction({
    required String commodity, String? market, String? state, int days = 60,
  }) => _dio.get('/mandi/prices/predict', queryParameters: {
    'commodity': commodity, 'days': days,
    if (market != null && market.isNotEmpty) 'market': market,
    if (state != null && state.isNotEmpty) 'state': state,
  });

  Future<Response> getMandiCommodities() => _dio.get('/mandi/commodities');

  // ── Calendar ──
  Future<Response> createCalendar(Map<String, dynamic> data) =>
      _dio.post('/calendar', data: data);

  Future<Response> listCalendars() => _dio.get('/calendar');

  Future<Response> getCalendar(String id) => _dio.get('/calendar/$id');

  Future<Response> deleteCalendar(String id) => _dio.delete('/calendar/$id');

  Future<Response> getUpcomingTasks() => _dio.get('/calendar/tasks/upcoming');

  Future<Response> updateTask(String calId, String taskId, Map<String, dynamic> data) =>
      _dio.patch('/calendar/$calId/tasks/$taskId', data: data);

  // ── Community ──
  Future<Response> listQuestions({
    int page = 1, int limit = 10, String sort = 'recent',
    String? search, String? topic,
  }) => _dio.get('/community/questions', queryParameters: {
    'page': page, 'limit': limit, 'sort': sort,
    if (search != null && search.isNotEmpty) 'search': search,
    if (topic != null && topic.isNotEmpty) 'topic': topic,
  });

  Future<Response> getQuestion(String id) => _dio.get('/community/questions/$id');

  Future<Response> createQuestion(FormData formData) =>
      _dio.post('/community/questions', data: formData,
          options: Options(contentType: 'multipart/form-data'));

  Future<Response> voteQuestion(String id, String vote) =>
      _dio.post('/community/questions/$id/vote', data: {'vote': vote});

  Future<Response> createAnswer(String questionId, FormData formData) =>
      _dio.post('/community/questions/$questionId/answers', data: formData,
          options: Options(contentType: 'multipart/form-data'));

  Future<Response> voteAnswer(String id, String vote) =>
      _dio.post('/community/answers/$id/vote', data: {'vote': vote});

  Future<Response> acceptAnswer(String questionId, String answerId) =>
      _dio.patch('/community/questions/$questionId/accept/$answerId');

  // ── Schemes ──
  Future<Response> listSchemes({
    String? type, String? state, String? search, int page = 1, int limit = 20,
  }) => _dio.get('/schemes', queryParameters: {
    'page': page, 'limit': limit,
    if (type != null && type.isNotEmpty) 'type': type,
    if (state != null && state.isNotEmpty) 'state': state,
    if (search != null && search.isNotEmpty) 'search': search,
  });

  Future<Response> getScheme(String id) => _dio.get('/schemes/$id');

  Future<Response> getSchemeTypes() => _dio.get('/schemes/types');

  Future<Response> getMySchemes() => _dio.get('/schemes/my-schemes');

  // ── Assistant ──
  Future<Response> askAssistant(String question, {String? language}) =>
      _dio.post('/assistant/ask', data: {
        'question': question,
        if (language != null) 'language': language,
      });
}
