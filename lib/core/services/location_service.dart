import 'package:geolocator/geolocator.dart';
import 'package:pair_app/core/core.dart';

/// Service สำหรับจัดการตำแหน่งที่ตั้งและ permissions ตามมาตรฐาน production
/// 
/// Features:
/// - ตรวจสอบและขอ permission location
/// - ดึงตำแหน่งปัจจุบัน
/// - จัดการกรณีที่ไม่อนุญาต permission
/// - รองรับทั้ง iOS และ Android
class LocationService {

  Future<bool> checkAndRequestPermission() async {
    try {
      // ตรวจสอบว่า location service เปิดอยู่หรือไม่
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        log('Location services are disabled');
        return false;
      }

      // ตรวจสอบ permission ปัจจุบัน
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        // ขอ permission ครั้งแรก
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          log('Location permission denied');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permission ถูกปิดถาวร ต้องให้ผู้ใช้ไปเปิดที่ settings
        log('Location permissions are permanently denied');
        return false;
      }

      //log('Location permission granted');
      return true;
    } catch (e) {
      log('Error checking location permission: $e');
      return false;
    }
  }

  /// ดึงตำแหน่งปัจจุบันของผู้ใช้
  /// 
  /// Returns:
  /// - `Position` ถ้าสำเร็จ
  /// - `null` ถ้าไม่สามารถดึงตำแหน่งได้
  Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await checkAndRequestPermission();
      if (!hasPermission) {
        //log('Cannot get location: permission not granted');
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      //log('Current location: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      log('Error getting current location: $e');
      return null;
    }
  }

  /// ตรวจสอบสถานะ permission ปัจจุบันโดยไม่ขอ permission ใหม่
  Future<bool> hasLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      log('Error checking location permission: $e');
      return false;
    }
  }

  /// เปิดหน้า app settings เพื่อให้ผู้ใช้เปิด permission เอง
  /// ใช้กรณีที่ permission ถูกปฏิเสธถาวร (deniedForever)
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Stream สำหรับติดตามการเปลี่ยนแปลงตำแหน่งแบบ real-time
  /// 
  /// Use case: แสดงตำแหน่งบนแผนที่แบบ real-time
  Stream<Position> getLocationStream() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // อัพเดทเมื่อเคลื่อนที่ 10 เมตร
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// คำนวณระยะทางระหว่างสองจุด (เป็นเมตร)
  double getDistanceBetween({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
}
