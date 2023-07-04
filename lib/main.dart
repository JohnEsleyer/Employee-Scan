import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:employee_scan/providers/DBProvider.dart';
import 'package:employee_scan/providers/UserDataProvider.dart';
import 'package:employee_scan/user_defined_functions.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

import 'screens/HomePage.dart';
import 'screens/ScanScreen.dart';
import 'providers/InternetProvider.dart';
import 'user_defined_functions.dart';

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
        'CREATE TABLE attendance (id INTEGER PRIMARY KEY, employee_id INTEGER, company_id INTEGER, scanner_id INTEGER, time_in TEXT, time_out TEXT, date_entered TEXT, sync INTEGER);');
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
        ChangeNotifierProvider(
          create: (_) => UserDataProvider(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData.light(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (_) => Login(),
          '/home': (_) => EmployeeScan(),
        },
      ),
    ),
  );
}

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isSuccess = true;
  bool isWaiting = false;

  Future<bool> login(BuildContext context) async {
    // Get the username and password from the text fields
    String username = _usernameController.text;
    String password = _passwordController.text;

    // Create the request URL
    Uri url = Uri.parse("$API_URL/login");

    // Create the headers
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json"
    };

    // Create the body of the request
    Map<String, String> body = {
      "username": username,
      "password": password,
    };

    // Make the request
    http.Response response =
        await http.post(url, headers: headers, body: jsonEncode(body));

    // Check the status code
    if (response.statusCode == 200) {
      // The request was successful, parse the body
      String body = response.body;
      var result = jsonDecode(body);

      Provider.of<UserDataProvider>(context, listen: false)
          .setToken(result['token']);

      return true;
    } else {
      // The request failed, print the error
      // print(response.statusCode);
      // print(response.body);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var $ScreenWidth = MediaQuery.of(context).size.width;
    var $ScreenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              color: Colors.blue,
              height: $ScreenWidth * (30 / 100),
              child: Image.asset(
                'assets/placeholder.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            'Login',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 30),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            width: $ScreenWidth * (75 / 100),
            height: $ScreenHeight * (30 / 100),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      offset: Offset(2.0, 2.0),
                      blurRadius: 3.0,
                      spreadRadius: 0.5)
                ]),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: $ScreenWidth * (70 / 100),
                  height: $ScreenWidth * (15 / 100),
                  child: TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                      label: Text('Username'),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  width: $ScreenWidth * (70 / 100),
                  height: $ScreenWidth * (15 / 100),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                      label: Text('Password'),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),

                const SizedBox(
                  height: 15,
                ),
                if (isSuccess == true)
                  SizedBox(
                    width: $ScreenWidth * (50 / 100),
                    child: !isWaiting
                        ? ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                isWaiting = true;
                              });
                              bool result = await login(context);
                              
                              setState(() {
                                isWaiting = false;
                              });
                              if (result) {
                                Navigator.popAndPushNamed(context, '/home');
                              } else {
                                setState(() {
                                  isSuccess = false;
                                });
                              }
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(fontSize: 18),
                            ))
                        : Center(
                          child: CircularProgressIndicator(
                              color: Colors.blue,
                            ),
                        ),
                  )
                else if (isSuccess == false)
                  SizedBox(
                    width: $ScreenWidth * (50 / 100),
                    child: Column(
                      children: [
                        Text(
                          'Login Failed',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                        !isWaiting
                        ? ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                isWaiting = true;
                              });
                              bool result = await login(context);
                              
                              setState(() {
                                isWaiting = false;
                              });
                              if (result) {
                                Navigator.popAndPushNamed(context, '/home');
                              } else {
                                setState(() {
                                  isSuccess = false;
                                });
                              }
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(fontSize: 18),
                            ))
                        : Center(
                          child: CircularProgressIndicator(
                              color: Colors.blue,
                            ),
                        ),
                        
                      ],
                    ),
                  )
              ],
            ),
          )
        ],
      )),
    );
  }
}

class EmployeeScan extends StatefulWidget {
  @override
  _EmployeeScanState createState() => _EmployeeScanState();
}

class _EmployeeScanState extends State<EmployeeScan> {
  late DatabaseProvider db_provider;
  String token = '';

  Future<List<dynamic>> fetchEmployeeList() async {
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
    token = Provider.of<UserDataProvider>(context).getToken;

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
                    data[i]['last_name'], data[i]['company_id']);
              } catch (error) {
                print('Error: Error at inserting employee ($error)');
              }
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
