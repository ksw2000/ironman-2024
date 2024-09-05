void main() {
  var first_publish = {};

  first_publish['go'] = 2009;
  first_publish['rust'] = 2010;
  first_publish['kotlin'] = 2011;
  first_publish['flutter'] = 2017;
  print(first_publish);

  // {go: 2009, rust: 2010, kotlin: 2011, flutter: 2017}

  var first_publish2 = {
    'go': 2019,
    'rust': 2010,
    'kotlin': 2011,
    'flutter': 2017
  };

  // var first_publish3 = <String, int>{};
  // Map<String, int> first_publish4 = {};

  print(first_publish.keys); // 取得鍵的 Iterable 類
  print(first_publish.values); // 取得值的 Iterable 類
  print(first_publish.length); // 取得 map 長度
  print(first_publish.isEmpty); // map 是否為空
  print(first_publish.isNotEmpty); // map 是否非空

  // (go, rust, kotlin, flutter)
  // (2009, 2010, 2011, 2017)
  // 4
  // false
  // true

  var other_first_publish = {
    'c': 1972,
    'c++': 1983,
    'python': 1991,
    'php': 1995,
    'java': 1995,
    'javascript': 1996
  };

  first_publish2.addAll(other_first_publish);
  print(first_publish2);

  // {go: 2019, rust: 2010, kotlin: 2011, flutter: 2017, c: 1972, c++: 1983, python: 1991, php: 1995, java: 1995, javascript: 1996}

  first_publish2.remove('php');
  print(first_publish2);
  // {go: 2019, rust: 2010, kotlin: 2011, flutter: 2017, c: 1972, c++: 1983, python: 1991, java: 1995, javascript: 1996}

  first_publish2.forEach((k, v) {
    print("$k -> $v");
  });

  // go -> 2019
  // rust -> 2010
  // kotlin -> 2011
  // flutter -> 2017
  // c -> 1972
  // c++ -> 1983
  // python -> 1991
  // java -> 1995
  // javascript -> 1996
}
