import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketDemoPage extends StatefulWidget {
  const WebSocketDemoPage({super.key});

  @override
  State<WebSocketDemoPage> createState() => _WebSocketDemoPageState();
}

class _WebSocketDemoPageState extends State<WebSocketDemoPage> {
  // 使用 WebSocketChannel 建立連接
  // 網址的部分根據我們的伺服器做調整
  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('ws://localhost:8080/ws'),
  );

  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    channel.sink.close();
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      channel.sink.add(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSocket Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Send a message'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendMessage,
              child: const Text('Send'),
            ),
            const SizedBox(height: 20),
            StreamBuilder(
              stream: channel.stream, // 監聽 WebSocket 的數據流
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
          ],
        ),
      ),
    );
  }
}
