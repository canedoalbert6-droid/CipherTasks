import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'viewmodels/settings_viewmodel.dart';
import 'views/login_view.dart';
import 'views/register_view.dart';
import 'views/otp_view.dart';
import 'views/todo_list_view.dart';
import 'views/profile_view.dart';
import 'utils/constants.dart';
import 'utils/app_theme.dart';
import 'views/widgets/app_logo.dart'; 
import 'views/widgets/grid_background.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final keyStorage = KeyStorageService();
  
  final dbKey = await keyStorage.getOrCreateKey(AppConstants.dbKeyStorageKey);
  final aesKey = await keyStorage.getOrCreateKey(AppConstants.aesKeyStorageKey);

  final dbService = DatabaseService(dbKey);
  final encryptionService = EncryptionService(aesKey);
  final emailService = EmailService();

  final sessionService = SessionService(
    timeoutMinutes: AppConstants.sessionTimeoutMinutes,
    onWarning: () {
      HapticFeedback.vibrate(); 
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text('WATCH OUT: Session will end in 30 seconds...'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 5),
        ),
      );
    },
    onTimeout: () {
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
    },
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsViewModel(keyStorage)),
        ChangeNotifierProvider(create: (_) => AuthViewModel(keyStorage, emailService)),
        ChangeNotifierProvider(create: (_) => TodoViewModel(dbService, encryptionService)),
        ChangeNotifierProvider(create: (_) {
          sessionService.setContext(navigatorKey.currentContext!);
          return sessionService;
        }),
      ],
      child: const CipherTaskApp(),
    ),
  );
}

class CipherTaskApp extends StatelessWidget {
  const CipherTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsViewModel = context.watch<SettingsViewModel>();
    
    return MaterialApp(
      title: 'CipherTask',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme.copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      darkTheme: AppTheme.darkTheme.copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      themeMode: settingsViewModel.themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => const InitializerScreen(),
        '/login': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),
        '/otp': (context) => const OtpView(),
        '/todo_list': (context) => const TodoListView(),
        '/profile': (context) => const ProfileView(),
      },
      // This builder wraps every route in the Persistent GridBackground
      builder: (context, child) {
        return GridBackground(
          child: child ?? const SizedBox.shrink(),
        );
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
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    // Background is now provided by MaterialApp.builder
    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(child: AppLogo(size: 150, showText: true)),
          const SizedBox(height: 16),
          Text(
            'MY SAFE STORAGE',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary.withAlpha(100),
              letterSpacing: 4,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn(delay: 800.ms, duration: 600.ms),
          const SizedBox(height: 64),
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
              strokeWidth: 3,
            ),
          ).animate().fadeIn(delay: 1200.ms),
        ],
      ),
    );
  }
}
