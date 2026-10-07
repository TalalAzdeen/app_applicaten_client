import 'package:flutter/material.dart';
import '../../../core/localization/localized_text.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/service_model.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/app_repository.dart';
import '../../auth/services/auth_service.dart';
import '../../orders/services/order_service.dart';
import '../../../core/network/api_client.dart';

class HomeCatalogScreen extends StatefulWidget {
  final Function(OrderModel) onOrderCreated;

  const HomeCatalogScreen({super.key, required this.onOrderCreated});

  @override
  State<HomeCatalogScreen> createState() => _HomeCatalogScreenState();
}

class _HomeCatalogScreenState extends State<HomeCatalogScreen> {
  String selectedCategoryId = 'all';
  bool _submitting = false;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredServices = AppRepository.services.where((service) {
      final matchesCategory = selectedCategoryId == 'all' || service.categoryId == selectedCategoryId;
      final matchesQuery = [service.name, service.description, translate(context, service.name), translate(context, service.description)].any((value) => value.toLowerCase().contains(searchQuery.toLowerCase()));
      return matchesCategory && matchesQuery;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.handyman_rounded, color: AppTheme.primaryTeal, size: 20),
            SizedBox(width: 6),
            AppText(
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
                const SnackBar(content: AppText('لا توجد إشعارات جديدة حالياً', style: TextStyle(fontSize: 14))),
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
                        AppText(
                          'أهلاً بك في منصة صلّح المعتمدة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        AppText(
                          'نضمن لك جودة التنفيذ وضمان الخدمة عبر فنيين ومؤسسات موثقة برقم نفاذ.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
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
                style: const TextStyle(fontSize: 14),
                onChanged: (val) => setState(() => searchQuery = val),
                decoration: InputDecoration(
                  hintText: translate(context, 'ابحث عن خدمة صيانة (سباكة، تكييف، كهرباء...)'),
                  hintStyle: const TextStyle(fontSize: 14),
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
            const AppText(
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
                const AppText(
                  'الخدمات المتاحة للطلب',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                AppText(
                  '${filteredServices.length} خدمة',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
                      AppText('لم نجد خدمات تطابق بحثك', style: TextStyle(color: Colors.grey, fontSize: 14)),
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
        label: AppText(
          label,
          style: TextStyle(
            fontSize: 14,
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
                  child: AppText(
                    service.name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AppText(
                    badgeText,
                    style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            AppText(
              service.description,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText('التكلفة المقدرة', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 2),
                    AppText(
                      service.formattedPrice,
                      style: const TextStyle(
                        fontSize: 14,
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
                  label: const AppText('طلب الخدمة', style: TextStyle(fontSize: 14)),
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
    final live = AuthService.instance.authenticated;
    final localAddresses = AppRepository.addresses.where((address) => address.id.startsWith('local_')).toList();
    if (live && localAddresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: AppText('أضف عنوانًا حقيقيًا من صفحة العناوين قبل إنشاء الطلب.')));
      return;
    }
    CustomerAddress selectedAddress = live ? localAddresses.first : AppRepository.addresses.first;
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
                        AppText(
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
                    const AppText('العنوان وموقع الخدمة *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<CustomerAddress>(
                      value: selectedAddress,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                      items: (live ? localAddresses : AppRepository.addresses).map((addr) {
                        return DropdownMenuItem(
                          value: addr,
                          child: AppText('${addr.label} (${addr.fullAddress})', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
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
                    const AppText('وصف تفصيلي للمشكلة *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: descriptionController,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: translate(context, 'اكتب تفاصيل لمساعدة الفني في التشخيص والمعدات المطلوبة...'),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Media Upload
                    const AppText('إرفاق صور/فيديو للمشكلة (اختياري)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 6),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: AppText('إرفاق الصور غير متصل بعد.', style: TextStyle(fontSize: 14))),
                        );
                      },
                      icon: const Icon(Icons.add_a_photo_outlined, size: 16),
                      label: const AppText('رفع صورة من المعرض أو الكاميرا', style: TextStyle(fontSize: 14)),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 38),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Execution mode
                    SwitchListTile(
                      dense: true,
                      title: const AppText('المطابقة التلقائية مع أسرع مؤسسة متاحة', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      subtitle: const AppText('سيقوم النظام باختيار التغطية الأنسب لمنطقتك', style: TextStyle(fontSize: 12)),
                      value: isAutoMatching,
                      activeThumbColor: AppTheme.primaryTeal,
                      onChanged: (val) => setModalState(() => isAutoMatching = val),
                    ),

                    // Schedule toggle
                    SwitchListTile(
                      dense: true,
                      title: const AppText('جدولة الطلب لموعد لاحق', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      subtitle: AppText(isScheduled ? 'الموعد: غداً الساعة 10:00 صباحاً' : 'طلب فوري الآن', style: const TextStyle(fontSize: 12)),
                      value: isScheduled,
                      activeThumbColor: AppTheme.primaryTeal,
                      onChanged: AuthService.instance.authenticated ? null : (val) => setModalState(() => isScheduled = val),
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
                        onPressed: _submitting ? null : () async {
                          if (descriptionController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: AppText('الرجاء إدخال وصف المشكلة', style: TextStyle(fontSize: 14))),
                            );
                            return;
                          }

                          if (AuthService.instance.authenticated) {
                            setModalState(() => _submitting = true);
                            try {
                              final remoteOrder = await OrderService().create(service, selectedAddress, descriptionController.text.trim());
                              if (!mounted || !sheetContext.mounted) return;
                              widget.onOrderCreated(remoteOrder);
                              Navigator.pop(sheetContext);
                            } on ApiFailure catch (error) {
                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: AppText(error.message)));
                            } catch (_) {
                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: AppText('تعذر الاتصال. تحقق من الشبكة وأعد المحاولة.')));
                            } finally {
                              _submitting = false;
                              if (sheetContext.mounted) setModalState(() {});
                            }
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
                              content: AppText('طلب تجريبي محلي: ${newOrder.referenceNumber}', style: const TextStyle(fontSize: 14)),
                              backgroundColor: Colors.green[800],
                            ),
                          );
                        },
                        child: const AppText(
                          'تأكيد وإرسال الطلب',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
