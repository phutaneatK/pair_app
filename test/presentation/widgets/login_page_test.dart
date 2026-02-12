import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pair_app/presentation/widgets/login_page.dart';

void main() {
  group('widget login_page test', () {
    testWidgets('login page check click alert show button', (tester) async {
      //arrange
      await tester.pumpWidget(
        MaterialApp(home: LoginPage(key: ValueKey(LoginPage.pageKey))),
      );
      await tester.pump();

      //act
      // หาปุ่ม login
      final loginButton = find.byKey(Key('login_button'));
      expect(loginButton, findsOneWidget);

      // กดปุ่ม login
      await tester.tap(loginButton);
      await tester.pumpAndSettle(); // รอให้ animation ของ dialog เสร็จ

      //assert
      // เช็คว่ามี AlertDialog ขึ้นมา
      expect(find.byType(AlertDialog), findsOneWidget);

      // เช็คว่ามีข้อความ "สวัสดี" ใน dialog
      expect(find.text('สวัสดี'), findsOneWidget);
      expect(find.text('ยินดีต้อนรับ!'), findsOneWidget);

      // เช็คว่ามีปุ่ม "ตกลง"
      expect(find.text('ตกลง'), findsOneWidget);

      // (Optional) ทดสอบปิด dialog
      await tester.tap(find.text('ตกลง'));
      await tester.pumpAndSettle();

      // เช็คว่า dialog หายไป
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
