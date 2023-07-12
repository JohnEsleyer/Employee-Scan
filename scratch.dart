import 'package:bcrypt/bcrypt.dart';


void main(){
  String storedHashedPassword = r'$2y$10$qjTaoZOOgrZWUx0W2CsbSugYHJYzSyeseEvGvJsEzgHVN0mVupv6G';
  String password = 'password123';

  
  // Check password
  final bool checkPassword = BCrypt.checkpw(password, storedHashedPassword);

  print(checkPassword);
}