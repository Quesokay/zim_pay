import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'cards_screen.dart';
import 'manual_entry_screen.dart';
import 'transaction_history_screen.dart';
import 'settings_screen.dart';

class AddToWalletScreen extends StatelessWidget {
  static const primaryColor = Color(0xFF0058BA);
  static const primaryContainerColor = Color(0xFF6C9FFF);
  static const secondaryColor = Color(0xFF006A2B);
  static const tertiaryColor = Color(0xFFB41A14);
  static const surfaceColor = Color(0xFFF4F7FA);
  static const onSurfaceColor = Color(0xFF2B2F32);
  static const onSurfaceVariantColor = Color(0xFF585C5F);
  static const surfaceContainerLowestColor = Color(0xFFFFFFFF);
  static const surfaceContainerLowColor = Color(0xFFEEF1F5);
  static const surfaceContainerHighestColor = Color(0xFFD8DDE2);
  static const outlineVariantColor = Color(0xFFAAADB1);

  const AddToWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: surfaceColor,
      extendBody: true,
      body: Stack(
        children: [
          // Decorative floating elements
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: 0.05),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 3,
            right: -100,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: secondaryColor.withValues(alpha: 0.05),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // TopAppBar
              SliverAppBar(
                floating: true,
                pinned: true,
                backgroundColor: Colors.white.withValues(alpha: 0.6),
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                leadingWidth: 72,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Center(
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: onSurfaceColor),
                      style: IconButton.styleFrom(
                        hoverColor: surfaceContainerLowColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
                flexibleSpace: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Container(color: Colors.transparent),
                  ),
                ),
                title: Text(
                  'Add to Wallet',
                  style: GoogleFonts.plusJakartaSans(
                    color: onSurfaceColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: surfaceContainerHighestColor,
                        image: DecorationImage(
                          image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCs9z9FdbjL_cv9oUb2CCZVxOqeHaNY1N1Mg6G0_akC-4-h4rI-OUjF8923vWC7z1zN4xlCcIrmRAJ7QzafFpQ0RzGAsWSehPyM6zBEgINx4XvWu4AfmGKAyKl54fM42bQMuH5Hl323DbwSMfbLAfhyTanDFJRfV_yHW5_hJC8ly8J02iU_IdX5ybrNIOyvG66h8iRc_z7m5YBFZrAlIsogrdPGTXuznoJZhK6Rmf67xlcbGcQwLXO0ez1nBSsmgnzFIya8m75l6qb-'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Scan Card Section
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        decoration: BoxDecoration(
                          color: surfaceContainerLowestColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      primaryColor.withValues(alpha: 0.05),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: outlineVariantColor.withValues(alpha: 0.2),
                                    width: 2,
                                    style: BorderStyle.none, // Need a custom painter for dashed
                                  ),
                                ),
                                child: _DashedBorderContainer(
                                  color: outlineVariantColor.withValues(alpha: 0.2),
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 64,
                                          height: 64,
                                          decoration: const BoxDecoration(
                                            color: primaryContainerColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.photo_camera,
                                            color: Color(0xFF00214E),
                                            size: 32,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Scan a card',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: onSurfaceColor,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Hold your card in the frame to automatically capture details',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: onSurfaceVariantColor,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        // Viewfinder Placeholder
                                        LayoutBuilder(
                                          builder: (context, constraints) {
                                            final viewfinderWidth = constraints.maxWidth * 0.9;
                                            return Container(
                                              width: viewfinderWidth,
                                              height: viewfinderWidth / 1.586,
                                              decoration: BoxDecoration(
                                                color: surfaceContainerLowColor,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: primaryColor.withValues(alpha: 0.2),
                                                  width: 2,
                                                ),
                                              ),
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.credit_card,
                                                    size: viewfinderWidth * 0.2,
                                                    color: primaryColor.withValues(alpha: 0.2),
                                                  ),
                                                  ..._buildViewfinderCorners(primaryColor),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Options List
                    Text(
                      'CHOOSE TYPE',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildOptionItem(
                      icon: Icons.credit_card,
                      iconColor: Colors.blue[600]!,
                      bgColor: Colors.blue[50]!,
                      title: 'Payment card',
                      subtitle: 'Credit or debit card',
                      onSurfaceColor: onSurfaceColor,
                      onSurfaceVariantColor: onSurfaceVariantColor,
                      surfaceContainerLowestColor: surfaceContainerLowestColor,
                      surfaceContainerLowColor: surfaceContainerLowColor,
                    ),
                    const SizedBox(height: 8),
                    _buildOptionItem(
                      icon: Icons.directions_subway,
                      iconColor: secondaryColor,
                      bgColor: const Color(0xFFE8F5E9),
                      title: 'Transit pass',
                      subtitle: 'Bus, train, or light rail',
                      onSurfaceColor: onSurfaceColor,
                      onSurfaceVariantColor: onSurfaceVariantColor,
                      surfaceContainerLowestColor: surfaceContainerLowestColor,
                      surfaceContainerLowColor: surfaceContainerLowColor,
                    ),
                    const SizedBox(height: 8),
                    _buildOptionItem(
                      icon: Icons.card_membership,
                      iconColor: Colors.amber[600]!,
                      bgColor: Colors.yellow[50]!,
                      title: 'Loyalty',
                      subtitle: 'Store rewards and memberships',
                      onSurfaceColor: onSurfaceColor,
                      onSurfaceVariantColor: onSurfaceVariantColor,
                      surfaceContainerLowestColor: surfaceContainerLowestColor,
                      surfaceContainerLowColor: surfaceContainerLowColor,
                    ),
                    const SizedBox(height: 8),
                    _buildOptionItem(
                      icon: Icons.card_giftcard,
                      iconColor: tertiaryColor,
                      bgColor: const Color(0xFFFFEBEE),
                      title: 'Gift card',
                      subtitle: 'Prepaid retail balances',
                      onSurfaceColor: onSurfaceColor,
                      onSurfaceVariantColor: onSurfaceVariantColor,
                      surfaceContainerLowestColor: surfaceContainerLowestColor,
                      surfaceContainerLowColor: surfaceContainerLowColor,
                    ),

                    const SizedBox(height: 48),

                    // Footer Action
                    Center(
                      child: Column(
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ManualEntryScreen()),
                              );
                            },
                            icon: const Icon(Icons.edit, size: 20),
                            label: const Text('Enter details manually'),
                            style: TextButton.styleFrom(
                              foregroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
                              shape: const StadiumBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(
                                style: TextStyle(
                                  fontFamily: 'Inter', // Fallback since GoogleFonts.inter() is not const
                                  fontSize: 12,
                                  color: onSurfaceVariantColor,
                                ),
                                children: [
                                  TextSpan(text: 'Your data is protected by Google\'s industry-leading security. '),
                                  TextSpan(
                                    text: 'Learn more',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 120),
                  ]),
                ),
              ),
            ],
          ),

          // Bottom Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(bottom: 24, top: 12, left: 32, right: 32),
              decoration: BoxDecoration(
                color: surfaceColor.withValues(alpha: 0.6),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2B2F32).withValues(alpha: 0.08),
                    blurRadius: 32,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(context, Icons.wallet, 'Wallet', false, onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                          (route) => false,
                        );
                      }),
                      _buildNavItem(context, Icons.history, 'History', false, onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TransactionHistoryScreen()),
                        );
                      }),
                      _buildNavItem(context, Icons.credit_card, 'Cards', true, onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CardsScreen()),
                        );
                      }),
                      _buildNavItem(context, Icons.settings, 'Settings', false, onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingsScreen()),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildViewfinderCorners(Color color) {
    const double size = 24.0;
    const double thickness = 2.0;
    const double padding = 16.0;

    return [
      // Top Left
      Positioned(
        top: padding,
        left: padding,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: thickness),
              left: BorderSide(color: color, width: thickness),
            ),
          ),
        ),
      ),
      // Top Right
      Positioned(
        top: padding,
        right: padding,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: thickness),
              right: BorderSide(color: color, width: thickness),
            ),
          ),
        ),
      ),
      // Bottom Left
      Positioned(
        bottom: padding,
        left: padding,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: thickness),
              left: BorderSide(color: color, width: thickness),
            ),
          ),
        ),
      ),
      // Bottom Right
      Positioned(
        bottom: padding,
        right: padding,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: thickness),
              right: BorderSide(color: color, width: thickness),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildOptionItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required Color onSurfaceColor,
    required Color onSurfaceVariantColor,
    required Color surfaceContainerLowestColor,
    required Color surfaceContainerLowColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surfaceContainerLowestColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
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
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: onSurfaceColor,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        color: onSurfaceVariantColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: onSurfaceVariantColor.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive, {VoidCallback? onTap}) {
    return Flexible(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: isActive
              ? BoxDecoration(
                  color: const Color(0xFFD3E3FD),
                  borderRadius: BorderRadius.circular(30),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? const Color(0xFF041E49) : const Color(0xFF44474E),
                size: 24,
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isActive ? const Color(0xFF041E49) : const Color(0xFF44474E),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderContainer extends StatelessWidget {
  final Widget child;
  final Color color;

  const _DashedBorderContainer({required this.child, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashPainter(color: color),
      child: child,
    );
  }
}

class _DashPainter extends CustomPainter {
  final Color color;

  _DashPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const double dashWidth = 8;
    const double dashSpace = 8;
    final RRect rrect = RRect.fromLTRBR(0, 0, size.width, size.height, const Radius.circular(12));
    final Path path = Path()..addRRect(rrect);

    final Path dashedPath = Path();
    for (final PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0;
      while (distance < pathMetric.length) {
        dashedPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(_DashPainter oldDelegate) => oldDelegate.color != color;
}
