import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 使用手刻版 Android shared preferences
// import 'package:shared_preferences_practice/shared_pref_android.dart';

// 使用手刻版 Web local storage
// import 'package:shared_preferences_practice/shared_pref_web.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _received;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Flutter Demo Home Page'),
        ),
        // 使用 FutureBuilder 建構
        body: FutureBuilder(
            // 等待 SharedPreferences 初始化
            future: Future.delayed(const Duration(seconds: 2),
                () => SharedPreferences.getInstance()),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      OutlinedButton(
                        child: const Text('Set (foo => bar)'),
                        onPressed: () {
                          final prefs = snapshot.data;
                          prefs?.setString('foo', 'bar');
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      OutlinedButton(
                        child: const Text('Get (foo)'),
                        onPressed: () {
                          final prefs = snapshot.data;
                          final res = prefs?.getString('foo');
                          setState(() {
                            _received = res;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      _received != null ? Text(_received!) : const SizedBox(),
                      const SizedBox(
                        height: 10,
                      ),
                      OutlinedButton(
                        child: const Text('Remove (foo)'),
                        onPressed: () {
                          final prefs = snapshot.data;
                          prefs?.remove('foo');
                          setState(() {
                            _received = "";
                          });
                        },
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                    child: Text("Unexpected error ${snapshot.error}"));
              }
              // 初始化前先放個轉圈圈動畫
              return const Center(child: CircularProgressIndicator());
            }));
  }
}
