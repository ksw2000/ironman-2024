class User {
  final String name;
  final int age;

  User(this.name, this.age);

  User.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        age = json['age'] as int;

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
      };
}
