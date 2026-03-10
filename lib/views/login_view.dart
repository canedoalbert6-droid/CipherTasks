import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../utils/app_theme.dart';
import 'widgets/app_logo.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isRegistered = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final authViewModel = context.read<AuthViewModel>();
    final registered = await authViewModel.isRegistered();
    if (mounted) {
      setState(() {
        _isRegistered = registered;
      });
    }
  }

  bool _isEmailValid(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || _passwordController.text.isEmpty) return;

    if (!_isEmailValid(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final authViewModel = context.read<AuthViewModel>();
    
    bool emailCorrect = await authViewModel.isEmailRegistered(email);
    
    if (emailCorrect) {
      final success = await authViewModel.login(_passwordController.text);
      setState(() => _isLoading = false);

      if (success && mounted) {
        HapticFeedback.lightImpact();
        Navigator.pushReplacementNamed(context, '/todo_list');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wrong password. Please try again.')),
        );
      }
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email not found. Please sign up.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsViewModel = context.watch<SettingsViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : AppTheme.lightTextPrimary;
    final secondaryTextColor = isDark ? Colors.white.withAlpha(128) : AppTheme.lightTextSecondary;

    return Scaffold(
      backgroundColor: Colors.transparent, // Let grid show through
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: AppLogo(size: 100, showText: true),
              ),
              const SizedBox(height: 48),
              Text(
                'Log in to your safe',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 16,
                ),
              ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2, end: 0),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: primaryTextColor),
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(FontAwesomeIcons.envelope, size: 18),
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: TextStyle(color: primaryTextColor),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(FontAwesomeIcons.lock, size: 18),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                      size: 18,
                      color: secondaryTextColor,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : const Text('LOG IN'),
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
              
              if (_isRegistered && settingsViewModel.fingerprintEnabled) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final authViewModel = context.read<AuthViewModel>();
                      final success = await authViewModel.authenticateWithBiometrics();
                      if (success && mounted) {
                        HapticFeedback.mediumImpact();
                        Navigator.pushReplacementNamed(context, '/todo_list');
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fingerprint check failed.')),
                        );
                      }
                    },
                    icon: const Icon(FontAwesomeIcons.fingerprint, color: AppTheme.primaryCyan),
                    label: const Text('USE FINGERPRINT', style: TextStyle(color: AppTheme.primaryCyan)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppTheme.primaryCyan, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ).animate().fadeIn(delay: 650.ms).slideY(begin: 0.2, end: 0),
              ],

              const SizedBox(height: 32),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(color: secondaryTextColor),
                      children: const [
                        TextSpan(
                          text: 'Sign Up',
                          style: TextStyle(
                            color: AppTheme.primaryCyan,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 700.ms),
            ],
          ),
        ),
      ),
    );
  }
}
