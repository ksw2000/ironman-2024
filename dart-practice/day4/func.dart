int add(int a, int b) {
  return a + b;
}

int add2(int a, int b) => a + b;

void add3(int a, int b, Function callback) {
  callback(a + b);
}

void add4(int a, int b, void Function(int) callback) {
  callback(a + b);
}

int add5({int? a, int? b}) {
  int aa = a ?? 0;
  int bb = b ?? 0;
  return aa + bb;
}

int add6({int a = 0, int b = 0}) {
  return a + b;
}

int add7({required int a, int b = 0}) {
  return a + b;
}

int add8(int a, [int? b, int? c]) {
  return a + (b ?? 0) + (c ?? 0);
}

int add9(int a, [int b = 0, int c = 0]) {
  return a + b + c;
}

void main() {
  print(add(3, 4)); // 7
  print(add2(3, 4)); // 7

  add3(4, 5, (n) {
    print(n); // 9
  });

  add4(6, 7, (e) {
    print(e); // 13
  });

  print(add5(a: 2)); // 2
  print(add5(b: 3)); // 3
  print(add5(a: 2, b: 3)); // 5

  add7(a: 3); // 3
  // add7(b: 3); 編譯不過

  print(add8(2)); // 2
  print(add8(2, 3)); // 5
  print(add8(2, 3, 4)); // 9
}
