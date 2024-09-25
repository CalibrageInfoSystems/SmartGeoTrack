import 'package:flutter/material.dart';
import 'package:smartgetrack/HomeScreen.dart';
import 'package:smartgetrack/ViewLeads.dart';
import 'package:smartgetrack/common_styles.dart';
import 'package:smartgetrack/test.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: buildBody(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedItemColor: CommonStyles.primaryTextColor,
          selectedLabelStyle: CommonStyles.txStyF14CbFF5,
          items: <BottomNavigationBarItem>[
            bottomNavItem(
              imagePath: Icons.home,
              label: 'data',
            ),
            bottomNavItem(
              imagePath: Icons.offline_bolt,
              label: 'Orders',
            ),
            bottomNavItem(
              imagePath: Icons.chat,
              label: 'Chat',
            ),
            bottomNavItem(
              imagePath: Icons.person,
              label: 'Profile',
            ),
          ],
        ));
  }

  BottomNavigationBarItem bottomNavItem(
      {required IconData imagePath, required String label}) {
    return BottomNavigationBarItem(
      icon: Icon(
        imagePath,
        color: Colors.black.withOpacity(0.6),
      ),
      activeIcon: Icon(
        imagePath,
        color: CommonStyles.primaryTextColor,
      ),
      label: label,
    );
  }

  Widget buildBody(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();

      case 1:
        return const ViewLeads();

      case 2:
        return const Scaffold(
          body: Center(
            child: Text('Chat Screen'),
          ),
        );

      case 3:
        return const Scaffold(
          body: Center(
            child: Text('Profile Screen'),
          ),
        );

      default:
        return const HomeScreen();
    }
  }
}
