import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:provider/provider.dart';
import 'package:wallpaper_app/CategoriesUI.dart';
import 'package:wallpaper_app/SavedWallpapersUI.dart';
import 'AuthService.dart';
import 'HomeUI.dart';
import 'SignUp_UI.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  /*final List<Widget> _pages = [
    HomeUI(),
    CategoriesUI(),
  ];*/

  void _onTabSelected(int index) {
    final authProvider = Provider.of<AutheProvider>(context, listen: false);
    final userEmail = authProvider.currentUser?.email;

    if (index == 2) { // SavedWallpapers tab
      if (userEmail == null) {
        // Navigate to SignUpUI if not logged in
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignUpUI()),
        );
        return;
      }
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeUI(),
          CategoriesUI(),
          SavedWallpapers(),
        ],
      ),
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      extendBody: true,
      backgroundColor: Colors.transparent,
      bottomNavigationBar: SnakeNavigationBar.color(
        behaviour: SnakeBarBehaviour.floating,
        snakeShape: SnakeShape.indicator,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        backgroundColor: Colors.black,
        showUnselectedLabels: false,
        showSelectedLabels: true,
        snakeViewColor: Colors.white,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[400],
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border_outlined),
            label: 'Saved',
          ),
        ],
      ),
    );
  }

}
