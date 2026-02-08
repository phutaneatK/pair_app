import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pair_app/presentation/login/cubit/password_visibility_cubit.dart';

/// 🧪 Unit Test สำหรับ PasswordVisibilityCubit
/// 
/// Cubit นี้มีหน้าที่จัดการ state ของการแสดง/ซ่อน password
/// - Initial state: false (ซ่อนรหัสผ่าน)
/// - show(): เปลี่ยนเป็น true
/// - hide(): เปลี่ยนเป็น false
/// - toggle(): สลับค่า true/false
void main() {
  group('PasswordVisibilityCubit', () {
    
    // ===== Test 1: ตรวจสอบ Initial State =====
    // ✅ เช็คว่าค่าเริ่มต้นต้องเป็น false (ซ่อนรหัสผ่านก่อน)
    test('initial state should be false (password hidden)', () {
      final cubit = PasswordVisibilityCubit();
      
      // Assert: ตรวจสอบว่า state เริ่มต้นเป็น false
      expect(cubit.state, false);
      
      // Clean up: ปิด cubit หลังใช้งาน
      cubit.close();
    });

    // ===== Test 2: ทดสอบ show() method =====
    // ✅ เมื่อเรียก show() ต้องเปลี่ยน state เป็น true
    blocTest<PasswordVisibilityCubit, bool>(
      'show() should emit true',
      
      // Build: สร้าง cubit instance
      build: () => PasswordVisibilityCubit(),
      
      // Act: เรียก show() method
      act: (cubit) => cubit.show(),
      
      // Expect: คาดหวังว่าจะ emit state เป็น [true]
      expect: () => [true],
    );

    // ===== Test 3: ทดสอบ hide() method =====
    // ✅ เมื่อเรียก hide() ต้องเปลี่ยน state เป็น false
    blocTest<PasswordVisibilityCubit, bool>(
      'hide() should emit false',
      
      build: () => PasswordVisibilityCubit(),
      
      // Seed: กำหนด initial state เป็น true ก่อน
      seed: () => true,
      
      // Act: เรียก hide() method
      act: (cubit) => cubit.hide(),
      
      // Expect: คาดหวังว่าจะ emit state เป็น [false]
      expect: () => [false],
    );

    // ===== Test 4: ทดสอบ toggle() - false to true =====
    // ✅ toggle() จาก false → true
    blocTest<PasswordVisibilityCubit, bool>(
      'toggle() should emit true when current state is false',
      
      build: () => PasswordVisibilityCubit(),
      
      // Seed: initial state = false (default)
      
      // Act: เรียก toggle()
      act: (cubit) => cubit.toggle(),
      
      // Expect: สลับจาก false → true
      expect: () => [true],
    );

    // ===== Test 5: ทดสอบ toggle() - true to false =====
    // ✅ toggle() จาก true → false
    blocTest<PasswordVisibilityCubit, bool>(
      'toggle() should emit false when current state is true',
      
      build: () => PasswordVisibilityCubit(),
      
      // Seed: กำหนด initial state เป็น true
      seed: () => true,
      
      // Act: เรียก toggle()
      act: (cubit) => cubit.toggle(),
      
      // Expect: สลับจาก true → false
      expect: () => [false],
    );

    // ===== Test 6: ทดสอบ toggle() หลายครั้งติดกัน =====
    // ✅ toggle() 3 ครั้ง: false → true → false → true
    blocTest<PasswordVisibilityCubit, bool>(
      'toggle() multiple times should alternate states',
      
      build: () => PasswordVisibilityCubit(),
      
      // Act: toggle() 3 ครั้ง
      act: (cubit) {
        cubit.toggle(); // false → true
        cubit.toggle(); // true → false
        cubit.toggle(); // false → true
      },
      
      // Expect: ลำดับ state ที่ emit ออกมา
      expect: () => [
        true,   // ครั้งที่ 1
        false,  // ครั้งที่ 2
        true,   // ครั้งที่ 3
      ],
    );

    // ===== Test 7: ทดสอบ State Consistency =====
    // ✅ เรียก show() แล้วตามด้วย hide() ต้องกลับเป็น false
    blocTest<PasswordVisibilityCubit, bool>(
      'show() then hide() should return to false',
      
      build: () => PasswordVisibilityCubit(),
      
      // Act: show() แล้วตาม hide()
      act: (cubit) {
        cubit.show();
        cubit.hide();
      },
      
      // Expect: [true, false]
      expect: () => [true, false],
    );

    // ===== Test 8: Verify method เรียกซ้ำ =====
    // ✅ เรียก show() 2 ครั้งติดกัน ต้อง emit true แค่ครั้งเดียว
    // (เพราะ Cubit ไม่ emit ซ้ำถ้า state เหมือนเดิม)
    blocTest<PasswordVisibilityCubit, bool>(
      'calling show() twice should emit true only once',
      
      build: () => PasswordVisibilityCubit(),
      
      // Act: show() 2 ครั้ง
      act: (cubit) {
        cubit.show();
        cubit.show(); // ควรไม่ emit ซ้ำ
      },
      
      // Expect: emit [true] แค่ครั้งเดียว
      expect: () => [true],
    );

  });
}
