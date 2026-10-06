import 'package:flutter_test/flutter_test.dart';
import 'package:untitled1/main.dart';

void main() {
  testWidgets('Sallih customer app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SallihCustomerApp());

    // Verify that the title appears
    expect(find.textContaining('صلّح'), findsWidgets);
  });
}
