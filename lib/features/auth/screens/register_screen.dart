import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/app_repository.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onProceedToNafath;
  final VoidCallback onNavigateToLogin;

  const RegisterScreen({
    super.key,
    required this.onProceedToNafath,
    required this.onNavigateToLogin,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameController = TextEditingController(text: 'عبدالله السعيد');
  final _nationalIdController = TextEditingController(text: '1098765432');
  final _phoneController = TextEditingController(text: '0501234567');
  final _emailController = TextEditingController(text: 'abdullah@example.com');
  bool _agreeToTerms = true;

  void _handleRegister() {
    if (_fullNameController.text.trim().isEmpty ||
        _nationalIdController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تعبئة الحقول الأساسية لإنشاء الحساب', style: TextStyle(fontSize: 11))),
      );
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء الموافقة على الشروط والأحكام لاستكمال التسجيل', style: TextStyle(fontSize: 11))),
      );
      return;
    }

    AppRepository.currentUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      fullName: _fullNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      nationalId: _nationalIdController.text.trim(),
      isNafathVerified: false,
    );

    widget.onProceedToNafath();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب جديد', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: widget.onNavigateToLogin,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'مرحباً بك في صلّح',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'أنشئ حسابك للوصول إلى كافة خدمات الصيانة والضمان المعتمد.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),

                  const SizedBox(height: 18),

                  // Full Name
                  const Text('الاسم الكامل *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _fullNameController,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      hintText: 'مثال: عبدالله الشمري',
                      prefixIcon: Icon(Icons.person, size: 18, color: AppTheme.primaryTeal),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // National ID / Iqama
                  const Text('رقم الهوية الوطنية / الإقامة *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nationalIdController,
                    style: const TextStyle(fontSize: 12),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '10XXXXXXXX',
                      prefixIcon: Icon(Icons.badge_outlined, size: 18, color: AppTheme.primaryTeal),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Phone Number
                  const Text('رقم الجوال *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _phoneController,
                    style: const TextStyle(fontSize: 12),
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: '05XXXXXXXX',
                      prefixIcon: Icon(Icons.phone_android, size: 18, color: AppTheme.primaryTeal),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Email
                  const Text('البريد الإلكتروني', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(fontSize: 12),
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'example@domain.com',
                      prefixIcon: Icon(Icons.email_outlined, size: 18, color: AppTheme.primaryTeal),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Terms agreement
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _agreeToTerms,
                          activeColor: AppTheme.primaryTeal,
                          onChanged: (val) => setState(() => _agreeToTerms = val ?? true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'أوافق على شروط الخدمة وسياسة الخصوصية لمنصة صلّح SALLIH',
                          style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _handleRegister,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('إنشاء الحساب والمتابعة لنفاذ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        SizedBox(width: 6),
                        Icon(Icons.verified_user_outlined, size: 16),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('لديك حساب بالفعل؟', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                      TextButton(
                        onPressed: widget.onNavigateToLogin,
                        child: const Text(
                          'تسجيل الدخول',
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
      ),
    );
  }
}
