void main() {
  var name = ['小櫻', '知世', '小狼'];
  name.add('小可');
  name.add('雪兔');
  print(name);
  // [小櫻, 知世, 小狼, 小可, 雪兔]

  // List<String> name2 = [];
  // List name3 = <String>[];

  // 除了用 var 判定型態也可以使用 List 自動判定
  List group = ['小狼', '小櫻', '小可'];
  List<String> group2 = ['知世', '雪兔', ...group];
  print(group2);
  // [知世, 雪兔, 小狼, 小櫻, 小可]

  print(name.first); // 取得第一個元素:
  print(name.isEmpty); // list 是否為空
  print(name.isNotEmpty); // list 是否不為空
  print(name.length); // 取得 list 長度
  print(name.last); // 取得最後一個元素
  print(name.reversed); // 反轉

  //  小櫻
  // false
  // true
  // 5
  // 雪兔
  // (雪兔, 小可, 小狼, 知世, 小櫻)

  for (int i = 0; i < name.length; i++) {
    print(name[i]);
  }

  for (var n in name) {
    print(n);
  }

  name.forEach((e) {
    print(e);
  });
}
