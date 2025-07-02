import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pomo_timer/pomodoro_setting.dart';
import 'package:pomo_timer/pomodoro_timer.dart';
import 'package:pomo_timer/goal_set.dart';
import 'package:pomo_timer/providers.dart';

// ファイル分割前
void main() {
  final app = MyMainPage();
  final scope = ProviderScope(child: app);
  runApp(scope);
}

class MyMainPage extends ConsumerWidget {
  const MyMainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter(
      initialLocation: '/main',
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            final location = state.uri.toString();
            int currentIndex = 0;
            if (location.startsWith('/Timer')) {
              currentIndex = 1;
            } else if (location.startsWith('/Timersettings')) {
              currentIndex = 2;
            } else if (location.startsWith('/goal')) {
              currentIndex = 3;
            }

            return Scaffold(
              appBar: AppBar(
                title: const Text('ポモドーロタイマー'),
                backgroundColor: Colors.orange.shade100,
                foregroundColor: Colors.orange.shade800,
              ),
              body: child,
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: (index) {
                  switch (index) {
                    case 0:
                      context.go('/main');
                      break;
                    case 1:
                      context.go('/Timer');
                      break;
                    case 2:
                      context.go('/Timersettings');
                      break;
                    case 3:
                      context.go('/goal');
                      break;
                  }
                },
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.timer),
                    label: 'タイマー',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: '設定',
                  ),
                  BottomNavigationBarItem(icon: Icon(Icons.flag), label: '目標'),
                ],
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.orange.shade800,
                unselectedItemColor: Colors.grey,
              ),
            );
          },
          routes: [
            GoRoute(
              path: '/main',
              builder: (context, state) => const MainPage(),
            ),
            GoRoute(
              path: '/Timer',
              builder: (context, state) => const PomodoroTimerPage(),
            ),
            GoRoute(
              path: '/Timersettings',
              builder: (context, state) => const PomodoroSettingPage(),
            ),
            GoRoute(
              path: '/goal',
              builder: (context, state) => const GoalSettingsPage(),
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }
}

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer, size: 80, color: Colors.orange),
                const SizedBox(height: 20),
                const Text(
                  'ポモドーロタイマー',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '集中力を高めて、効率的に作業しましょう',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                _buildMainButton(
                  context: context,
                  title: 'タイマーを開始',
                  subtitle: '設定した時間でポモドーロを開始',
                  icon: Icons.play_circle_filled,
                  color: Colors.green,
                  onPressed: () {
                    final timerNotifier = ref.read(timerInfoProvider.notifier);
                    final settings = ref.read(pomodoroSettingsProvider);
                    // 設定がデフォルト値ならデフォルトで開始、そうでなければ現在の設定で開始
                    final isDefault =
                        settings.focusMinutes == 25 &&
                        settings.breakMinutes == 5 &&
                        settings.cycles == 4;
                    final startSettings = isDefault
                        ? PomodoroSettings()
                        : settings;
                    timerNotifier.startTimer(startSettings);
                    context.go('/Timer');
                  },
                ),
                const SizedBox(height: 20),
                _buildMainButton(
                  context: context,
                  title: '設定を変更',
                  subtitle: '集中時間・休憩時間・サイクル数を調整',
                  icon: Icons.settings,
                  color: Colors.blue,
                  onPressed: () => context.go('/Timersettings'),
                ),
                const SizedBox(height: 20),
                _buildMainButton(
                  context: context,
                  title: '目標を設定',
                  subtitle: '今日の目標を設定してモチベーション向上',
                  icon: Icons.flag,
                  color: Colors.purple,
                  onPressed: () => context.go('/goal'),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'ポモドーロテクニックとは？',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '25分の集中作業と5分の休憩のように\n集中と休憩をを繰り返すことで、\n集中力と生産性を向上させる時間管理手法です。',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
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

  Widget _buildMainButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
