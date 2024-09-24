import 'package:flutter/material.dart';

class Me {
  const Me(
      {required this.uid,
      required this.id,
      required this.name,
      required this.token,
      required this.profile});
  final int uid;
  final String id;
  final String name;
  final String token;
  final String? profile;

  static Future<Me> login(String id, String password) async {
    // TODO 向伺服器發送帳密資訊以請求登入
    await Future.delayed(const Duration(seconds: 1));
    return Future.value(const Me(
        uid: 0,
        id: "kahou0522",
        name: "日野下花帆",
        token: "",
        profile: "https://i.imgur.com/DnhwqwV.png"));
  }

  static Future<void> logout() async {
    // TODO 清除 shared preference
    await Future.delayed(const Duration(seconds: 3));
    return;
  }
}

class MeDataLayer extends InheritedWidget {
  const MeDataLayer(
      {super.key,
      required this.user,
      required this.setUser,
      required super.child});

  final Function(Me? user) setUser;
  final Me? user;

  static MeDataLayer of(BuildContext context) {
    final res = context.dependOnInheritedWidgetOfExactType<MeDataLayer>();
    assert(res != null, 'No UserData found in context');
    return res!;
  }

  @override
  bool updateShouldNotify(MeDataLayer oldWidget) {
    return oldWidget.user != user;
  }
}
