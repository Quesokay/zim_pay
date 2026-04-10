// ignore_for_file: sort_child_properties_last

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GettingStartedScreen extends StatelessWidget {
  const GettingStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0058BA);
    const primaryContainerColor = Color(0xFF6C9FFF);
    const secondaryColor = Color(0xFF006A2B);
    const secondaryContainerColor = Color(0xFF86F898);
    const tertiaryColor = Color(0xFFB41A14);
    const tertiaryContainerColor = Color(0xFFFF9384);
    const backgroundColor = Color(0xFFF4F7FA);
    const onSurfaceColor = Color(0xFF2B2F32);
    const onSurfaceVariantColor = Color(0xFF585C5F);
    const surfaceContainerLowestColor = Color(0xFFFFFFFF);
    const outlineVariantColor = Color(0xFFAAADB1);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // TopAppBar
              SliverAppBar(
                floating: true,
                pinned: true,
                backgroundColor: const Color(0xFFF8FAFC).withValues(alpha: 0.6),
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                centerTitle: false,
                title: Row(
                  children: [
                    const Icon(Icons.wallet, color: primaryColor, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Wallet',
                      style: GoogleFonts.plusJakartaSans(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                flexibleSpace: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(color: Colors.transparent),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.help_outline, color: onSurfaceVariantColor),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Hero Image Section
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              primaryColor.withValues(alpha: 0.1),
                              Colors.white,
                              secondaryColor.withValues(alpha: 0.1),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 64,
                              offset: const Offset(0, 32),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            // Blurred decorative circles
                            Positioned(
                              top: -40,
                              left: -40,
                              child: Container(
                                width: 288,
                                height: 288,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: primaryContainerColor.withValues(alpha: 0.3),
                                ),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                                  child: Container(color: Colors.transparent),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -40,
                              right: -40,
                              child: Container(
                                width: 288,
                                height: 288,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: secondaryContainerColor.withValues(alpha: 0.3),
                                ),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                                  child: Container(color: Colors.transparent),
                                ),
                              ),
                            ),
                            // Main Image
                            Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDInl9Q7RJxxY0Tkw-ZCFf9rRlRnBGRpIVSVMbPh-nhSFN0yu3pQIyA9u6yN6tQ4oy468SCaHk-67lq2SxzPAv7VGUbv1mF7aTfl7NAdOYzFd4fmlsoGeJnI5aY1uFndlmLsQ80uAwysPTNILCSXMSp54REcyJ-4PHhYInJG5DWAbAe36O0mlg1KvuGT8vwK4h0IbHQU5vu5bUct-KMYIUMqVmk1C98NOBv-qm3iAQdFWQpaZUnp4qPBpOXVSpnX17oeyIXYKDBERZe',
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Copy & Action Section
                    Column(
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: onSurfaceColor,
                              height: 1.1,
                            ),
                            children: [
                              const TextSpan(text: 'Welcome to your new '),
                              TextSpan(
                                text: 'digital home.',
                                style: GoogleFonts.plusJakartaSans(color: primaryColor),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Store your credit cards, transit passes, event tickets, and digital keys all in one secure, private place.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              color: onSurfaceVariantColor,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Action Cluster
                        SizedBox(
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.2),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                elevation: 0,
                              ),
                              child: Text(
                                'Get Started',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.open_in_new, size: 14),
                              label: const Text('Learn more'),
                              style: TextButton.styleFrom(
                                foregroundColor: primaryColor,
                                textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: outlineVariantColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () {},
                              child: const Text('Sign in'),
                              style: TextButton.styleFrom(
                                foregroundColor: primaryColor,
                                textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),

                    // Features Grid
                    Column(
                      children: [
                        _buildFeatureItem(
                          icon: Icons.security,
                          title: 'Secure by design',
                          description: 'Industry-leading encryption keeps your data yours.',
                          iconColor: primaryColor,
                          bgColor: primaryContainerColor.withValues(alpha: 0.1),
                          onSurfaceColor: onSurfaceColor,
                          onSurfaceVariantColor: onSurfaceVariantColor,
                          surfaceContainerLowestColor: surfaceContainerLowestColor,
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureItem(
                          icon: Icons.contactless,
                          title: 'Easy tap to pay',
                          description: 'Pay in stores or ride transit with just a tap.',
                          iconColor: secondaryColor,
                          bgColor: secondaryContainerColor.withValues(alpha: 0.1),
                          onSurfaceColor: onSurfaceColor,
                          onSurfaceVariantColor: onSurfaceVariantColor,
                          surfaceContainerLowestColor: surfaceContainerLowestColor,
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureItem(
                          icon: Icons.confirmation_number,
                          title: 'All your passes',
                          description: 'Boarding passes and tickets are always ready.',
                          iconColor: tertiaryColor,
                          bgColor: tertiaryContainerColor.withValues(alpha: 0.1),
                          onSurfaceColor: onSurfaceColor,
                          onSurfaceVariantColor: onSurfaceVariantColor,
                          surfaceContainerLowestColor: surfaceContainerLowestColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),

                    // Footer
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: Text(
                        '© 2024 Google Wallet • Privacy • Terms',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: onSurfaceVariantColor.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color iconColor,
    required Color bgColor,
    required Color onSurfaceColor,
    required Color onSurfaceVariantColor,
    required Color surfaceContainerLowestColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceContainerLowestColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              color: onSurfaceColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: onSurfaceVariantColor,
            ),
          ),
        ],
      ),
    );
  }
}
