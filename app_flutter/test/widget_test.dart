import 'package:flutter_test/flutter_test.dart';
import 'package:frost_puno/app.dart';

void main() {
  testWidgets('renders FrostPuno home screen', (tester) async {
    await tester.pumpWidget(const FrostPunoApp());
    await tester.pump();

    expect(find.text('FrostPuno'), findsOneWidget);
    expect(find.text('Riesgo actual de helada'), findsOneWidget);
  });
}
