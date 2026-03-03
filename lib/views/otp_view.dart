import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class OtpView extends StatefulWidget {
  const OtpView({super.key});

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _verifyOtp() async {
    String otp = _controllers.map((controller) => controller.text).join();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PLEASE ENTER ALL 6 DIGITS')),
      );
      return;
    }

    setState(() => _isLoading = true);
    bool success = await context.read<AuthViewModel>().verifyOtp(otp);
    setState(() => _isLoading = false);

    if (success) {
      if (mounted) Navigator.pushReplacementNamed(context, '/todo_list');
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('INVALID OTP. ACCESS DENIED.')),
        );
      }
    }
  }

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
                const Icon(Icons.security_outlined, size: 80, color: Color(0xFF00FF41)),
                const SizedBox(height: 16),
                const Text(
                  'IDENTITY VERIFICATION',
                  style: TextStyle(
                    color: Color(0xFF00FF41),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'ENTER 6-DIGIT AUTHORIZATION CODE',
                  style: TextStyle(color: Color(0xFF004400), fontSize: 12),
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    6,
                    (index) => SizedBox(
                      width: 45,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(color: Color(0xFF00FF41), fontSize: 24, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          counterText: "",
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xFF004400)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                          if (value.isNotEmpty && index == 5) {
                            _verifyOtp();
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                if (_isLoading)
                  const CircularProgressIndicator(color: Color(0xFF00FF41))
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _verifyOtp,
                      child: const Text('VERIFY CODE'),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('DID NOT RECEIVE CODE? ', style: TextStyle(color: Color(0xFF004400), fontSize: 12)),
                    TextButton(
                      onPressed: _isLoading ? null : () async {
                        setState(() => _isLoading = true);
                        final authViewModel = context.read<AuthViewModel>();
                        // We use the pending email already stored in ViewModel
                        // If we don't have it, we might need to pass it or handle error
                        try {
                          // Assuming sendOtp can be called without password to just resend
                          await authViewModel.sendOtp(authViewModel.pendingEmail ?? '');
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('NEW OTP SENT')),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('RESEND FAILED: $e')),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                      child: const Text('RESEND', style: TextStyle(color: Color(0xFF00FF41), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL', style: TextStyle(color: Color(0xFF004400))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
