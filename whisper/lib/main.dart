import 'package:flutter/material.dart';
import 'package:whisper/data/me.dart';
import 'package:whisper/pages/login.dart';
import 'package:whisper/pages/me.dart';

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
      Future.delayed(const Duration(seconds: 3), () {
    return (false, null);
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _checkKeepLogin,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
                appBar: AppBar(
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  title: const Text('登入 Whisper'),
                ),
                body: Center(
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
                )));
          } else if (snapshot.hasData) {
            if (snapshot.data!.$1 == false) {
              // 渲染登入畫面
              return const LoginPage();
            }
            return const MePage();
          }
          return Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: const Text('登入 Whisper'),
              ),
              body: const Center(
                child: CircularProgressIndicator(),
              ));
        });
  }
}
