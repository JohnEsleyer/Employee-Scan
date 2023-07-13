import 'dart:convert';

import 'package:employee_scan/providers/DBProvider.dart';
import 'package:employee_scan/user_defined_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:toggle_switch/toggle_switch.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _offline_login;
  late bool _auto_sync;
  late int _seconds;
  late SharedPreferences _prefs;

  late DatabaseProvider db_provider;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _offline_login = _prefs.getBool('offline_login') ?? false;
      _auto_sync = _prefs.getBool('auto_sync') ?? true;
      _seconds = _prefs.getInt('seconds') ?? 0;
      // Initialize other settings here
      // ...
    });
  }

  Future<void> _saveSettings() async {
    await _prefs.setBool('offline_login', _offline_login);
    await _prefs.setBool('auto_sync', _auto_sync);
    await _prefs.setInt('seconds', _seconds);
    // put all future settings here
    // ...
  }

  Future<void> fetchUsers() async {
    String token = _prefs.getString('token') ?? '';
    var url = Uri.parse(API_URL + '/users');
    Map<String, String> headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
      "Accept": "application/json"
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body) as List<dynamic>;

      for (int i = 0; i < data.length; i++) {
        try {
          // Insert data into the database
          db_provider.insertUser(data[i]['id'], data[i]['first_name'],
              data[i]['last_name'], data[i]['username'], data[i]['password']);
        } catch (error) {
          print('Error: Error at inserting user ($error)');
        }
      }
    } else {
      print('Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    db_provider = Provider.of<DatabaseProvider>(context);

    List<String> durations = [
      '30',
      '60',
      '300',
    ];
    return Scaffold(
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              SwitchListTile(
                title: Text("Offline Login"),
                value: _offline_login,
                onChanged: (value) async {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  setState(() {
                    _offline_login = value;
                  });
                  _saveSettings();

                  if (value == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Downloading all users from the server...'),
                        showCloseIcon: false,
                      ),
                    );

                    await fetchUsers();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('All users\' data downloaded successfully.'),
                        showCloseIcon: false,
                      ),
                    );
                  }
                },
                subtitle: Text(
                    'When enabled, the app will automatically download all the users\' data from the server for offline use'),
              ),
              SwitchListTile(
                title: Text("Auto-sync"),
                value: _auto_sync,
                onChanged: (value) async {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  setState(() {
                    _auto_sync = value;
                  });
                  _saveSettings();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'This toggle requires restarting the app to take effect.'),
                      showCloseIcon: false,
                    ),
                  );
                },
                subtitle: Text(
                    'Attendance stored locally will be sent to the server every 30/60/300 seconds. This will also sync all employee data.'),
              ),
              Center(
                child: Column(
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: _seconds,
                      inactiveBgColor: Colors.white,
                      totalSwitches: 3,
                      labels: durations,
                      onToggle: (index) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        setState(() {
                          _seconds = index ?? 0;
                        });
                        _saveSettings();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'You set the sync countdown to ${durations[index ?? 0]} seconds. This toggle requires restarting the app to take effect.'),
                            showCloseIcon: false,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text('Sync Attendance and Employee'),
                subtitle: Text(
                    'This will only send records that have set all time ins and time outs. The employee records stored in this device will be updated.'),
                trailing: ElevatedButton(
                  child: Text('Send'),
                  onPressed: () {
                    db_provider.sync();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
