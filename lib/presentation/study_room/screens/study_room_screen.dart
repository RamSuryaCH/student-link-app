import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:student_link_app/core/constants/colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:student_link_app/presentation/common/widgets/glass_container.dart';

class StudyRoomScreen extends StatefulWidget {
  const StudyRoomScreen({Key? key}) : super(key: key);

  @override
  _StudyRoomScreenState createState() => _StudyRoomScreenState();
}

class _StudyRoomScreenState extends State<StudyRoomScreen> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  bool isFocusMode = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(minutes: 25), // Pomodoro standard
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _toggleTimer() {
    setState(() {
      isFocusMode = !isFocusMode;
      if (isFocusMode) {
        _progressController.forward();
      } else {
        _progressController.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isFocusMode ? Colors.black : AppColors.background,
      appBar: AppBar(
        title: const Text("Study Room"),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Glowing Background
                if (isFocusMode)
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.3),
                          blurRadius: 60,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                   .custom(duration: 2.seconds, builder: (_, value, child) {
                     return Transform.scale(scale: 1.0 + (value * 0.1), child: child);
                   }),
                
                // Progress Circle
                SizedBox(
                  width: 250,
                  height: 250,
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return CircularProgressIndicator(
                        value: _progressController.value,
                        strokeWidth: 12,
                        backgroundColor: AppColors.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                      );
                    },
                  ),
                ),
                
                // Timer Text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "25:00",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 48),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isFocusMode ? "Focusing..." : "Ready to Start",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryText.withOpacity(0.7)
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 60),
            GestureDetector(
              onTap: _toggleTimer,
              child: GlassContainer(
                height: 70,
                width: 200,
                borderRadius: 35,
                child: Center(
                  child: Text(
                    isFocusMode ? "PAUSE" : "START SESSION",
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                      letterSpacing: 1.2,
                      color: isFocusMode ? AppColors.warning : AppColors.success,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
