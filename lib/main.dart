import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_link_app/core/theme.dart';
import 'package:student_link_app/core/di/injection.dart';
import 'package:student_link_app/presentation/auth/screens/login_screen.dart';
import 'package:student_link_app/presentation/auth/screens/signup_screen.dart';
import 'package:student_link_app/presentation/common/widgets/navigation_wrapper.dart';
import 'package:get_it/get_it.dart';
import 'package:student_link_app/data/datasources/firebase_auth_service.dart';
import 'package:student_link_app/data/datasources/push_notification_service.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Setup background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Setup Dependency Injection
  await setupDependencyInjection();
  
  // Initialize Push Notifications
  await GetIt.I<PushNotificationService>().initialize();
  
  // Enable offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  
  runApp(const StudentLinkApp());
}

class StudentLinkApp extends StatelessWidget {
  const StudentLinkApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Link',
      theme: AppTheme.darkTheme,
      home: const AuthChecker(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const NavigationWrapper(),
      },
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = GetIt.I<FirebaseAuthService>();
    
    return StreamBuilder(
      stream: authService.userChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          return const NavigationWrapper();
        }
        
        return const LoginScreen();
      },
    );
  }
}
