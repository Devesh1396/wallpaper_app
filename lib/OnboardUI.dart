import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<String> quotes = [
      '“Your Wallpaper Mirrors your identity”',
      '“Transform your screen with vibrant wallpapers”',
      '“Fresh. Bold. Dynamic Wallpapers”',
      '“Create a masterpiece on your screen”',
      '“Express yourself through visuals”',
    ];

    Future<void> _completeOnboarding(BuildContext context) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboard', true);
      Navigator.pushReplacementNamed(context, '/main');
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          ClipPath(
            clipper: RoundedBottomClipper(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orangeAccent, Colors.yellow],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: SizedBox(
                  width: 300.0,
                  height: 100.0,
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    child: AnimatedTextKit(
                      animatedTexts: quotes.map((quote) {
                        return FadeAnimatedText(
                          quote,
                          textAlign: TextAlign.center,
                          duration: const Duration(seconds: 3),
                        );
                      }).toList(),
                      repeatForever: true,
                      // Loop forever
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Brand name and button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Brand name
                  const Text(
                    'Welcome to WallNova',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Get Started Button
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: ElevatedButton(
                      onPressed: () {
                        _completeOnboarding(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RoundedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0, size.height - 100); // Start at the bottom-left
    path.quadraticBezierTo(
      size.width / 2, // Control point (center of the width)
      size.height, // Control point (slightly below the container)
      size.width, // End point (bottom-right corner)
      size.height - 100, // End point (height - 100)
    );
    path.lineTo(size.width, 0); // Line to the top-right
    path.close(); // Close the path
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false; // No need to reclip
  }
}
