mixin Flyable on Animal {
  void fly() {
    print('我在飛！');
  }

  void something() {
    print("Flyable");
  }
}

mixin Jumpable {
  void something() {
    print("Jumpable");
  }
}

class Animal {
  void eat() {
    print('我在吃！');
  }

  void something() {
    print("Animal");
  }
}

class Bird extends Animal with Flyable, Jumpable {
  // Bird 繼承 Animal，並混入 Flyable 的行為
}

void main() {
  Bird bird = Bird();
  bird.eat(); // 我在吃！
  bird.fly(); // 我在飛！
  bird.something(); // Jumpable
}
