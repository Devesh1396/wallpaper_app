import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallpaper_app/HomeUI.dart';
import 'package:wallpaper_app/MainApp.dart';
import 'package:wallpaper_app/OnboardUI.dart';
import 'package:wallpaper_app/SignUp_UI.dart';
import 'package:wallpaper_app/SplashUI.dart';
import 'package:wallpaper_app/pixabay_provider.dart';
import 'AuthService.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PixabayProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AutheProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'WallNova',
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: SplashUI(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/home': (context) => HomeUI(),
          '/signUp': (context) => SignUpUI(),
          '/onboard': (context) => OnboardingUI(),
          '/main': (context) => MainScreen(),
        },
      ),
    );
  }
}