import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/models.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  void _addNewAddress() {
    final labelCtrl = TextEditingController();
    final addressCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('إضافة عنوان جديد (customer_addresses)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelCtrl,
                decoration: const InputDecoration(labelText: 'اسم العنوان (مثلاً: المنزل، الاستراحة)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(labelText: 'العنوان التفصيلي والحي'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005F73)),
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
                    const SnackBar(content: Text('تمت إضافة العنوان بنجاح وتحديده في الخريطة')),
                  );
                }
              },
              child: const Text('حفظ العنوان', style: TextStyle(color: Colors.white)),
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
        title: const Text('المحفظة والعناوين - SALLIH', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wallet Balance Card
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
                  BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('رصيد المحفظة (customer_wallets)', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      Icon(Icons.account_balance_wallet, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${AppRepository.walletBalance.toStringAsFixed(2)} ر.س',
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'مكافآت الكاش باك المكتسبة: ${AppRepository.cashbackEarned.toStringAsFixed(2)} ر.س',
                        style: const TextStyle(color: Colors.amberAccent, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('سيتم فتح شاشة شحن المحفظة')),
                          );
                        },
                        child: const Text('شحن المحفظة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Addresses Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('عناويني المسجلة (PostGIS)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: _addNewAddress,
                  icon: const Icon(Icons.add_location_alt, size: 18, color: Color(0xFF005F73)),
                  label: const Text('إضافة عنوان', style: TextStyle(color: Color(0xFF005F73))),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ...AppRepository.addresses.map((addr) {
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: addr.isDefault ? const Color(0xFF005F73) : Colors.grey[300],
                    child: Icon(
                      Icons.location_on,
                      color: addr.isDefault ? Colors.white : Colors.grey[700],
                    ),
                  ),
                  title: Text(addr.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(addr.fullAddress),
                  trailing: addr.isDefault
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.teal[50], borderRadius: BorderRadius.circular(10)),
                          child: const Text('الافتراضي', style: TextStyle(fontSize: 11, color: Color(0xFF005F73))),
                        )
                      : null,
                ),
              );
            }),

            const SizedBox(height: 24),

            // Recent Transactions
            const Text('سجل المعاملات المالية والكاش باك', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
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
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(date, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        trailing: Text(amount, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
      ),
    );
  }
}
