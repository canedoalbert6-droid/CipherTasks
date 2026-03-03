import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.black.withOpacity(0.9), const Color(0xFF001100)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 80, color: Color(0xFF00FF41)),
                const SizedBox(height: 16),
                const Text(
                  'TERMINAL ACCESS',
                  style: TextStyle(
                    color: Color(0xFF00FF41),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 48),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'SECURITY EMAIL',
                    prefixIcon: Icon(Icons.email, color: Color(0xFF00FF41)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Color(0xFF00FF41), fontFamily: 'monospace'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'MASTER PASSKEY',
                    prefixIcon: Icon(Icons.key, color: Color(0xFF00FF41)),
                  ),
                  obscureText: true,
                  style: const TextStyle(color: Color(0xFF00FF41), fontFamily: 'monospace'),
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const CircularProgressIndicator(color: Color(0xFF00FF41))
                else ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        bool success = await context.read<AuthViewModel>().login(_passwordController.text);
                        if (success && mounted) {
                          Navigator.pushReplacementNamed(context, '/todo_list');
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.red,
                              content: Text('ACCESS DENIED: INVALID KEY'),
                            ),
                          );
                        }
                      },
                      child: const Text('AUTHORIZE WITH PASSKEY'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF00FF41)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () async {
                        if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('INVALID SECURITY EMAIL')),
                          );
                          return;
                        }

                        setState(() => _isLoading = true);
                        final authVM = context.read<AuthViewModel>();
                        bool isRegistered = await authVM.isEmailRegistered(_emailController.text);
                        
                        if (isRegistered) {
                          await authVM.sendOtp(_emailController.text);
                          if (mounted) Navigator.pushNamed(context, '/otp');
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('EMAIL NOT REGISTERED ON THIS TERMINAL')),
                            );
                          }
                        }
                        setState(() => _isLoading = false);
                      },
                      child: const Text('GET OTP FOR ACCESS', style: TextStyle(color: Color(0xFF00FF41))),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                const Text('OR', style: TextStyle(color: Color(0xFF004400))),
                const SizedBox(height: 24),
                InkWell(
                  onTap: () async {
                    bool success = await context.read<AuthViewModel>().authenticateWithBiometrics();
                    if (success && mounted) {
                      Navigator.pushReplacementNamed(context, '/todo_list');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF00FF41), width: 1),
                    ),
                    child: const Icon(Icons.fingerprint, size: 48, color: Color(0xFF00FF41)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'BIOMETRIC SCAN',
                  style: TextStyle(color: Color(0xFF00FF41), fontSize: 10, letterSpacing: 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
