import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashUI extends StatefulWidget {
  @override
  _SplashUIState createState() => _SplashUIState();
}

class _SplashUIState extends State<SplashUI> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();

    _navigateToNextPage();
  }

  Future<void> _navigateToNextPage() async {
    // Wait for the animation to complete
    await Future.delayed(const Duration(seconds: 4));

    // Check shared preferences for 'onboard' value
    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenOnboard = prefs.getBool('onboard') ?? false;

    if (hasSeenOnboard) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/onboard');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: SvgPicture.asset(
            'assets/images/logo_main.svg',
            width: 180,
            height: 180,
          ),
        ),
      ),
    );
  }
}
