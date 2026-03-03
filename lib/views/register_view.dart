import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Colors.black),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Icon(Icons.shield_outlined, size: 80, color: Color(0xFF00FF41)),
                const SizedBox(height: 16),
                const Text(
                  'SYSTEM INITIALIZATION',
                  style: TextStyle(
                    color: Color(0xFF00FF41),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'ESTABLISH MASTER ENCRYPTION KEY',
                  style: TextStyle(color: Color(0xFF004400), fontSize: 12),
                ),
                const SizedBox(height: 48),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'SECURITY EMAIL',
                    prefixIcon: const Icon(Icons.email, color: Color(0xFF00FF41)),
                    suffixIcon: TextButton(
                      onPressed: _isLoading ? null : () async {
                        if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('INVALID SECURITY EMAIL')),
                          );
                          return;
                        }
                        
                        setState(() => _isLoading = true);
                        try {
                          await context.read<AuthViewModel>().sendOtp(_emailController.text);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('OTP SENT TO YOUR EMAIL')),
                            );
                            Navigator.pushNamed(context, '/otp');
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('FAILED TO SEND OTP: $e')),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                      child: const Text('GET OTP', style: TextStyle(color: Color(0xFF00FF41), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Color(0xFF00FF41), fontFamily: 'monospace'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'SET MASTER PASSKEY',
                    prefixIcon: Icon(Icons.security, color: Color(0xFF00FF41)),
                    helperText: 'You will need this after verifying OTP',
                    helperStyle: TextStyle(color: Color(0xFF004400)),
                  ),
                  obscureText: true,
                  onChanged: (value) {
                    context.read<AuthViewModel>().setPendingPassword(value);
                  },
                  style: const TextStyle(color: Color(0xFF00FF41), fontFamily: 'monospace'),
                ),
                const SizedBox(height: 32),
                if (_isLoading)
                  const CircularProgressIndicator(color: Color(0xFF00FF41))
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('INVALID SECURITY EMAIL')),
                          );
                          return;
                        }
                        if (_passwordController.text.length < 4) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('KEY TOO SHORT: MIN 4 CHARS')),
                          );
                          return;
                        }
                        
                        setState(() => _isLoading = true);
                        try {
                          await context.read<AuthViewModel>().sendOtp(
                            _emailController.text,
                            _passwordController.text,
                          );
                          if (mounted) Navigator.pushNamed(context, '/otp');
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('FAILED TO SEND OTP: $e')),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                      child: const Text('INITIALIZE SYSTEM'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
