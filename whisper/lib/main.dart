import 'package:flutter/material.dart';
import 'package:whisper/data/me.dart';
import 'package:whisper/pages/login.dart';
import 'package:whisper/pages/me.dart';
import 'package:whisper/widgets/error.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAPPState();
}

class _MyAPPState extends State<MyApp> {
  Me? me;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MeDataLayer(
        user: me,
        setUser: (user) {
          setState(() {
            me = user;
          });
        },
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
            useMaterial3: true,
          ),
          home: const RoutingLoginOrMe(),
        ));
  }
}

class RoutingLoginOrMe extends StatefulWidget {
  const RoutingLoginOrMe({super.key});

  @override
  State<RoutingLoginOrMe> createState() => _RoutingLoginOrMeState();
}

class _RoutingLoginOrMeState extends State<RoutingLoginOrMe> {
  final Future<(bool, Me?)> _checkKeepLogin =
      Future.delayed(const Duration(seconds: 1), () {
    // throw (Exception("Unexpected Error"));
    return (false, null);
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _checkKeepLogin,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(body: MyErrorWidget(snapshot.error.toString()));
          } else if (snapshot.hasData) {
            if (snapshot.data!.$1 == false) {
              // 渲染登入畫面
              return const LoginPage();
            }
            return const MePage();
          }
          return const Scaffold(
              body: Center(
            child: CircularProgressIndicator(),
          ));
        });
  }
}
