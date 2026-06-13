import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> onboardingPages = [
    OnboardingData(
      title: "Data Statistik Terlengkap",
      description:
          "Akses data statistik Indonesia yang komprehensif dan terpercaya dari berbagai sektor",
      image: Icons.analytics_rounded,
      color: const Color(0xFF42A5F5), // Biru cerah
    ),
    OnboardingData(
      title: "Visualisasi Interaktif",
      description:
          "Jelajahi data dengan grafik, chart, dan peta interaktif yang mudah dipahami",
      image: Icons.show_chart_rounded,
      color: const Color(0xFF2196F3), // Biru medium cerah
    ),
    OnboardingData(
      title: "Export & Download",
      description:
          "Unduh data dalam berbagai format seperti PDF, Excel, dan gambar untuk kebutuhan Anda",
      image: Icons.file_download_rounded,
      color: const Color(0xFF1E88E5), // Biru cerah gelap
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: onboardingPages.length,
            itemBuilder: (context, index) {
              return OnboardingPage(data: onboardingPages[index]);
            },
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    onboardingPages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? onboardingPages[index].color
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _currentPage == onboardingPages.length - 1
                            ? null
                            : _skipOnboarding,
                        child: Text(
                          'Lewati',
                          style: TextStyle(
                            color: _currentPage == onboardingPages.length - 1
                                ? Colors.transparent
                                : Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _currentPage == onboardingPages.length - 1
                            ? _finishAsUser
                            : _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: onboardingPages[_currentPage].color,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          _currentPage == onboardingPages.length - 1
                              ? 'Mulai'
                              : 'Lanjut',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _skipOnboarding() async {
    _finishAsUser();
  }

  Future<void> _finishAsUser() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('first_time', false);

      if (mounted) {
        Navigator.of(context).pop(); // Close bottom sheet
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      debugPrint('Error finishing as user: $e');
    }
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData image;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.image,
    required this.color,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            data.color.withOpacity(0.08),
            const Color(0xFFF8F9FA),
            Colors.white,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container dengan efek glassmorphism
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  data.color.withOpacity(0.15),
                  data.color.withOpacity(0.05),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: data.color.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  data.image,
                  size: 90,
                  color: data.color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 60),
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A5F),
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              data.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
