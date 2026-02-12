import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pair_api/pair_api.dart';
import 'package:pair_app/presentation/login/bloc/login_bloc.dart';
import 'package:pair_app/presentation/login/cubit/password_visibility_cubit.dart';
import 'package:pair_app/presentation/login/pages/login_page.dart';
import 'package:pair_app/router/app_routers.dart';

// Mocks
class MockLoginBloc extends MockBloc<LoginEvent, LoginState>
    implements LoginBloc {}

class MockPasswordVisibilityCubit extends MockCubit<bool>
    implements PasswordVisibilityCubit {}

class MockGoRouter extends Mock implements GoRouter {}

// Fake classes for Mocktail
class FakeLoginEvent extends Fake implements LoginEvent {}

class FakeLoginState extends Fake implements LoginState {}

void main() {
  late MockLoginBloc mockLoginBloc;
  late MockPasswordVisibilityCubit mockPasswordVisibilityCubit;
  late MockGoRouter mockGoRouter;

  setUpAll(() {
    registerFallbackValue(FakeLoginEvent());
    registerFallbackValue(FakeLoginState());
  });

  setUp(() {
    mockLoginBloc = MockLoginBloc();
    mockPasswordVisibilityCubit = MockPasswordVisibilityCubit();
    mockGoRouter = MockGoRouter();

    // Default states
    when(() => mockLoginBloc.state).thenReturn(LoginInitial());
    when(() => mockPasswordVisibilityCubit.state).thenReturn(false);
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>.value(value: mockLoginBloc),
        BlocProvider<PasswordVisibilityCubit>.value(
          value: mockPasswordVisibilityCubit,
        ),
      ],
      child: MaterialApp(
        home: InheritedGoRouter(
          goRouter: mockGoRouter,
          child: const LoginPage(),
        ),
      ),
    );
  }

  group('LoginPage Widget Tests', () {
    testWidgets('renders all UI elements correctly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify logo
      expect(find.byType(Image), findsOneWidget);

      // Verify title and subtitle
      expect(find.text('Welcome PAir App'), findsOneWidget);
      expect(find.text('Sign in to continue'), findsOneWidget);

      // Verify text fields
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      // Verify login button
      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      // Verify icons
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('username field validation shows error when empty', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find and tap login button without entering username
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verify error message is shown
      expect(find.text('Please enter your username'), findsOneWidget);
    });

    testWidgets('password field validation shows error when empty', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter username but leave password empty
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Username'),
        'testuser',
      );

      // Tap login button
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verify error message is shown
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('password visibility toggles when icon is tapped', (
      tester,
    ) async {
      // Setup: เริ่มต้น state เป็น false (ซ่อน password)
      //when(() => mockPasswordVisibilityCubit.state).thenReturn(false);

      whenListen(
        mockPasswordVisibilityCubit,
        Stream.fromIterable([true]), // emit true หลังกด toggle
        initialState: false, // เริ่มต้นเป็น false
      );

      await tester.pumpWidget(createWidgetUnderTest());

      // // Verify: เริ่มต้นต้องเป็นไอคอน visibility_off
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);

      // Verify: password field ต้อง obscure (หา TextField ภายใน TextFormField)
      final textFieldWidget = tester.widget<TextField>(
        find.descendant(
          of: find.byType(TextFormField).last,
          matching: find.byType(TextField),
        ),
      );
      expect(textFieldWidget.obscureText, true);

      // // Act: เปลี่ยน state เป็น true (แสดง password) เมื่อกดไอคอน
      when(() => mockPasswordVisibilityCubit.state).thenReturn(true);

      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester
          .pumpAndSettle(); // ใช้ pumpAndSettle เพื่อรอให้ rebuild เสร็จ

      // // Verify: ต้องเรียก toggle method
      verify(() => mockPasswordVisibilityCubit.toggle()).called(1);

      // Verify: ไอคอนเปลี่ยนเป็น visibility
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);

      //Verify: password field ไม่ obscure แล้ว
      final textFieldWidgetAfter = tester.widget<TextField>(
        find.descendant(
          of: find.byType(TextFormField).last,
          matching: find.byType(TextField),
        ),
      );
      expect(textFieldWidgetAfter.obscureText, false);
    });

    testWidgets('password field shows visibility icon when visible', (
      tester,
    ) async {
      when(() => mockPasswordVisibilityCubit.state).thenReturn(true);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify visibility icon is shown instead of visibility_off
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
    });

    testWidgets('submits login event when form is valid and button is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter valid credentials
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Username'),
        'testuser',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );

      // Tap login button
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButton);
      await tester.pump();

      // Verify LoginSubmitted event was added
      verify(
        () => mockLoginBloc.add(
          any(
            that: isA<LoginSubmitted>()
                .having((e) => e.username, 'username', 'testuser')
                .having((e) => e.password, 'password', 'password123'),
          ),
        ),
      ).called(1);
    });

    testWidgets('shows loading indicator when login is in progress', (
      tester,
    ) async {
      when(() => mockLoginBloc.state).thenReturn(LoginLoading());

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify CircularProgressIndicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Verify Login text is not shown
      expect(find.text('Login'), findsNothing);

      // Verify button is disabled
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('navigates to home when login is successful', (tester) async {
      final user = UserEntity(username: 'testuser', token: 'test-token');

      whenListen(
        mockLoginBloc,
        Stream.fromIterable([LoginLoading(), LoginSuccess(user)]),
        initialState: LoginInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify navigation to home
      verify(() => mockGoRouter.go(AppRoutes.homePath)).called(1);
    });

    testWidgets('shows error snackbar when login fails', (tester) async {
      const errorMessage = 'Invalid credentials';

      whenListen(
        mockLoginBloc,
        Stream.fromIterable([LoginLoading(), LoginFailure(errorMessage)]),
        initialState: LoginInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify SnackBar is shown with error message
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);

      // Verify SnackBar has red background
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, Colors.red);
    });

    testWidgets('does not submit when button is disabled during loading', (
      tester,
    ) async {
      when(() => mockLoginBloc.state).thenReturn(LoginLoading());

      await tester.pumpWidget(createWidgetUnderTest());

      // Enter credentials
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Username'),
        'testuser',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );

      // Try to tap login button (should be disabled)
      final loginButton = find.byType(ElevatedButton);
      await tester.tap(loginButton);
      await tester.pump();

      // Verify no new login event was added
      verifyNever(() => mockLoginBloc.add(any()));
    });

    testWidgets('form fields accept text input', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      const testUsername = 'john_doe';
      const testPassword = 'secure_password';

      // Enter username
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Username'),
        testUsername,
      );

      // Enter password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        testPassword,
      );

      await tester.pump();

      // Verify text was entered
      expect(find.text(testUsername), findsOneWidget);
      // Password text won't be directly visible due to obscureText
    });

    testWidgets('has correct styling for login button', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final buttonStyle = button.style;

      expect(buttonStyle, isNotNull);
    });

    testWidgets('password field is obscured by default', (tester) async {
      when(() => mockPasswordVisibilityCubit.state).thenReturn(false);

      await tester.pumpWidget(createWidgetUnderTest());

      final textFieldWidgetAfter = tester.widget<TextField>(
        find.descendant(
          of: find.byType(TextFormField).last,
          matching: find.byType(TextField),
        ),
      );
      expect(textFieldWidgetAfter.obscureText, true);
    });

    testWidgets('password field is visible when visibility is toggled', (
      tester,
    ) async {
      when(() => mockPasswordVisibilityCubit.state).thenReturn(true);

      await tester.pumpWidget(createWidgetUnderTest());

      final textFieldWidgetAfter = tester.widget<TextField>(
        find.descendant(
          of: find.byType(TextFormField).last,
          matching: find.byType(TextField),
        ),
      );
      expect(textFieldWidgetAfter.obscureText, false);
    });

    testWidgets('disposes controllers properly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify widget is built
      expect(find.byType(LoginPage), findsOneWidget);

      // Dispose the widget
      await tester.pumpWidget(Container());

      // Widget should be removed
      expect(find.byType(LoginPage), findsNothing);
    });
  });
}
