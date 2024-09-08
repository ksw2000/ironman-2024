import 'package:practice/practice.dart' as practice;
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

void getWeb() async {
  var url =
      Uri.https('www.googleapis.com', '/books/v1/volumes', {'q': '{http}'});

  // Await the http get response, then decode the json-formatted response.
  var response = await http.get(url);
  if (response.statusCode == 200) {
    var jsonResponse =
        convert.jsonDecode(response.body) as Map<String, dynamic>;
    var itemCount = jsonResponse['totalItems'];
    print('Number of books about http: $itemCount.');
  } else {
    print('Request failed with status: ${response.statusCode}.');
  }
}

void main(List<String> arguments) {
  print('Hello world: ${practice.calculate()}!');
  getWeb(); // 異步處理

  print("do something... 1");
  print("do something... 2");
}
