import 'dart:isolate';

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
  return await Isolate.run(() => _fibonacci(a));
}

void main() {
  fibonacci(40).then((v) {
    print('fibonacci(40) = $v');
  }).catchError((e) {
    print('caught error: $e');
  });

  print("do something... 1");
  print("do something... 2");
  print("do something... 3");
}
