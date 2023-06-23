import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider extends ChangeNotifier {
  final Database db;

  DatabaseProvider(this.db);

  // Future<void> createTable() async {
  //   await db.execute(
  //       'CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, age INTEGER)');
  // }

  // Future<void> insertData() async {
  //   await db.insert('users', {'name': 'John Doe', 'age': 30});
  //   await db.insert('users', {'name': 'Jane Doe', 'age': 25});
  // }

  Future<void> insertAttendance(int employee_id, int company_id, int scanner_id,
      String time_in, String time_out, String time_entered) async {
    await db.insert('attendance', {
      'employee_id': employee_id,
      'company_id': company_id,
      'scanner_id': scanner_id,
      'time_in': time_in,
      'time_out': time_out,
      'time_entered': time_entered
    });
  }

  Future<void> updateTimeOut(
      int employee_id, int company_id, String newTimeOut) async {
    final whereArgs = [employee_id, company_id];
    final updates = {'time_out': newTimeOut};

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
      return attendanceRecord;
    }
  }

  Future<bool> isAttendanceRecordExistsDate(
      int employee_id, String date_entered) async {
    final results = await db.query('attendance',
        where: 'employee_id = ? and date_entered = ?',
        whereArgs: [employee_id, date_entered]);

    return results.isNotEmpty;
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
}
