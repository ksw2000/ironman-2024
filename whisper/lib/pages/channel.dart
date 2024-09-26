import 'package:flutter/material.dart';
import 'package:whisper/data/me.dart';
import 'package:whisper/data/message.dart';

class ChannelPage extends StatefulWidget {
  const ChannelPage({super.key, required this.channelID});
  final int channelID;

  @override
  State<ChannelPage> createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> {
  final ctrl = TextEditingController();

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('聊天室')),
        body: Column(children: [
          const Expanded(child: MessageListView()),
          Container(
              color: Colors.pink[50],
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              child: Row(children: [
                Expanded(
                    child: TextField(
                        controller: ctrl,
                        decoration: InputDecoration(
                            hintText: '傳送訊息',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.white, width: 2.0))))),
                IconButton(
                    onPressed: () {
                      print(ctrl.text);
                    },
                    icon: const Icon(Icons.send))
              ]))
          // Text("Channel Page, fetch messages by ${widget.channelID}")
        ]));
  }
}

class MessageListView extends StatefulWidget {
  const MessageListView({super.key});

  @override
  State<MessageListView> createState() => _MessageListViewState();
}

class _MessageListViewState extends State<MessageListView> {
  final _scrollCtrl = ScrollController();
  final List<Message> _messageList = [];
  bool _isLoadingMore = false;

  @override
  void initState() {
    _loadMoreItems();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels == _scrollCtrl.position.maxScrollExtent) {
        _loadMoreItems();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMoreItems() async {
    if (!_isLoadingMore) {
      if (mounted) {
        setState(() {
          _isLoadingMore = true;
        });
      }

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _messageList.addAll(List<Message>.generate(
              20,
              (index) => Message(
                  senderUID: index % 2 == 0 ? 0 : 1,
                  plaintext: "message $index",
                  time: DateTime.now().subtract(Duration(hours: index)))));
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int myUID = MeDataLayer.of(context).user!.uid;

    return ListView.builder(
        controller: _scrollCtrl,
        reverse: true,
        itemBuilder: (context, index) {
          if (index == _messageList.length) {
            return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(child: CircularProgressIndicator()));
          }
          var t = _messageList[index].time;
          var showTime = "${t.month}/${t.day} ${t.hour}:${t.minute}";
          return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Align(
                  alignment: _messageList[index].senderUID != myUID
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Column(children: [
                    Container(
                        constraints: const BoxConstraints(maxWidth: 100),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.pink),
                            borderRadius: BorderRadius.circular(12)),
                        child: Text(_messageList[index].plaintext)),
                    const SizedBox(height: 3),
                    Text(showTime)
                  ])));
        },
        itemCount: _messageList.length + (_isLoadingMore ? 1 : 0));
  }
}
