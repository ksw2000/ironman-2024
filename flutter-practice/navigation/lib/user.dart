import 'package:flutter/material.dart';

class User {
  const User({required this.name});
  final String name;
}

class UserDataLayer extends InheritedWidget {
  const UserDataLayer(
      {super.key,
      required this.user,
      required this.setUser,
      required super.child});

  final Function(User user) setUser;
  final User? user;

  static UserDataLayer of(BuildContext context) {
    final res = context.dependOnInheritedWidgetOfExactType<UserDataLayer>();
    assert(res != null, 'No UserData found in context');
    return res!;
  }

  @override
  bool updateShouldNotify(UserDataLayer oldWidget) {
    return oldWidget.user != user;
  }
}
