import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

void main() async {
  final response = await http.get(Uri.parse('http://ojt.infoactiv.org/api/employee'));

    if (response.statusCode == 200) {
      print("200");
      // The request was successful, parse the JSON
      // return jsonDecode(response.body) as List<dynamic>;
    } else {
      print("Error");
      // The request failed, throw an error
      // throw Exception('Something went wrong');
    }
}