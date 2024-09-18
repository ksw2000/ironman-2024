import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:push_notification/firebase_options.dart';
import 'package:push_notification/vapid_key.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print(message);
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // 處理背景通知
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
  String? _message;

  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // 處理前景通知
      StringBuffer stringBuffer = StringBuffer();
      stringBuffer.write("Got a message whilst in the onMessage! \n");
      print("data: ${message.data}");
      message.data.forEach((key, value) {
        stringBuffer.write("key: $key, value: $value\n");
      });
      stringBuffer.write("message id: ${message.messageId}\n");
      stringBuffer.write("title: ${message.notification?.title}\n");
      stringBuffer.write("body: ${message.notification?.body}\n");

      setState(() {
        _message = stringBuffer.toString();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('推播通知演示'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Android 裝置要用 requestPermission 請求開啟
              // Web 可以直接用 getToken 如果沒開權限會要求開
              OutlinedButton(
                  onPressed: () async {
                    final notificationSettings = await FirebaseMessaging
                        .instance
                        .requestPermission(provisional: true);
                    print(notificationSettings.authorizationStatus);
                    switch (notificationSettings.authorizationStatus) {
                      case AuthorizationStatus.authorized:
                      case AuthorizationStatus.provisional:
                        final fcmToken = await FirebaseMessaging.instance
                            .getToken(vapidKey: vapidKey);
                        print(fcmToken);
                      default:
                        print("使用者未開啟權限");
                    }
                  },
                  child: const Text('Android 註冊推播通知')),
              const SizedBox(
                height: 20,
              ),
              OutlinedButton(
                  onPressed: () async {
                    final fcmToken = await FirebaseMessaging.instance
                        .getToken(vapidKey: vapidKey);
                    print(fcmToken);
                  },
                  child: const Text('Web 註冊推播通知')),
              const SizedBox(
                height: 20,
              ),
              _message != null ? Text(_message!) : const SizedBox()
            ],
          ),
        ));
  }
}
