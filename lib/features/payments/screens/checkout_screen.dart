import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/localization/localized_text.dart';
import '../../../core/network/api_client.dart';
import '../services/payment_service.dart';

class CheckoutScreen extends StatefulWidget {
  final String orderId;
  const CheckoutScreen({super.key, required this.orderId});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _payments = PaymentService();
  bool _busy = false;
  String? _error;

  Future<void> _run(Future<void> Function() action) async {
    setState(() { _busy = true; _error = null; });
    try { await action(); }
    on ApiFailure catch (error) { if (mounted) setState(() => _error = error.message); }
    catch (_) { if (mounted) setState(() => _error = 'تعذر الاتصال. تحقق من الشبكة وأعد المحاولة.'); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  Future<void> _openCheckout() => _run(() async {
    final uri = await _payments.createCheckout(widget.orderId);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication, webOnlyWindowName: '_self')) {
      throw const ApiFailure('تعذر فتح صفحة الدفع.');
    }
  });

  Future<void> _verify() => _run(() async {
    final paid = await _payments.isPaid(widget.orderId);
    if (!mounted) return;
    if (paid) { Navigator.pop(context, true); }
    else { setState(() => _error = 'لم يؤكد الخادم الدفع بعد. انتظر قليلًا ثم أعد التحقق.'); }
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const AppText('دفع آمن')),
    body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480),
      child: Padding(padding: const EdgeInsets.all(24), child: Column(
        mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.lock_outline, size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 24),
          const AppText('ستدخل بيانات البطاقة في صفحة مزود الدفع الآمنة. لا يحفظ التطبيق بيانات بطاقتك.',
            textAlign: TextAlign.center),
          const SizedBox(height: 16),
          if (_error != null) AppText(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          if (_busy) const LinearProgressIndicator(),
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: _busy ? null : _openCheckout,
            icon: const Icon(Icons.open_in_new), label: const AppText('فتح صفحة الدفع')),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: _busy ? null : _verify, child: const AppText('التحقق من حالة الدفع')),
          const SizedBox(height: 12),
          const AppText('بعد الدفع، عد إلى التطبيق للتحقق. الرجوع من صفحة الدفع وحده لا يؤكد نجاح العملية.',
            textAlign: TextAlign.center),
        ],
      )))),
  );
}
