import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:employee_scan/providers/db_provider.dart';
import 'package:employee_scan/user_defined_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'database.dart';
import 'navbar.dart';
import 'package:http/http.dart' as http;

import 'scan_screen.dart';
import 'providers/internet_provider.dart';

const API_URL = 'http://ojt.infoactiv.org/api';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create the database file
  String path = await getDatabasesPath();
  String dbPath = join(path, 'local_database.db');

  // Open the database
  Database db = await openDatabase(dbPath, version: 1, onCreate: (db, version) {
    // Create the tables in the database.
    db.execute(
        'CREATE TABLE employee (id INTEGER PRIMARY KEY, first_name TEXT, last_name TEXT, company INTEGER);');
    db.execute(
        'CREATE TABLE attendance (id INTEGER PRIMARY KEY, employee_id TEXT, company_id TEXT, scanner_id TEXT, time_in TEXT, time_out TEXT, date_entered TEXT, sync INTEGER);');
  });

  // Insert data into the database
  // await db.insert('employee', {
  //   'first_name': 'Ralph John',
  //   'last_name': 'Policarpio',
  //   'company': 1
  // });
  // await db.insert('users', {'id': 103, 'name': 'Jane Doe', 'age': 25});
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => InternetProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => DatabaseProvider(db),
        ),
      ],
      child: MaterialApp(
        home: EmployeeScan(),
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
    final response = await http.get(Uri.parse(API_URL + '/employee'));

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
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.light(),
      home: FutureBuilder(
        future: fetchEmployeeList(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<dynamic>? data = snapshot.data;
            for (int i = 0; i < data!.length; i++) {
              // Insert data into the database
              db_provider.insertEmployee(data[i]['id'], data[i]['first_name'],
                  data[i]['last_name'], data[i]['company_id']);
            }

            return HomePage();
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
