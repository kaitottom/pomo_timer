import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pomo_timer/providers.dart';

class PomodoroTimerPage extends ConsumerStatefulWidget {
  const PomodoroTimerPage({super.key});

  @override
  ConsumerState<PomodoroTimerPage> createState() => _PomodoroTimerPageState();
}

class _PomodoroTimerPageState extends ConsumerState<PomodoroTimerPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final timerInfo = ref.read(timerInfoProvider);
      final settings = ref.read(pomodoroSettingsProvider);

      if (timerInfo.state == TimerState.running && timerInfo.endTime != null) {
        final now = DateTime.now();
        final remainingSeconds = timerInfo.endTime!.difference(now).inSeconds;

        if (remainingSeconds <= 0) {
          // タイマー終了時の処理
          _handleTimerComplete(settings);
        } else {
          // 残り時間を更新
          ref
              .read(timerInfoProvider.notifier)
              .updateRemainingSeconds(remainingSeconds);
        }
      }
    });
  }

  void _handleTimerComplete(PomodoroSettings settings) {
    final timerInfo = ref.read(timerInfoProvider);

    if (timerInfo.type == TimerType.focus) {
      // 集中時間が終了した場合
      if (timerInfo.currentCycle < timerInfo.totalCycles) {
        // 次のサイクルがある場合は休憩時間に切り替え
        ref.read(timerInfoProvider.notifier).switchToBreak(settings);
      } else {
        // 全サイクル完了
        _showCompletionDialog();
      }
    } else {
      // 休憩時間が終了した場合
      ref.read(timerInfoProvider.notifier).switchToFocus(settings);
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('お疲れさまでした！'),
        content: const Text('ポモドーロセッションが完了しました。'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(timerInfoProvider.notifier).stopTimer();
              context.go('/main');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timerInfo = ref.watch(timerInfoProvider);
    final formattedTime = ref.watch(formattedTimeProvider);
    final timerStateText = ref.watch(timerStateTextProvider);
    final settings = ref.watch(pomodoroSettingsProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // 目標表示エリア（将来の拡張用）
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.flag, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        '目標: 集中力を高める',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // タイマー状態表示
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: timerInfo.type == TimerType.focus
                        ? Colors.red.shade50
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: timerInfo.type == TimerType.focus
                          ? Colors.red.shade200
                          : Colors.green.shade200,
                    ),
                  ),
                  child: Text(
                    timerStateText,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: timerInfo.type == TimerType.focus
                          ? Colors.red.shade700
                          : Colors.green.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 40),

                // 残り時間表示
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '残り時間',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formattedTime,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // サイクル数表示
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.repeat, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        'サイクル ${timerInfo.currentCycle} / ${timerInfo.totalCycles}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // 制御ボタン
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 一時停止/再開ボタン
                    if (timerInfo.state != TimerState.stopped)
                      ElevatedButton.icon(
                        onPressed: () {
                          if (timerInfo.state == TimerState.running) {
                            ref.read(timerInfoProvider.notifier).pauseTimer();
                          } else if (timerInfo.state == TimerState.paused) {
                            ref.read(timerInfoProvider.notifier).resumeTimer();
                          }
                        },
                        icon: Icon(
                          timerInfo.state == TimerState.running
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                        label: Text(
                          timerInfo.state == TimerState.running ? '一時停止' : '再開',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),

                    // 中断ボタン
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('タイマーを中断しますか？'),
                            content: const Text('現在のセッションがリセットされます。'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('キャンセル'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  ref
                                      .read(timerInfoProvider.notifier)
                                      .stopTimer();
                                  context.go('/main');
                                },
                                child: const Text('中断'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.stop),
                      label: const Text('中断'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 設定画面へのボタン
                OutlinedButton(
                  onPressed: () => context.go('/Timersettings'),
                  child: const Text('設定を変更'),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
