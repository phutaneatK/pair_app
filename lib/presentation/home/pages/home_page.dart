import 'package:flutter/material.dart';
import 'package:pcore/pcore.dart';
import 'package:pair_app/core/services/auth_service.dart';
import 'package:pair_app/injection.dart';
import 'package:pair_app/presentation/home/pages/stations_page.dart';
import 'package:pair_app/presentation/home/pages/map_page.dart';
import 'package:pair_app/presentation/home/pages/favorite_page.dart';
import 'package:pair_app/router/app_routers.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final AuthService _authService = getIt<AuthService>();

  final List<Widget> _pages = const [StationsPage(), MapPage(), FavoritePage()];

  @override
  void initState() {
    super.initState();
    log("HonePage init ~");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      appBar: AppBar(
        backgroundColor: Colors.red,
        elevation: 0,
        title: Text(
          'PAir',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
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
      body: IndexedStack(index: _currentIndex, children: _pages),
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
