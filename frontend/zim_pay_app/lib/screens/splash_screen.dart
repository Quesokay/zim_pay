import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../repositories/health_repository.dart';
import 'getting_started_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  String _statusMessage = 'Securing your digital assets...';
  bool _isBackendReachable = false;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkConnectivity();
  }

  void _initAnimations() {
    _controllers = List.generate(4, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      );
    });

    _animations = _controllers.map((controller) {
      return TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.1).chain(CurveTween(curve: Curves.easeInOut)),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.1, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
          weight: 50,
        ),
      ]).animate(controller);
    }).toList();

    // Start animations with delay
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat();
        }
      });
    }
  }

  Future<void> _checkConnectivity() async {
    if (_isChecking) return;
    
    setState(() {
      _isChecking = true;
      _statusMessage = 'Connecting to Zim Pay services...';
    });
    
    final healthRepository = context.read<HealthRepository>();
    final stopwatch = Stopwatch()..start();
    
    _isBackendReachable = await healthRepository.checkHealth();
    stopwatch.stop();

    if (mounted) {
      setState(() => _isChecking = false);
      if (_isBackendReachable) {
        setState(() => _statusMessage = 'Connection established');
        // Ensure splash shows for at least 2 seconds if connection is fast
        final remainingDelay = 2000 - stopwatch.elapsedMilliseconds;
        Future.delayed(Duration(milliseconds: remainingDelay > 0 ? remainingDelay : 500), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const GettingStartedScreen()),
            );
          }
        });
      } else {
        setState(() => _statusMessage = 'Backend unreachable.');
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0058BA);
    const secondaryColor = Color(0xFF006A2B);
    const tertiaryColor = Color(0xFFB41A14);
    const surfaceColor = Color(0xFFF4F7FA);
    const onSurfaceColor = Color(0xFF2B2F32);
    const onSurfaceVariantColor = Color(0xFF585C5F);
    const primaryContainerColor = Color(0xFF6C9FFF);
    const secondaryContainerColor = Color(0xFF86F898);

    return Scaffold(
      backgroundColor: surfaceColor,
      body: Stack(
        children: [
          // Decorative Ambient Background Elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryContainerColor.withValues(alpha: 0.2),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: secondaryContainerColor.withValues(alpha: 0.2),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Container
                Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00214E).withValues(alpha: 0.05),
                        blurRadius: 40,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [primaryColor, primaryContainerColor],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Color(0xFFF0F2FF),
                        size: 48,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Typography
                Text(
                  'Zim Pay',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: onSurfaceColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'DIGITAL CUSTODIAN',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: onSurfaceVariantColor,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),

          // Bottom Content
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 96),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Loading Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLoadingDot(_animations[0], primaryColor),
                      const SizedBox(width: 12),
                      _buildLoadingDot(_animations[1], secondaryColor),
                      const SizedBox(width: 12),
                      _buildLoadingDot(_animations[2], tertiaryColor),
                      const SizedBox(width: 12),
                      _buildLoadingDot(_animations[3], primaryContainerColor),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Contextual Status
                  Opacity(
                    opacity: 0.8,
                    child: Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _isBackendReachable ? onSurfaceVariantColor : tertiaryColor,
                      ),
                    ),
                  ),
                  if (!_isBackendReachable && !_isChecking) ...[
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: _checkConnectivity,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Retry Connection'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: const BorderSide(color: primaryColor, width: 1.5),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const GettingStartedScreen()),
                        );
                      },
                      child: Text(
                        'Proceed Offline',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: onSurfaceVariantColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Privacy Shield
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Opacity(
                opacity: 0.4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_user,
                      size: 16,
                      color: onSurfaceVariantColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Encrypted & Secure',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: onSurfaceVariantColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingDot(Animation<double> animation, Color color) {
    return ScaleTransition(
      scale: animation,
      child: FadeTransition(
        opacity: animation.drive(Tween(begin: 0.3, end: 1.0)),
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
