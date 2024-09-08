int _fibonacci(int a) {
  if (a == 0) {
    return 0;
  } else if (a == 1) {
    return 1;
  }
  return _fibonacci(a - 1) + _fibonacci(a - 2);
}

Future<int> fibonacci(int a) async {
  if (a < 0) {
    throw Exception('Invalid input');
  }
  return Future.value(_fibonacci(a));
}

void main() {
  fibonacci(20).then((v) {
    print('fibonacci(20) = $v');
  }).catchError((e) {
    print('caught error: $e');
  });

  fibonacci(-1).then((v) {
    print('fibonacci(-1) = $v');
  }).catchError((e) {
    print('caught error: $e');
  });

  print("do something... 1");
  print("do something... 2");
  print("do something... 3");

  // do something... 1
  // do something... 2
  // do something... 3
  // fibonacci(20) = 6765
  // caught error: Exception: Invalid input
}
