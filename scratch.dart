import 'package:intl/intl.dart';

String convertToFormattedDateTime(String dateTimeString) {
  // Parse the input string to a DateTime object
  DateTime dateTime = DateTime.parse(dateTimeString);

  // Create a DateFormat object with the desired format
  DateFormat dateFormat = DateFormat('yyyy-MM-dd hh:mm a');

  // Format the DateTime object using the DateFormat
  String formattedDateTime = dateFormat.format(dateTime);

  return formattedDateTime;
}

void main(){
  var timeNow = DateTime.now();
  print(convertToFormattedDateTime(timeNow.toString()));
}