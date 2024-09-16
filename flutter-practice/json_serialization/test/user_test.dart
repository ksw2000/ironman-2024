import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:json_serialization/user2.dart';

void main() {
  test('test fromJSON', () {
    const json = '{"name": "日野下花帆", "age": 17}';
    final Map<String, dynamic> jsonMap = jsonDecode(json);

    // 將 JSON 資料轉換為 User2 物件
    final user = User2.fromJson(jsonMap);

    // 驗證物件的屬性是否正確
    expect(user.name, '日野下花帆');
    expect(user.age, 17);
  });

  test('test toJson', () {
    // 創建 User2 物件
    final user = User2('藤島慈', 18);

    // 將物件轉換為 JSON
    final jsonMap = user.toJson();

    // 驗證 JSON 結構
    expect(jsonMap['name'], '藤島慈');
    expect(jsonMap['age'], 18);
  });
}
