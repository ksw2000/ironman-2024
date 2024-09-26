import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameCtrl = TextEditingController();
  final idCtrl = TextEditingController();
  final pwdCtrl = TextEditingController();
  final pwd2Ctrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final scrollCtrl = ScrollController();

  @override
  void dispose() {
    nameCtrl.dispose();
    idCtrl.dispose();
    pwdCtrl.dispose();
    pwd2Ctrl.dispose();
    emailCtrl.dispose();
    scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('註冊'),
      ),
      body: Scrollbar(
        controller: scrollCtrl,
        child: SingleChildScrollView(
          controller: scrollCtrl,
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(hintText: '使用者名稱'),
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
                    controller: idCtrl,
                    decoration: const InputDecoration(hintText: 'Email'),
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
                    height: 10,
                  ),
                  TextField(
                    controller: pwd2Ctrl,
                    obscureText: true,
                    decoration: const InputDecoration(hintText: '確認密碼'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  OutlinedButton(onPressed: () {}, child: const Text("送出"))
                ],
              )),
        ),
      ),
    );
  }
}
