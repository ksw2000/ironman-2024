class Animal {
  String name;
  int age;

  Animal(this.name, this.age);

  void makeSound() {
    print('動物在發出聲音...');
  }
}

class Dog extends Animal {
  Dog(String name, int age) : super(name, age);
  // 也可以寫成以下的樣子
  // Dog(super.name, super.age);

  @override
  void makeSound() {
    print('$name 在汪汪叫！');
  }

  void fetch() {
    print('$name 在撿球！');
  }
}

class Cat extends Animal {
  Cat(super.name, super.age);

  @override
  void makeSound() {
    print('$name 在喵喵叫！');
  }
}

void main() {
  Dog myDog = Dog('小黑', 3);
  Cat myCat = Cat('小白', 2);

  myDog.makeSound(); // 小黑 在汪汪叫！
  myDog.fetch(); // 小黑 在撿球！
  myCat.makeSound(); // 小白 在喵喵叫！
}
