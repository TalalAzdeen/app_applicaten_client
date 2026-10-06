import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/service_model.dart';
import '../../../data/repositories/app_repository.dart';

class WalletAddressesScreen extends StatefulWidget {
  const WalletAddressesScreen({super.key});

  @override
  State<WalletAddressesScreen> createState() => _WalletAddressesScreenState();
}

class _WalletAddressesScreenState extends State<WalletAddressesScreen> {
  void _addNewAddress() {
    final labelCtrl = TextEditingController();
    final addressCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('إضافة عنوان جديد (customer_addresses)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelCtrl,
                style: const TextStyle(fontSize: 11),
                decoration: const InputDecoration(labelText: 'اسم العنوان (مثلاً: المنزل، الاستراحة)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: addressCtrl,
                style: const TextStyle(fontSize: 11),
                decoration: const InputDecoration(labelText: 'العنوان التفصيلي والحي'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(fontSize: 11)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
              onPressed: () {
                if (labelCtrl.text.isNotEmpty && addressCtrl.text.isNotEmpty) {
                  setState(() {
                    AppRepository.addresses.add(
                      CustomerAddress(
                        id: 'a_${DateTime.now().millisecondsSinceEpoch}',
                        label: labelCtrl.text.trim(),
                        fullAddress: addressCtrl.text.trim(),
                        latitude: 24.71,
                        longitude: 46.67,
                      ),
                    );
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تمت إضافة العنوان بنجاح وتحديده في الخريطة', style: TextStyle(fontSize: 11))),
                  );
                }
              },
              child: const Text('حفظ العنوان', style: TextStyle(color: Colors.white, fontSize: 11)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المحفظة والعناوين - SALLIH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compact Wallet Balance Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryTeal, AppTheme.secondaryTeal],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('رصيد المحفظة (customer_wallets)', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${AppRepository.walletBalance.toStringAsFixed(2)} ر.س',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white30, height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'مكافآت الكاش باك المكتسبة: ${AppRepository.cashbackEarned.toStringAsFixed(2)} ر.س',
                        style: const TextStyle(color: Colors.amberAccent, fontSize: 10.5, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('سيتم فتح شاشة شحن المحفظة', style: TextStyle(fontSize: 11))),
                          );
                        },
                        child: const Text('شحن المحفظة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Addresses Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('عناويني المسجلة (PostGIS)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                  onPressed: _addNewAddress,
                  icon: const Icon(Icons.add_location_alt, size: 16, color: AppTheme.primaryTeal),
                  label: const Text('إضافة عنوان', style: TextStyle(color: AppTheme.primaryTeal, fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ...AppRepository.addresses.map((addr) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: addr.isDefault ? AppTheme.primaryTeal : Colors.grey[300],
                    child: Icon(
                      Icons.location_on,
                      size: 16,
                      color: addr.isDefault ? Colors.white : Colors.grey[700],
                    ),
                  ),
                  title: Text(addr.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  subtitle: Text(addr.fullAddress, style: const TextStyle(fontSize: 10.5)),
                  trailing: addr.isDefault
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.teal[50], borderRadius: BorderRadius.circular(8)),
                          child: const Text('الافتراضي', style: TextStyle(fontSize: 9.5, color: AppTheme.primaryTeal, fontWeight: FontWeight.bold)),
                        )
                      : null,
                ),
              );
            }),

            const SizedBox(height: 18),

            // Recent Transactions
            const Text('سجل المعاملات المالية والكاش باك', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildTransactionTile('كاش باك مكتسب - طلب SAL-7732', '+15.00 ر.س', 'اليوم 10:30 ص', Colors.green),
            _buildTransactionTile('سداد طلب صيانة مكيفات SAL-9041', '-230.00 ر.س', 'أمس 04:15 م', Colors.black87),
            _buildTransactionTile('شحن المحفظة إلكترونياً', '+300.00 ر.س', '12 أكتوبر', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(String title, String amount, String date, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        title: Text(title, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
        subtitle: Text(date, style: TextStyle(fontSize: 9.5, color: Colors.grey[600])),
        trailing: Text(amount, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }
}
