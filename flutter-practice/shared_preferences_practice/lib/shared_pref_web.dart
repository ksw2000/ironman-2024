import 'dart:js';

void sharedPreferenceSet(String key, String value) {
  context.callMethod('saveData', [key, value]);
}

dynamic sharedPreferenceGet(String key) {
  return context.callMethod('getData', [key]);
}
