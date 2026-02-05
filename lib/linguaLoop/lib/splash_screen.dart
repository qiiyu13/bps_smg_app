import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:ui';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isVideoInitialized = false;
  bool _isDisposed = false;
  Timer? _timeoutTimer;
  Timer? _stuckCheckTimer;
  Timer? _maxDurationTimer;
  bool _hasNavigated = false;
  Duration _lastPosition = Duration.zero;
  int _stuckCounter = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeVideo();
    // Safety net: ensure we navigate after max 8 seconds no matter what
    _maxDurationTimer = Timer(const Duration(seconds: 8), () {
      if (!_hasNavigated && !_isDisposed) {
        print('Max splash duration reached, forcing navigation');
        _navigateToHome();
      }
    });
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  void _initializeVideo() async {
    try {
      if (_isDisposed) return;

      _timeoutTimer = Timer(const Duration(seconds: 5), () {
        if (!_isVideoInitialized && !_isDisposed) {
          print('Video loading timeout, using fallback');
          _showFallbackSplash();
        }
      });

      _videoController = VideoPlayerController.asset(
        'assets/animations/ringan.mp4',
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true, // Allow playing without taking audio focus
          allowBackgroundPlayback: false,
        ),
      );

      await _videoController!.initialize();

      if (_isDisposed) return;

      _timeoutTimer?.cancel();

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }

      _fadeController.forward();
      await _videoController!.setLooping(false);
      await _videoController!.setVolume(0.0);

      print('Video duration: ${_videoController!.value.duration}');

      // Try to play video with error handling
      try {
        await _videoController!.play();
        _videoController!.addListener(_checkVideoCompletion);
      } catch (playError) {
        print('Error playing video: $playError');
        // If video fails to play (e.g., audio focus issue), show fallback
        if (!_isDisposed && mounted) {
          _showFallbackSplash();
        }
      }
    } catch (error) {
      print('Error initializing video: $error');
      _timeoutTimer?.cancel();
      if (!_isDisposed) {
        _showFallbackSplash();
      }
    }
  }

  void _checkVideoCompletion() {
    if (_videoController == null || !mounted) return;

    final position = _videoController!.value.position;
    final duration = _videoController!.value.duration;

    print('Video position: $position / $duration');

    // Check if video is stuck (position not changing)
    if (position == _lastPosition) {
      _stuckCounter++;
      if (_stuckCounter > 3) {
        // Stuck for ~3 seconds
        print('Video appears stuck, using fallback');
        _videoController?.pause();
        _showFallbackSplash();
        return;
      }
    } else {
      _stuckCounter = 0;
      _lastPosition = position;
    }

    // Check if video completed
    if (position >= duration && !_hasNavigated) {
      print('Video completed, navigating to home');
      _navigateToHome();
    }
  }

  void _showFallbackSplash() {
    if (_isDisposed) return;

    if (mounted) {
      setState(() {
        _isVideoInitialized = false;
      });
    }
    _fadeController.forward();

    Timer(const Duration(seconds: 3), () {
      if (!_hasNavigated) {
        _navigateToHome();
      }
    });
  }

  void _setNavigationTimeout() {
    Timer(const Duration(seconds: 6), () {
      if (!_hasNavigated) {
        _navigateToHome();
      }
    });
  }

  Future<void> _navigateToHome() async {
    if (_hasNavigated || _isDisposed) return;
    _hasNavigated = true;

    try {
      if (!mounted) return;
      await _fadeController.reverse();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      print('Error navigating: $e');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timeoutTimer?.cancel();
    _stuckCheckTimer?.cancel();
    _maxDurationTimer?.cancel();

    if (_videoController != null) {
      _videoController!.removeListener(_checkVideoCompletion);
      _videoController!.pause();
      _videoController!.dispose();
    }

    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: Container(
        color: const Color(0xFFF4F4F4),
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Video player di bagian tengah
              if (_isVideoInitialized && _videoController != null)
                Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: screenSize.width * 0.6,
                      height: screenSize.width * 0.6,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _videoController!.value.size.width,
                          height: _videoController!.value.size.height,
                          child: VideoPlayer(_videoController!),
                        ),
                      ),
                    ),
                  ),
                ),

              // Loading state atau fallback content
              if (!_isVideoInitialized)
                Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF84CC16), // Lime green
                      ),
                    ),
                  ),
                ),

              // Progress indicator untuk video - using RepaintBoundary to optimize
              if (_isVideoInitialized && _videoController != null)
                Positioned(
                  bottom: 60,
                  left: 50,
                  right: 50,
                  child: RepaintBoundary(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: ValueListenableBuilder(
                        valueListenable: _videoController!,
                        builder: (context, VideoPlayerValue value, child) {
                          final progress = value.duration.inMilliseconds > 0
                              ? value.position.inMilliseconds /
                                  value.duration.inMilliseconds
                              : 0.0;
                          return Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: const Color(
                                  0xFFD1D5DB), // Darker gray background
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.transparent,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF84CC16), // Lime green
                                ),
                                minHeight: 6,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo dengan shadow biru
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.2),
                blurRadius: 25,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Image.network(
                  'https://semarangkota.bps.go.id/images/logo-bps.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) {
                    return const Icon(
                      Icons.analytics_outlined,
                      size: 50,
                      color: Color(0xFF2563EB),
                    );
                  },
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'BPS Kota Semarang',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E40AF),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF3B82F6).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: const Text(
            'Data Statistik Terpercaya',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF1E40AF),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandingText() {
    return Column(
      children: [
        const Text(
          'BPS Kota Semarang',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E40AF),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF3B82F6).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: const Text(
            'Data Statistik Terpercaya',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF1E40AF),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF3B82F6).withOpacity(0.1),
            border: Border.all(
              color: const Color(0xFF3B82F6).withOpacity(0.3),
              width: 2,
            ),
          ),
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              const Color(0xFF3B82F6),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Memuat aplikasi...',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF1E40AF),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
