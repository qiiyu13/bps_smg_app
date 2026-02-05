import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'splash_screen.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';
import 'login_admin.dart';
import 'admin_home_screen.dart' as admin_home_screen;

void main() {
  // Performance optimizations for Flutter rendering
  WidgetsFlutterBinding.ensureInitialized();
  
  // Optimize for smooth animations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Statistik Indonesia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF1976D2),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
        // Performance: Use platform-specific page transitions
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),

      // Halaman awal
      home: const AppInitializer(),

      // Definisi semua route
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/admin-home': (context) => const admin_home_screen.AdminHomeScreen(),
        '/admin': (context) => const admin_home_screen.AdminHomeScreen(),
      },
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({Key? key}) : super(key: key);

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      print("🚀 Inisialisasi aplikasi...");
      // Let splash screen handle its own navigation timing
      // No forced timeout - video will play to completion
    } catch (e, s) {
      print("❌ Error saat inisialisasi: $e");
      print(s);
      // Fallback ke home jika terjadi error
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Splash screen tetap tampil selama inisialisasi
    return const SplashScreen();
  }
}