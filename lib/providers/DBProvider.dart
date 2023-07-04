import 'package:employee_scan/providers/UserDataProvider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import '../user_defined_functions.dart';


class DatabaseProvider extends ChangeNotifier {
  final Database db;

  DatabaseProvider(this.db);

  Future<void> insertAttendance(int employee_id, int company_id, int scanner_id,
      String time_in, String time_out, String date_entered) async {
    await db.insert('attendance', {
      'employee_id': employee_id,
      'company_id': company_id,
      'scanner_id': scanner_id,
      'time_in': time_in,
      'time_out': time_out,
      'date_entered': date_entered,
      'sync': 0,
    });
  }

  Future<void> updateTimeOut(
      int employee_id, int company_id, String newTimeOut) async {
    final whereArgs = [employee_id, company_id];
    final updates = {'time_out': newTimeOut};

    await db.update('attendance', updates,
        where: 'employee_id = ? and company_id = ?', whereArgs: whereArgs);
  }

  Future<void> updateSync(
      int employee_id, int company_id, int new_sync) async {
    final whereArgs = [employee_id, company_id];
    final updates = {'sync': new_sync};

    await db.update('attendance', updates,
        where: 'employee_id = ? and company_id = ?', whereArgs: whereArgs);
  }

  Future<bool> isAttendanceRecordExists(int employee_id, int company_id) async {
    final results = await db.query('attendance',
        where: 'employee_id = ? and company_id = ?',
        whereArgs: [employee_id, company_id]);

    return results.isNotEmpty;
  }

  Future<Map<String, dynamic>> getAttendanceByEmployeeIdAndCompany(
      int employee_id, int company_id) async {
    final results = await db.query('attendance',
        where: 'employee_id = ? and company_id = ?',
        whereArgs: [employee_id, company_id]);

    if (results.isEmpty) {
      return {};
    } else {
      Map<String, dynamic> attendanceRecord = {};
      attendanceRecord['employee_id'] = results[0]['employee_id'];
      attendanceRecord['company_id'] = results[0]['company_id'];
      attendanceRecord['scanner_id'] = results[0]['scanner_id'];
      attendanceRecord['time_in'] = results[0]['time_in'];
      attendanceRecord['time_out'] = results[0]['time_out'];
      attendanceRecord['date_entered'] = results[0]['date_entered'];
      attendanceRecord['sync'] = results[0]['sync'];
      return attendanceRecord;
    }
  }

  Future<List<Map<String, dynamic>>> getAllAttendanceRecords() async {
    final results = await db.query('attendance');

    List<Map<String, dynamic>> attendanceRecords = [];
    for (var row in results) {
      Map<String, dynamic> attendanceRecord = {};
      attendanceRecord['id'] = row['id'];
      attendanceRecord['employee_id'] = row['employee_id'];
      attendanceRecord['company_id'] = row['company_id'];
      attendanceRecord['scanner_id'] = row['scanner_id'];
      attendanceRecord['time_in'] = row['time_in'];
      attendanceRecord['time_out'] = row['time_out'];
      attendanceRecord['date_entered'] = row['date_entered'];
      attendanceRecord['sync'] = row['sync'];
      attendanceRecords.add(attendanceRecord);
    }

    return attendanceRecords;
  }

  Future<bool> isAttendanceRecordExistsDate(
      int employee_id, String date_entered) async {
    final results = await db.query('attendance',
        where: 'employee_id = ? and date_entered = ?',
        whereArgs: [employee_id, date_entered]);

    return results.isNotEmpty;
  }

  Future<void> insertEmployee(int employee_id, String first_name, String last_name, int company ) async {
    await db.insert('employee', {
      'id': employee_id,
      'first_name': first_name,
      'last_name': last_name,
      'company': company,
    });
  }


  Future<List<Map<String, dynamic>>> getAllEmployeeRecords() async {
    print('Executed getAllEmployeeRecords');
    final results = await db.query('employee');

    List<Map<String, dynamic>> employeeRecords = [];
    for (var row in results) {
      Map<String, dynamic> employeeRecord = {};
      employeeRecord['id'] = row['id'];
      employeeRecord['first_name'] = row['first_name'];
      employeeRecord['last_name'] = row['last_name'];
      employeeRecord['company'] = row['company'];
      employeeRecords.add(employeeRecord);
    }

    return employeeRecords;
  }

  

  Future<bool> isEmployeeExists(int employee_id) async {
    final result =
        await db.query('employee', where: 'id = ?', whereArgs: [employee_id]);
    return result.isNotEmpty;
  }

  Future<void> updateData() async {
    await db.update('users', {'name': 'John Smith'}, where: 'id = 1');
  }

  Future<void> deleteData() async {
    await db.delete('users', where: 'id = 2');
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    return await db.query('users');
  }

  Future<Map<String, dynamic>?> getEmployeeById(int id) async {
    final results =
        await db.query('employee', where: 'id = ?', whereArgs: [id]);

    if (results.isEmpty) {
      return {'name': 'null'};
    } else {
      return results.first;
    }
  }


  Future<void> syncAttendance(BuildContext context) async {
  try {
    // Retrieve all attendance records
    List<Map<String, dynamic>> attendances =
        await getAllAttendanceRecords();
    print('Total attendance records: ${attendances.length}');

    // Counter to track synced records
    int counter = 0;

    // Iterate through each attendance record
    for (int i = 0; i < attendances.length; i++) {
      // Check if the record is not yet synced
      if (attendances[i]['sync'] == 0) {
        final url = API_URL + '/attendance';
        final requestBody = {
          "employee_id": attendances[i]['employee_id'],
          "company_id": attendances[i]['company_id'],
          "scanner_id": attendances[i]['scanner_id'],
          "time_in": attendances[i]['time_in'],
          "time_out": attendances[i]['time_out'],
          "date_entered": attendances[i]['date_entered'],
        };

        // Check if the record has a valid time_out value
        if (attendances[i]['time_out'] == 'not set') {
          print('Invalid record: ${attendances[i]}');
        } else {
          try {
            String token = Provider.of<UserDataProvider>(context, listen: false).getToken;

            Map<String, String> headers = {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
              "Accept": "application/json"
            };
            // Send a POST request to the API
            final response = await http.post(
              Uri.parse(url),
              body: json.encode(requestBody),
              headers: headers,
            );

            if (response.statusCode == 200) {
              // Request successful
              final responseBody = json.decode(response.body);
              print('Response body: $responseBody');

              // Update the record's sync status
              await updateSync(
                  attendances[i]['employee_id'],
                  attendances[i]['company_id'],
                  1);
            } else {
              // Request failed
              print('Request failed');
            }
          } catch (error) {
            print('Error: $error');
          }
          counter++;
        }
      }
    }
    print('Total records synced: $counter');
  } catch (error) {
    print('Error: $error');
  }
}
}
