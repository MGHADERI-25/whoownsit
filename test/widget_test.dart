import 'package:flutter_test/flutter_test.dart';
import 'package:whoownsit/app/app.dart';

void main() {
  testWidgets('WhoOwnsIt app loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const WhoOwnsItApp());

    expect(find.text('WhoOwnsIt'), findsOneWidget);
    expect(find.text('Corporate ownership lookup starts here.'), findsOneWidget);
  });
}