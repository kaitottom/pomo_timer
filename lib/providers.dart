import 'package:flutter_riverpod/flutter_riverpod.dart';

// ポモドーロ設定のデータクラス
class PomodoroSettings {
  final int focusMinutes;
  final int breakMinutes;
  final int cycles;
  // ポモドーロ設定のコンストラクタ
  const PomodoroSettings({
    this.focusMinutes = 25,
    this.breakMinutes = 5,
    this.cycles = 4,
  });
  // ポモドーロ設定を更新するメソッド
  PomodoroSettings copyWith({
    int? focusMinutes,
    int? breakMinutes,
    int? cycles,
  }) {
    return PomodoroSettings(
      focusMinutes: focusMinutes ?? this.focusMinutes,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      cycles: cycles ?? this.cycles,
    );
  }
}

// タイマーの状態を表すenum 列挙型
enum TimerState {
  stopped, // 停止中
  running, // 実行中
  paused, // 一時停止中
}

// タイマーの種類を表すenum
enum TimerType {
  focus, // 集中時間
  break_, // 休憩時間
}

// タイマー情報のデータクラス
class TimerInfo {
  final TimerState state;
  final TimerType type;
  final int remainingSeconds;
  final int currentCycle;
  final int totalCycles;
  final DateTime? endTime;

  const TimerInfo({
    this.state = TimerState.stopped,
    this.type = TimerType.focus,
    this.remainingSeconds = 0,
    this.currentCycle = 1,
    this.totalCycles = 4,
    this.endTime,
  });

  TimerInfo copyWith({
    TimerState? state,
    TimerType? type,
    int? remainingSeconds,
    int? currentCycle,
    int? totalCycles,
    DateTime? endTime,
  }) {
    return TimerInfo(
      state: state ?? this.state,
      type: type ?? this.type,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      currentCycle: currentCycle ?? this.currentCycle,
      totalCycles: totalCycles ?? this.totalCycles,
      endTime: endTime ?? this.endTime,
    );
  }
}

// ポモドーロ設定のプロバイダー
// PomodoroSettingsNotifier(notifier)とPomodoroSettings(state)を使って、ポモドーロ設定を管理する
final pomodoroSettingsProvider =
    StateNotifierProvider<PomodoroSettingsNotifier, PomodoroSettings>((ref) {
      return PomodoroSettingsNotifier();
    });

// タイマー情報のプロバイダー
// TimerInfoNotifier(notifier)とTimerInfo(state)を使って、タイマー情報を管理する
final timerInfoProvider = StateNotifierProvider<TimerInfoNotifier, TimerInfo>((
  ref,
) {
  return TimerInfoNotifier();
});

// ポモドーロ設定のStateNotifier
class PomodoroSettingsNotifier extends StateNotifier<PomodoroSettings> {
  PomodoroSettingsNotifier() : super(const PomodoroSettings());

  void updateFocusMinutes(int minutes) {
    state = state.copyWith(focusMinutes: minutes);
  }

  void updateBreakMinutes(int minutes) {
    state = state.copyWith(breakMinutes: minutes);
  }

  void updateCycles(int cycles) {
    state = state.copyWith(cycles: cycles);
  }
}

// タイマー情報のStateNotifier
class TimerInfoNotifier extends StateNotifier<TimerInfo> {
  TimerInfoNotifier() : super(const TimerInfo());

  void startTimer(PomodoroSettings settings) {
    final focusSeconds = settings.focusMinutes * 60;
    final endTime = DateTime.now().add(Duration(seconds: focusSeconds));

    state = state.copyWith(
      state: TimerState.running,
      type: TimerType.focus,
      remainingSeconds: focusSeconds,
      currentCycle: 1,
      totalCycles: settings.cycles,
      endTime: endTime,
    );
  }

  void pauseTimer() {
    if (state.state == TimerState.running) {
      state = state.copyWith(state: TimerState.paused);
    }
  }

  void resumeTimer() {
    if (state.state == TimerState.paused) {
      // when the timer is paused, get the remaining seconds and add it to the current time
      final remainingSeconds = state.remainingSeconds;
      final endTime = DateTime.now().add(Duration(seconds: remainingSeconds));
      // update the state to running and set the revised end time
      state = state.copyWith(state: TimerState.running, endTime: endTime);
    }
  }

  void stopTimer() {
    // reset the timer info
    state = const TimerInfo();
  }

  // update the remaining seconds
  void updateRemainingSeconds(int seconds) {
    state = state.copyWith(remainingSeconds: seconds);
  }

  void switchToBreak(PomodoroSettings settings) {
    final breakSeconds = settings.breakMinutes * 60;
    final endTime = DateTime.now().add(Duration(seconds: breakSeconds));

    // update the state to break and set the end time
    state = state.copyWith(
      type: TimerType.break_,
      remainingSeconds: breakSeconds,
      endTime: endTime,
    );
  }

  void switchToFocus(PomodoroSettings settings) {
    final focusSeconds = settings.focusMinutes * 60;
    final endTime = DateTime.now().add(Duration(seconds: focusSeconds));
    final nextCycle = state.currentCycle + 1; // increment the current cycle

    // update the state to focus and set the end time
    state = state.copyWith(
      type: TimerType.focus,
      remainingSeconds: focusSeconds,
      currentCycle: nextCycle,
      endTime: endTime,
    );
  }
}

// 残り時間を分:秒形式で表示するためのプロバイダー
final formattedTimeProvider = Provider<String>((ref) {
  final timerInfo = ref.watch(timerInfoProvider);
  final minutes = timerInfo.remainingSeconds ~/ 60;
  final seconds = timerInfo.remainingSeconds % 60;
  // format the time to display in the format of mm:ss
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
});

// タイマーの状態を日本語で表示するプロバイダー
final timerStateTextProvider = Provider<String>((ref) {
  final timerInfo = ref.watch(timerInfoProvider);
  switch (timerInfo.type) {
    case TimerType.focus:
      return '集中時間';
    case TimerType.break_:
      return '休憩時間';
  }
});
