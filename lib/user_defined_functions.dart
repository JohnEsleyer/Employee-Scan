import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


// Constants
const API_URL = 'https://ojt.infoactiv.org/api';

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

String convertToFormattedDateTime(String dateTimeString) {

  if (dateTimeString != 'not set'){
    // Parse the input string to a DateTime object
    DateTime dateTime = DateTime.parse(dateTimeString);

    // Create a DateFormat object with the desired format
    DateFormat dateFormat = DateFormat('yyyy-MM-dd hh:mm a');

    // Format the DateTime object using the DateFormat
    String formattedDateTime = dateFormat.format(dateTime);

    return formattedDateTime;
  }else{
    return 'not set';
  }
}
