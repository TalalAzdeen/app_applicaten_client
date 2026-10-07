import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthFailure implements Exception {
  final String message;
  const AuthFailure(this.message);
}

/// Access tokens stay in memory; a fresh app session requires signing in again.
class AuthService {
  static final instance = AuthService();
  static const _base = String.fromEnvironment('SUPABASE_URL');
  static const _publicKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  String? _accessToken;
  DateTime? _expiresAt;
  String? userId;
  bool get configured => _base.isNotEmpty && _publicKey.isNotEmpty;
  String? get accessToken => _expiresAt != null && DateTime.now().isBefore(_expiresAt!) ? _accessToken : null;
  bool get authenticated => accessToken != null;

  Future<void> signIn(String email, String password) async {
    if (!configured) throw const AuthFailure('تسجيل الدخول الحقيقي غير مهيأ. استخدم وضع العرض فقط.');
    final base = Uri.parse(_base);
    if (base.scheme != 'https') throw const AuthFailure('إعداد تسجيل الدخول غير صالح.');
    final response = await http.post(base.resolve('/auth/v1/token?grant_type=password'),
      headers: {'apikey': _publicKey, 'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim(), 'password': password}),
    ).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) throw const AuthFailure('تعذر تسجيل الدخول. تحقق من البريد وكلمة المرور.');
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    _accessToken = body['access_token'] as String;
    _expiresAt = DateTime.now().add(Duration(seconds: (body['expires_in'] as num).toInt() - 30));
    userId = (body['user'] as Map<String, dynamic>)['id'] as String;
  }

  Future<void> signUp(String name, String email, String password) async {
    if (!configured) throw const AuthFailure('تسجيل الدخول الحقيقي غير مهيأ. استخدم وضع العرض فقط.');
    final base = Uri.parse(_base);
    if (base.scheme != 'https') throw const AuthFailure('إعداد تسجيل الدخول غير صالح.');
    final response = await http.post(base.resolve('/auth/v1/signup'),
      headers: {'apikey': _publicKey, 'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim(), 'password': password, 'data': {'full_name': name.trim()}}),
    ).timeout(const Duration(seconds: 20));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const AuthFailure('تعذر إنشاء الحساب. تحقق من البيانات أو حاول لاحقًا.');
    }
  }

  void signOut() { _accessToken = null; _expiresAt = null; userId = null; }
}
