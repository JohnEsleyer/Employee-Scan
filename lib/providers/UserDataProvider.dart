import 'package:flutter/material.dart';



class UserDataProvider extends ChangeNotifier{

  String _token = " ";

  String get getToken => _token;

  void setToken(String token){
    _token = token;
  }

  
}