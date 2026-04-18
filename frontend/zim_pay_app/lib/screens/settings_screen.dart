import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../blocs/user/user_bloc.dart';
import '../services/biometric_service.dart';
import 'link_tag_screen.dart';
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

  Future<void> _unlinkTag(int currentUserId) async {
    // Show confirmation dialog first
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unlink Physical Tag?'),
        content: const Text('If you lost your tag, this will instantly deactivate it. Your funds and digital cards will remain safe. You will need to link a new tag to use tap-to-pay.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Unlink It'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    // Execute the API Call
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/User/$currentUserId/unlink-tag'),
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tag Deactivated. Your funds are secure.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? 'Failed to unlink tag'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Network error. Check connection.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _linkNewTag(int currentUserId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/User/$currentUserId/generate-nfc-token'),
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final String newDigitalToken = responseData['data'];

        if (mounted) {
          // We reuse the exact same screen we built for registration!
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LinkTagScreen(
                digitalToken: newDigitalToken,
                isRelinking: true,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? 'Failed to generate token'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Network error. Check connection.'), backgroundColor: Colors.red),
        );
      }
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
                                onChanged: (val) async {
                                  if (val) {
                                    // Verify identity before enabling
                                    bool authenticated = await BiometricService.authenticate(
                                      context,
                                      'Confirm fingerprint to enable biometric security',
                                    );
                                    if (authenticated) {
                                      if (mounted) {
                                        context.read<UserBloc>().add(UpdateUserEvent(fingerprintEnabled: true));
                                      }
                                    }
                                  } else {
                                    // Always allow disabling (or you could require auth here too)
                                    context.read<UserBloc>().add(UpdateUserEvent(fingerprintEnabled: false));
                                  }
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
                      child: Column(
                        children: [
                          _buildSwitchItem(
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
                          _buildClickableItem(
                            icon: Icons.nfc_outlined,
                            title: 'Unlink Lost Tag',
                            subtitle: 'Instantly deactivate physical card',
                            onSurfaceColor: Colors.red,
                            onSurfaceVariantColor: Colors.redAccent,
                            surfaceContainerHighColor: Colors.red.withValues(alpha: 0.1),
                            outlineVariantColor: Colors.red.withValues(alpha: 0.3),
                            onTap: () {
                              final userState = context.read<UserBloc>().state;
                              if (userState is UserCreated) {
                                _unlinkTag(userState.user.id);
                              }
                            },
                          ),
                          _buildClickableItem(
                            icon: Icons.nfc,
                            title: 'Link New Tag',
                            subtitle: 'Pair a new or recovered physical card',
                            onSurfaceColor: onSurfaceColor,
                            onSurfaceVariantColor: onSurfaceVariantColor,
                            surfaceContainerHighColor: primaryColor.withValues(alpha: 0.1),
                            outlineVariantColor: outlineVariantColor,
                            onTap: () {
                              final userState = context.read<UserBloc>().state;
                              if (userState is UserCreated) {
                                _linkNewTag(userState.user.id);
                              }
                            },
                          ),
                        ],
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
            'Transactions under \$${_currentLimit.toInt()} won\'t require a fingerprint.',
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

    // Format the phone number for the UI if it's in the +15555555555 format
    String initialPhone = userState.user.phone;
    if (initialPhone.startsWith('+1') && initialPhone.length == 12) {
      initialPhone = '+1 ${initialPhone.substring(2, 5)} ${initialPhone.substring(5, 8)} ${initialPhone.substring(8)}';
    }
    final phoneController = TextEditingController(text: initialPhone);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Profile',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                  hintText: '+1 555 555 5555',
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (value.length < 15) {
                    return 'Format: +1 555 555 5555';
                  }
                  return null;
                },
                onChanged: (value) {
                  // Basic auto-formatting
                  String digits = value.replaceAll(RegExp(r'\D'), '');
                  if (digits.startsWith('1')) {
                    String formatted = '+1';
                    if (digits.length > 1) {
                      formatted += ' ${digits.substring(1, digits.length > 4 ? 4 : digits.length)}';
                    }
                    if (digits.length > 4) {
                      formatted += ' ${digits.substring(4, digits.length > 7 ? 7 : digits.length)}';
                    }
                    if (digits.length > 7) {
                      formatted += ' ${digits.substring(7, digits.length > 11 ? 11 : digits.length)}';
                    }
                    phoneController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                // Strip spaces for backend compatibility
                final cleanPhone = phoneController.text.replaceAll(' ', '');
                context.read<UserBloc>().add(UpdateUserEvent(
                  name: nameController.text.trim(),
                  phone: cleanPhone,
                ));
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0058BA),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Changes'),
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