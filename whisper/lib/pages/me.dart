import 'package:flutter/material.dart';
import 'package:whisper/data/me.dart';
import 'package:whisper/pages/login.dart';
// import 'package:whisper/pages/login.dart';

class MePage extends StatefulWidget {
  const MePage({super.key});

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('聊天主畫面'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Hello ${MeDataLayer.of(context).user?.name}'),
              const SizedBox(
                height: 20,
              ),
              _isLoggingOut
                  ? const CircularProgressIndicator()
                  : OutlinedButton(
                      onPressed: () async {
                        setState(() {
                          _isLoggingOut = true;
                        });
                        await Me.logout();
                        if (context.mounted) {
                          MeDataLayer.of(context).setUser(null);
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return const LoginPage();
                          }));
                        }
                        setState(() {
                          _isLoggingOut = false;
                        });
                      },
                      child: const Text("登出")),
            ],
          ),
        ),
      ),
    );
  }
}
