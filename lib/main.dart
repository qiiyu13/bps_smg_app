import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
// device_preview is a dev-only tool, kept out of release via kReleaseMode below.
// ignore: depend_on_referenced_packages
import 'package:device_preview/device_preview.dart';
import 'services/github_data_service.dart';
import 'splash_screen.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';
import 'app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  PaintingBinding.instance.imageCache.maximumSize = 50;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 16 << 20;

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    // DevicePreview must never wrap the app in release builds.
    runApp(
      kReleaseMode
          ? const MyApp()
          : DevicePreview(builder: (context) => const MyApp()),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Statistik Indonesia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF1976D2),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'PlusJakartaSans',
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ParallaxPageTransitionsBuilder(),
            TargetPlatform.iOS: ParallaxPageTransitionsBuilder(),
          },
        ),
      ),

      // Halaman awal
      home: const AppInitializer(),

      // Definisi semua route
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

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
    // SplashScreen owns navigation to '/home' (via its own timers/fallbacks).
    // We only warm the data cache here; failure is non-fatal and must NOT
    // trigger a second navigation, which would race the splash.
    try {
      await GitHubDataService.init();
    } catch (e, s) {
      debugPrint("❌ Error saat inisialisasi: $e");
      debugPrint(s.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Splash screen tetap tampil selama inisialisasi
    return const SplashScreen();
  }
}
