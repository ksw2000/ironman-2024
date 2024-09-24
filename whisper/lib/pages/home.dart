import 'package:flutter/material.dart';
import 'package:whisper/data/me.dart';
import 'package:whisper/data/friend.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollCtrl = ScrollController();
  final List<Friend> _friendList = [];
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

  Future<void> _loadMoreItems() async {
    if (!_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
      });

      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _friendList.addAll(List<Friend>.generate(
            20,
            (index) => Friend(
                profile: "https://i.imgur.com/91bOTO6.png",
                userName: "さやか-${index + _friendList.length}",
                userID: 1,
                channelID: 0)));
        _isLoadingMore = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Me me = MeDataLayer.of(context).user!;

    return Scrollbar(
      controller: _scrollCtrl,
      child: CustomScrollView(
        controller: _scrollCtrl,
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                ListTile(
                  leading: me.profile == null
                      ? Image.asset("assets/default_profile.png")
                      : Image.network(me.profile!),
                  title: Text(
                    me.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                  child: Text("朋友",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                )
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => FriendCard(
                friend: _friendList[index],
              ),
              childCount: _friendList.length,
            ),
          ),
          SliverToBoxAdapter(
              child: Center(
            child: _isLoadingMore
                ? const CircularProgressIndicator()
                : const SizedBox(),
          ))
        ],
      ),
    );
  }
}

class FriendCard extends StatelessWidget {
  const FriendCard({super.key, required this.friend});
  final Friend friend;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      leading: friend.profile == null
          ? Image.asset("assets/default_profile.png")
          : Image.network(friend.profile!),
      title: Text(friend.userName),
      onTap: () {
        // TODO
        print("go to ${friend.channelID}");
      },
    );
  }
}
