import 'package:flutter/material.dart';

Stream<int> counterStream() async* {
  for (int i = 1; i <= 5; i++) {
    await Future.delayed(const Duration(seconds: 1));
    yield i; // 每秒發出一個整數
  }
}

class StreamBuilderDemoPage extends StatelessWidget {
  const StreamBuilderDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StreamBuilder Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: StreamBuilder<int>(
          stream: counterStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('錯誤 ${snapshot.error}');
            } else {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return const Text('目前尚未連線到任何異步計算');
                case ConnectionState.waiting:
                  return const Text('已連線，等待互動');
                case ConnectionState.active:
                  return Text('資料傳輸中：${snapshot.data}');
                case ConnectionState.done:
                  return const Text('資料傳輸完成');
              }
            }
          },
        ),
      ),
    );
  }
}
