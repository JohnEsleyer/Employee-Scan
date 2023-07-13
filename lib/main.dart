import 'dart:convert';

import 'package:employee_scan/providers/DBProvider.dart';

import 'package:employee_scan/screens/SettingsScreen.dart';
import 'package:employee_scan/user_defined_functions.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

import 'screens/HomePage.dart';

import 'providers/InternetProvider.dart';
import 'screens/LoginScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create the database file
  String path = await getDatabasesPath();
  String dbPath = join(path, 'local_database.db');

  SharedPreferences prefs = await SharedPreferences.getInstance();

  // If app is initialized for the first time, set first_time to true
  prefs.setBool('first_time', true);

  // Open the database
  Database db = await openDatabase(dbPath, version: 1, onCreate: (db, version) {
    // Create the tables in the database.
    // Only create if app is initialized for the first time
    bool first_time = prefs.getBool('first_time') ?? true;
    if (first_time) {
      db.execute(
          'CREATE TABLE employee (id INTEGER PRIMARY KEY, first_name TEXT, last_name TEXT, department INTEGER);');
      db.execute(
          'CREATE TABLE attendance (id INTEGER PRIMARY KEY, employee_id INTEGER, office_id INTEGER, time_in_am TEXT, time_out_am TEXT, time_in_pm TEXT, time_out_pm TEXT, sync INTEGER);');
      db.execute(
          'CREATE TABLE user (id INTEGER PRIMARY KEY, first_name TEXT, last_name TEXT, username TEXT, password TEXT);');

      // Set first_time to false
      prefs.setBool('first_time', false);
    }
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => InternetProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => DatabaseProvider(db),
        ),
        // ChangeNotifierProvider(
        //   create: (_) => UserDataProvider(),
        // ),
      ],
      child: MaterialApp(
        theme: ThemeData.light(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (_) => LoginScreen(),
          '/home': (_) => HomePage(),
          '/settings': (_) => SettingsScreen(),
        },
      ),
    ),
  );
}

class EmployeeScan extends StatefulWidget {
  @override
  _EmployeeScanState createState() => _EmployeeScanState();
}

class _EmployeeScanState extends State<EmployeeScan> {
  late DatabaseProvider db_provider;

  Future<List<dynamic>> fetchEmployeeList() async {
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
      print("200");
      // The request was successful, parse the JSON
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      print("Error");
      // The request failed, throw an error
      throw Exception('Something went wrong');
    }
  }

  @override
  Widget build(BuildContext context) {
    db_provider = Provider.of<DatabaseProvider>(context);

    return Container(
      child: FutureBuilder(
        future: fetchEmployeeList(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<dynamic>? data = snapshot.data;
            for (int i = 0; i < data!.length; i++) {
              try {
                // Insert data into the database
                db_provider.insertEmployee(data[i]['id'], data[i]['first_name'],
                    data[i]['last_name'], data[i]['department_id']);
              } catch (error) {
                print('Error: Error at inserting employee ($error)');
              }
            }

            Navigator.of(context).popAndPushNamed('/home');

            return Container();
          } else {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}
