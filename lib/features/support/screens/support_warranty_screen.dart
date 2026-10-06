import 'package:flutter/material.dart';
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
        const SnackBar(content: Text('الرجاء إدخال تفاصيل البلاغ أو المطالبة بالضمان', style: TextStyle(fontSize: 11))),
      );
      return;
    }

    final ticketId = 'TCK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.verified, color: Colors.green, size: 20),
            SizedBox(width: 6),
            Text('تم فتح التذكرة بنجاح', style: TextStyle(fontSize: 14)),
          ],
        ),
        content: Text(
          'تم إنشاء تذكرة دعم برقم $ticketId وربطها بالطلب ${selectedOrder?.referenceNumber}.\n\nسيقوم فريق دعم صلّح بمراجعة الأدلة والرد عليك خلال أقل من ساعتين.',
          style: const TextStyle(fontSize: 11),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
            onPressed: () {
              Navigator.pop(ctx);
              descriptionController.clear();
            },
            child: const Text('حسناً', style: TextStyle(color: Colors.white, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دعم صلّح والضمان - SALLIH Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
                    child: Text(
                      'جميع الخدمات المنفذة عبر صلّح مغطاة بضمان الخدمة المعتمد. يمكنك رفع مطالبة ضمان أو بلاغ في أي وقت.',
                      style: TextStyle(fontSize: 11, color: AppTheme.primaryTeal),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Select Order
            const Text('اختر الطلب المرتبط بالبلاغ/الضمان *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            const SizedBox(height: 6),
            DropdownButtonFormField<OrderModel>(
              value: selectedOrder,
              style: const TextStyle(fontSize: 11, color: Colors.black87),
              items: AppRepository.sampleOrders.map((o) {
                return DropdownMenuItem(
                  value: o,
                  child: Text('${o.referenceNumber} - ${o.service.name}', style: const TextStyle(fontSize: 11)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => selectedOrder = val);
              },
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),

            const SizedBox(height: 12),

            // Select Issue Type
            const Text('نوع البلاغ / المطالبة *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: issueType,
              style: const TextStyle(fontSize: 11, color: Colors.black87),
              items: issueTypes.map((t) {
                return DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 11)));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => issueType = val);
              },
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),

            const SizedBox(height: 12),

            // Details text
            const Text('تفاصيل المشكلة والأدلة *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            const SizedBox(height: 6),
            TextField(
              controller: descriptionController,
              style: const TextStyle(fontSize: 11),
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'اكتب وصفاً تفصيلياً للمشكلة الحاصلة بعد تنفيذ الخدمة...',
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
                  const SnackBar(content: Text('تم إرفاق صورة العطل أو الإثبات للضمان', style: TextStyle(fontSize: 11))),
                );
              },
              icon: const Icon(Icons.attach_file, size: 16, color: AppTheme.primaryTeal),
              label: const Text('إرفاق صور أو مقطع فيديو توضيحي (Object Storage)', style: TextStyle(fontSize: 11)),
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
                child: const Text('إرسال التذكرة لفريق الدعم', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
