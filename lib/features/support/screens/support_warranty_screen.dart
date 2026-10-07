import 'package:flutter/material.dart';
import '../../../core/localization/localized_text.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/app_repository.dart';

class SupportWarrantyScreen extends StatefulWidget {
  const SupportWarrantyScreen({super.key});

  @override
  State<SupportWarrantyScreen> createState() => _SupportWarrantyScreenState();
}

class _SupportWarrantyScreenState extends State<SupportWarrantyScreen> {
  OrderModel? selectedOrder;
  String issueType = 'مطالبة بالضمان (Warranty Claim)';
  final TextEditingController descriptionController = TextEditingController();

  final List<String> issueTypes = [
    'مطالبة بالضمان (Warranty Claim)',
    'شكوى على الفني أو المؤسسة',
    'مشكلة في الدفع أو الفاتورة',
    'استفسار عام',
  ];

  @override
  void initState() {
    super.initState();
    if (AppRepository.sampleOrders.isNotEmpty) {
      selectedOrder = AppRepository.sampleOrders.first;
    }
  }

  void _submitTicket() {
    if (descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AppText('الرجاء إدخال تفاصيل البلاغ أو المطالبة بالضمان', style: TextStyle(fontSize: 14))),
      );
      return;
    }


    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.verified, color: Colors.green, size: 20),
            SizedBox(width: 6),
            AppText('تم إنشاء تذكرة تجريبية', style: TextStyle(fontSize: 14)),
          ],
        ),
        content: AppText(
          'تم إنشاء تذكرة تجريبية محلية. لم تُرسل إلى فريق الدعم.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
            onPressed: () {
              Navigator.pop(ctx);
              descriptionController.clear();
            },
            child: const AppText('حسناً', style: TextStyle(color: Colors.white, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText('دعم صلّح والضمان - SALLIH Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.teal[200]!),
              ),
              child: Row(
                children: const [
                  Icon(Icons.security, size: 28, color: AppTheme.primaryTeal),
                  SizedBox(width: 10),
                  Expanded(
                    child: AppText(
                      'النموذج الحالي تجريبي ولا يرسل تذاكر الدعم إلى خادم.',
                      style: TextStyle(fontSize: 14, color: AppTheme.primaryTeal),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Select Order
            const AppText('اختر الطلب المرتبط بالبلاغ/الضمان *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 6),
            DropdownButtonFormField<OrderModel>(
              value: selectedOrder,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              items: AppRepository.sampleOrders.map((o) {
                return DropdownMenuItem(
                  value: o,
                  child: AppText('${o.referenceNumber} - ${o.service.name}', style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => selectedOrder = val);
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),

            const SizedBox(height: 12),

            // Select Issue Type
            const AppText('نوع البلاغ / المطالبة *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: issueType,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              items: issueTypes.map((t) {
                return DropdownMenuItem(value: t, child: AppText(t, style: const TextStyle(fontSize: 14)));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => issueType = val);
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),

            const SizedBox(height: 12),

            // Details text
            const AppText('تفاصيل المشكلة والأدلة *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: descriptionController,
              style: const TextStyle(fontSize: 14),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: translate(context, 'اكتب وصفاً تفصيلياً للمشكلة الحاصلة بعد تنفيذ الخدمة...'),
              ),
            ),

            const SizedBox(height: 12),

            // Media attachment placeholder
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 38),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: AppText('إرفاق الصور غير متصل بعد.', style: TextStyle(fontSize: 14))),
                );
              },
              icon: const Icon(Icons.attach_file, size: 16, color: AppTheme.primaryTeal),
              label: const AppText('إرفاق صور أو مقطع فيديو توضيحي (Object Storage)', style: TextStyle(fontSize: 14)),
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _submitTicket,
                child: const AppText('إنشاء تذكرة تجريبية', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
