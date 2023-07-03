import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

void main() async {
  // Get the bearer token from somewhere
  String token = "7|W5VhsRJmt7E6FwUi2PANqrZ8iB6EgyoHHjbGEJ8G";
  print("1");
  // Create the request URL
  Uri url = Uri.parse("http://ojt.infoactiv.org/api/employee");

  // Create the headers
  Map<String, String> headers = {
    "Authorization": "Bearer $token",
    "Accept": "application/json"
  };
  print("1");
  // Make the request
  http.Response response = await http.get(url, headers: headers);
  print("1");
  // Check the status code
  if (response.statusCode == 200) {
    // The request was successful, parse the body
    String body = response.body;
    var user = jsonDecode(body);
    print(user);
  } else {
    // The request failed, print the error
    print(response.statusCode);
    print(response.body);
  }
}
