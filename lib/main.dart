import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pomo_timer/pages/pages.dart';

void main() {
  final app = MyMainPage();
  final scope = ProviderScope(child: app);
  runApp(scope);
}

class MyMainPage extends ConsumerWidget {
  //StatelessWidget
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
            if (location.startsWith('/Timersettings') || location.startsWith('/Timer')) {
              currentIndex = 1;
            } else if (location.startsWith('/goal')) {
              currentIndex = 2;
            } else if (location.startsWith('/stats')) {
              currentIndex = 3;
            }

            return PopScope(
                canPop: false, // ← 戻る操作を内部では処理しない
              onPopInvokedWithResult: (didPop, result) {
                SystemNavigator.pop(); // ← アプリ終了
              },
            child: Scaffold(
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
                      context.go('/Timersettings');
                      break;
                    case 2:
                      context.go('/goal');
                      break;
                    case 3:
                      context.go('/stats');
                      break;
                  }
                },
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),

                  BottomNavigationBarItem(
                    icon: Icon(Icons.timer_outlined),
                    label: '設定',
                  ),
                  BottomNavigationBarItem(icon: Icon(Icons.flag), label: '目標'),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.analytics),
                    label: '記録',
                  ),
                ],
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.orange.shade800,
                unselectedItemColor: Colors.grey,
              ),
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
              builder: (context, state) => const GoalMainPage(),
              routes: [
                GoRoute(
                  path: 'new', // 目標goalの新規設定
                  builder: (context, state) => const GoalNewPage(), //{
                    //final fromReview =
                    //    state.uri.queryParameters['fromReview'] == 'true';
                    //return GoalNewPage(fromReview: fromReview);
                  //},
                ),
                GoRoute(
                  path: 'tasks', //目標へのタスクを入力や設定
                  builder: (context, state) => const GoalTasksPage(),
                ),
                GoRoute(
                  path: 'review', //目標とタスクを全体的に確認
                  builder: (context, state) => const GoalReviewPage(),
                ),
                GoRoute(
                  path: 'edit', //既存の目標やタスクを変更、再設定
                  builder: (context, state) {
                    final from = state.uri.queryParameters['from']; // "review" が入る
                    return GoalEditPage(from: from);
                  },
                  //builder: (context, state) => const GoalEditPage(),
                ),
              ],
            ),
            GoRoute(
              path: '/stats',
              builder: (context, state) => const StatsPage(),
            ),
            GoRoute(
              path: '/score',
              builder: (context, state) => const ScorePage(),
            ),
            GoRoute(
              path: '/evaluation',
              builder: (context, state) => const EvaluationPage(),
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }
}
