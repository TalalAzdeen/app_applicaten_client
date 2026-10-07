import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../features/auth/services/auth_service.dart';

class ApiFailure implements Exception {
  final String message;
  const ApiFailure(this.message);
}

class ApiClient {
  static const _base = String.fromEnvironment('API_BASE_URL');
  static bool get configured => _base.isNotEmpty;

  Future<Map<String, dynamic>> request(String method, String path, [Map<String, dynamic>? body]) async {
    if (!configured) throw const ApiFailure('خدمة الدفع غير مهيأة بعد.');
    final token = AuthService.instance.accessToken;
    if (token == null) throw const ApiFailure('سجّل الدخول بحساب حقيقي للمتابعة.');
    final base = Uri.parse(_base);
    if (base.scheme != 'https') throw const ApiFailure('يجب أن يستخدم الخادم اتصال HTTPS.');
    final headers = {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};
    final url = base.resolve(path);
    final response = await (method == 'GET' ? http.get(url, headers: headers)
      : http.post(url, headers: headers, body: jsonEncode(body)))
      .timeout(const Duration(seconds: 25));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiFailure(response.statusCode == 401 ? 'انتهت الجلسة. سجّل الدخول مجددًا.'
        : response.statusCode == 404 ? 'الطلب غير موجود في الخادم. الطلبات التجريبية لا تقبل الدفع.'
        : 'تعذر إكمال العملية. حاول مجددًا أو تواصل مع الدعم.');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
