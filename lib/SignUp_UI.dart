import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wallpaper_app/SignUp_bgUi.dart';
import 'AuthService.dart';

class SignUpUI extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AutheProvider>(context);

    return Stack(
      children: [
        // Background with sliding images
        SignupBackground(),

        // Gradient overlay
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black26, // 50% dark at the top
                  Colors.black87, // Darker toward the bottom
                  Colors.black, // Fully dark at the bottom
                ],
              ),
            ),
          ),
        ),

        // Foreground content
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/logo_main.svg', // Path to your SVG file
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Thousands of amazing photos & videos. for free.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.none, height: 1.4),
              ),
            ),
            const SizedBox(height: 30),
            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // Make buttons full width
                children: [
                  // Google Button
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await authProvider.signInWithGoogle(context);
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Failed to sign in: $e")),
                        );
                      }
                    },
                    icon: const Icon(Icons.g_mobiledata, size: 28),
                    label: const Text('Continue with Google'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Facebook Button
                  ElevatedButton.icon(
                    onPressed: () {
                    },
                    icon: const Icon(Icons.facebook, size: 28, color: Colors.white),
                    label: const Text('Continue with Facebook', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}
