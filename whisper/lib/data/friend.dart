import 'package:flutter/material.dart';

class Friend {
  Friend(
      {required this.profile,
      required this.userName,
      required this.userID,
      required this.channelID});
  String? profile;
  String userName;
  int userID;
  int channelID;
}

class FriendListDataLayer extends InheritedWidget {
  const FriendListDataLayer(
      {super.key,
      required this.list,
      required this.setFriendList,
      required super.child});

  final Function(List<Friend>) setFriendList;
  final List<Friend> list;

  static FriendListDataLayer of(BuildContext context) {
    final res =
        context.dependOnInheritedWidgetOfExactType<FriendListDataLayer>();
    assert(res != null, 'No UserData found in context');
    return res!;
  }

  @override
  bool updateShouldNotify(FriendListDataLayer oldWidget) {
    return oldWidget.list != list;
  }
}
