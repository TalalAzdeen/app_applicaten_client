import 'package:flutter/material.dart';
import '../../../core/localization/localized_text.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onProceedToNafath;
  final VoidCallback onNavigateToLogin;
  const RegisterScreen({super.key, required this.onProceedToNafath, required this.onNavigateToLogin});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _busy = false;
  String? _message;
  @override
  void dispose() { _name.dispose(); _email.dispose(); _password.dispose(); super.dispose(); }

  Future<void> _register() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _busy = true; _message = null; });
    try {
      await AuthService.instance.signUp(_name.text, _email.text, _password.text);
      if (mounted) setState(() => _message = 'راجع بريدك لتأكيد الحساب، ثم سجّل الدخول.');
    } on AuthFailure catch (error) { if (mounted) setState(() => _message = error.message); }
    catch (_) { if (mounted) setState(() => _message = 'تعذر الاتصال. تحقق من الشبكة وأعد المحاولة.'); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const AppText('إنشاء حساب جديد')),
    body: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480), child: Form(key: _form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const AppText('مرحباً بك في صلّح', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          TextFormField(controller: _name, maxLength: 100,
            decoration: InputDecoration(labelText: translate(context, 'الاسم الكامل')),
            validator: (value) => value?.trim().isNotEmpty == true ? null : translate(context, 'هذا الحقل مطلوب')),
          const SizedBox(height: 16),
          TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, textDirection: TextDirection.ltr,
            decoration: InputDecoration(labelText: translate(context, 'البريد الإلكتروني')),
            validator: (value) => value != null && RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim())
              ? null : translate(context, 'أدخل بريدًا إلكترونيًا صالحًا')),
          const SizedBox(height: 16),
          TextFormField(controller: _password, obscureText: true,
            decoration: InputDecoration(labelText: translate(context, 'كلمة المرور')),
            validator: (value) => (value?.length ?? 0) >= 12 ? null : translate(context, 'استخدم كلمة مرور من 12 حرفًا على الأقل')),
          const SizedBox(height: 24),
          if (_message != null) AppText(_message!),
          if (_busy) const LinearProgressIndicator(),
          FilledButton(onPressed: _busy ? null : _register, child: const AppText('إنشاء حساب جديد')),
          TextButton(onPressed: _busy ? null : widget.onNavigateToLogin, child: const AppText('تسجيل الدخول')),
        ]))))),
  );
}
