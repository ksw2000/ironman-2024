void main() {
  var n = 15;
  if (n % 2 == 1) {
    print("$n is odd");
  } else {
    print("$n is even");
  }
  // 15 is odd

  var m = 10;
  if (m == 0) {
    print("$m is 0");
  } else if (m > 0) {
    print("$m is larger than 0");
  } else {
    print("$m is less than 0");
  }
  // 10 is larger than 0

  int num = 5;
  String isEven = num & 1 == 1 ? "odd" : "even";
  print("$num is $isEven");
  // 5 is odd

  int x = 5;
  switch (x) {
    case 1:
      print(1);
    case 2:
      print(2);
    default:
      print("other");
  }
  // other

  int y = 5;
  switch (y) {
    case 1:
    case 2:
    case 3:
    case 4:
      print("1~4");
    // break; (這裡才會 break)
    case 5:
    case 6:
    case 7:
    case 8:
      print("5~8");
    // break; (這裡才會 break)
    default:
      print("other");
  }

  for (int i = 0; i < 5; i++) {
    print(i);
  }
  // 0
  // 1
  // 2
  // 3
  // 4

  l1:
  for (var i = 0; i < 10; i++) {
    l2:
    for (var j = 0; j < 9; j++) {
      if (j == 2) {
        break l2;
      }
      if (i == 5) {
        break l1;
      }
      print("i:$i j:$j");
    }
  }

  // i:0 j:0
  // i:0 j:1
  // i:1 j:0
  // i:1 j:1
  // i:2 j:0
  // i:2 j:1
  // i:3 j:0
  // i:3 j:1
  // i:4 j:0
  // i:4 j:1

  int i = 0;
  while (i < 5) {
    print(i);
    i++;
  }

  // 0
  // 1
  // 2
  // 3
  // 4

  print("--");

  do {
    print(i);
    i++;
  } while (i < 10);

  // 5
  // 6
  // 7
  // 8
  // 9
}
