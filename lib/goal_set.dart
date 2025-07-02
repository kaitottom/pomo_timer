import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GoalSettingsPage extends StatefulWidget {
  const GoalSettingsPage({super.key});

  @override
  State<GoalSettingsPage> createState() => _GoalSettingsPageState();
}

class _GoalSettingsPageState extends State<GoalSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          children: [
            Text('Goal Setting'),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => context.push('/main'),
                  child: Text('メインメニューへ'),
                ),
                ElevatedButton(
                  onPressed: () => context.push('/Timer'),
                  child: Text('タイマーへ'),
                ),
                ElevatedButton(
                  onPressed: () => context.push('/Timersettings'),
                  child: Text('タイマー設定へ'),
                ),
              ],
            ),
          ],
        ),

    );
  }
}
