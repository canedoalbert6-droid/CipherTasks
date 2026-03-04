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
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _handleRegister() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;

    setState(() => _isLoading = true);
    final authViewModel = context.read<AuthViewModel>();
    
    // In this updated flow, we send OTP first to verify email
    await authViewModel.sendOtp(_emailController.text, _passwordController.text);
    
    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pushNamed(context, '/otp');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent to your email for verification.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.backgroundDark, Color(0xFF1E293B)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(FontAwesomeIcons.arrowLeft),
                ),
                const SizedBox(height: 32),
                Text(
                  'Create Vault',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
                const SizedBox(height: 8),
                Text(
                  'Secure your data with military-grade encryption',
                  style: TextStyle(
                    color: Colors.white.withAlpha(128),
                    fontSize: 16,
                  ),
                ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0),
                const SizedBox(height: 48),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(FontAwesomeIcons.envelope, size: 18),
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Master Password',
                    prefixIcon: const Icon(FontAwesomeIcons.lock, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                        size: 18,
                        color: Colors.white70,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
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
                        : const Text('GENERATE SECURE KEY'),
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
                            'A verification code will be sent to your email to authorize this device.',
                            style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(179)),
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
      ),
    );
  }
}
