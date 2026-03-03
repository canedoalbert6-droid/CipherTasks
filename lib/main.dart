import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00FF41), // Matrix Green
        scaffoldBackgroundColor: const Color(0xFF0D0D0D), // Deep Black
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FF41),
          secondary: Color(0xFF008F11),
          surface: Color(0xFF1A1A1A),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00FF41),
            foregroundColor: Colors.black,
            textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF00FF41)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF003300)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF00FF41), width: 2),
          ),
          labelStyle: const TextStyle(color: Color(0xFF00FF41)),
        ),
        useMaterial3: true,
      ),
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
    final authViewModel = context.read<AuthViewModel>();

    if (await authViewModel.isRegistered()) {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    } else {
      if (mounted) Navigator.pushReplacementNamed(context, '/register');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
