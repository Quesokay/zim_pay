import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/user/user_bloc.dart';
import 'home_screen.dart';
import 'cards_screen.dart';
import 'transaction_history_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _emailEnabled = false;
  double _currentLimit = 50.0; // Local state for the biometric limit slider

  @override
  void initState() {
    super.initState();
    final userState = context.read<UserBloc>().state;
    if (userState is UserCreated) {
      _currentLimit = userState.user.tapLimit;
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0058BA);
    const backgroundColor = Color(0xFFF4F7FA);
    const onSurfaceColor = Color(0xFF2B2F32);
    const onSurfaceVariantColor = Color(0xFF585C5F);
    const surfaceContainerLowestColor = Color(0xFFFFFFFF);
    const surfaceContainerHighColor = Color(0xFFDEE3E8);
    const outlineVariantColor = Color(0xFFAAADB1);
    const secondaryContainerColor = Color(0xFFCFFFCE);
    const secondaryColor = Color(0xFF006A2B);

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBody: true,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Top App Bar
              SliverAppBar(
                floating: true,
                pinned: true,
                backgroundColor: backgroundColor.withValues(alpha: 0.6),
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: onSurfaceColor),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  'Settings',
                  style: GoogleFonts.plusJakartaSans(
                    color: onSurfaceColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                flexibleSpace: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Container(color: Colors.transparent),
                  ),
                ),
                actions: [
                  BlocBuilder<UserBloc, UserState>(
                    builder: (context, state) {
                      String name = 'Guest';
                      if (state is UserCreated) {
                        name = state.user.name;
                      }
                      return Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
                            image: DecorationImage(
                              image: NetworkImage('https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Hero Header
                    BlocBuilder<UserBloc, UserState>(
                      builder: (context, state) {
                        String name = 'Guest';
                        if (state is UserCreated) {
                          name = state.user.name;
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, $name',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: onSurfaceColor,
                                letterSpacing: -1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Manage how you pay and secure your wallet.',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: onSurfaceVariantColor,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 40),

                    // Profile Group
                    _buildSectionHeader('PROFILE', primaryColor),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: surfaceContainerLowestColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: BlocBuilder<UserBloc, UserState>(
                        builder: (context, state) {
                          String email = 'Not signed in';
                          if (state is UserCreated) {
                            email = state.user.email;
                          }
                          return Column(
                            children: [
                              _buildClickableItem(
                                icon: Icons.person,
                                title: 'Personal Information',
                                subtitle: 'Manage your name and phone number',
                                onSurfaceColor: onSurfaceColor,
                                onSurfaceVariantColor: onSurfaceVariantColor,
                                surfaceContainerHighColor: surfaceContainerHighColor,
                                outlineVariantColor: outlineVariantColor,
                                onTap: () => _showEditProfileDialog(context),
                              ),
                              _buildReadOnlyItem(
                                icon: Icons.alternate_email,
                                title: 'Email address',
                                subtitle: email,
                                onSurfaceColor: onSurfaceColor,
                                onSurfaceVariantColor: onSurfaceVariantColor,
                                surfaceContainerHighColor: surfaceContainerHighColor,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Security Group
                    _buildSectionHeader('SECURITY', primaryColor),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: surfaceContainerLowestColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: BlocBuilder<UserBloc, UserState>(
                        builder: (context, state) {
                          final bool fingerprintEnabled = state is UserCreated ? state.user.fingerprintEnabled : true;
                          final bool contactlessEnabled = state is UserCreated ? state.user.contactlessEnabled : true;

                          return Column(
                            children: [
                              _buildSwitchItem(
                                icon: Icons.fingerprint,
                                title: 'Fingerprint unlock',
                                subtitle: 'Require biometric to view or use cards',
                                value: fingerprintEnabled,
                                onChanged: (val) {
                                  context.read<UserBloc>().add(UpdateUserEvent(fingerprintEnabled: val));
                                },
                                primaryColor: primaryColor,
                                onSurfaceColor: onSurfaceColor,
                                onSurfaceVariantColor: onSurfaceVariantColor,
                              ),
                              _buildSwitchItem(
                                icon: Icons.contactless,
                                title: 'Contactless payments',
                                subtitle: 'Tap to pay with NFC enabled cards',
                                value: contactlessEnabled,
                                onChanged: (val) {
                                  context.read<UserBloc>().add(UpdateUserEvent(contactlessEnabled: val));
                                },
                                primaryColor: primaryColor,
                                onSurfaceColor: onSurfaceColor,
                                onSurfaceVariantColor: onSurfaceVariantColor,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Divider(color: outlineVariantColor.withValues(alpha: 0.3), height: 32),
                              ),
                              _buildLimitSlider(primaryColor, onSurfaceColor, onSurfaceVariantColor),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Preferences Group
                    _buildSectionHeader('PREFERENCES', primaryColor),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: surfaceContainerLowestColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: _buildSwitchItem(
                        icon: Icons.mail,
                        title: 'Email notifications',
                        subtitle: 'Receipts and security alerts',
                        value: _emailEnabled,
                        onChanged: (val) => setState(() => _emailEnabled = val),
                        primaryColor: primaryColor,
                        onSurfaceColor: onSurfaceColor,
                        onSurfaceVariantColor: onSurfaceVariantColor,
                        iconColor: secondaryColor,
                        iconBgColor: secondaryContainerColor.withValues(alpha: 0.3),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // About Group
                    _buildSectionHeader('ABOUT', primaryColor),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: surfaceContainerLowestColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          _buildClickableItem(
                            icon: Icons.help,
                            title: 'Help & feedback',
                            subtitle: 'Get support or suggest features',
                            onSurfaceColor: onSurfaceColor,
                            onSurfaceVariantColor: onSurfaceVariantColor,
                            surfaceContainerHighColor: surfaceContainerHighColor,
                            outlineVariantColor: outlineVariantColor,
                          ),
                          _buildClickableItem(
                            icon: Icons.description,
                            title: 'Terms of service',
                            subtitle: 'Legal information and privacy policy',
                            onSurfaceColor: onSurfaceColor,
                            onSurfaceVariantColor: onSurfaceVariantColor,
                            surfaceContainerHighColor: surfaceContainerHighColor,
                            outlineVariantColor: outlineVariantColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Version
                    Center(
                      child: Text(
                        'ZIM PAY v24.12.8',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: outlineVariantColor,
                          letterSpacing: 1.5,
                        ),
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
              padding: const EdgeInsets.only(bottom: 24, top: 12, left: 24, right: 24),
              decoration: BoxDecoration(
                color: backgroundColor.withValues(alpha: 0.6),
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
                      _buildNavItem(context, Icons.credit_card, 'Cards', false, onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CardsScreen()),
                        );
                      }),
                      _buildNavItem(context, Icons.settings, 'Settings', true),
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

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color primaryColor,
    required Color onSurfaceColor,
    required Color onSurfaceVariantColor,
    Color? iconColor,
    Color? iconBgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor ?? primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor ?? primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
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
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: primaryColor,
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildLimitSlider(Color primaryColor, Color onSurfaceColor, Color onSurfaceVariantColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tap-to-Pay Auto-Approve Limit',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: onSurfaceColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Transactions under this amount won\'t require a fingerprint.',
            style: GoogleFonts.inter(
              color: onSurfaceVariantColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('\$0', style: GoogleFonts.inter(color: onSurfaceVariantColor)),
              Expanded(
                child: Slider(
                  value: _currentLimit,
                  min: 0,
                  max: 200,
                  divisions: 20,
                  activeColor: primaryColor,
                  label: '\$${_currentLimit.toStringAsFixed(0)}',
                  onChanged: (double value) {
                    setState(() {
                      _currentLimit = value;
                    });
                  },
                  onChangeEnd: (double finalValue) {
                    context.read<UserBloc>().add(UpdateUserEvent(tapLimit: finalValue));
                    debugPrint('Saved new limit: \$${finalValue.toStringAsFixed(2)}');
                  },
                ),
              ),
              Text('\$200', style: GoogleFonts.inter(color: onSurfaceVariantColor)),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildClickableItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color onSurfaceColor,
    required Color onSurfaceVariantColor,
    required Color surfaceContainerHighColor,
    required Color outlineVariantColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: surfaceContainerHighColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: onSurfaceVariantColor, size: 24),
            ),
            const SizedBox(width: 16),
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
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: outlineVariantColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color onSurfaceColor,
    required Color onSurfaceVariantColor,
    required Color surfaceContainerHighColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: surfaceContainerHighColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: onSurfaceVariantColor, size: 24),
          ),
          const SizedBox(width: 16),
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
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final userState = context.read<UserBloc>().state;
    if (userState is! UserCreated) return;

    final nameController = TextEditingController(text: userState.user.name);
    final phoneController = TextEditingController(text: userState.user.phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<UserBloc>().add(UpdateUserEvent(
                name: nameController.text,
                phone: phoneController.text,
              ));
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
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