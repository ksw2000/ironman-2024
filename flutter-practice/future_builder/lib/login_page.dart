import 'package:flutter/material.dart';
import 'package:future_builder/user.dart';
import 'package:future_builder/user_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final idCtrl = TextEditingController();
  final pwdCtrl = TextEditingController();

  @override
  void dispose() {
    idCtrl.dispose();
    pwdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Login Page'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: idCtrl,
                decoration: const InputDecoration(hintText: '帳號'),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: pwdCtrl,
                obscureText: true,
                decoration: const InputDecoration(hintText: '密碼'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    UserDataLayer.of(context).setUser(User(name: idCtrl.text));
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return UserPage();
                    }));
                  },
                  child: const Text('登入'))
            ],
          ),
        ),
      ),
    );
  }
}
