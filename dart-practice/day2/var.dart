void main() {
  // 使用 var 自動判定型別
  // var name = 'Voyager I';
  // var year = 1977;
  // var antennaDiameter = 3.7;

  // 手動賦予型別
  // String name2 = '坂倉';
  // int year2 = 2004;
  // double pi = 3.14;
  // bool yes = true; // 在 dart 中布林值為全小寫，跟 Python 不一樣
  // bool no = false;

  int x = 10;
  print(x / 3); // 3.3333333333333335
  print(x ~/ 3); // 3

  int a = 10;
  print("int a = $a"); // int a = 10

  print("Is a larger than 5 ... ${a > 5 ? "yes" : "no"}");
  // is a larger than 5 ... yes

  print("\$a $a"); // $a 10

  var s1 = 'String '
      'concatenation'
      " works even over line breaks.";

  var s2 = 'String concatenation works even over line breaks.';

  print("is s1 == s2? ${s1 == s2}"); // is s1 == s2? true

  var s3 = '''
You can create
multi-line strings like this one.
''';

  var s4 = """This is also a
multi-line string.""";

  print(s3);
  print(s4);
}
