import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:employee_scan/user_defined_functions.dart';

import 'dart:convert';

import '../providers/DBProvider.dart';

class ShowEmployeeScreen extends StatefulWidget {
  @override
  _ShowEmployeeScreen createState() => _ShowEmployeeScreen();
}

class _ShowEmployeeScreen extends State<ShowEmployeeScreen> {
  late DatabaseProvider db_provider;
  late List<dynamic> _employees;
  late bool _loading;

  @override 
  void initState(){
    super.initState();
    setState(() {
      _loading = true;
    });
    _obtainEmployees();
    
  }

  Future<void> _obtainEmployees() async {
     SharedPreferences prefs = await SharedPreferences.getInstance();

    String token = prefs.getString('token') ?? '';
    Map<String, String> headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
      "Accept": "application/json"
    };

    final response = await http.get(
      Uri.parse(API_URL + '/employee'),
      headers: headers,
    );

    if (response.statusCode == 200) {

      // The request was successful, parse the JSON
      var data = jsonDecode(response.body);
      
      setState(() {
        _employees = data;
      });
    
      setState(() {
      _loading = false;
    });
    } else {
      print("Error");
      // The request failed, throw an error
      throw Exception('Something went wrong');
    }
  }

  @override
  Widget build(BuildContext context) {
    db_provider = Provider.of<DatabaseProvider>(context);
    return Scaffold(
      body: Container(
        child: !_loading ? RefreshIndicator(
          onRefresh: _obtainEmployees,
          child: ListView.builder(
            itemCount: _employees.length,
            itemBuilder:(context, index) {
              Map<String, dynamic> employeeRecord = _employees[index];
              return ListTile(
                title: Text('${employeeRecord['id']}'),
              );
            },
          ),
        ) : Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
