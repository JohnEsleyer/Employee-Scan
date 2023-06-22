import 'dart:convert';

// Identify is string is JSON
bool isJSON(String? string) {
  try {
    json.decode(string as String);
    return true;
  } on FormatException {
    return false;
  }
}
