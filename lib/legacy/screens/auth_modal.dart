import 'package:flutter/material.dart';

class AuthModal extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const AuthModal({super.key, required this.onLoginSuccess});

  @override
  State<AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends State<AuthModal> {
  bool isOtpSent = false;
  final phoneController = TextEditingController(text: '0501234567');
  final otpController = TextEditingController();

  void _requestOtp() {
    if (phoneController.text.trim().length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال رقم جوال صحيح')),
      );
      return;
    }
    setState(() => isOtpSent = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إرسال رمز التحقق OTP إلى جوالك: 1234')),
    );
  }

  void _verifyOtp() {
    if (otpController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال رمز التحقق OTP')),
      );
      return;
    }
    widget.onLoginSuccess();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تسجيل الدخول بنجاح وإنشاء الجلسة!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 24,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('تسجيل الدخول / إنشاء حساب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const Divider(),
          const SizedBox(height: 10),
          if (!isOtpSent) ...[
            const Text('أدخل رقم الجوال لاستلام رمز التحقق OTP', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.phone_android, color: Color(0xFF005F73)),
                labelText: 'رقم الجوال',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005F73)),
                onPressed: _requestOtp,
                child: const Text('إرسال رمز التحقق OTP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ] else ...[
            Text('تم إرسال رمز التحقق OTP إلى ${phoneController.text}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.lock_clock, color: Color(0xFF005F73)),
                labelText: 'رمز التحقق (أدخل 1234)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005F73)),
                onPressed: _verifyOtp,
                child: const Text('تأكيد وتسجيل الدخول', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
