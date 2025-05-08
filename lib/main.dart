import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart';
import 'services/auth_service.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.spotifyBlack,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.spotifyGreen,
          brightness: Brightness.dark,
          surface: AppColors.spotifyBlack,
        ),
        fontFamily: 'Gotham', // You can change this to a font similar to Spotify's
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          
          if (user == null) {
            // User is not signed in
            return const LoginScreen();
          } else {
            // User is signed in - use MainScreen instead of HomeScreen placeholder
            return const MainScreen();
          }
        }
        
        // Waiting for connection state to be determined
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: AppColors.spotifyGreen,
            ),
          ),
        );
      },
    );
  }
}
