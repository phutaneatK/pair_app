import 'package:flutter/material.dart';
import 'package:pair_app/core/core.dart';
import 'package:pair_app/core/services/auth_service.dart';
import 'package:pair_app/core/services/location_service.dart';
import 'package:pair_app/injection.dart';
import 'package:pair_app/presentation/home/pages/stations_page.dart';
import 'package:pair_app/presentation/home/pages/map_page.dart';
import 'package:pair_app/presentation/home/pages/favorite_page.dart';
import 'package:pair_app/presentation/home/widgets/cloud_app_bar.dart';
import 'package:pair_app/router/app_routers.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final AuthService _authService = getIt<AuthService>();
  final LocationService _locationService = getIt<LocationService>();

  final List<Widget> _pages = const [StationsPage(), MapPage(), FavoritePage()];

  @override
  void initState() {
    super.initState();
    log("HomePage init ~");
    _requestLocationPermission();
  }

  /// ขอ location permission ตอนเปิดแอพ
  Future<void> _requestLocationPermission() async {
    final hasPermission = await _locationService.checkAndRequestPermission();

    if (!hasPermission) {
      // แสดง dialog แจ้งเตือนถ้าไม่ได้รับ permission
      if (mounted) {
        _showPermissionDeniedDialog();
      }
    } else {
      //log("Location permission granted successfully");
      // สามารถดึงตำแหน่งปัจจุบันได้เลย
      // final position = await _locationService.getCurrentLocation();
      // if (position != null) {
      //   //log("Current position: ${position.latitude}, ${position.longitude}");
      // }
    }
  }

  /// แสดง dialog เมื่อผู้ใช้ไม่อนุญาต location permission
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'ต้องการสิทธิ์เข้าถึงตำแหน่ง',
            style: TextStyle(color: Colors.grey[800]),
          ),
          content: Text(
            'แอปต้องการเข้าถึงตำแหน่งของคุณเพื่อแสดงสถานีตรวจวัดคุณภาพอากาศที่ใกล้เคียง',
            style: TextStyle(color: Colors.grey[700]),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('ปิด', style: TextStyle(color: Colors.grey[600])),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _locationService.openAppSettings();
              },
              child: Text(
                'ตั้งค่า',
                style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double appBarHeight = kToolbarHeight;
    double totalHeight = statusBarHeight + appBarHeight;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        //title: Text("PAir"),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.grey[800]),
            color: Colors.white,
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.grey[700], size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'ออกจากระบบ',
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CloudBackground(isShowCloud: _currentIndex != 1),
          ),
          Column(
            children: [
              SizedBox(height: totalHeight),
              Expanded(
                child: IndexedStack(index: _currentIndex, children: _pages),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.grey[800],
        unselectedItemColor: Colors.grey[400],
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'รายการ'),
          BottomNavigationBarItem(icon: Icon(Icons.public), label: 'แผนที่'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'รายการโปรด',
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('ออกจากระบบ', style: TextStyle(color: Colors.grey[800])),
          content: Text(
            'คุณต้องการออกจากระบบหรือไม่?',
            style: TextStyle(color: Colors.grey[700]),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('ยกเลิก', style: TextStyle(color: Colors.grey[600])),
            ),
            TextButton(
              onPressed: () async {
                await _authService.deleteToken();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  await CoveNav.clearAndPush(AppRoutes.loginPath);
                }
              },
              child: Text(
                'ออกจากระบบ',
                style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // no controller to dispose
}
