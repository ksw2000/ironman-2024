import 'dart:html';

const target =
    'https://raw.githubusercontent.com/ksw2000/ironman-2024/master/flutter-practice/http_practice/msg.json';

Future<void> fetchData() async {
  HttpRequest.getString(target).then((res) {
    print(res);
  });
}
