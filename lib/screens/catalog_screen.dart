import 'package:flutter/material.dart';
import '../models/models.dart';
import '../data/mock_data.dart';

class CatalogScreen extends StatefulWidget {
  final Function(OrderModel) onOrderCreated;

  const CatalogScreen({super.key, required this.onOrderCreated});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
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
            Icon(Icons.handyman, color: Color(0xFF005F73)),
            SizedBox(width: 8),
            Text(
              'صلّح | SALLIH',
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF005F73)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('لا توجد إشعارات جديدة حالياً')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF005F73), Color(0xFF0A9396)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
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
                          'أهلاً بك في تطبيق صلّح',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'احصل على أفضل الفنيين والمؤسسات المعتمدة لصيانة منزلك فوراً وبأعلى جودة.',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.home_repair_service, color: Colors.white, size: 32),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Search Bar
            TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: 'ابحث عن خدمة (سباكة، تكييف، كهرباء...)',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF005F73)),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Categories horizontal list
            const Text(
              'التصنيفات الرئيسية',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
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
            const SizedBox(height: 24),

            // Service Items Grid / List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'الخدمات المتاحة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${filteredServices.length} خدمة',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (filteredServices.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: const [
                      Icon(Icons.search_off, size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('لم نجد خدمات تطابق بحثك', style: TextStyle(color: Colors.grey)),
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
      padding: const EdgeInsets.only(left: 8.0),
      child: FilterChip(
        selected: isSelected,
        showCheckmark: false,
        avatar: Icon(icon, size: 18, color: isSelected ? Colors.white : const Color(0xFF005F73)),
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selectedColor: const Color(0xFF005F73),
        backgroundColor: Colors.grey[100],
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
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    service.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              service.description,
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('التكلفة المقدرة', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 2),
                    Text(
                      service.formattedPrice,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF005F73),
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005F73),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _showCreateOrderSheet(context, service),
                  icon: const Icon(Icons.add_task, size: 18),
                  label: const Text('طلب الخدمة'),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 20,
                left: 20,
                right: 20,
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
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Address Selector
                    const Text('العنوان وموقع الخدمة *', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<CustomerAddress>(
                      value: selectedAddress,
                      items: AppRepository.addresses.map((addr) {
                        return DropdownMenuItem(
                          value: addr,
                          child: Text('${addr.label} (${addr.fullAddress})', overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedAddress = val);
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF005F73)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Problem description
                    const Text('وصف تفصيلي للمشكلة *', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'اكتب تفاصيل إضافية لمساعدة الفني في التشخيص والمعدات المطلوبة...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Media Upload Placeholder
                    const Text('إرفاق صور/فيديو للمشكلة (اختياري)', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم اختيار صورة توضيحية للمشكلة')),
                        );
                      },
                      icon: const Icon(Icons.add_a_photo_outlined),
                      label: const Text('رفع صورة من المعرض أو الكاميرا'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Execution mode (Auto match vs direct choice)
                    SwitchListTile(
                      title: const Text('المطابقة التلقائية مع أسرع مؤسسة متاحة'),
                      subtitle: const Text('سيقوم النظام باختيار التغطية الأنسب لمنطقتك'),
                      value: isAutoMatching,
                      activeThumbColor: const Color(0xFF005F73),
                      onChanged: (val) => setModalState(() => isAutoMatching = val),
                    ),

                    // Schedule toggle
                    SwitchListTile(
                      title: const Text('جدولة الطلب لموعد لاحق'),
                      subtitle: Text(isScheduled ? 'الموعد: غداً الساعة 10:00 صباحاً' : 'طلب فوري الآن'),
                      value: isScheduled,
                      activeThumbColor: const Color(0xFF005F73),
                      onChanged: (val) => setModalState(() => isScheduled = val),
                    ),

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005F73),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          if (descriptionController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('الرجاء إدخال وصف المشكلة')),
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
                              content: Text('تم إنشاء الطلب بنجاح برقم ${newOrder.referenceNumber}'),
                              backgroundColor: Colors.green[800],
                            ),
                          );
                        },
                        child: const Text(
                          'تأكيد وإرسال الطلب',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
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
