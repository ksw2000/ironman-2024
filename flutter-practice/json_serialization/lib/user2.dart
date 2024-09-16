import 'package:json_annotation/json_annotation.dart';

/// This allows the `User2` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'user2.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()
class User2 {
  final String name;
  final int age;

  User2(this.name, this.age);

  /// A necessary factory constructor for creating a new User2 instance
  /// from a map. Pass the map to the generated `_$User2FromJson()` constructor.
  /// The constructor is named after the source class, in this case, User2.
  factory User2.fromJson(Map<String, dynamic> json) => _$User2FromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$User2ToJson`.
  Map<String, dynamic> toJson() => _$User2ToJson(this);
}
