import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqlite_project/models/emp_model.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  final String _tableName = "EmployeesData";
  final String _tableNameColumnName = "name";
  final String _tableDepartmentColumnName = "department";
  final String _tableEmployeeIdColumnName = "employee_id";

  DatabaseService._constructor();


  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    debugPrint(databaseDirPath.toString());
    final databasePath = join(databaseDirPath, "master_db.db");
    final database =
        await openDatabase(databasePath, version: 1, onCreate: (db, version) {
      db.execute('''
      CREATE TABLE $_tableName (
      $_tableEmployeeIdColumnName INTEGER PRIMARY KEY,
      $_tableNameColumnName TEXT NOT NULL,
      $_tableDepartmentColumnName TEXT NOT NULL
      )
      ''');
    });
    // await database.close();
    return database;
  }

  void addEmployee(String name, String dept, int empId) async {
    try{
      final db = await database;
      await db.insert(_tableName, {
        _tableNameColumnName: name,
        _tableDepartmentColumnName: dept,
        _tableEmployeeIdColumnName: empId
      });
    }catch(e){
      debugPrint("Inside add error");
      debugPrint(e.toString());
    }
  }

  void updateEmployee(String name, String dept, int empId) async {
    final db = await database;
    await db.update(
      _tableName,
      {
        _tableNameColumnName: name,
        _tableDepartmentColumnName: dept,
      },
      where: "$_tableEmployeeIdColumnName = ?",
      whereArgs: [empId],
    );
  }

  Future<List<EmployeeModel>> getEmployees() async {
    final db = await database;
    final data = await db.query(_tableName);
    print(data);
    List<EmployeeModel> empModelList = data
        .map((e) => EmployeeModel(
              empId: e[_tableEmployeeIdColumnName] as int,
              name: e[_tableNameColumnName] as String,
              dept: e[_tableDepartmentColumnName] as String,
            ))
        .toList();
    return empModelList;
  }

  Future<List<Map<String, dynamic>>> searchEmployee(int id) async {
    final db = await database;
    List<Map<String, dynamic>> l = await db.rawQuery(
      'SELECT * FROM $_tableName WHERE $_tableEmployeeIdColumnName = ?',
      [id],
    );
    return l;
  }

  void deleteEmployee(int id) async {
    final db = await database;
    await db.delete(_tableName,
        where: "$_tableEmployeeIdColumnName = ?", whereArgs: [id]);
  }
}
