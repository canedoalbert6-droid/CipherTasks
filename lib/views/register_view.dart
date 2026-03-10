import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../utils/app_theme.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _isPasswordValid(String password) {
    final regex = RegExp(r'^(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$');
    return regex.hasMatch(password);
  }

  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    double strength = 0.0;
    if (password.length >= 8) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<> ]').hasMatch(password)) strength += 0.25;
    return strength;
  }

  Color _getStrengthColor(double strength) {
    if (strength <= 0.25) return AppTheme.errorRed;
    if (strength <= 0.5) return Colors.orange;
    if (strength <= 0.75) return Colors.yellow;
    return AppTheme.successGreen;
  }

  String _getStrengthText(double strength) {
    if (strength <= 0.25) return 'Weak';
    if (strength <= 0.5) return 'Fair';
    if (strength <= 0.75) return 'Good';
    return 'Strong';
  }

  bool _isEmailValid(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  void _handleRegister() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    if (!_isEmailValid(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email.')),
      );
      return;
    }

    if (!_isPasswordValid(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 8 characters with a special character.')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final authViewModel = context.read<AuthViewModel>();
    await authViewModel.sendOtp(email, password);
    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pushNamed(context, '/otp');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code sent to your email.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(FontAwesomeIcons.arrowLeft, color: primaryTextColor),
              ),
              const SizedBox(height: 32),
              Text(
                'Sign Up',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
              ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
              const SizedBox(height: 8),
              Text(
                'Keep your data safe and private',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 16,
                ),
              ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: primaryTextColor),
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(FontAwesomeIcons.envelope, size: 18),
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: TextStyle(color: primaryTextColor),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Create Password',
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
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 12),
              if (_passwordController.text.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _calculatePasswordStrength(_passwordController.text),
                    backgroundColor: isDark ? Colors.white.withAlpha(26) : Colors.black.withAlpha(13),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getStrengthColor(_calculatePasswordStrength(_passwordController.text)),
                    ),
                  ),
                ).animate().fadeIn(),
                const SizedBox(height: 8),
                Text(
                  'Strength: ${_getStrengthText(_calculatePasswordStrength(_passwordController.text))}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getStrengthColor(_calculatePasswordStrength(_passwordController.text)),
                  ),
                ).animate().fadeIn(),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                style: TextStyle(color: primaryTextColor),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Type Password Again',
                  prefixIcon: const Icon(FontAwesomeIcons.shieldHalved, size: 18),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                      size: 18,
                      color: secondaryTextColor,
                    ),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
              ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 8),
              if (_confirmPasswordController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Row(
                    children: [
                      Icon(
                        _passwordController.text == _confirmPasswordController.text
                            ? FontAwesomeIcons.circleCheck
                            : FontAwesomeIcons.circleXmark,
                        size: 14,
                        color: _passwordController.text == _confirmPasswordController.text
                            ? AppTheme.successGreen
                            : AppTheme.errorRed,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _passwordController.text == _confirmPasswordController.text
                            ? 'Passwords match'
                            : 'Passwords do not match',
                        style: TextStyle(
                          fontSize: 12,
                          color: _passwordController.text == _confirmPasswordController.text
                              ? AppTheme.successGreen
                              : AppTheme.errorRed,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 200.ms),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : const Text('CREATE ACCOUNT'),
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 24),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryCyan.withAlpha(13),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryCyan.withAlpha(26)),
                  ),
                  child: Row(
                    children: [
                      const Icon(FontAwesomeIcons.circleInfo, size: 16, color: AppTheme.primaryCyan),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'We will send a code to your email to confirm your account.',
                          style: TextStyle(fontSize: 12, color: primaryTextColor.withAlpha(179)),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
