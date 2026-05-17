import 'package:car_rental_appp/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows the home screen actions', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('RentFlow'), findsOneWidget);
    expect(find.text('Drive the car that fits your day.'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Create an Account'), findsOneWidget);
  });
}
