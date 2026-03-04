import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'services/key_storage_service.dart';
import 'services/encryption_service.dart';
import 'services/database_service.dart';
import 'services/session_service.dart';
import 'services/email_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/todo_viewmodel.dart';
import 'views/login_view.dart';
import 'views/register_view.dart';
import 'views/otp_view.dart';
import 'views/todo_list_view.dart';
import 'utils/constants.dart';
import 'utils/app_theme.dart';
import 'views/widgets/app_logo.dart'; // Import the new logo widget

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final keyStorage = KeyStorageService();
  
  // Get or create keys for DB and Field Encryption
  final dbKey = await keyStorage.getOrCreateKey(AppConstants.dbKeyStorageKey);
  final aesKey = await keyStorage.getOrCreateKey(AppConstants.aesKeyStorageKey);

  final dbService = DatabaseService(dbKey);
  final encryptionService = EncryptionService(aesKey);
  final emailService = EmailService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel(keyStorage, emailService)),
        ChangeNotifierProvider(create: (_) => TodoViewModel(dbService, encryptionService)),
        ChangeNotifierProvider(create: (_) => SessionService(
          timeoutMinutes: AppConstants.sessionTimeoutMinutes,
          onTimeout: () {
            navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
          },
        )),
      ],
      child: const CipherTaskApp(),
    ),
  );
}

class CipherTaskApp extends StatelessWidget {
  const CipherTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CipherTask',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const InitializerScreen(),
        '/login': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),
        '/otp': (context) => const OtpView(),
        '/todo_list': (context) => const TodoListView(),
      },
    );
  }
}

class InitializerScreen extends StatefulWidget {
  const InitializerScreen({super.key});

  @override
  State<InitializerScreen> createState() => _InitializerScreenState();
}

class _InitializerScreenState extends State<InitializerScreen> {
  @override
  void initState() {
    super.initState();
    _checkRegistration();
  }

  Future<void> _checkRegistration() async {
    // Add a small delay so the user can actually see the cool splash screen animation
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    final authViewModel = context.read<AuthViewModel>();

    if (await authViewModel.isRegistered()) {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    } else {
      if (mounted) Navigator.pushReplacementNamed(context, '/register');
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLogo(size: 150, showText: true), // Using the new unique logo
            const SizedBox(height: 16),
            Text(
              'SECURE DATA VAULT',
              style: TextStyle(
                color: AppTheme.primaryCyan.withAlpha(100),
                letterSpacing: 4,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(delay: 800.ms, duration: 600.ms),
            const SizedBox(height: 64),
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryCyan),
                strokeWidth: 3,
              ),
            ).animate().fadeIn(delay: 1200.ms),
          ],
        ),
      ),
    );
  }
}
