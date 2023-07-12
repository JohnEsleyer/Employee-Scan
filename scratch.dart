// import 'package:bcrypt/bcrypt.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:employee_scan/user_defined_functions.dart';

void main() async {
 Map<String, String> headers = {
      "Authorization": "Bearer 22|nIeaEzFl4dijt0nBjJ9zkIaYIlHvlP0HfMA6vBOa",
      "Content-Type": "application/json",
      "Accept": "application/json"
    };

    final response = await http.get(
      Uri.parse(API_URL + '/users'),
      headers: headers,
    );
    try {
       if (response.statusCode == 200) {
      print("200");
      // The request was successful, parse the JSON
      print(response.body);
    } else {
      print("Error");
      // The request failed, throw an error
      // throw Exception('Something went wrong');
    }
    }catch(e){
      print(e);
    }
   
}



// void main(){
//   String storedHashedPassword = r'$2y$10$qjTaoZOOgrZWUx0W2CsbSugYHJYzSyeseEvGvJsEzgHVN0mVupv6G';
//   String password = 'password123';

  
//   // Check password
//   final bool checkPassword = BCrypt.checkpw(password, storedHashedPassword);

//   print(checkPassword);
// }