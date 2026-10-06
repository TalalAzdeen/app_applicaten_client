import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/order_model.dart';
import '../../chat/screens/order_chat_screen.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel order;
  final Function(OrderModel) onOrderUpdated;

  const OrderDetailsScreen({
    super.key,
    required this.order,
    required this.onOrderUpdated,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
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
      const SnackBar(content: Text('تم قبول عرض السعر بنجاح وتأكيد الاتفاقية', style: TextStyle(fontSize: 11))),
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
              const SnackBar(content: Text('شكراً لك! تم تسليم تقييمك بنجاح وقيد ضمان الخدمة.', style: TextStyle(fontSize: 11))),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.payment, size: 36, color: AppTheme.primaryTeal),
              const SizedBox(height: 8),
              Text(
                'سداد المكون المالي للطلب ${currentOrder.referenceNumber}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'المبلغ الإجمالي المعتمد: ${currentOrder.finalPrice ?? currentOrder.currentQuote?.totalAmount ?? 150} ر.س',
                style: const TextStyle(fontSize: 15, color: AppTheme.primaryTeal, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListTile(
                dense: true,
                leading: const Icon(Icons.credit_card, size: 20, color: Colors.blue),
                title: const Text('بطاقة مدى / ائتمان', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right, size: 18),
                onTap: () => _finishPayment(ctx),
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.account_balance_wallet, size: 20, color: Colors.green),
                title: const Text('المحفظة الإلكترونية (كاش باك)', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right, size: 18),
                onTap: () => _finishPayment(ctx),
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.money, size: 20, color: Colors.orange),
                title: const Text('دفع نقداً للفني', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right, size: 18),
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
        content: Text('تم الدفع وإصدار الإيصال بنجاح. تم تفعيل الكاش باك والضمان!', style: TextStyle(fontSize: 11)),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الطلب ${currentOrder.referenceNumber}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            _buildStatusHeader(),
            const SizedBox(height: 12),

            // Live Tracking Panel if EN_ROUTE or ARRIVED
            if (currentOrder.canTrackTechnician) _buildLiveTrackingPanel(),

            // Timeline Steps
            _buildTimelineSection(),
            const SizedBox(height: 12),

            // Organization & Technician Info
            if (currentOrder.organizationName != null) _buildTechnicianCard(),
            const SizedBox(height: 12),

            // Quote Section
            if (currentOrder.currentQuote != null) _buildQuoteSection(),
            const SizedBox(height: 12),

            // Order Details Card
            _buildOrderInfoCard(),
            const SizedBox(height: 12),

            // Actions (Chat, Pay, Review, Warranty)
            _buildActionsCard(),
            const SizedBox(height: 16),

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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor.withAlpha(60)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: statusColor,
            radius: 14,
            child: const Icon(Icons.info_outline, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('الحالة الحالية', style: TextStyle(fontSize: 10, color: Colors.grey)),
                const SizedBox(height: 1),
                Text(
                  statusText,
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: statusColor),
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
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
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
                    Icon(Icons.near_me, color: Colors.amber, size: 16),
                    SizedBox(width: 6),
                    Text('التتبع الحي لموقع الفني', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                Chip(
                  label: Text('مباشر Live', style: TextStyle(color: Colors.white, fontSize: 9)),
                  backgroundColor: Colors.red,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 90,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white24),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Text(
                      '🗺️ خريطة التتبع المباشر (Maps SDK)\nالفني يبعد 1.2 كم عن موقعك',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                      child: const Text('الوقت التقديري للوصول: 8 دقائق', style: TextStyle(color: Colors.white, fontSize: 9.5)),
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
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('مخطط متابعة الطلب (Timeline)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 12),
            Row(
              children: List.generate(statuses.length, (index) {
                final isPassed = currentIndex >= index;
                final isCurrent = currentIndex == index;
                return Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCurrent
                              ? AppTheme.primaryTeal
                              : (isPassed ? Colors.green : Colors.grey[300]),
                        ),
                        child: Icon(
                          isPassed ? Icons.check : Icons.circle,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                      if (index < statuses.length - 1)
                        Expanded(
                          child: Container(
                            height: 2,
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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppTheme.primaryTeal,
              radius: 16,
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentOrder.technicianName ?? 'الفني المكلف',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    currentOrder.organizationName ?? 'المؤسسة المنفذة',
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                ],
              ),
            ),
            if (currentOrder.canChat)
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline, color: AppTheme.primaryTeal, size: 20),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderChatScreen(
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
      ),
    );
  }

  Widget _buildQuoteSection() {
    final quote = currentOrder.currentQuote!;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: quote.isAccepted ? Colors.green : Colors.orange),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('عرض السعر المقدم (Quote)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Chip(
                  label: Text(quote.isAccepted ? 'تم القبول' : 'قيد الانتظار', style: const TextStyle(fontSize: 10)),
                  backgroundColor: quote.isAccepted ? Colors.green[100] : Colors.orange[100],
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('أجور أيدي العاملين:', style: TextStyle(fontSize: 11)),
                Text('${quote.laborFee.toStringAsFixed(2)} ر.س', style: const TextStyle(fontSize: 11)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('قطع الغيار والمواد:', style: TextStyle(fontSize: 11)),
                Text('${quote.sparePartsFee.toStringAsFixed(2)} ر.س', style: const TextStyle(fontSize: 11)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ضريبة القيمة المضافة (15%):', style: TextStyle(fontSize: 11)),
                Text('${quote.taxAmount.toStringAsFixed(2)} ر.س', style: const TextStyle(fontSize: 11)),
              ],
            ),
            const Divider(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الإجمالي الشامل:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(
                  '${quote.totalAmount.toStringAsFixed(2)} ر.س',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryTeal),
                ),
              ],
            ),
            if (!quote.isAccepted) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم رفض عرض السعر وإرجاع الطلب للبحث', style: TextStyle(fontSize: 11))),
                        );
                      },
                      child: const Text('رفض العرض', style: TextStyle(fontSize: 11)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryTeal,
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: _acceptQuote,
                      child: const Text('قبول عرض السعر', style: TextStyle(color: Colors.white, fontSize: 11)),
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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('تفاصيل الخدمة والموقع', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const Divider(height: 14),
            Text('الخدمة: ${currentOrder.service.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            const SizedBox(height: 4),
            Text('الوصف: ${currentOrder.description}', style: const TextStyle(fontSize: 11)),
            const SizedBox(height: 4),
            Text('العنوان: ${currentOrder.address.label} - ${currentOrder.address.fullAddress}', style: const TextStyle(fontSize: 11)),
            const SizedBox(height: 4),
            Text('تاريخ الطلب: ${currentOrder.createdAt.toString().split('.')[0]}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
            height: 38,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryTeal,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderChatScreen(
                      orderId: currentOrder.id,
                      referenceNumber: currentOrder.referenceNumber,
                      technicianName: currentOrder.technicianName ?? 'الفني',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.chat, size: 16),
              label: const Text('محادثة الفني والمؤسسة', style: TextStyle(fontSize: 11.5)),
            ),
          ),
        const SizedBox(height: 8),
        if (!currentOrder.isPaid && currentOrder.status != OrderStatus.cancelled)
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                foregroundColor: Colors.white,
              ),
              onPressed: _processPayment,
              icon: const Icon(Icons.payment, size: 16),
              label: const Text('الدفع الإلكتروني وإصدار الإيصال', style: TextStyle(fontSize: 11.5)),
            ),
          ),
        const SizedBox(height: 8),
        if (currentOrder.status == OrderStatus.completed && currentOrder.rating == null)
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton.icon(
              onPressed: _showRatingDialog,
              icon: const Icon(Icons.star_rate, color: Colors.amber, size: 16),
              label: const Text('إضافة تقييم للخدمة', style: TextStyle(fontSize: 11.5)),
            ),
          ),
      ],
    );
  }

  Widget _buildSimulationToolbar() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚙️ شريط محاكاة رحلة الطلب للتحقق من النظام:', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
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
      title: const Text('تقييم الخدمة والفني', textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('كيف كانت تجربتك مع تنفيذ الطلب؟', style: TextStyle(fontSize: 11)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  index < selectedRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 26,
                ),
                onPressed: () {
                  setState(() => selectedRating = (index + 1).toDouble());
                },
              );
            }),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: reviewController,
            style: const TextStyle(fontSize: 11),
            decoration: const InputDecoration(
              hintText: 'اكتب ملاحظاتك وتقييمك للفني والمؤسسة...',
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء', style: TextStyle(fontSize: 11)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
          onPressed: () {
            widget.onRatingSubmitted(selectedRating, reviewController.text.trim());
            Navigator.pop(context);
          },
          child: const Text('إرسال التقييم', style: TextStyle(color: Colors.white, fontSize: 11)),
        ),
      ],
    );
  }
}
