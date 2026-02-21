import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:student_link_app/core/constants/colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:student_link_app/presentation/common/widgets/glass_container.dart';
import 'package:student_link_app/presentation/study_room/bloc/pomodoro_bloc.dart';
import 'package:student_link_app/presentation/study_room/bloc/pomodoro_event.dart';
import 'package:student_link_app/presentation/study_room/bloc/pomodoro_state.dart';

class StudyRoomScreen extends StatelessWidget {
  const StudyRoomScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PomodoroBloc(),
      child: const _StudyRoomContent(),
    );
  }
}

class _StudyRoomContent extends StatelessWidget {
  const _StudyRoomContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PomodoroBloc, PomodoroState>(
      builder: (context, state) {
        final isFocusMode = state.status == PomodoroStatus.running ||
            state.status == PomodoroStatus.break_;

        return Scaffold(
          backgroundColor: isFocusMode ? Colors.black : AppColors.background,
          appBar: AppBar(
            title: const Text("Study Room"),
            backgroundColor: Colors.transparent,
            actions: [
              if (state.completedSessions > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '🍅 ${state.completedSessions}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
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
                              color: (state.status == PomodoroStatus.break_
                                      ? AppColors.success
                                      : AppColors.accent)
                                  .withOpacity(0.3),
                              blurRadius: 60,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                      )
                          .animate(
                              onPlay: (controller) =>
                                  controller.repeat(reverse: true))
                          .custom(
                            duration: 2.seconds,
                            builder: (_, value, child) {
                              return Transform.scale(
                                  scale: 1.0 + (value * 0.1), child: child);
                            },
                          ),

                    // Progress Circle
                    SizedBox(
                      width: 250,
                      height: 250,
                      child: CircularProgressIndicator(
                        value: state.progress,
                        strokeWidth: 12,
                        backgroundColor: AppColors.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          state.status == PomodoroStatus.break_
                              ? AppColors.success
                              : AppColors.accent,
                        ),
                      ),
                    ),

                    // Timer Text
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.timeDisplay,
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(fontSize: 48),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.statusText,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.primaryText.withOpacity(0.7),
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                
                // Control Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (state.status == PomodoroStatus.running ||
                        state.status == PomodoroStatus.break_)
                      GestureDetector(
                        onTap: () => context
                            .read<PomodoroBloc>()
                            .add(const PausePomodoroEvent()),
                        child: GlassContainer(
                          height: 70,
                          width: 180,
                          borderRadius: 35,
                          child: Center(
                            child: Text(
                              "PAUSE",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (state.status == PomodoroStatus.initial ||
                        state.status == PomodoroStatus.paused)
                      GestureDetector(
                        onTap: () => context
                            .read<PomodoroBloc>()
                            .add(const StartPomodoroEvent()),
                        child: GlassContainer(
                          height: 70,
                          width: 200,
                          borderRadius: 35,
                          child: Center(
                            child: Text(
                              state.status == PomodoroStatus.paused
                                  ? "RESUME"
                                  : "START SESSION",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (state.status != PomodoroStatus.initial) ...[
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => context
                            .read<PomodoroBloc>()
                            .add(const ResetPomodoroEvent()),
                        child: GlassContainer(
                          height: 70,
                          width: 70,
                          borderRadius: 35,
                          child: const Center(
                            child: Icon(
                              Icons.refresh,
                              color: AppColors.error,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Info Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildInfoCard(
                        context,
                        'Focus',
                        '25:00',
                        CupertinoIcons.timer,
                        AppColors.accent,
                      ),
                      _buildInfoCard(
                        context,
                        'Short Break',
                        '5:00',
                        CupertinoIcons.pause_circle,
                        AppColors.success,
                      ),
                      _buildInfoCard(
                        context,
                        'Long Break',
                        '15:00',
                        CupertinoIcons.moon_fill,
                        AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return GlassContainer(
      width: 100,
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
