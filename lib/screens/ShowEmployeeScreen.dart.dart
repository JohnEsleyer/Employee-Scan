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
                    return ListTile(
                      title: Text(employeeRecord['first_name'] +
                          ' ' +
                          employeeRecord['last_name']),
                      subtitle: Text('ID: ${employeeRecord['id']}'),
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