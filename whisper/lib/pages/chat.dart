import 'package:flutter/material.dart';
import 'package:whisper/data/chat.dart';
import 'package:whisper/pages/channel.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final Future<List<Chat>> _loadChatList =
      Future.delayed(const Duration(seconds: 1), () {
    return List<Chat>.generate(
        20,
        (index) => Chat(
            profile: "https://i.imgur.com/91bOTO6.png",
            userName: "さやか-$index",
            userID: 1,
            channelID: index,
            lastMessage: "おはよう"));
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _loadChatList,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                ),
                const SizedBox(
                  height: 20,
                ),
                Text("${snapshot.error}")
              ],
            ));
          } else if (snapshot.hasData) {
            return Center(
              child: ChatCardListView(
                items: snapshot.data!,
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}

class ChatCardListView extends StatefulWidget {
  const ChatCardListView({super.key, required this.items});
  final List<Chat> items;

  @override
  State<ChatCardListView> createState() => _ChatCardListViewState();
}

class _ChatCardListViewState extends State<ChatCardListView> {
  final _scrollController = ScrollController();
  List<Chat> _items = [];
  bool _isLoadingMore = false;

  @override
  void initState() {
    _items = widget.items;
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreItems();
      }
    });
    super.initState();
  }

  Future<void> _loadMoreItems() async {
    if (!_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
      });

      // 模擬一個延遲載入更多項目
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _items.addAll(List<Chat>.generate(
            20,
            (index) => Chat(
                profile: "https://i.imgur.com/91bOTO6.png",
                userName: "さやか${_items.length + index}",
                userID: 1,
                channelID: _items.length + index,
                lastMessage: "おはよう")));
        _isLoadingMore = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _items.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return ChatCard(_items[index]);
      },
    );
  }
}

class ChatCard extends StatelessWidget {
  const ChatCard(this.chatInfo, {super.key});
  final Chat chatInfo;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: chatInfo.profile != null
          ? Image.network(chatInfo.profile!)
          : Image.asset("assets/default_profile.png"),
      title: Text(
        chatInfo.userName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(chatInfo.lastMessage ?? ""),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return ChannelPage(channelID: chatInfo.channelID);
        }));
      },
    );
  }
}
