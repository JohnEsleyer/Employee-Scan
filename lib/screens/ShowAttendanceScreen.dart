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

  Future<List<Map<String, dynamic>>> getAllAttendanceRecordAndEmployee() async{
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
      body: Container(
        child: FutureBuilder(
          future: getAllAttendanceRecordAndEmployee(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Map<String, dynamic>>? attendanceRecords = snapshot.data;
              
              if (attendanceRecords!.length != 0){
                return ListView.builder(
                  itemCount: attendanceRecords!.length,
                  itemBuilder: ((context, index) {
                    Map<String, dynamic> attendanceRecord =
                        attendanceRecords[index];
                     return Row(
                      children: [
                        Icon(Icons.person,size: 50,),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              Row(
                                children: [
                                  Text(
                                    "Employee ID: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(attendanceRecord['employee_id']
                                      .toString()),
                                ],
                              ),
                               Row(
                                children: [
                                  Text(
                                    "Name: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('${allEmployees[index]['first_name']}, ${allEmployees[index]['last_name']}'),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Time In: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(attendanceRecord['time_in']),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Time Out: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(attendanceRecord['time_out']),
                                ],
                              )
                            ]),
                          ),
                        ),
                      ],
                    );
                    
                  }));
              }else{
                return Center(child: Text("No Attendance Yet"),);
              }
              
              
            } else {
              return CircularProgressIndicator(color: Colors.blue);
            }
          },
        ),
      ),
    );
  }
}
