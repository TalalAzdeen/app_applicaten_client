import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onProceedToNafath;
  final VoidCallback onNavigateToRegister;

  const LoginScreen({
    super.key,
    required this.onProceedToNafath,
    required this.onNavigateToRegister,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneOrEmailController = TextEditingController(text: '0501234567');
  final _passwordController = TextEditingController(text: '123456');
  bool _isPasswordVisible = false;

  void _handleGoogleSignIn() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جارٍ تسجيل الدخول بواسطة جوجل...', style: TextStyle(fontSize: 12)),
        backgroundColor: AppTheme.primaryTeal,
      ),
    );
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) widget.onProceedToNafath();
    });
  }

  void _handleLogin() {
    if (_phoneOrEmailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال رقم الجوال أو البريد الإلكتروني', style: TextStyle(fontSize: 12))),
      );
      return;
    }
    widget.onProceedToNafath();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Compact Logo Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal.withAlpha(15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.handyman_rounded,
                          size: 32,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'صلّح | SALLIH',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTeal,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'منصة صيانة المنزل المعتمدة بالكامل',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Card Container
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'تسجيل الدخول',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'أدخل بياناتك أو سجل عبر حساب جوجل للمتابعة.',
                          style: TextStyle(color: Colors.grey[600], fontSize: 11),
                        ),

                        const SizedBox(height: 18),

                        // Google Sign-In Button
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: BorderSide(color: Colors.grey[300]!),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _handleGoogleSignIn,
                          icon: Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
                            height: 18,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.g_mobiledata, size: 22, color: Colors.red),
                          ),
                          label: const Text(
                            'تسجيل الدخول باستخدام Google',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey[300])),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'أو عبر الجوال / البريد',
                                style: TextStyle(color: Colors.grey[500], fontSize: 10),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey[300])),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Phone / Email Input
                        const Text(
                          'رقم الجوال أو البريد الإلكتروني',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _phoneOrEmailController,
                          style: const TextStyle(fontSize: 12),
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: '05XXXXXXXX أو example@domain.com',
                            prefixIcon: Icon(Icons.person_outline, size: 18, color: AppTheme.primaryTeal),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Password Input
                        const Text(
                          'كلمة المرور',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _passwordController,
                          style: const TextStyle(fontSize: 12),
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AppTheme.primaryTeal),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                size: 18,
                                color: Colors.grey[600],
                              ),
                              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            ),
                          ),
                        ),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تم إرسال رابط إعادة ضبط كلمة المرور إلى جوالك', style: TextStyle(fontSize: 11))),
                              );
                            },
                            child: const Text('نسيت كلمة المرور؟', style: TextStyle(color: AppTheme.primaryTeal, fontSize: 10)),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Login CTA Button
                        ElevatedButton(
                          onPressed: _handleLogin,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('المتابعة إلى نفاذ (Nafath)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              SizedBox(width: 6),
                              Icon(Icons.arrow_forward, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('ليس لديك حساب بعد؟', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                    TextButton(
                      onPressed: widget.onNavigateToRegister,
                      child: const Text(
                        'إنشاء حساب جديد',
                        style: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
