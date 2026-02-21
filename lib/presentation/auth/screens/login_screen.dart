import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:student_link_app/core/constants/colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:student_link_app/presentation/common/widgets/glass_container.dart';
import 'package:student_link_app/presentation/common/widgets/navigation_wrapper.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Decor elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.3),
                shape: BoxShape.circle,
                boxShadow: const [BoxShadow(blurRadius: 100, spreadRadius: 50, color: AppColors.primary)],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.2),
                shape: BoxShape.circle,
                boxShadow: const [BoxShadow(blurRadius: 80, spreadRadius: 40, color: AppColors.accent)],
              ),
            ),
          ),
          // Form Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Student Link",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40),
                    ).animate().fade(duration: 500.ms).slideY(begin: -0.2),
                    const SizedBox(height: 8),
                    Text(
                      "The ultimate campus networking platform",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryText.withOpacity(0.7)
                      ),
                    ).animate().fade(delay: 200.ms).slideY(begin: -0.2),
                    
                    const SizedBox(height: 48),

                    GlassContainer(
                      height: 320,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextField(
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Student Email ending in .edu',
                              prefixIcon: const Icon(CupertinoIcons.mail, color: AppColors.primary),
                              filled: true,
                              fillColor: AppColors.surface.withOpacity(0.5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Password',
                              prefixIcon: const Icon(CupertinoIcons.lock, color: AppColors.primary),
                              filled: true,
                              fillColor: AppColors.surface.withOpacity(0.5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [BoxShadow(color: AppColors.primary, blurRadius: 15, spreadRadius: -5)],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context, 
                                  MaterialPageRoute(builder: (context) => const NavigationWrapper())
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                "LOGIN",
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 400.ms, duration: 400.ms).scaleXY(begin: 0.9, end: 1),

                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () {},
                      child: const Text("Don't have an account? Sign Up", style: TextStyle(color: AppColors.accent)),
                    ).animate().fade(delay: 600.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
