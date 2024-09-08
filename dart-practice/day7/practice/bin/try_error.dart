void main(List<String> arguments) {
  try {
    int result = divide(10, 0); // 嘗試除以 0，這會導致錯誤
    print('Result: $result');
  } catch (e) {
    print('Caught an error: $e'); // 捕捉錯誤並輸出錯誤訊息
  } finally {
    print('This block is always executed.'); // 無論是否有錯誤，finally 區塊都會執行
  }

  // Caught an error: Exception: Cannot divide by zero
  // This block is always executed.

  try {
    checkAge(-10);
  } on InvalidAgeException {
    print('Caught InvalidAgeException');
  } catch (e) {
    print('Caught an error: $e');
  }

  // Caught InvalidAgeException

  try {
    checkAge(-10);
  } on InvalidAgeException catch (e) {
    print('Caught $e');
  } catch (e) {
    print('Caught an error: $e');
  }
}

int divide(int a, int b) {
  if (b == 0) {
    throw Exception('Cannot divide by zero'); // 主動拋出 Exception
  }
  return a ~/ b; // 使用 ~/ 進行整數除法
}

void checkAge(int age) {
  if (age < 0) {
    throw InvalidAgeException('Age cannot be negative'); // 拋出自定義錯誤
  } else {
    print('Your age is $age');
  }
}

class InvalidAgeException implements Exception {
  final String message;

  InvalidAgeException(this.message);

  @override
  String toString() {
    return "InvalidAgeException: $message";
  }
}
