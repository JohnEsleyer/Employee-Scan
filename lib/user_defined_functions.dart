import 'dart:convert';
import 'package:http/http.dart' as http;

// Identify is string is JSON
bool isJSON(String? string) {
  try {
    json.decode(string as String);
    return true;
  } on FormatException {
    return false;
  }
}

Future<List<dynamic>> fetchDataList(String url) async {
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    // The request was successful, parse the JSON
    return jsonDecode(response.body) as List<dynamic>;
  } else {
    // The request failed, throw an error
    throw Exception('Something went wrong');
  }
}