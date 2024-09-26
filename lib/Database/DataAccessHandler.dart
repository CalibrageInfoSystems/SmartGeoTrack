import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class DataAccessHandler with ChangeNotifier {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = Directory('/storage/emulated/0');
    const String folderName = 'SmartGeoTrack';
    Directory customDirectory =
        Directory('${documentsDirectory.path}/$folderName');

    if (!await customDirectory.exists()) {
      await customDirectory.create(recursive: true);
    }

    String path = join(customDirectory.path, 'smartgeotrack.sqlite');
    print('Database path: $path'); // Debugging statement to check the path

    bool dbExists = await _checkDatabase(path);

    if (!dbExists) {
      await _copyDatabase(path);
    }

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        print('Creating tables');
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        print('Upgrading database from version $oldVersion to $newVersion');
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS NewTable(
              Id INTEGER PRIMARY KEY AUTOINCREMENT,
              Column1 VARCHAR(100),
              Column2 INT NOT NULL,
              Column3 FLOAT NOT NULL
            )
          ''');
          print('NewTable created during upgrade');
        }
      },
      onOpen: (db) async {
        print('Opening database');
        await _createTables(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS NewTable(
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        Column1 VARCHAR(100),
        Column2 INT NOT NULL,
        Column3 FLOAT NOT NULL
      )
    ''');
    print('Table NewTable created');
  }

  Future<bool> _checkDatabase(String path) async {
    try {
      return await File(path).exists();
    } catch (e) {
      print('Error checking database existence: $e');
      return false;
    }
  }

  Future<void> _copyDatabase(String path) async {
    try {
      ByteData data = await rootBundle.load('assets/smartgeotrack.sqlite');
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
      print('Database copied to $path');
    } catch (e) {
      print('Error copying database: $e');
      throw Exception('Error copying database');
    }
  }

  Future<void> deleteRow(String tableName) async {
    try {
      final db = await database;
      await db.delete(tableName);
      print('Deleted all rows from $tableName');
    } catch (e) {
      print('Error deleting rows from $tableName: $e');
    }
  }

  Future<void> insertData(
      String tableName, List<Map<String, dynamic>> data) async {
    try {
      final db = await database;
      for (var item in data) {
        await db.insert(tableName, item);
      }
      print('Data inserted into $tableName');
    } catch (e) {
      print('Error inserting data into $tableName: $e');
    }
  }

  Future<int> insertLead(Map<String, dynamic> leadData) async {
    final db = await database;
    return await db.insert(
      'Leads',
      leadData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertFileRepository(Map<String, dynamic> fileData) async {
    final db = await database;
    return await db.insert(
      'FileRepositorys',
      fileData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int?> getOnlyOneIntValueFromDb(String query) async {
    debugPrint("@@@ query $query");
    try {
      List<Map<String, dynamic>> result =
          await (await database).rawQuery(query);
      if (result.isNotEmpty) {
        return result.first.values.first as int;
      }
      return null;
    } catch (e) {
      debugPrint("Exception: $e");
      return null;
    }
  }

  Future<String?> getOnlyOneStringValueFromDb(
      String query, List<dynamic> params) async {
    List<Map<String, dynamic>> result;
    try {
      final db = await database;
      result = await db.rawQuery(query, params);

      if (result.isNotEmpty && result.first.isNotEmpty) {
        return result.first.values.first.toString();
      }
      return null;
    } catch (e) {
      debugPrint("Exception: $e");
      return null;
    }
  }

  Future<void> closeDataBase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<List<Map<String, dynamic>>> getleads() async {
    final db = await database;
    String query = 'SELECT * FROM Leads';
    print('Executing Query: $query');
    List<Map<String, dynamic>> results = await db.query('Leads');
    print('Query Results:');
    for (var row in results) {
      print(row);
    }
    return results;
  }

  Future<List<Map<String, dynamic>>> getTodayLeads(String today) async {
    final db = await database;
    String query = 'SELECT * FROM Leads WHERE DATE(CreatedDate) = $today';
    List<Map<String, dynamic>> results = await db.query(query);
    print('xxx: $query');
    print('xxx: ${jsonEncode(results)}');
    return results;
  }
  // Function to fetch the Base64-encoded image from SQLite database using leadCode
  Future<String?> fetchBase64Image(String leadCode) async {
    // Replace with your actual database path and query
    final db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT FileName FROM FileRepositorys WHERE leadsCode = ?',
      [leadCode],
    );

    if (result.isNotEmpty) {
      return result.first['FileName'] as String; // Assuming FileName contains Base64
    }
    return null; // Return null if no image found
  }


}
