import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers.dart';
import 'models/pomodoro_settings.dart';

class PomodoroSettingPage extends ConsumerWidget {
  const PomodoroSettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(pomodoroSettingsProvider);
    final settingsNotifier = ref.read(pomodoroSettingsProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // タイトル
                const Text(
                  'ポモドーロ設定',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // 集中時間設定
                _buildSettingCard(
                  title: '集中時間',
                  value: settings.focusMinutes,
                  onIncrement: () {
                    if (settings.focusMinutes < 60) {
                      settingsNotifier.updateFocusMinutes(
                        settings.focusMinutes + 1,
                      );
                    }
                  },
                  onDecrement: () {
                    if (settings.focusMinutes > 1) {
                      settingsNotifier.updateFocusMinutes(
                        settings.focusMinutes - 1,
                      );
                    }
                  },
                  onChanged: (value) {
                    final minutes = int.tryParse(value) ?? 25;
                    if (minutes >= 1 && minutes <= 60) {
                      settingsNotifier.updateFocusMinutes(minutes);
                    }
                  },
                ),

                const SizedBox(height: 20),

                // 休憩時間設定
                _buildSettingCard(
                  title: '休憩時間',
                  value: settings.breakMinutes,
                  onIncrement: () {
                    if (settings.breakMinutes < 30) {
                      settingsNotifier.updateBreakMinutes(
                        settings.breakMinutes + 1,
                      );
                    }
                  },
                  onDecrement: () {
                    if (settings.breakMinutes > 1) {
                      settingsNotifier.updateBreakMinutes(
                        settings.breakMinutes - 1,
                      );
                    }
                  },
                  onChanged: (value) {
                    final minutes = int.tryParse(value) ?? 5;
                    if (minutes >= 1 && minutes <= 30) {
                      settingsNotifier.updateBreakMinutes(minutes);
                    }
                  },
                ),

                const SizedBox(height: 20),

                // サイクル数設定
                _buildSettingCard(
                  title: 'サイクル数',
                  value: settings.cycles,
                  onIncrement: () {
                    if (settings.cycles < 10) {
                      settingsNotifier.updateCycles(settings.cycles + 1);
                    }
                  },
                  onDecrement: () {
                    if (settings.cycles > 1) {
                      settingsNotifier.updateCycles(settings.cycles - 1);
                    }
                  },
                  onChanged: (value) {
                    final cycles = int.tryParse(value) ?? 4;
                    if (cycles >= 1 && cycles <= 10) {
                      settingsNotifier.updateCycles(cycles);
                    }
                  },
                ),

                const SizedBox(height: 40),

                // 開始ボタン
                ElevatedButton(
                  onPressed: () {
                    // タイマーを開始してタイマー画面に遷移
                    final timerNotifier = ref.read(timerInfoProvider.notifier);
                    timerNotifier.startTimer(settings);
                    context.go('/Timer');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'タイマー開始',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required int value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required Function(String) onChanged,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 減少ボタン
                IconButton(
                  onPressed: onDecrement,
                  icon: const Icon(Icons.remove_circle_outline),
                  iconSize: 32,
                  color: Colors.red,
                ),

                const SizedBox(width: 20),

                // 数値入力フィールド
                SizedBox(
                  width: 80,
                  child: TextField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: value.toString()),
                    onChanged: onChanged,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                // 増加ボタン
                IconButton(
                  onPressed: onIncrement,
                  icon: const Icon(Icons.add_circle_outline),
                  iconSize: 32,
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
