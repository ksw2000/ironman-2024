import 'package:flutter/material.dart';
import 'package:whisper/data/me.dart';
import 'package:whisper/pages/me.dart';
import 'package:whisper/pages/signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final idCtrl = TextEditingController();
  final pwdCtrl = TextEditingController();
  bool _isLogging = false;

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
        title: const Text('Whisper'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                "登入",
                style: TextStyle(fontSize: 35),
              ),
              const SizedBox(
                height: 10,
              ),
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
              _isLogging
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLogging = true;
                        });
                        Me.login(idCtrl.text, pwdCtrl.text).then((me) {
                          if (context.mounted) {
                            MeDataLayer.of(context).setUser(me);
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) {
                              return const MePage();
                            }));
                          }
                        }).catchError((err) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("登入失敗：$err")));
                          }
                        }).whenComplete(() {
                          setState(() {
                            _isLogging = false;
                          });
                        });
                      },
                      child: const Text('登入')),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("沒有帳戶嗎？"),
                  TextButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const SignUpPage();
                        }));
                      },
                      child: const Text("馬上註冊"))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
