import 'package:flutter/material.dart';
import '../../../core/localization/localized_text.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onProceedToNafath;
  final VoidCallback onNavigateToRegister;
  const LoginScreen({super.key, required this.onProceedToNafath, required this.onNavigateToRegister});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _busy = false;
  bool _hidden = true;
  String? _error;

  @override
  void dispose() { _email.dispose(); _password.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _busy = true; _error = null; });
    try {
      await AuthService.instance.signIn(_email.text, _password.text);
      if (mounted) widget.onProceedToNafath();
    } on AuthFailure catch (error) { if (mounted) setState(() => _error = error.message); }
    catch (_) { if (mounted) setState(() => _error = 'تعذر الاتصال. تحقق من الشبكة وأعد المحاولة.'); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Center(
    child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480), child: Form(key: _form, child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(28)),
            child: Column(children: [
              Icon(Icons.handyman_rounded, size: 56, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              const AppText('صلّح | SALLIH', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const AppText('خدمات منزلك في مكان واحد', textAlign: TextAlign.center),
            ])),
          const SizedBox(height: 32),
          const AppText('تسجيل الدخول', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextFormField(controller: _email, keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr, autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(labelText: translate(context, 'البريد الإلكتروني'), prefixIcon: const Icon(Icons.alternate_email)),
            validator: (value) => value != null && RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim())
              ? null : translate(context, 'أدخل بريدًا إلكترونيًا صالحًا')),
          const SizedBox(height: 16),
          TextFormField(controller: _password, obscureText: _hidden,
            autofillHints: const [AutofillHints.password],
            decoration: InputDecoration(labelText: translate(context, 'كلمة المرور'), prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(tooltip: translate(context, _hidden ? 'إظهار كلمة المرور' : 'إخفاء كلمة المرور'),
                onPressed: () => setState(() => _hidden = !_hidden), icon: Icon(_hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined))),
            validator: (value) => value?.isNotEmpty == true ? null : translate(context, 'هذا الحقل مطلوب')),
          if (_error != null) Padding(padding: const EdgeInsets.only(top: 16), child: AppText(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
          const SizedBox(height: 24),
          if (_busy) const LinearProgressIndicator(),
          FilledButton(onPressed: _busy ? null : _login, child: const AppText('تسجيل الدخول')),
          TextButton(onPressed: _busy ? null : widget.onNavigateToRegister, child: const AppText('إنشاء حساب جديد')),
          const Divider(height: 32),
          OutlinedButton.icon(onPressed: _busy ? null : () {
            AuthService.instance.signOut(); widget.onProceedToNafath();
          }, icon: const Icon(Icons.explore_outlined), label: const AppText('استكشاف النسخة التجريبية')),
          const SizedBox(height: 12),
          const AppText('وضع العرض لا ينفذ دفعًا أو توثيق نفاذ حقيقيًا.', textAlign: TextAlign.center),
        ],
      ))),
    ),
  )));
}
