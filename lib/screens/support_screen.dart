 import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/models.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
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
        const SnackBar(content: Text('الرجاء إدخال تفاصيل البلاغ أو المطالبة بالضمان')),
      );
      return;
    }

    final ticketId = 'TCK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.verified, color: Colors.green),
            SizedBox(width: 8),
            Text('تم فتح التذكرة بنجاح'),
          ],
        ),
        content: Text(
          'تم إنشاء تذكرة دعم برقم $ticketId وربطها بالطلب ${selectedOrder?.referenceNumber}.\n\nسيقوم فريق دعم صلّح بمراجعة الأدلة والرد عليك خلال أقل من ساعتين.',
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005F73)),
            onPressed: () {
              Navigator.pop(ctx);
              descriptionController.clear();
            },
            child: const Text('حسناً', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دعم صلّح والضمان - SALLIH Support', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal[200]!),
              ),
              child: Row(
                children: const [
                  Icon(Icons.security, size: 36, color: Color(0xFF005F73)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'جميع الخدمات المنفذة عبر صلّح مغطاة بضمان الخدمة المعتمد. يمكنك رفع مطالبة ضمان أو بلاغ في أي وقت.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF005F73)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Select Order
            const Text('اختر الطلب المرتبط بالبلاغ/الضمان *', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<OrderModel>(
              value: selectedOrder,
              items: AppRepository.sampleOrders.map((o) {
                return DropdownMenuItem(
                  value: o,
                  child: Text('${o.referenceNumber} - ${o.service.name}'),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => selectedOrder = val);
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // Select Issue Type
            const Text('نوع البلاغ / المطالبة *', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: issueType,
              items: issueTypes.map((t) {
                return DropdownMenuItem(value: t, child: Text(t));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => issueType = val);
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // Details text
            const Text('تفاصيل المشكلة والأدلة *', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'اكتب وصفاً تفصيلياً للمشكلة الحاصلة بعد تنفيذ الخدمة...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),

            // Media attachment placeholder
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إرفاق صورة العطل أو الإثبات للضمان')),
                );
              },
              icon: const Icon(Icons.attach_file, color: Color(0xFF005F73)),
              label: const Text('إرفاق صور أو مقطع فيديو توضيحي (Object Storage)'),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005F73),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _submitTicket,
                child: const Text('إرسال التذكرة لفريق الدعم', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
