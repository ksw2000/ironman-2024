import 'dart:convert';

import 'package:http/http.dart' as http;

const target =
    'https://raw.githubusercontent.com/ksw2000/ironman-2024/master/flutter-practice/http_practice/msg.json';

Future<void> fetchData() async {
  http.get(Uri.parse(target)).then((res) {
    if (res.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(res.body);
      print(data["msg"]);
    }
  });
}
