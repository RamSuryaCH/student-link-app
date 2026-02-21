import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:student_link_app/presentation/study_room/bloc/pomodoro_event.dart';
import 'package:student_link_app/presentation/study_room/bloc/pomodoro_state.dart';

class PomodoroBloc extends Bloc<PomodoroEvent, PomodoroState> {
  Timer? _timer;
  static const int focusDuration = 25 * 60; // 25 minutes
  static const int shortBreakDuration = 5 * 60; // 5 minutes
  static const int longBreakDuration = 15 * 60; // 15 minutes

  PomodoroBloc() : super(const PomodoroState()) {
    on<StartPomodoroEvent>(_onStart);
    on<PausePomodoroEvent>(_onPause);
    on<ResetPomodoroEvent>(_onReset);
    on<TickPomodoroEvent>(_onTick);
    on<CompletePomodoroEvent>(_onComplete);
    on<StartBreakEvent>(_onStartBreak);
  }

  void _onStart(StartPomodoroEvent event, Emitter<PomodoroState> emit) {
    if (state.status == PomodoroStatus.initial) {
      emit(state.copyWith(
        status: PomodoroStatus.running,
        remainingSeconds: focusDuration,
        totalSeconds: focusDuration,
      ));
    } else if (state.status == PomodoroStatus.paused) {
      emit(state.copyWith(status: PomodoroStatus.running));
    }

    _startTimer();
  }

  void _onPause(PausePomodoroEvent event, Emitter<PomodoroState> emit) {
    _timer?.cancel();
    emit(state.copyWith(status: PomodoroStatus.paused));
  }

  void _onReset(ResetPomodoroEvent event, Emitter<PomodoroState> emit) {
    _timer?.cancel();
    emit(const PomodoroState());
  }

  void _onTick(TickPomodoroEvent event, Emitter<PomodoroState> emit) {
    if (event.remainingSeconds > 0) {
      emit(state.copyWith(remainingSeconds: event.remainingSeconds));
    } else {
      _timer?.cancel();
      add(const CompletePomodoroEvent());
    }
  }

  void _onComplete(CompletePomodoroEvent event, Emitter<PomodoroState> emit) {
    final newCompletedSessions = state.completedSessions + 1;
    final isLongBreak = newCompletedSessions % 4 == 0;

    emit(state.copyWith(
      status: PomodoroStatus.completed,
      completedSessions: newCompletedSessions,
    ));

    // Auto-start break after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      if (!isClosed) {
        add(StartBreakEvent(isLongBreak: isLongBreak));
      }
    });
  }

  void _onStartBreak(StartBreakEvent event, Emitter<PomodoroState> emit) {
    final breakDuration = event.isLongBreak ? longBreakDuration : shortBreakDuration;
    
    emit(state.copyWith(
      status: PomodoroStatus.break_,
      remainingSeconds: breakDuration,
      totalSeconds: breakDuration,
      isLongBreak: event.isLongBreak,
    ));

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isClosed) {
        add(TickPomodoroEvent(state.remainingSeconds - 1));
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
