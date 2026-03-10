import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/todo_viewmodel.dart';
import '../utils/app_theme.dart';
import '../services/key_storage_service.dart';
import '../utils/constants.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final keyStorage = context.read<KeyStorageService>();
    final email = await keyStorage.read(AppConstants.userEmailKey);
    if (mounted) {
      setState(() {
        _userEmail = email ?? 'User';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsViewModel = context.watch<SettingsViewModel>();
    final authViewModel = context.read<AuthViewModel>();
    final isDarkMode = settingsViewModel.themeMode == ThemeMode.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          children: [
            // User Header
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryColor.withAlpha(51), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: primaryColor.withAlpha(26),
                      child: Icon(FontAwesomeIcons.userShield, size: 40, color: primaryColor),
                    ),
                  ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 16),
                  Text(
                    _userEmail,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withAlpha(26),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'SECURED ACCOUNT',
                      style: TextStyle(color: AppTheme.successGreen, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Settings Sections
            _buildSectionHeader(context, 'Security'),
            _buildSettingTile(
              context,
              icon: FontAwesomeIcons.fingerprint,
              title: 'Use Fingerprint',
              subtitle: 'Unlock with biometrics',
              trailing: Switch.adaptive(
                value: settingsViewModel.fingerprintEnabled,
                onChanged: (val) => settingsViewModel.setFingerprintEnabled(val),
                activeColor: primaryColor,
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Appearance'),
            _buildSettingTile(
              context,
              icon: isDarkMode ? FontAwesomeIcons.moon : FontAwesomeIcons.sun,
              title: 'Theme Mode',
              subtitle: isDarkMode ? 'Dark theme active' : 'Light theme active',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(FontAwesomeIcons.sun, size: 14, color: isDarkMode ? Colors.grey : Colors.orange),
                  Switch.adaptive(
                    value: isDarkMode,
                    onChanged: (val) => settingsViewModel.toggleTheme(val),
                    activeColor: primaryColor,
                  ),
                  Icon(FontAwesomeIcons.moon, size: 14, color: isDarkMode ? primaryColor : Colors.grey),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Account Settings'),
            _buildActionTile(
              context,
              icon: FontAwesomeIcons.rightFromBracket,
              title: 'Logout',
              onTap: () {
                authViewModel.logout();
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
            ),
            
            const SizedBox(height: 40),
            Text(
              'CipherTask v1.0.0',
              style: TextStyle(color: Colors.grey.withAlpha(100), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Theme.of(context).colorScheme.primary.withAlpha(150),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withAlpha(13)
            : AppTheme.lightBorder,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withAlpha(13),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        trailing: trailing,
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withAlpha(13)
            : AppTheme.lightBorder,
        ),
      ),
      child: ListTile(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        leading: Icon(icon, size: 18, color: titleColor ?? Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(150)),
        title: Text(
          title, 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 15, 
            color: titleColor
          )
        ),
        trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
      ),
    );
  }
}
