import 'package:flutter_test/flutter_test.dart';
import 'package:untitled1/core/localization/localized_text.dart';

void main() {
  test('generated labels translate counts, prices and service names', () {
    expect(translateForLanguage('الجارية (3)', 'en'), 'Active (3)');
    expect(translateForLanguage('الخدمة: تركيب أدوات صحية', 'en'), 'Service: Bathroom fixture installation');
    expect(translateForLanguage('150 ر.س', 'en'), '150 SAR');
    expect(translateForLanguage('دقة الموقع: 12 متر', 'en'), 'Reported accuracy: 12 metres');
  });
  test('Arabic and unrelated user text are preserved', () {
    expect(translateForLanguage('تسجيل الدخول', 'ar'), 'تسجيل الدخول');
    expect(translateForLanguage('Apartment 27', 'en'), 'Apartment 27');
  });
}
