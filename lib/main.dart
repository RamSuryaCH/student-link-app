import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:student_link_app/core/theme.dart';
import 'package:student_link_app/presentation/auth/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Note: Firebase setup configured. For actual build, use `flutterfire configure`.
  // await Firebase.initializeApp();
  
  // Setup Dependency Injection here:
  // setupLocator();
  
  runApp(const StudentLinkApp());
}

class StudentLinkApp extends StatelessWidget {
  const StudentLinkApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Link',
      theme: AppTheme.darkTheme,
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
