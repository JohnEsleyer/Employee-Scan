import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/DBProvider.dart';

class ShowEmployeeScreen extends StatefulWidget {
  @override
  _ShowEmployeeScreen createState() => _ShowEmployeeScreen();
}

class _ShowEmployeeScreen extends State<ShowEmployeeScreen> {
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
                    return Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              boxShadow: [
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
                            child: Container(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.person,
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
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(employeeRecord['id']
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
                                                Text(
                                                    '${employeeRecord['last_name']}, ${employeeRecord['first_name']}'),
                                              ],
                                            ),
                                            SizedBox(height: 15),
                                          ]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
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
