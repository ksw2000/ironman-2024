class Point {
  double? x;
  double? y;
  Point(double x, double y) {
    this.x = x;
    this.y = y;
  }
  Point.origin() {
    this.x = 0;
    this.y = 0;
  }
}

class Point2 {
  double x;
  double y;
  Point2(this.x, this.y);
  Point2.origin()
      : this.x = 0,
        this.y = 0;
}

class Rectangle {
  double left, top, width, height;

  Rectangle(this.left, this.top, this.width, this.height);

  double getRight() {
    return left + width;
  }

  void setRight(double value) {
    left = value - width;
  }

  double getBottom() {
    return top + height;
  }

  void setBottom(double value) {
    top = value - height;
  }
}

class Rectangle2 {
  double left, top, width, height;

  Rectangle2(this.left, this.top, this.width, this.height);

  // Define two calculated properties: right and bottom.
  double get right => left + width;
  set right(double value) => left = value - width;
  double get bottom => top + height;
  set bottom(double value) => top = value - height;
}

abstract class Animal {
  void bark();
}

class Cat extends Animal {
  @override
  void bark() {
    print("喵");
  }
}

class Dog extends Animal {
  @override
  void bark() {
    print("汪");
  }
}

void barking(Animal m) {
  m.bark();
}

void main() {
  var p = Point(3, 4);
  print("${p.x} ${p.y}"); // 3.0 4.0
  var q = Point.origin();
  print("${q.x} ${q.y}"); // 0.0 0.0

  List<int> list1 = List.filled(5, 1);
  List<int> list2 = List.empty();
  print(list1); //[1, 1, 1, 1, 1]
  print(list2); //[]

  var r = Rectangle(0, 0, 30, 40);
  r.setBottom(50);
  r.setRight(40);
  print("${r.top}, ${r.left}"); // 10.0, 10.0

  var s = Rectangle2(0, 0, 30, 40);
  s.bottom = 50;
  s.right = 40;
  print("${s.top}, ${s.left}"); // 10.0, 10.0

  var cat = Cat(); // cat 的型別是 Cat，同時也符合 Animal
  var dog = Dog(); // dog 的型別是 Dog，同時也符合 Animal
  barking(cat); // barking 吃的型別是 Animal，Cat 符合 Animal
  barking(dog); // barking 吃的型別是 Animal，Dog 符合 Animal
}
