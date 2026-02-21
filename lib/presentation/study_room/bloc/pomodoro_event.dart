import 'package:equatable/equatable.dart';

abstract class PomodoroEvent extends Equatable {
  const PomodoroEvent();

  @override
  List<Object?> get props => [];
}

class StartPomodoroEvent extends PomodoroEvent {
  const StartPomodoroEvent();
}

class PausePomodoroEvent extends PomodoroEvent {
  const PausePomodoroEvent();
}

class ResetPomodoroEvent extends PomodoroEvent {
  const ResetPomodoroEvent();
}

class TickPomodoroEvent extends PomodoroEvent {
  final int remainingSeconds;

  const TickPomodoroEvent(this.remainingSeconds);

  @override
  List<Object?> get props => [remainingSeconds];
}

class CompletePomodoroEvent extends PomodoroEvent {
  const CompletePomodoroEvent();
}

class StartBreakEvent extends PomodoroEvent {
  final bool isLongBreak;

  const StartBreakEvent({this.isLongBreak = false});

  @override
  List<Object?> get props => [isLongBreak];
}
