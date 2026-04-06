import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/features/auth/providers/auth_provider.dart';
import 'package:flutter_application_1/core/providers/language_provider.dart';
import 'package:flutter_application_1/core/localization/app_translations.dart';
import 'package:flutter_application_1/core/services/notification_service.dart';
import 'package:flutter_application_1/core/widgets/saga_app_bar.dart';

/// Settings screen for app configuration and user actions
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();

  bool _notificationsEnabled = false;
  bool _isLoadingNotificationPref = true;
  bool _isSavingNotificationPref = false;
  String? _initializedUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = context.read<AuthProvider>().user?.id;

    if (userId == null || userId.isEmpty || _initializedUserId == userId) {
      return;
    }

    _initializedUserId = userId;
    _loadNotificationPreference(userId);
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    String t(String key) => AppTranslations.tr(languageProvider, key);

    return Scaffold(
      appBar: SagaAppBar(
        backgroundColor: AppColors.mfuBlue,
        centerTitle: true,
        title: Text(
          t('settings'),
          style: GoogleFonts.kanit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.user;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              // Profile Header Section
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.mfuBlue,
                      child: const Icon(
                        Icons.person,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'John Doe',
                            style: GoogleFonts.kanit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.faculty ?? 'Faculty of Engineering',
                            style: GoogleFonts.kanit(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Account Section
              _buildSectionHeader(t('account')),
              _buildMenuItem(
                icon: Icons.storefront,
                iconColor: AppColors.mfuBlue,
                title: t('myListings'),
                subtitle: t('listedProducts'),
                onTap: () {
                  context.push('/my-products');
                },
              ),

              // General Section
              _buildSectionHeader(t('general')),
              _buildMenuItemWithSwitch(
                icon: Icons.notifications,
                iconColor: AppColors.mfuBlue,
                title: t('notifications'),
                subtitle: t('newMessageAlert'),
                value: _notificationsEnabled,
                enabled:
                    !_isLoadingNotificationPref && !_isSavingNotificationPref,
                onChanged: (value) async {
                  final userId = user?.id;
                  if (userId == null || userId.isEmpty) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please sign in before changing notification settings.',
                        ),
                      ),
                    );
                    return;
                  }

                  await _updateNotificationPreference(
                    userId: userId,
                    enabled: value,
                  );
                },
              ),

              // Support Section
              _buildSectionHeader(t('support')),
              _buildMenuItem(
                icon: Icons.phone,
                iconColor: AppColors.mfuBlue,
                title: t('itSupportUniversity'),
                subtitle:
                    '053-****** • 053-****** • 053-******\nefr.dd@gmail.com',
                onTap: null,
              ),

              const SizedBox(height: 24),

              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton(
                  onPressed: () {
                    _showLogoutDialog(context, languageProvider);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.mfuRed),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.logout,
                        color: AppColors.mfuRed,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        t('logout'),
                        style: GoogleFonts.kanit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mfuRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: GoogleFonts.kanit(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: GoogleFonts.kanit(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.kanit(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            )
          : null,
      trailing: onTap != null
          ? const Icon(Icons.chevron_right, color: AppColors.mfuBlue)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildMenuItemWithSwitch({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required bool value,
    bool enabled = true,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: GoogleFonts.kanit(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.kanit(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
        activeColor: AppColors.mfuRed,
      ),
    );
  }

  Future<void> _loadNotificationPreference(String userId) async {
    setState(() {
      _isLoadingNotificationPref = true;
    });

    try {
      final enabled = await _notificationService.getNotificationsEnabled(
        userId,
      );

      if (enabled) {
        await _notificationService.saveCurrentDeviceToken(userId);
      }

      if (!mounted) return;

      setState(() {
        _notificationsEnabled = enabled;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load notification settings: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingNotificationPref = false;
      });
    }
  }

  Future<void> _updateNotificationPreference({
    required String userId,
    required bool enabled,
  }) async {
    setState(() {
      _isSavingNotificationPref = true;
    });

    final previousValue = _notificationsEnabled;

    try {
      if (enabled) {
        final granted = await _notificationService.requestPermission();
        if (!granted) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification permission was not granted.'),
            ),
          );

          setState(() {
            _notificationsEnabled = false;
          });
          await _notificationService.setNotificationsEnabled(
            userId: userId,
            enabled: false,
          );
          return;
        }

        await _notificationService.saveCurrentDeviceToken(userId);
      } else {
        await _notificationService.disableNotificationsForDevice(userId);
      }

      await _notificationService.setNotificationsEnabled(
        userId: userId,
        enabled: enabled,
      );

      if (!mounted) return;
      setState(() {
        _notificationsEnabled = enabled;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _notificationsEnabled = previousValue;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update notifications: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isSavingNotificationPref = false;
      });
    }
  }

  void _showLogoutDialog(
    BuildContext context,
    LanguageProvider languageProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppTranslations.tr(languageProvider, 'logout'),
          style: GoogleFonts.kanit(fontWeight: FontWeight.bold),
        ),
        content: Text(
          AppTranslations.tr(languageProvider, 'logoutConfirm'),
          style: GoogleFonts.kanit(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              AppTranslations.tr(languageProvider, 'cancel'),
              style: GoogleFonts.kanit(color: Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
              context.go('/');
            },
            child: Text(
              AppTranslations.tr(languageProvider, 'logout'),
              style: GoogleFonts.kanit(
                color: AppColors.mfuRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
