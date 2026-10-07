import 'package:flutter/material.dart';
import 'phrase_catalog.dart';

String translate(BuildContext context, String value) =>
    translateForLanguage(value, Localizations.localeOf(context).languageCode);

String translateForLanguage(String value, String language) {
  if (language != 'en') return value;
  final exact = phraseCatalog[value];
  if (exact != null) return exact;
  // Translate generated labels without changing user-entered text.
  const templates = <String, String>{
    r'^دقة الموقع: (.+) متر$': 'Reported accuracy: {0} metres',
    r'^الكل \((\d+)\)$': 'All ({0})',
    r'^الجارية \((\d+)\)$': 'Active ({0})',
    r'^المكتملة \((\d+)\)$': 'Completed ({0})',
    r'^(\d+) خدمة$': '{0} services',
    r'^رقم الطلب: (.+)$': 'Order: {0}',
    r'^الخدمة: (.+)$': 'Service: {0}',
    r'^الوصف: (.+)$': 'Description: {0}',
    r'^العنوان: (.+)$': 'Address: {0}',
    r'^تاريخ الطلب: (.+)$': 'Created: {0}',
    r'^تفاصيل الطلب (.+)$': 'Order details {0}',
    r'^محادثة الطلب (.+)$': 'Order chat {0}',
    r'^الفني: (.+)$': 'Technician: {0}',
    r'^طلب: (.+)$': 'Request: {0}',
    r'^تم إنشاء الطلب بنجاح برقم (.+)$': 'Local request created: {0}',
    r'^رقم الهوية: (.+)$': 'National ID: {0}',
    r'^ينتهي الطلب خلال: (.+)$': 'Expires in: {0}',
    r'^اختر الرقم \((.+)\) للموافقة وإكمال التوثيق\.$': 'Select code {0} to continue the demo.',
  };
  for (final entry in templates.entries) {
    final match = RegExp(entry.key).firstMatch(value);
    if (match != null) {
      var result = entry.value;
      for (var i = 1; i <= match.groupCount; i++) {
        result = result.replaceAll('{${i - 1}}',
            translateForLanguage(match.group(i)!, language));
      }
      return result;
    }
  }
  var result = value;
  // Named services and address labels may be embedded in generated summaries.
  final phrases = phraseCatalog.keys.toList()
    ..sort((a, b) => b.length.compareTo(a.length));
  for (final phrase in phrases) {
    result = result.replaceAll(phrase, phraseCatalog[phrase]!);
  }
  return result.replaceAll('ر.س', 'SAR');
}

/// Resolves labels during build, so const widgets react to locale changes.
class AppText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool? softWrap;
  final TextDirection? textDirection;
  final String? semanticsLabel;

  const AppText(this.data, {super.key, this.style, this.textAlign,
    this.overflow, this.maxLines, this.softWrap, this.textDirection,
    this.semanticsLabel});

  @override
  Widget build(BuildContext context) => Text(
    translate(context, data), style: style, textAlign: textAlign,
    overflow: overflow, maxLines: maxLines, softWrap: softWrap,
    textDirection: textDirection, semanticsLabel: semanticsLabel,
  );
}
