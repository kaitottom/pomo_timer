import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/goal_settings_provider.dart';
//import '../models/goal_settings.dart';
import 'task_card.dart';
import 'task_form_modal.dart';

class GoalTasksBottomSheet extends ConsumerWidget {
  final VoidCallback onComplete; // 親に遷移処理を委譲

  const GoalTasksBottomSheet({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentGoal = ref.watch(tempGoalProvider);
    const maxTasks = 5;

    if (currentGoal == null) {
      return const Center(child: Text('目標がありません'));
    }

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.90, // 高さを画面の90%に調整
        child: Column(
          children: [
            // Drag Indicator
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Text(
              "タスク設定",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            // タスクリスト
            Expanded(
              child: currentGoal.tasks.isEmpty
                  ? const Center(child: Text("タスクがありません"))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: currentGoal.tasks.length,
                itemBuilder: (context, i) {
                  final task = currentGoal.tasks[i];
                  return TaskCard(
                    task: task,
                    onDelete: () =>
                        ref.read(tempGoalProvider.notifier).deleteTask(task.task),
                    onEdit: () => showDialog(
                      context: context,
                      builder: (_) => TaskFormModal(
                        initialTask: task,
                        currentTaskCount: currentGoal.tasks.length,
                        maxTasks: maxTasks,
                        onSave: (updated) =>
                            ref.read(tempGoalProvider.notifier).updateTask(updated),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // タスク追加 or 最大表示
            if (currentGoal.tasks.length < maxTasks)
              ElevatedButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => TaskFormModal(
                    currentTaskCount: currentGoal.tasks.length,
                    maxTasks: maxTasks,
                    onSave: (task) =>
                        ref.read(tempGoalProvider.notifier).addTask(task),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text("タスクを追加"),
              ),
            if (currentGoal.tasks.length >= maxTasks)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Text(
                  'タスクは最大5個までです',
                  style: TextStyle(color: Colors.orange),
                ),
              ),

            const SizedBox(height: 12),

            // 完了ボタン
            ElevatedButton(
              onPressed: () async {
                // BottomSheet を閉じるのを待つ
                 await Navigator.of(context).maybePop(); // その後に遷移

                 onComplete(); // ここで GoRouter.of(context).go('/goal/review');
    },


              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("完了"),
            ),
          ],
        ),
      ),
    );
  }
}
