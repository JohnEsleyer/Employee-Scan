import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee_scan/database/db_provider.dart';
import 'package:employee_scan/user_defined_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'database.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // Create the database file
  String path = await getDatabasesPath();
  String dbPath = join(path, 'local_database.db');

  // Open the database
  Database db = await openDatabase(dbPath, version: 1, onCreate: (db, version) {
    // Create the tables in the database.
    db.execute(
        'CREATE TABLE employee (id INTEGER PRIMARY KEY, first_name TEXT, last_name TEXT, company TEXT);');
    db.execute(
        'CREATE TABLE attendance (id INTEGER PRIMARY KEY, employee_id TEXT, company_id TEXT, scanner_id TEXT, time_in TEXT, time_out TEXT, date_entered TEXT);');
  });

  // Insert data into the database
  await db.insert('employee', {
    'first_name': 'Ralph John',
    'last_name': 'Policarpio',
    'company': 'InfoActiv'
  });
  // await db.insert('users', {'id': 103, 'name': 'Jane Doe', 'age': 25});
  runApp(
    ChangeNotifierProvider(
      create: (_) => DatabaseProvider(db),
      child: MaterialApp(home: MyApp()),
    ),
  );
}

// Temporary screen
// class MyApp2 extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: FutureBuilder(
//           future: Provider.of<DatabaseProvider>(context).getEmployeeById(101),
//           builder: (context, snapshot) {
//             if (snapshot.hasData) {
//               return Text(snapshot.data?['first_name']);
//             } else {
//               return Text("...");
//             }
//           },
//         ),
//       ),
//     );
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: MyHome(),
    );
  }
}

class MyHome extends StatelessWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Demo Home Page')),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const QRViewExample(),
                ));
              },
              child: const Text('qrView'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SQLiteScreen(),
                ));
              },
              child: const Text('Show Employee'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SQLiteScreen2(),
                ));
              },
              child: const Text('Show Attendance'),
            ),
          ],
        ),
      ),
    );
  }
}

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  String? first_name;
  String? last_name;
  String? department;
  String? scan_status;
  String temp = " ";
  Barcode? result;
  Color borderColor = Color.fromARGB(255, 255, 255, 255);
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late DatabaseProvider db_provider;
  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    db_provider = Provider.of<DatabaseProvider>(context);
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  // if (result != null)
                  //   Text(
                  //       'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
                  // else
                  //   const Text('Scan a code'),
                  Text(temp),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                            onPressed: () async {
                              await controller?.toggleFlash();
                              setState(() {});
                            },
                            child: FutureBuilder(
                              future: controller?.getFlashStatus(),
                              builder: (context, snapshot) {
                                return Text('Flash: ${snapshot.data}');
                              },
                            )),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                            onPressed: () async {
                              await controller?.flipCamera();
                              setState(() {});
                            },
                            child: FutureBuilder(
                              future: controller?.getCameraInfo(),
                              builder: (context, snapshot) {
                                if (snapshot.data != null) {
                                  return Text(
                                      'Camera facing ${describeEnum(snapshot.data!)}');
                                } else {
                                  return const Text('loading');
                                }
                              },
                            )),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await controller?.pauseCamera();
                          },
                          child: const Text('pause',
                              style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await controller?.resumeCamera();
                            setState(() {
                              borderColor = Color.fromARGB(255, 255, 255, 255);
                            });
                          },
                          child: const Text('resume',
                              style: TextStyle(fontSize: 20)),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: borderColor,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    final dbHelper = DatabaseHelper();
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      await controller.pauseCamera(); // Pause camera
      setState(() {
        borderColor = Color.fromARGB(255, 17, 139, 10);
      });
      // Check if data is JSON
      if (isJSON(scanData.code as String)) {
        Map<String, dynamic> data = jsonDecode(scanData.code as String);
        setState(() {
          temp = "Is JSON";
        });
        // Check if qr code belongs to the company
        if (data['company'] == 111) {
          setState(() {
            temp = "Infoactiv";
          });

          // Check employee existence
          bool employeeExists =
              await db_provider.isEmployeeExists(data['employee']);
          if (employeeExists) {
            setState(() {
              temp = 'OK';
            });

            // CollectionReference attendance = firestore.collection("Attendance");
            // attendance
            //     .add({
            //       'company': data['company'],
            //       'employee': data['employee'],
            //       'date_entered': Timestamp.fromDate(DateTime.now()),
            //     })
            //     .then((value) => setState(() {
            //           temp = 'Attendance Recorded';
            //         }))
            //     .catchError((error) {
            //       setState(() {
            //         temp = 'Failed to record attendance!';
            //       });
            //     });

            // Check if employee was already recorded
            DateTime currentDate = DateTime.now();
            String formattedDate = DateFormat('MM/dd/yyyy').format(currentDate);
            String formattedTime = DateFormat('HH:mm a').format(currentDate);
            bool recordExists = await db_provider.isAttendanceRecordExistsDate(
                data['employee'], formattedDate);
            if (recordExists) {
              Map<String, dynamic> attendanceRecord =
                  await db_provider.getAttendanceByEmployeeIdAndCompany(
                      data['employee'], data['company']);
              if (attendanceRecord.isNotEmpty) {
                // Process the retrieved attendance record
                String timeIn = attendanceRecord['time_in'];
                String timeOut = attendanceRecord['time_out'];

                temp = 'Time In: $timeIn, Time Out: $timeOut';

                if (timeOut == 'not set') {
                  // Update timeOut
                  await db_provider.getAttendanceByEmployeeIdAndCompany(
                    data['employee'],
                    data['company'],
                  );
                } else {
                  temp = 'attendance was already set';
                }
              } else {
                temp = 'No attendance record found ';
              }
            } else {
              // Generate a v4 (random) UUID
              var uuid = Uuid();
              String randomUuid = uuid.v4();

              await db_provider.insertAttendance(data['employee'],
                  data['company'], 1, formattedTime, 'not set', formattedDate);
              temp = 'attendance recorded';
            }
          } else {
            setState(() {
              temp = 'Employee not found!';
            });
          }
        } else {
          setState(() {
            temp = "Does not belong!";
          });
        }
      } else {
        setState(() {
          temp = "Not JSON";
          borderColor = Color.fromARGB(255, 242, 38, 38);
        });
      }
      setState(() {
        result = scanData;
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

// SQLite Screen
class SQLiteScreen extends StatefulWidget {
  @override
  _SQLiteScreen createState() => _SQLiteScreen();
}

class _SQLiteScreen extends State<SQLiteScreen> {
  late DatabaseProvider db_provider;
  @override
  Widget build(BuildContext context) {
    db_provider = Provider.of<DatabaseProvider>(context);
    return Scaffold(
      body: Container(
        child: FutureBuilder(
          future: db_provider.getAllEmployeeRecords(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Map<String, dynamic>>? employeeRecords = snapshot.data;
              return ListView.builder(
                  itemCount: employeeRecords!.length,
                  itemBuilder: ((context, index) {
                    Map<String, dynamic> employeeRecord =
                        employeeRecords[index];
                    return ListTile(
                      title: Text(employeeRecord['first_name'] +
                          ' ' +
                          employeeRecord['last_name']),
                      subtitle: Text(employeeRecord['id'].toString()),
                    );
                  }));
            } else {
              return CircularProgressIndicator(
                color: Colors.blue,
              );
            }
          },
        ),
      ),
    );
  }
}

class SQLiteScreen2 extends StatefulWidget {
  @override
  _SQLiteScreen2State createState() => _SQLiteScreen2State();
}

class _SQLiteScreen2State extends State<SQLiteScreen2> {
  late DatabaseProvider db_provider;
  @override
  Widget build(BuildContext context) {
    db_provider = Provider.of<DatabaseProvider>(context);
    return Scaffold(
      body: Container(
        child: FutureBuilder(
          future: db_provider.getAllAttendanceRecords(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Map<String, dynamic>>? attendanceRecords = snapshot.data;
              return ListView.builder(
                  itemCount: attendanceRecords!.length,
                  itemBuilder: ((context, index) {
                    Map<String, dynamic> attendanceRecord =
                        attendanceRecords[index];
                    return ListTile(
                      title: Text('Employee: ' +
                          attendanceRecord['employee_id'] +
                          ' ' +
                          'Company: ' +
                          attendanceRecord['company_id']),
                      subtitle: Text(attendanceRecord['id'].toString()),
                    );
                  }));
            } else {
              return CircularProgressIndicator(color: Colors.blue);
            }
          },
        ),
      ),
    );
  }
}
