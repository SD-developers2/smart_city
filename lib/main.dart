
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/app_provider.dart';
import 'presentation/screens/main_shell.dart';
import 'presentation/screens/auth_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const SmartCityApp(),
    ),
  );
}

class SmartCityApp extends StatelessWidget {
  const SmartCityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart City Termez',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        debugPrint('AUTH STATUS: ${snapshot.connectionState}');
        debugPrint('AUTH USER: ${snapshot.data?.uid}');
        debugPrint(
          'FIREBASE PROJECT: ${Firebase.app().options.projectId}',
        );

        // Firebase holati tekshirilmoqda
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Firebase xatosi
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Firebase xatosi: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        // Foydalanuvchi tizimga kirgan
        final user = snapshot.data;

        if (user != null) {
          return  MainShell();
        }

        // Foydalanuvchi tizimga kirmagan
        return const AuthScreen();
      },
    );
  }
}
