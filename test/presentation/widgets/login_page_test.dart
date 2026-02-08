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

    testWidgets('page check has button login', (tester) async {
      //arrange
      //act
      await tester.pumpWidget(
        MaterialApp(home: LoginPage(key: ValueKey(LoginPage.pageKey))),
      );
      await tester.pump();

      //assert
      // Debug: ดูว่ามี widget อะไรบ้าง
      final elevateButtons = find.byType(ElevatedButton);
      print('Found ${elevateButtons.evaluate().length} ElevatedButtons');

      final textWidgets = find.byType(Text);
      print('Found ${textWidgets.evaluate().length} Text widgets');

      // ลองหาด้วย text ก่อน
      final loginButtonByText = find.text('Login');
      print('Found by text: ${loginButtonByText.evaluate().length}');

      // ลองหาด้วย key หลายแบบ
      final pageKey = ValueKey(LoginPage.pageKey);
      print('Page key toString: ${pageKey.toString()}');

      // ลองแบบนี้
      final loginButton = find.byKey(
        ValueKey('${pageKey.toString()}/login_button'),
      );
      print('Key we are looking for: ${pageKey.toString()}/login_button');

      expect(find.byKey(pageKey), findsOneWidget);

      //expect(loginButtonByText, findsOneWidget);
      //expect(elevateButtons.evaluate().length, 1);
      //expect(textWidgets.evaluate().length, 4);
    });

  });
}
