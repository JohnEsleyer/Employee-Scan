import 'dart:core';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Define database properties
  static final _databaseName = 'local_database.db';
  static final _databaseVersion = 1;

  // Employee table
  static final tableEmployee = 'Employee';
  static final employeeColumnId = '_id';
  static final employeeColumnFirstName = 'first_name';
  static final employeeColumnLastName = 'last_name';
  static final employeeColumnCompany = 'company';
  static final employeeColumnDepartment = 'department';

  // Attendance table
  static final tableAttendance = 'Attenance';
  static final attendanceColumnId = '_id';
  static final attendanceColumnEmployee = 'employee_id';
  static final attendanceColumnCompany = 'company_id';
  static final attendanceColumnScanner = 'scanner_id';
  static final attendanceColumnTimeIn = 'time_in';
  static final attendanceColumnTimeOut = 'time_out';
  static final attendanceColumnDate = 'date_entered';

  // ..add more columns as needed

  static Database? _database;

  // Get a reference to the database or create it if it doesn't exist
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Open the database or create it if it doesn't exist
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // Create the database table
  Future<void> _onCreate(Database db, int version) async {
    //Create Employee table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableEmployee (
        $employeeColumnId TEXT PRIMARY KEY,
        $employeeColumnFirstName TEXT,
        $employeeColumnLastName TEXT,
        $employeeColumnCompany TEXT
      );
      ''');
    //Create the Attendance table
    await db.execute('''
      CREATE TABLE  IF NOT EXISTS $tableEmployee (
        $attendanceColumnId TEXT PRIMARY KEY,
        $attendanceColumnEmployee TEXT,
        $attendanceColumnCompany TEXT,
        $attendanceColumnScanner TEXT,
        $attendanceColumnTimeIn TEXT,
        $attendanceColumnTimeOut TEXT,
        $attendanceColumnDate TEXT
      );
      ''');
  }

  // ========== Employee methods ============

  // Insert a employee record into the database
  Future<int> insertEmployee(
      String firstName, String lastName, String company) async {
    Database db = await database;
    Map<String, dynamic> row = {
      employeeColumnFirstName: firstName,
      employeeColumnLastName: lastName,
      employeeColumnCompany: company,
    };
    return await db.insert(tableEmployee, row);
  }

  // Update employee record
  Future<int> updateEmployee(
      int id, String firstName, String lastName, String company) async {
    Database db = await database;
    Map<String, dynamic> row = {
      employeeColumnId: id,
      employeeColumnFirstName: firstName,
      employeeColumnLastName: lastName,
      employeeColumnCompany: company,
    };
    return await db.update(
      tableEmployee,
      row,
      where: '$employeeColumnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteEmployee(int id) async {
    Database db = await database;
    return await db.delete(
      tableEmployee,
      where: '$employeeColumnId = ?',
      whereArgs: [id],
    );
  }

  // Check whether employee record exists
  Future<bool> checkEmployeeExists(String id) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      tableEmployee,
      where: '$employeeColumnId = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }

  // Get employee record by its ID as Map object
  Future<Map<String, dynamic>> getEmployeeById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      tableEmployee,
      where: '$employeeColumnId = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return {}; // returns an empty map if record is not found
    }
  }

  // Retrieve all employee records from the database
  Future<List<Map<String, dynamic>>> getEmployees() async {
    Database db = await database;
    return await db.query(tableEmployee);
  }

  // ... add more database operations (update, delete, etc) as needed

  // ========== Attendance Methods =========

  // Insert attendance record
  Future<int> insertAttendance(String id, String employee_id, String company_id,
      String scanner_id, String timeIn, String timeOut, String date) async {
    Database db = await database;
    var row = {
      attendanceColumnId: id,
      attendanceColumnEmployee: employee_id,
      attendanceColumnCompany: company_id,
      attendanceColumnScanner: scanner_id,
      attendanceColumnTimeIn: timeIn,
      attendanceColumnTimeOut: timeOut,
      attendanceColumnDate: date,
    };
    return await db.insert(tableEmployee, row);
  }

  // Update attendance record
  Future<int> updateAttendance(String id, String employee_id, String company_id,
      String scanner_id, String, timeIn, String timeOut) async {
    Database db = await database;
    var row = {
      attendanceColumnId: id,
      attendanceColumnEmployee: employee_id,
      attendanceColumnCompany: company_id,
      attendanceColumnScanner: scanner_id,
      attendanceColumnTimeIn: timeIn,
      attendanceColumnTimeOut: timeOut,
    };
    return await db.update(
      tableAttendance,
      row,
      where: '$attendanceColumnId = ?',
      whereArgs: [id],
    );
  }

  // Update the timeOut column of an attendance record
  Future<int> updateTimeOut(String employee_id, String timeOut) async {
    Database db = await database;

    var row = {
      attendanceColumnTimeOut: timeOut,
    };

    return await db.update(
      tableAttendance,
      row,
      where: '$attendanceColumnEmployee = ?',
      whereArgs: [employee_id],
    );
  }

  // Delete attendance record
  Future<int> deleteAttendance(int id) async {
    Database db = await database;
    return await db.delete(
      tableAttendance,
      where: '$attendanceColumnId = ?',
      whereArgs: [id],
    );
  }

  // Check whether attendance record exists
  Future<bool> checkAttendanceExists(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      tableAttendance,
      where: '$attendanceColumnId = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }

  // Get attendance record by its ID as Map object
  Future<Map<String, dynamic>> getAttendanceById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      tableAttendance,
      where: '$attendanceColumnId = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return {}; // returns an empty map if record is not found
    }
  }

  // Get attendance records by employee_id and company_id
  Future<List<Map<String, dynamic>>> getAttendanceByEmployeeIdAndCompanyList(
      String employeeId, String companyId) async {
    Database db = await database;

    List<Map<String, dynamic>> result = await db.query(
      tableAttendance,
      where: '$attendanceColumnEmployee = ? AND $attendanceColumnCompany = ?',
      whereArgs: [employeeId, companyId],
    );

    return result;
  }

  // Get attendance record by employee_id and company_id
  Future<Map<String, dynamic>> getAttendanceByEmployeeIdAndCompany(
      String employeeId, String companyId) async {
    Database db = await database;

    List<Map<String, dynamic>> result = await db.query(
      tableAttendance,
      where: '$attendanceColumnEmployee = ? AND $attendanceColumnCompany = ?',
      whereArgs: [employeeId, companyId],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return {}; // returns an empty map if record is not found
    }
  }

  // Retrieve all attendance records from the database
  Future<List<Map<String, dynamic>>> getAttendance() async {
    Database db = await database;
    return await db.query(tableAttendance);
  }

  // Check if any record in Attendance has column data equal to employee_id
  Future<bool> isAttendanceRecordExists(String employee_id, String date) async {
    Database db = await database;

    List<Map<String, dynamic>> result = await db.query(
      tableAttendance,
      where: '$attendanceColumnEmployee = ? AND $attendanceColumnDate LIKE ?',
      whereArgs: [employee_id, '$date%'],
      limit: 1,
    );

    return result.isNotEmpty;
  }
}
