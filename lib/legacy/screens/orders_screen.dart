import 'package:flutter/material.dart';
import '../models/models.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  final List<OrderModel> orders;
  final Function(OrderModel) onOrderUpdated;

  const OrdersScreen({
    super.key,
    required this.orders,
    required this.onOrderUpdated,
  });

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeOrders = widget.orders.where((o) => o.status != OrderStatus.completed && o.status != OrderStatus.cancelled).toList();
    final completedOrders = widget.orders.where((o) => o.status == OrderStatus.completed).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('طلباتي - صلّح', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF005F73),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF005F73),
          tabs: [
            Tab(text: 'الكل (${widget.orders.length})'),
            Tab(text: 'الجارية (${activeOrders.length})'),
            Tab(text: 'المكتملة (${completedOrders.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(widget.orders),
          _buildOrderList(activeOrders),
          _buildOrderList(completedOrders),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.assignment_outlined, size: 60, color: Colors.grey),
            SizedBox(height: 12),
            Text('لا توجد طلبات في هذه القائمة حالياً', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final order = list[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    Color badgeColor;
    String badgeText;

    switch (order.status) {
      case OrderStatus.submitted:
        badgeColor = Colors.blue;
        badgeText = 'مُرسل';
        break;
      case OrderStatus.searching:
        badgeColor = Colors.orange;
        badgeText = 'جارٍ البحث';
        break;
      case OrderStatus.assigned:
        badgeColor = Colors.teal;
        badgeText = 'تم المعاينة';
        break;
      case OrderStatus.enRoute:
        badgeColor = Colors.deepOrange;
        badgeText = 'في الطريق 📍';
        break;
      case OrderStatus.arrived:
        badgeColor = Colors.indigo;
        badgeText = 'وصل الفني';
        break;
      case OrderStatus.inProgress:
        badgeColor = Colors.purple;
        badgeText = 'قيد التنفيذ';
        break;
      case OrderStatus.completed:
        badgeColor = Colors.green;
        badgeText = 'مكتمل';
        break;
      case OrderStatus.cancelled:
        badgeColor = Colors.red;
        badgeText = 'ملغي';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailScreen(
                order: order,
                onOrderUpdated: widget.onOrderUpdated,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'رقم الطلب: ${order.referenceNumber}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'الخدمة: ${order.service.name}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                order.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(order.address.label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  Row(
                    children: const [
                      Text(
                        'التفاصيل والخيارات',
                        style: TextStyle(color: Color(0xFF005F73), fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF005F73)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
