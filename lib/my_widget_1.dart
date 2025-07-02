import 'package:flutter/material.dart';
import 'package:pomo_timer/s1.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyWidget1 extends ConsumerStatefulWidget{
  const MyWidget1({
    super.key,
  });

  @override
  ConsumerState<MyWidget1> createState() => _MyWidget1State();

}

class _MyWidget1State extends ConsumerState<MyWidget1> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // 現在の nickname を初期値としてセット
    // ここでは String で初期化（int をそのまま入れるとエラー）
    final s1Value = ref.read(s1NotifierProvider);
    _controller = TextEditingController(text: s1Value.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // S1 watch
    final s1 = ref.watch(s1NotifierProvider);
    // S1 listen
    ref.listen(
      s1NotifierProvider,
          (oldState, newState) {
        // スナックバーを表示
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('S1データが変更されました $oldState -> $newState'),
                ),
              );
            });
      },
    );
    // S1 テキスト
    final s1Text = Text('$s1');
    // S1 ボタン
    final s1Button = ElevatedButton(
      onPressed: () {
        // S1 ノティファイアを呼ぶ
        final notifier = ref.read(s1NotifierProvider.notifier);
        // S1 データを変更
        notifier.updateState();
      },
      child: const Text('+1'),
    );

    final textfield = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Input a number',
            ),
          ),
        ),
        ElevatedButton(onPressed: () {
          final notifier = ref.read(s1NotifierProvider.notifier);
          notifier.setState(int.parse(_controller.text));
        }, child: Text('SET'),
        ),
      ],
    );
    final twicebutton = ElevatedButton(onPressed: () {
      final notifier = ref.read(s1NotifierProvider.notifier);
      final currentnumber = ref.watch(s1NotifierProvider);
      notifier.setState(currentnumber * 2);
    }, child: Text("×2"));


    // 縦に並べる
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          s1Text,
          s1Button,
          twicebutton,
          textfield,
        ],
      ),
    );


  }
}