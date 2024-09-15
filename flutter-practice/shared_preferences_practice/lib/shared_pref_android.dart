import 'package:flutter/services.dart';

const platform =
    MethodChannel('com.github.ksw2000.my_shared_preferences_channel');

void sharedPreferenceSet(String key, String value) async {
  await platform
      .invokeMethod('shared_preference_set', {'key': key, 'value': value});
}

Future<dynamic> sharedPreferenceGet(String key) async {
  await platform.invokeMethod('shared_preference_get', {'key': key});
}
