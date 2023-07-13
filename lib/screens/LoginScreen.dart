import 'package:employee_scan/providers/UserDataProvider.dart';
import 'package:flutter/material.dart';
import 'package:employee_scan/user_defined_functions.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../providers/DBProvider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late bool is_offline;
  late SharedPreferences _prefs;
  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      is_offline = _prefs.getBool('offline_login') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // var db_provider = Provider.of<DatabaseProvider>(context);
    // var temp = db_provider.loginUser('a', 'aaaaaa');
    // print(temp);
    if (is_offline) {
      return LoginScreenOffline();
    }

    return LoginScreenOnline();
  }
}

class LoginScreenOnline extends StatefulWidget {
  const LoginScreenOnline({Key? key}) : super(key: key);

  @override
  _LoginScreenOnlineState createState() => _LoginScreenOnlineState();
}

class _LoginScreenOnlineState extends State<LoginScreenOnline> {
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

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', result['token']);

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

class LoginScreenOffline extends StatefulWidget {
  const LoginScreenOffline({Key? key}) : super(key: key);

  @override
  _LoginScreenOfflineState createState() => _LoginScreenOfflineState();
}

class _LoginScreenOfflineState extends State<LoginScreenOffline> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late DatabaseProvider db_provider;

  bool isSuccess = true;
  bool isWaiting = false;

  @override
  Widget build(BuildContext context) {
    db_provider = Provider.of<DatabaseProvider>(context);
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
          const Text(
            'Offline Mode',
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

                              bool result = await db_provider.loginUser(
                                  _usernameController.text,
                                  _passwordController.text);
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
                                  bool result = await db_provider.loginUser(
                                      _usernameController.text,
                                      _passwordController.text);

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
