class A {
  void a() {
    print("A.a()");
  }
}

class B {
  void b() {
    print("B.a()");
  }
}

class C {
  void c() {
    print("C.c()");
  }
}

class D extends C implements A, B {
  @override
  void a() {
    print("D.a()");
  }

  @override
  void b() {
    print("D.b()");
  }
}

// interface class
// class A 可以被繼承
class E extends A {}

interface class AA {
  void aa() {
    print("AA.aa()");
  }
}

// interface class AA 只能被實作
class F implements AA {
  @override
  void aa() {
    print("F.aa()");
  }
}

// abstract interface class

abstract interface class AAA {
  void aaa() {
    print("aaa");
  }
}

void main() {
  var d = D();
  d.a(); // D.a()
  d.b(); // D.b()
  d.c(); // C.c()

  var e = E();
  e.a(); // A.a()

  var f = F();
  f.aa(); // F.aa()

  var aa = AA();
  aa.aa(); // AA.aa()

  // Error!
  // Abstract classes can't be instantiated.
  // var aaa = AAA();
}
