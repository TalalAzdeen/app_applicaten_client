import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/localization/localized_text.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/app_repository.dart';

class NafathVerificationScreen extends StatefulWidget {
  final VoidCallback onVerificationSuccess;
  final VoidCallback onCancel;

  const NafathVerificationScreen({
    super.key,
    required this.onVerificationSuccess,
    required this.onCancel,
  });

  @override
  State<NafathVerificationScreen> createState() => _NafathVerificationScreenState();
}

class _NafathVerificationScreenState extends State<NafathVerificationScreen> {
  final String _randomNafathCode = '42';
  int _secondsRemaining = 180;
  Timer? _timer;
  bool _isSimulating = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _simulateNafathAppApproval() {
    setState(() => _isSimulating = true);

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (AppRepository.currentUser != null) {
        AppRepository.currentUser = AppRepository.currentUser!.copyWith(
          isNafathVerified: false,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: AppText('محاكاة نفاذ فقط • لم يحدث توثيق حقيقي', style: TextStyle(fontSize: 14)),
          backgroundColor: AppTheme.nafathGreen,
        ),
      );

      widget.onVerificationSuccess();
    });
  }

  String get _formattedTime {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final user = AppRepository.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const AppText('التحقق عبر نفاذ (Nafath)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: widget.onCancel,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nafath Official Brand Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF006C4C), Color(0xFF00875A)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00875A).withAlpha(40),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        AppText(
                          'النفاذ الوطني الموحد',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.shield_outlined, color: Colors.white, size: 22),
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 18),
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.white24,
                          radius: 16,
                          child: Icon(Icons.person, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              user?.fullName ?? 'عبدالله السعيد',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            AppText(
                              'رقم الهوية: ${user?.nationalId ?? '1098765432'}',
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Center(
                child: AppText(
                  'الرقم المطلوب اختياره في تطبيق نفاذ:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),

              const SizedBox(height: 12),

              // Prominent 2-digit Nafath Verification Number Badge
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.nafathGreen, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.nafathGreen.withAlpha(25),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: AppText(
                      _randomNafathCode,
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.nafathGreen,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Countdown timer
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: Colors.red),
                    const SizedBox(width: 4),
                    AppText(
                      'ينتهي الطلب خلال: $_formattedTime',
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Instructions Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText(
                        'خطوات التوثيق والتحقق:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      _buildStepItem('1', 'افتح تطبيق نفاذ (Nafath) على هاتفك المحمول.'),
                      _buildStepItem('2', 'سوف يصلك إشعار طلب دخول وتوثيق حساب من تطبيق صلّح.'),
                      _buildStepItem('3', 'اختر الرقم ($_randomNafathCode) للموافقة وإكمال التوثيق.'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Simulate Approval CTA Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.nafathGreen,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _isSimulating ? null : _simulateNafathAppApproval,
                child: _isSimulating
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          AppText(
                            'تأكيد الموافقة في تطبيق نفاذ',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 8),

              TextButton(
                onPressed: widget.onCancel,
                child: const AppText('إلغاء وإعادة المحاولة', style: TextStyle(color: Colors.grey, fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem(String stepNumber, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: AppTheme.nafathGreen.withAlpha(25),
            child: AppText(
              stepNumber,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.nafathGreen),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AppText(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
