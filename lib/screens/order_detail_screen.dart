import 'package:flutter/material.dart';
import '../models/models.dart';
import 'chat_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;
  final Function(OrderModel) onOrderUpdated;

  const OrderDetailScreen({
    super.key,
    required this.order,
    required this.onOrderUpdated,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late OrderModel currentOrder;

  @override
  void initState() {
    super.initState();
    currentOrder = widget.order;
  }

  void _updateStatus(OrderStatus newStatus) {
    setState(() {
      currentOrder = OrderModel(
        id: currentOrder.id,
        referenceNumber: currentOrder.referenceNumber,
        service: currentOrder.service,
        address: currentOrder.address,
        description: currentOrder.description,
        status: newStatus,
        createdAt: currentOrder.createdAt,
        scheduledFor: currentOrder.scheduledFor,
        organizationName: currentOrder.organizationName ?? 'مؤسسة صيانة الرياض الفنية',
        technicianName: currentOrder.technicianName ?? 'سعد علي',
        technicianPhone: currentOrder.technicianPhone ?? '0551122334',
        currentQuote: currentOrder.currentQuote,
        isPaid: currentOrder.isPaid,
        finalPrice: currentOrder.finalPrice,
        rating: currentOrder.rating,
        reviewComment: currentOrder.reviewComment,
        hasWarranty: currentOrder.hasWarranty,
      );
    });
    widget.onOrderUpdated(currentOrder);
  }

  void _acceptQuote() {
    if (currentOrder.currentQuote == null) return;
    setState(() {
      final updatedQuote = QuoteModel(
        id: currentOrder.currentQuote!.id,
        orderId: currentOrder.currentQuote!.orderId,
        organizationName: currentOrder.currentQuote!.organizationName,
        laborFee: currentOrder.currentQuote!.laborFee,
        sparePartsFee: currentOrder.currentQuote!.sparePartsFee,
        taxAmount: currentOrder.currentQuote!.taxAmount,
        totalAmount: currentOrder.currentQuote!.totalAmount,
        isAccepted: true,
        createdAt: currentOrder.currentQuote!.createdAt,
      );

      currentOrder = OrderModel(
        id: currentOrder.id,
        referenceNumber: currentOrder.referenceNumber,
        service: currentOrder.service,
        address: currentOrder.address,
        description: currentOrder.description,
        status: currentOrder.status == OrderStatus.submitted ? OrderStatus.assigned : currentOrder.status,
        createdAt: currentOrder.createdAt,
        scheduledFor: currentOrder.scheduledFor,
        organizationName: currentOrder.organizationName,
        technicianName: currentOrder.technicianName,
        technicianPhone: currentOrder.technicianPhone,
        currentQuote: updatedQuote,
        isPaid: currentOrder.isPaid,
        finalPrice: updatedQuote.totalAmount,
        rating: currentOrder.rating,
        reviewComment: currentOrder.reviewComment,
        hasWarranty: currentOrder.hasWarranty,
      );
    });
    widget.onOrderUpdated(currentOrder);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم قبول عرض السعر بنجاح وتأكيد الاتفاقية')),
    );
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return _RatingDialog(
          onRatingSubmitted: (rating, comment) {
            setState(() {
              currentOrder = OrderModel(
                id: currentOrder.id,
                referenceNumber: currentOrder.referenceNumber,
                service: currentOrder.service,
                address: currentOrder.address,
                description: currentOrder.description,
                status: currentOrder.status,
                createdAt: currentOrder.createdAt,
                scheduledFor: currentOrder.scheduledFor,
                organizationName: currentOrder.organizationName,
                technicianName: currentOrder.technicianName,
                technicianPhone: currentOrder.technicianPhone,
                currentQuote: currentOrder.currentQuote,
                isPaid: currentOrder.isPaid,
                finalPrice: currentOrder.finalPrice,
                rating: rating,
                reviewComment: comment,
                hasWarranty: true,
              );
            });
            widget.onOrderUpdated(currentOrder);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('شكراً لك! تم تسليم تقييمك بنجاح وقيد ضمان الخدمة.')),
            );
          },
        );
      },
    );
  }

  void _processPayment() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.payment, size: 48, color: Color(0xFF005F73)),
              const SizedBox(height: 12),
              Text(
                'سداد المكون المالي للطلب ${currentOrder.referenceNumber}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'المبلغ الإجمالي المعتمد: ${currentOrder.finalPrice ?? currentOrder.currentQuote?.totalAmount ?? 150} ر.س',
                style: const TextStyle(fontSize: 18, color: Color(0xFF005F73), fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.credit_card, color: Colors.blue),
                title: const Text('بطاقة مدى / ائتمان'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _finishPayment(ctx),
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet, color: Colors.green),
                title: const Text('المحفظة الإلكترونية (كاش باك)'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _finishPayment(ctx),
              ),
              ListTile(
                leading: const Icon(Icons.money, color: Colors.orange),
                title: const Text('دفع نقداً للفني'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _finishPayment(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  void _finishPayment(BuildContext modalCtx) {
    Navigator.pop(modalCtx);
    setState(() {
      currentOrder = OrderModel(
        id: currentOrder.id,
        referenceNumber: currentOrder.referenceNumber,
        service: currentOrder.service,
        address: currentOrder.address,
        description: currentOrder.description,
        status: OrderStatus.completed,
        createdAt: currentOrder.createdAt,
        scheduledFor: currentOrder.scheduledFor,
        organizationName: currentOrder.organizationName,
        technicianName: currentOrder.technicianName,
        technicianPhone: currentOrder.technicianPhone,
        currentQuote: currentOrder.currentQuote,
        isPaid: true,
        finalPrice: currentOrder.finalPrice ?? 150.0,
        rating: currentOrder.rating,
        reviewComment: currentOrder.reviewComment,
        hasWarranty: true,
      );
    });
    widget.onOrderUpdated(currentOrder);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم الدفع وإصدار الإيصال بنجاح. تم تفعيل الكاش باك والضمان!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الطلب ${currentOrder.referenceNumber}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            _buildStatusHeader(),
            const SizedBox(height: 16),

            // Live Tracking Panel if EN_ROUTE or ARRIVED
            if (currentOrder.canTrackTechnician) _buildLiveTrackingPanel(),

            // Timeline Steps
            _buildTimelineSection(),
            const SizedBox(height: 16),

            // Organization & Technician Info
            if (currentOrder.organizationName != null) _buildTechnicianCard(),
            const SizedBox(height: 16),

            // Quote Section
            if (currentOrder.currentQuote != null) _buildQuoteSection(),
            const SizedBox(height: 16),

            // Order Details Card
            _buildOrderInfoCard(),
            const SizedBox(height: 16),

            // Actions (Chat, Pay, Review, Warranty)
            _buildActionsCard(),
            const SizedBox(height: 24),

            // Demo status simulation toolbar
            _buildSimulationToolbar(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    String statusText;
    Color statusColor;

    switch (currentOrder.status) {
      case OrderStatus.submitted:
        statusText = 'مُرسل (قيد المراجعة)';
        statusColor = Colors.blue;
        break;
      case OrderStatus.searching:
        statusText = 'جارٍ البحث عن أفضل مؤسسة وفني';
        statusColor = Colors.orange;
        break;
      case OrderStatus.assigned:
        statusText = 'تم قبول الطلب وتعيين المنفذ';
        statusColor = Colors.teal;
        break;
      case OrderStatus.enRoute:
        statusText = 'الفني في الطريق إليك الآن (تتبع حي)';
        statusColor = Colors.deepOrange;
        break;
      case OrderStatus.arrived:
        statusText = 'وصل الفني إلى الموقع';
        statusColor = Colors.indigo;
        break;
      case OrderStatus.inProgress:
        statusText = 'الخدمة قيد التنفيذ والعمل';
        statusColor = Colors.purple;
        break;
      case OrderStatus.completed:
        statusText = 'اكتملت الخدمة بنجاح';
        statusColor = Colors.green;
        break;
      case OrderStatus.cancelled:
        statusText = 'تم إلغاء الطلب';
        statusColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withAlpha(80)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: statusColor,
            radius: 18,
            child: const Icon(Icons.info_outline, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('الحالة الحالية', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(
                  statusText,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: statusColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveTrackingPanel() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.blue[900]!, Colors.blue[700]!],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Row(
                  children: [
                    Icon(Icons.near_me, color: Colors.amber, size: 20),
                    SizedBox(width: 8),
                    Text('التتبع الحي لموقع الفني', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                Chip(
                  label: Text('مباشر Live', style: TextStyle(color: Colors.white, fontSize: 10)),
                  backgroundColor: Colors.red,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Text(
                      '🗺️ خريطة التتبع المباشر (Maps SDK)\nالفني يبعد 1.2 كم عن موقعك',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                      child: const Text('الوقت التقديري للوصول: 8 دقائق', style: TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSection() {
    final statuses = [
      OrderStatus.submitted,
      OrderStatus.searching,
      OrderStatus.assigned,
      OrderStatus.enRoute,
      OrderStatus.inProgress,
      OrderStatus.completed,
    ];

    final currentIndex = statuses.indexOf(currentOrder.status);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('مخطط متابعة الطلب (Timeline)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              children: List.generate(statuses.length, (index) {
                final isPassed = currentIndex >= index;
                final isCurrent = currentIndex == index;
                return Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCurrent
                              ? const Color(0xFF005F73)
                              : (isPassed ? Colors.green : Colors.grey[300]),
                        ),
                        child: Icon(
                          isPassed ? Icons.check : Icons.circle,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                      if (index < statuses.length - 1)
                        Expanded(
                          child: Container(
                            height: 3,
                            color: isPassed ? Colors.green : Colors.grey[300],
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicianCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFF005F73),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentOrder.technicianName ?? 'الفني المكلف',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        currentOrder.organizationName ?? 'المؤسسة المنفذة',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (currentOrder.canChat)
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF005F73)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            orderId: currentOrder.id,
                            referenceNumber: currentOrder.referenceNumber,
                            technicianName: currentOrder.technicianName ?? 'الفني',
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteSection() {
    final quote = currentOrder.currentQuote!;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: quote.isAccepted ? Colors.green : Colors.orange),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('عرض السعر المقدم (Quote)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Chip(
                  label: Text(quote.isAccepted ? 'تم القبول' : 'قيد الانتظار'),
                  backgroundColor: quote.isAccepted ? Colors.green[100] : Colors.orange[100],
                  labelStyle: TextStyle(
                    color: quote.isAccepted ? Colors.green[900] : Colors.orange[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('أجور أيدي العاملين:'),
                Text('${quote.laborFee.toStringAsFixed(2)} ر.س'),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('قطع الغيار والمواد:'),
                Text('${quote.sparePartsFee.toStringAsFixed(2)} ر.س'),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ضريبة القيمة المضافة (15%):'),
                Text('${quote.taxAmount.toStringAsFixed(2)} ر.س'),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الإجمالي الشامل:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  '${quote.totalAmount.toStringAsFixed(2)} ر.س',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF005F73)),
                ),
              ],
            ),
            if (!quote.isAccepted) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم رفض عرض السعر وإرجاع الطلب للبحث')),
                        );
                      },
                      child: const Text('رفض العرض'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005F73)),
                      onPressed: _acceptQuote,
                      child: const Text('قبول عرض السعر', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('تفاصيل الخدمة والموقع', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            Text('الخدمة: ${currentOrder.service.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('الوصف: ${currentOrder.description}'),
            const SizedBox(height: 6),
            Text('العنوان: ${currentOrder.address.label} - ${currentOrder.address.fullAddress}'),
            const SizedBox(height: 6),
            Text('تاريخ الطلب: ${currentOrder.createdAt.toString().split('.')[0]}'),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard() {
    return Column(
      children: [
        if (currentOrder.canChat)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A9396),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      orderId: currentOrder.id,
                      referenceNumber: currentOrder.referenceNumber,
                      technicianName: currentOrder.technicianName ?? 'الفني',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.chat),
              label: const Text('محادثة الفني والمؤسسة'),
            ),
          ),
        const SizedBox(height: 10),
        if (!currentOrder.isPaid && currentOrder.status != OrderStatus.cancelled)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _processPayment,
              icon: const Icon(Icons.payment),
              label: const Text('الدفع الإلكتروني وإصدار الإيصال'),
            ),
          ),
        const SizedBox(height: 10),
        if (currentOrder.status == OrderStatus.completed && currentOrder.rating == null)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
              onPressed: _showRatingDialog,
              icon: const Icon(Icons.star_rate, color: Colors.amber),
              label: const Text('إضافة تقييم للخدمة'),
            ),
          ),
      ],
    );
  }

  Widget _buildSimulationToolbar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚙️ شريط محاكاة رحلة الطلب للتحقق من النظام:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _simButton('جارٍ البحث', () => _updateStatus(OrderStatus.searching)),
              _simButton('تعيين الفني', () => _updateStatus(OrderStatus.assigned)),
              _simButton('في الطريق (تتبع)', () => _updateStatus(OrderStatus.enRoute)),
              _simButton('وصل الفني', () => _updateStatus(OrderStatus.arrived)),
              _simButton('قيد التنفيذ', () => _updateStatus(OrderStatus.inProgress)),
              _simButton('إكمال وتجهيز الفاتورة', () => _updateStatus(OrderStatus.completed)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _simButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _RatingDialog extends StatefulWidget {
  final Function(double rating, String comment) onRatingSubmitted;

  const _RatingDialog({required this.onRatingSubmitted});

  @override
  State<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog> {
  double selectedRating = 5.0;
  final reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تقييم الخدمة والفني', textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('كيف كانت تجربتك مع تنفيذ الطلب؟'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < selectedRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
                onPressed: () {
                  setState(() => selectedRating = (index + 1).toDouble());
                },
              );
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: reviewController,
            decoration: const InputDecoration(
              hintText: 'اكتب ملاحظاتك وتقييمك للفني والمؤسسة...',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005F73)),
          onPressed: () {
            widget.onRatingSubmitted(selectedRating, reviewController.text.trim());
            Navigator.pop(context);
          },
          child: const Text('إرسال التقييم', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
