import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/service_model.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/app_repository.dart';

class HomeCatalogScreen extends StatefulWidget {
  final Function(OrderModel) onOrderCreated;

  const HomeCatalogScreen({super.key, required this.onOrderCreated});

  @override
  State<HomeCatalogScreen> createState() => _HomeCatalogScreenState();
}

class _HomeCatalogScreenState extends State<HomeCatalogScreen> {
  String selectedCategoryId = 'all';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredServices = AppRepository.services.where((service) {
      final matchesCategory = selectedCategoryId == 'all' || service.categoryId == selectedCategoryId;
      final matchesQuery = service.name.contains(searchQuery) || service.description.contains(searchQuery);
      return matchesCategory && matchesQuery;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.handyman_rounded, color: AppTheme.primaryTeal, size: 20),
            SizedBox(width: 6),
            Text(
              'صلّح | SALLIH',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryTeal, fontSize: 16),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('لا توجد إشعارات جديدة حالياً', style: TextStyle(fontSize: 11))),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compact Welcome Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryTeal, AppTheme.secondaryTeal],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'أهلاً بك في منصة صلّح المعتمدة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'نضمن لك جودة التنفيذ وضمان الخدمة عبر فنيين ومؤسسات موثقة برقم نفاذ.',
                          style: TextStyle(color: Colors.white70, fontSize: 10.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.home_repair_service, color: Colors.white, size: 22),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Compact Search Bar
            SizedBox(
              height: 40,
              child: TextField(
                style: const TextStyle(fontSize: 12),
                onChanged: (val) => setState(() => searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'ابحث عن خدمة صيانة (سباكة، تكييف، كهرباء...)',
                  hintStyle: const TextStyle(fontSize: 11),
                  prefixIcon: const Icon(Icons.search, size: 18, color: AppTheme.primaryTeal),
                  filled: true,
                  fillColor: const Color(0xFFF1F3F5),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Categories horizontal list
            const Text(
              'التصنيفات الرئيسية',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryChip('all', 'الكل', Icons.grid_view),
                  ...AppRepository.categories.map((c) {
                    IconData iconData = Icons.construction;
                    if (c.iconName == 'plumbing') iconData = Icons.plumbing;
                    if (c.iconName == 'electric_bolt') iconData = Icons.electric_bolt;
                    if (c.iconName == 'ac_unit') iconData = Icons.ac_unit;
                    if (c.iconName == 'cleaning_services') iconData = Icons.cleaning_services;
                    if (c.iconName == 'format_paint') iconData = Icons.format_paint;
                    if (c.iconName == 'kitchen') iconData = Icons.kitchen;
                    return _buildCategoryChip(c.id, c.name, iconData);
                  }),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Service Items Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'الخدمات المتاحة للطلب',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${filteredServices.length} خدمة',
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (filteredServices.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Column(
                    children: const [
                      Icon(Icons.search_off, size: 36, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('لم نجد خدمات تطابق بحثك', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredServices.length,
                itemBuilder: (context, index) {
                  final service = filteredServices[index];
                  return _buildServiceCard(context, service);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String id, String label, IconData icon) {
    final isSelected = selectedCategoryId == id;
    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: FilterChip(
        selected: isSelected,
        showCheckmark: false,
        visualDensity: VisualDensity.compact,
        avatar: Icon(icon, size: 14, color: isSelected ? Colors.white : AppTheme.primaryTeal),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selectedColor: AppTheme.primaryTeal,
        backgroundColor: const Color(0xFFF1F3F5),
        onSelected: (_) => setState(() => selectedCategoryId = id),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, ServiceItem service) {
    Color badgeColor;
    String badgeText;

    switch (service.pricingType) {
      case PricingType.fixed:
        badgeColor = Colors.green[800]!;
        badgeText = 'سعر ثابت';
        break;
      case PricingType.range:
        badgeColor = Colors.orange[800]!;
        badgeText = 'نطاق سعر';
        break;
      case PricingType.requiredQuote:
        badgeColor = Colors.purple[800]!;
        badgeText = 'معاينة / عرض سعر';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    service.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              service.description,
              style: TextStyle(color: Colors.grey[700], fontSize: 11),
            ),
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('التكلفة المقدرة', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 2),
                    Text(
                      service.formattedPrice,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _showCreateOrderSheet(context, service),
                  icon: const Icon(Icons.add_task, size: 14),
                  label: const Text('طلب الخدمة', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateOrderSheet(BuildContext context, ServiceItem service) {
    final descriptionController = TextEditingController();
    CustomerAddress selectedAddress = AppRepository.addresses.first;
    bool isAutoMatching = true;
    bool isScheduled = false;
    DateTime scheduledDate = DateTime.now().add(const Duration(days: 1));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                top: 16,
                left: 16,
                right: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'طلب: ${service.name}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 6),

                    // Address Selector
                    const Text('العنوان وموقع الخدمة *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<CustomerAddress>(
                      value: selectedAddress,
                      style: const TextStyle(fontSize: 11, color: Colors.black87),
                      items: AppRepository.addresses.map((addr) {
                        return DropdownMenuItem(
                          value: addr,
                          child: Text('${addr.label} (${addr.fullAddress})', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedAddress = val);
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.location_on_outlined, size: 18, color: AppTheme.primaryTeal),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Problem description
                    const Text('وصف تفصيلي للمشكلة *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: descriptionController,
                      style: const TextStyle(fontSize: 11),
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'اكتب تفاصيل لمساعدة الفني في التشخيص والمعدات المطلوبة...',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Media Upload
                    const Text('إرفاق صور/فيديو للمشكلة (اختياري)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    const SizedBox(height: 6),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم اختيار صورة توضيحية للمشكلة', style: TextStyle(fontSize: 11))),
                        );
                      },
                      icon: const Icon(Icons.add_a_photo_outlined, size: 16),
                      label: const Text('رفع صورة من المعرض أو الكاميرا', style: TextStyle(fontSize: 11)),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 38),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Execution mode
                    SwitchListTile(
                      dense: true,
                      title: const Text('المطابقة التلقائية مع أسرع مؤسسة متاحة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      subtitle: const Text('سيقوم النظام باختيار التغطية الأنسب لمنطقتك', style: TextStyle(fontSize: 10)),
                      value: isAutoMatching,
                      activeThumbColor: AppTheme.primaryTeal,
                      onChanged: (val) => setModalState(() => isAutoMatching = val),
                    ),

                    // Schedule toggle
                    SwitchListTile(
                      dense: true,
                      title: const Text('جدولة الطلب لموعد لاحق', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      subtitle: Text(isScheduled ? 'الموعد: غداً الساعة 10:00 صباحاً' : 'طلب فوري الآن', style: const TextStyle(fontSize: 10)),
                      value: isScheduled,
                      activeThumbColor: AppTheme.primaryTeal,
                      onChanged: (val) => setModalState(() => isScheduled = val),
                    ),

                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryTeal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          if (descriptionController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('الرجاء إدخال وصف المشكلة', style: TextStyle(fontSize: 11))),
                            );
                            return;
                          }

                          final newOrder = OrderModel(
                            id: 'o_${DateTime.now().millisecondsSinceEpoch}',
                            referenceNumber: 'SAL-${(1000 + AppRepository.sampleOrders.length + 1)}',
                            service: service,
                            address: selectedAddress,
                            description: descriptionController.text.trim(),
                            status: OrderStatus.submitted,
                            createdAt: DateTime.now(),
                            scheduledFor: isScheduled ? scheduledDate : null,
                            organizationName: isAutoMatching ? null : 'مؤسسة الخدمة السريعة',
                          );

                          widget.onOrderCreated(newOrder);
                          Navigator.pop(sheetContext);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تم إنشاء الطلب بنجاح برقم ${newOrder.referenceNumber}', style: const TextStyle(fontSize: 11)),
                              backgroundColor: Colors.green[800],
                            ),
                          );
                        },
                        child: const Text(
                          'تأكيد وإرسال الطلب',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
