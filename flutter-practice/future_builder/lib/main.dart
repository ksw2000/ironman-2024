import 'package:flutter/material.dart';
import 'package:future_builder/login_page.dart';
import 'package:future_builder/user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAPPState();
}

class _MyAPPState extends State<MyApp> {
  User? user;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return UserDataLayer(
      user: user,
      setUser: (user) {
        setState(() {
          this.user = user;
        });
      },
      child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const LoginPage()),
    );
  }
}
