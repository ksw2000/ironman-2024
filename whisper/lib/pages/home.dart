import 'package:flutter/material.dart';
import 'package:whisper/data/me.dart';
import 'package:whisper/pages/login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoggingOut = false;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('主頁'),
            const SizedBox(
              height: 20,
            ),
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
    );
  }
}
