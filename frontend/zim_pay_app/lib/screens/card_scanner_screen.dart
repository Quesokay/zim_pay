import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'manual_entry_screen.dart';

class CardScannerScreen extends StatefulWidget {
  const CardScannerScreen({super.key});

  @override
  State<CardScannerScreen> createState() => _CardScannerScreenState();
}

class _CardScannerScreenState extends State<CardScannerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Simulate a successful scan after 3 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ManualEntryScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Mock Camera View
          Positioned.fill(
            child: Container(
              color: const Color(0xFF1A1A1A),
              child: const Center(
                child: Opacity(
                  opacity: 0.3,
                  child: Icon(Icons.credit_card, size: 200, color: Colors.white),
                ),
              ),
            ),
          ),

          // Scanner Overlay
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Scan Card',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.flash_on, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                
                // Viewfinder
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: (MediaQuery.of(context).size.width * 0.85) / 1.586,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        // Animated Scanning Line
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Positioned(
                              top: _animationController.value * ((MediaQuery.of(context).size.width * 0.85) / 1.586),
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0058BA).withValues(alpha: 0.8),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                  gradient: const LinearGradient(
                                    colors: [Colors.transparent, Color(0xFF0058BA), Colors.transparent],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        ..._buildCorners(),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                Text(
                  'Align your card with the frame',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const ManualEntryScreen()),
                      );
                    },
                    child: Text(
                      'Enter Manually',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF4285F4),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCorners() {
    const double size = 30.0;
    const double thickness = 4.0;
    const Color color = Color(0xFF0058BA);

    return [
      Positioned(
        top: 0, left: 0,
        child: Container(
          width: size, height: size,
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: color, width: thickness), left: BorderSide(color: color, width: thickness)),
          ),
        ),
      ),
      Positioned(
        top: 0, right: 0,
        child: Container(
          width: size, height: size,
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: color, width: thickness), right: BorderSide(color: color, width: thickness)),
          ),
        ),
      ),
      Positioned(
        bottom: 0, left: 0,
        child: Container(
          width: size, height: size,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: color, width: thickness), left: BorderSide(color: color, width: thickness)),
          ),
        ),
      ),
      Positioned(
        bottom: 0, right: 0,
        child: Container(
          width: size, height: size,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: color, width: thickness), right: BorderSide(color: color, width: thickness)),
          ),
        ),
      ),
    ];
  }
}
