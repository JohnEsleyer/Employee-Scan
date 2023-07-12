import 'dart:convert';

import 'package:employee_scan/providers/DBProvider.dart';
import 'package:employee_scan/user_defined_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../providers/UserDataProvider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _offline_login;
  late SharedPreferences _prefs;
  late String _token;
  late DatabaseProvider _db_provider;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _offline_login = _prefs.getBool('offline_login') ?? false;
      // Initialize other settings here
      // ...
    });
  }

  Future<void> _saveSettings() async {
    await _prefs.setBool('offline_login', _offline_login);
    // put all future settings here
    // ...
  }

  Future<void> fetchUsers() async {
    print('Executed fetch Users');
    var url = Uri.parse('$API_URL/users');

    try {
      var headers = {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      };
      var response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        print(response.body);
        List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        
        for (int i = 0; i < data.length; i++) {
          try {
            // Insert data into the database
            _db_provider.insertUser(data[i]['id'], data[i]['first_name'],
                data[i]['last_name'], data[i]['username'],data[i]['password']);
          
          } catch (error) {
            print('Error: Error at inserting user ($error)');
          }
        }
      } else {

      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    _token = Provider.of<UserDataProvider>(context).getToken;
    _db_provider = Provider.of<DatabaseProvider>(context);

    return Scaffold(
      body: Container(
        child: ListView(
          children: [
            SwitchListTile(
              title: Text("Select all"),
              value: _offline_login,
              onChanged: (value) async {
                setState(() {
                  _offline_login = value;
                });
                _saveSettings();
                
                if (value == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Fetching all users from the server...'),
                      showCloseIcon: false,),
                  );
                  print('Before fetch users');
                  await fetchUsers();
                  // ScaffoldMessenger.of(context).clearSnackBars();
                 
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
