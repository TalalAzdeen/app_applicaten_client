import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/localization/localized_text.dart';
import '../../../data/models/service_model.dart';
import '../../../data/repositories/app_repository.dart';
import '../../location/screens/location_picker_screen.dart';
import '../../location/services/address_store.dart';

class WalletAddressesScreen extends StatefulWidget {
  const WalletAddressesScreen({super.key});
  @override
  State<WalletAddressesScreen> createState() => _WalletAddressesScreenState();
}

class _WalletAddressesScreenState extends State<WalletAddressesScreen> {
  bool _saving = false;

  Future<void> _addNewAddress() async {
    final selected = await Navigator.push<SelectedLocation>(context,
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()));
    if (!mounted || selected == null) return;
    final label = TextEditingController();
    final details = TextEditingController();
    final form = GlobalKey<FormState>();
    final address = await showDialog<CustomerAddress>(context: context, builder: (dialogContext) => AlertDialog(
      title: const AppText('إضافة عنوان'),
      content: SizedBox(width: 400, child: Form(key: form, child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: label, maxLength: 100,
          decoration: InputDecoration(labelText: translate(context, 'اسم العنوان')),
          validator: (value) => value?.trim().isNotEmpty == true ? null : translate(context, 'هذا الحقل مطلوب')),
        const SizedBox(height: 12),
        TextFormField(controller: details, maxLength: 500, maxLines: 3,
          decoration: InputDecoration(labelText: translate(context, 'العنوان التفصيلي والحي')),
          validator: (value) => value?.trim().isNotEmpty == true ? null : translate(context, 'هذا الحقل مطلوب')),
      ]))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const AppText('إلغاء')),
        FilledButton(onPressed: () {
          if (form.currentState!.validate()) Navigator.pop(dialogContext, CustomerAddress(
            id: 'local_${DateTime.now().microsecondsSinceEpoch}', label: label.text.trim(), fullAddress: details.text.trim(),
            latitude: selected.coordinates.latitude, longitude: selected.coordinates.longitude,
            accuracyMeters: selected.accuracyMeters,
          ));
        }, child: const AppText('حفظ العنوان')),
      ],
    ));
    // The dialog's closing animation still uses the fields; dispose after it ends.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    label.dispose(); details.dispose();
    if (!mounted || address == null) return;
    setState(() => _saving = true);
    try {
      final local = AppRepository.addresses.where((entry) => entry.id.startsWith('local_')).toList()..add(address);
      await AddressStore().save(local);
      if (!mounted) return;
      setState(() => AppRepository.addresses.add(address));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: AppText('تم حفظ العنوان على هذا الجهاز.')));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: AppText('تعذر حفظ العنوان. أعد المحاولة.')));
    } finally { if (mounted) setState(() => _saving = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const AppText('المحفظة والعناوين')),
    body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760),
      child: ListView(padding: const EdgeInsets.all(24), children: [
        Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, const Color(0xFF0A9396)]),
          borderRadius: BorderRadius.circular(24)),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.shield_outlined, color: Colors.white, size: 36),
            SizedBox(height: 16),
            AppText('الدفع مقابل الخدمة', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            AppText('ادفع من صفحة تفاصيل الطلب عبر مزود دفع آمن. شحن المحفظة غير متاح حاليًا.',
              style: TextStyle(color: Colors.white, fontSize: 16)),
          ])),
        const SizedBox(height: 24),
        Row(children: [
          const Expanded(child: AppText('عناويني المسجلة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
          IconButton(onPressed: _saving ? null : _addNewAddress, tooltip: translate(context, 'إضافة عنوان'),
            icon: const Icon(Icons.add_location_alt_outlined)),
        ]),
        const AppText('العناوين محفوظة على هذا الجهاز. العناوين الافتراضية بيانات توضيحية.'),
        const SizedBox(height: 16),
        if (_saving) const LinearProgressIndicator(),
        ...AppRepository.addresses.map((address) => Card(margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(contentPadding: const EdgeInsets.all(16),
            leading: Icon(Icons.location_on_outlined, color: Theme.of(context).colorScheme.primary),
            title: AppText(address.label, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: AppText(address.fullAddress),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push<SelectedLocation>(context, MaterialPageRoute(builder: (_) =>
              LocationPickerScreen(readOnly: true, initialPosition: LatLng(address.latitude, address.longitude)))),
          ))),
        const SizedBox(height: 12),
        OutlinedButton.icon(onPressed: _saving ? null : _addNewAddress, icon: const Icon(Icons.add), label: const AppText('إضافة عنوان')),
      ]))),
  );
}
