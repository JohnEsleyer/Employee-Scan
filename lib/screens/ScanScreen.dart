import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:employee_scan/widgets/CountdownTimer.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../widgets/navbar.dart';

import '../providers/DBProvider.dart';

import '../user_defined_functions.dart';

class QRViewScreen extends StatefulWidget {
  const QRViewScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewScreenState();
}

class _QRViewScreenState extends State<QRViewScreen> {
  Color borderColor = Color.fromARGB(255, 255, 255, 255);
  QRViewController? controller;
  late DatabaseProvider db_provider;
  String? department;
  bool didScan = false;
  String first_name = " ";
  int? id;
  String last_name = " ";
  bool notJSON = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  String? scan_status;
  String temp = " ";

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

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
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        didScan = true;
      });
      await controller.pauseCamera(); // Pause camera
      setState(() {
        borderColor = Color.fromARGB(255, 17, 139, 10);
      });
      // Check if data is JSON
      if (isJSON(scanData.code as String)) {
        notJSON = false;
        Map<String, dynamic> data = jsonDecode(scanData.code as String);
        setState(() {
          temp = "Is JSON";
        });
        // Check if qr code belongs to the company

        // Check employee existence
        bool employeeExists =
            await db_provider.isEmployeeExists(data['employee']);
        if (employeeExists) {
          setState(() {
            temp = 'OK';
          });

          // Check if employee was already recorded
          DateTime currentDate = DateTime.now();

          bool recordExists =
              await db_provider.isAttendanceRecordExists(data['employee']);
          if (recordExists) {
            Map<String, dynamic> attendanceRecord =
                await db_provider.getAttendanceByEmployeeId(data['employee']);
            if (attendanceRecord.isNotEmpty) {
              // Process the retrieved attendance record

              String timeOutAM = attendanceRecord['time_out_am'];


              if (timeOutAM == 'not set') {
                temp = 'not set';
                // Update timeOut
                await db_provider.updateTimeOutAM(
                    data['employee'], currentDate.toString());
                Map<String, dynamic>? employee =
                    await db_provider.getEmployeeById(data['employee']);
                setState(() {
                  temp = 'Time out recorded!';
                  id = data['employee'];
                  first_name = employee?['first_name'];
                  last_name = employee?['last_name'];
                });
              } else {
                String timeInPM = attendanceRecord['time_in_pm'];

                if (timeInPM == 'not set'){
                  temp = 'not set';
                  // Update timeOut
                  await db_provider.updateTimeInPM(
                      data['employee'], currentDate.toString());
                  Map<String, dynamic>? employee =
                      await db_provider.getEmployeeById(data['employee']);
                  setState(() {
                    temp = 'Time in recorded!';
                    id = data['employee'];
                    first_name = employee?['first_name'];
                    last_name = employee?['last_name'];
                  });
                }else{
                  String timeOutPM = attendanceRecord['time_out_pm'];

                  if (timeOutPM == 'not set'){
                     temp = 'not set';
                    // Update timeOut
                    await db_provider.updateTimeOutPM(
                        data['employee'], currentDate.toString());
                    Map<String, dynamic>? employee =
                        await db_provider.getEmployeeById(data['employee']);
                    setState(() {
                      temp = 'Time out recorded!';
                      id = data['employee'];
                      first_name = employee?['first_name'];
                      last_name = employee?['last_name'];
                    });
                  }else{
                    Map<String, dynamic>? employee =
                    await db_provider.getEmployeeById(data['employee']);
                    setState(() {
                      id = data['employee'];
                      first_name = employee?['first_name'];
                      last_name = employee?['last_name'];
                      temp = 'Attendance was already set for today';
                      borderColor = Colors.amber;
                    });

                  }

                }
                
                
              }
            } else {
              temp = 'No attendance record found ';
            }
          } else {
            // Generate a v4 (random) UUID
            // var uuid = Uuid();
            // String randomUuid = uuid.v4();

            await db_provider.insertAttendance(
              data['employee'],
              1,
              currentDate.toString(),
              'not set',
              'not set',
              'not set',
            );

            Map<String, dynamic>? employee =
                await db_provider.getEmployeeById(data['employee']);
            setState(() {
              temp = 'Time in recorded!';
              id = data['employee'];
              first_name = employee?['first_name'];
              last_name = employee?['last_name'];
            });
          }
        } else {
          setState(() {
            temp = 'Employee not found!';
          });
        }
      } else {
        setState(() {
          notJSON = true;
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
  Widget build(BuildContext context) {
    var $ScreenWidth = MediaQuery.of(context).size.width;
    var $ScreenHeight = MediaQuery.of(context).size.height;
    var $generalCam = 250.0;
    // var $logoPercentage = 10;

    db_provider = Provider.of<DatabaseProvider>(context);
    return Scaffold(
        key: scaffoldKey,
        drawer: const Navbar(),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),

              // ignore: sized_box_for_whitespace
              GestureDetector(
                onDoubleTap: () async {
                  await controller?.flipCamera();
                  setState(() {});
                },
                // onTap: () async {
                //   await controller?.pauseCamera();
                //   setState(() {});
                // },
                child: Container(
                  width: $generalCam,
                  height: $generalCam,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  // color: Colors.blue,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: QRView(
                      key: qrKey,
                      onQRViewCreated: _onQRViewCreated,
                      onPermissionSet: (ctrl, p) =>
                          _onPermissionSet(context, ctrl, p),
                      overlay: QrScannerOverlayShape(
                        borderColor: borderColor,
                        borderRadius: 20,
                        borderLength: 40,
                        borderWidth: 15,
                        cutOutSize: $generalCam,
                      ),
                      // onQRViewCreated: onQRViewCreated
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text("Double tap to flip the camera"),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                // ignore: sized_box_for_whitespace
                child: Container(
                  width: $ScreenWidth,
                  // color: Colors.white,
                  child: Column(
                    children: [
                      (didScan)
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CountdownTimer(
                                  duration: 3,
                                  onFinished: () {
                                    controller?.resumeCamera();
                                    setState(() {
                                      didScan = false;
                                      borderColor =
                                          Color.fromARGB(255, 255, 255, 255);
                                    });
                                  }),
                            )
                          : Container(),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                          width: $ScreenWidth * (70 / 100),
                          height: $ScreenHeight * (30 / 100),
                          padding: const EdgeInsets.all(15),
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
                            children: [
                              SizedBox(
                                width: $ScreenWidth,
                                height: 30,
                                child: const Text(
                                  'ID Number',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Divider(
                                height: 2,
                                thickness: 1,
                                indent: 0,
                                endIndent: 0,
                                color: Colors.black45,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              (!notJSON)
                                  ? Container(
                                      child: (temp == 'Employee not found!')
                                          ? SizedBox(
                                              width: $ScreenWidth,
                                              // height: 30,
                                              child: Column(
                                                children: [
                                                  Text('INVALID',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 25,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        // fontWeight: FontWeight.bold
                                                      )),
                                                  SizedBox(height: 10),
                                                  Text(temp,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        // fontWeight: FontWeight.bold
                                                      )),
                                                ],
                                              ))
                                          : SizedBox(
                                              width: $ScreenWidth,
                                              // height: 30,
                                              child: (result?.code == null)
                                                  ? const Text('No ID scanned',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        // fontWeight: FontWeight.bold
                                                      ))
                                                  : Column(
                                                      children: [
                                                        Text('$id',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontSize: 25,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              // fontWeight: FontWeight.bold
                                                            )),
                                                        SizedBox(height: 10),
                                                        Text(
                                                            '$last_name, $first_name',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              // fontWeight: FontWeight.bold
                                                            )),
                                                        Text(temp,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              // fontWeight: FontWeight.bold
                                                            )),
                                                      ],
                                                    )),
                                    )
                                  : Container(
                                      child: SizedBox(
                                          width: $ScreenWidth,
                                          // height: 30,
                                          child: Column(
                                            children: [
                                              Text('INVALID',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.bold,
                                                    // fontWeight: FontWeight.bold
                                                  )),
                                              SizedBox(height: 10),
                                              // Text(temp,
                                              //     textAlign: TextAlign.center,
                                              //     style: TextStyle(
                                              //       fontSize: 15,
                                              //       // fontWeight: FontWeight.bold
                                              //     )),
                                            ],
                                          )),
                                    ),
                            ],
                          )),
                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
