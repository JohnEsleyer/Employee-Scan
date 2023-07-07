import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/DBProvider.dart';

class ShowAttendanceScreen extends StatefulWidget {
  @override
  _ShowAttendanceScreenState createState() => _ShowAttendanceScreenState();
}

class _ShowAttendanceScreenState extends State<ShowAttendanceScreen> {
  late DatabaseProvider db_provider;
  late List<Map<String, dynamic>> allEmployees = [];
  bool isPressed = false;

  Future<List<Map<String, dynamic>>> getAllAttendanceRecordAndEmployee() async {
    var attendances = await db_provider.getAllAttendanceRecords();
    var employees = await db_provider.getAllEmployeeRecords();
    setState(() {
      allEmployees = employees;
    });

    return attendances;
  }

  @override
  Widget build(BuildContext context) {
    db_provider = Provider.of<DatabaseProvider>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        title: Text(
          "Local database",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              print("Pressed Clear All");
              setState(() {
                isPressed = true;
              });
              db_provider.clearAllAttendance();
              setState(() {
                isPressed = false;
              });
              Scaffold.of(context).reassemble();
            },
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 20,
                ),
                child: Text(
                  "Clear All",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        child: (!isPressed)
            ? FutureBuilder(
                future: getAllAttendanceRecordAndEmployee(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Map<String, dynamic>>? attendanceRecords =
                        snapshot.data;

                    if (attendanceRecords!.length != 0) {
                      return ListView.builder(
                          itemCount: attendanceRecords.length,
                          itemBuilder: ((context, index) {
                            Map<String, dynamic> attendanceRecord =
                                attendanceRecords[index];
                            return Container(
                              decoration: BoxDecoration(boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(2.0, 2.0),
                                  blurRadius: 3.0,
                                  blurStyle: BlurStyle.outer,
                                  spreadRadius: 0.5,
                                ),
                              ]),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    (attendanceRecord['sync'] == 1)
                                        ? Column(
                                            children: [
                                              Icon(
                                                Icons.check_circle_sharp,
                                                size: 50,
                                                color: Colors.green,
                                              ),
                                              Text('Synced',
                                                  style: TextStyle(
                                                      color: Colors.green)),
                                            ],
                                          )
                                        : Icon(
                                            Icons.radio_button_off,
                                            size: 50,
                                          ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    "Employee ID: ",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(attendanceRecord[
                                                          'employee_id']
                                                      .toString()),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "Name: ",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                      '${allEmployees[index]['last_name']}, ${allEmployees[index]['first_name']}'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "Time In: ",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(attendanceRecord[
                                                      'time_in']),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "Time Out: ",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(attendanceRecord[
                                                      'time_out']),
                                                ],
                                              )
                                            ]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }));
                    } else {
                      return Center(
                        child: Text("No Attendance Yet"),
                      );
                    }
                  } else {
                    return CircularProgressIndicator(color: Colors.blue);
                  }
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
