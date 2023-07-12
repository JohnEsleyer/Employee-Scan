import 'dart:async';

import 'dart:isolate';

import 'package:connectivity/connectivity.dart';
import 'package:employee_scan/widgets/navbar.dart';
import 'package:employee_scan/screens/ShowAttendanceScreen.dart';
import 'package:employee_scan/screens/ShowEmployeeScreen.dart.dart';
import 'package:employee_scan/widgets/CountdownTimerSync.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/DBProvider.dart';
import '../providers/InternetProvider.dart';

import 'ScanScreen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late InternetProvider internetProvider;
  late ReceivePort receivePort;
  late Isolate? isolate;
  late DatabaseProvider db_provider;
  String debug = '';
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();

    startBackgroundTask();
  }

  @override
  void dispose() {
    stopBackgroundTask();
    super.dispose();
  }

  Future<void> startBackgroundTask() async {
    receivePort = ReceivePort();

    isolate =
        await Isolate.spawn(checkConnectivityInIsolate, receivePort.sendPort);
    receivePort.listen((dynamic message) {
      if (message is bool) {
        internetProvider.setIsConnected(message);
      }
    });
  }

  void stopBackgroundTask() {
    isolate?.kill(priority: Isolate.immediate);
    isolate = null;
    receivePort.close();
  }

  static void checkConnectivityInIsolate(SendPort sendPort) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isConnected = connectivityResult != ConnectivityResult.none;
    sendPort.send(isConnected);

    // Continuously listen for connectivity changes in the isolate
    await for (var result in Connectivity().onConnectivityChanged) {
      final isConnected = result != ConnectivityResult.none;
      sendPort.send(isConnected);
    }
  }

  final List<BottomNavigationBarItem> _bottomNavigationBarItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.people),
      label: 'Attendance',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: 'Scan',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.people),
      label: 'Employee',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    db_provider = Provider.of<DatabaseProvider>(context);
    internetProvider = Provider.of<InternetProvider>(context);

    if (internetProvider.isConnected == true) {
      db_provider.syncAttendance(context);
    }

    final GlobalKey<ScaffoldState> _key = GlobalKey();

    return Scaffold(
      key: _key,
      drawer: Navbar(),
      bottomNavigationBar: BottomNavigationBar(
        items: _bottomNavigationBarItems,
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            _key.currentState!.openDrawer();
          },
          child: Icon(
            Icons.menu,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'Employee Scan',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: [
          internetProvider.isConnected
              ? Padding(
                  padding: const EdgeInsets.only(right: 15, top: 15),
                  child: CountdownTimerSync(
                    duration: 30,
                    onFinished: () {
                      db_provider.syncAttendance(context);
                    },
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Icon(Icons.wifi, color: Colors.red),
                      Text(
                        'Disconnected',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                )
        ],
        backgroundColor: Colors.white,
      ),
      body: _getBody(),
    );
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return ShowAttendanceScreen();
      case 1:
        return QRViewScreen();
      case 2:
        return ShowEmployeeScreen();
      default:
        return Container();
    }
  }
}
