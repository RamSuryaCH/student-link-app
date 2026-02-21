import 'package:equatable/equatable.dart';

enum PomodoroStatus { initial, running, paused, completed, break_ }

class PomodoroState extends Equatable {
  final PomodoroStatus status;
  final int remainingSeconds;
  final int totalSeconds;
  final int completedSessions;
  final bool isLongBreak;

  const PomodoroState({
    this.status = PomodoroStatus.initial,
    this.remainingSeconds = 25 * 60, // 25 minutes default
    this.totalSeconds = 25 * 60,
    this.completedSessions = 0,
    this.isLongBreak = false,
  });

  double get progress => 1 - (remainingSeconds / totalSeconds);

  String get timeDisplay {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get statusText {
    switch (status) {
      case PomodoroStatus.initial:
        return 'Ready to Start';
      case PomodoroStatus.running:
        return isLongBreak ? 'Long Break' : (status == PomodoroStatus.break_ ? 'Break Time' : 'Focusing...');
      case PomodoroStatus.paused:
        return 'Paused';
      case PomodoroStatus.completed:
        return 'Session Complete!';
      case PomodoroStatus.break_:
        return isLongBreak ? 'Long Break' : 'Short Break';
    }
  }

  PomodoroState copyWith({
    PomodoroStatus? status,
    int? remainingSeconds,
    int? totalSeconds,
    int? completedSessions,
    bool? isLongBreak,
  }) {
    return PomodoroState(
      status: status ?? this.status,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      completedSessions: completedSessions ?? this.completedSessions,
      isLongBreak: isLongBreak ?? this.isLongBreak,
    );
  }

  @override
  List<Object?> get props => [status, remainingSeconds, totalSeconds, completedSessions, isLongBreak];
}
