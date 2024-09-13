import 'dart:convert';
import 'dart:io';

const target =
    'https://raw.githubusercontent.com/ksw2000/ironman-2024/master/flutter-practice/http_practice/msg.json';

// Future<void> fetchData() async {
//   HttpRequest.getString(target).then((res) {
//     print(res);
//   });
// }

Future<void> fetchData() async {
  var client = HttpClient();
  try {
    var req = await client.getUrl(Uri.parse(target));
    var res = await req.close();
    if (res.statusCode == 200) {
      var responseBody = await res.transform(utf8.decoder).join();
      print('Response: $responseBody');
    } else {
      print('Error: ${res.statusCode}');
    }
  } catch (e) {
    print('Request failed: $e');
  } finally {
    client.close();
  }
}
