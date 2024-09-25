import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';

class Palm3FoilDatabase {
  static const LOG_TAG = 'Palm3FoilDatabase';
  static const int DATA_VERSION = 1; // Changed on 21st March 2024
  static const String DATABASE_NAME = 'smartgeotrack.sqlite';
  static const String Lock = 'dblock';

  static Palm3FoilDatabase? _palm3FoilDatabase;
  static Database? _database;
  static String? _dbPath;
  BuildContext? _context;

  Palm3FoilDatabase._privateConstructor();

  static Future<Palm3FoilDatabase?> getInstance() async {
    if (_palm3FoilDatabase == null) {
      _palm3FoilDatabase = Palm3FoilDatabase._privateConstructor();
      //     _palm3FoilDatabase!._context = context;
      Directory? documentsDirectory =   Directory('/storage/emulated/0'); // await getExternalStorageDirectory(); // Use getExternalStorageDirectory for Android
      final String folderName = 'SmartGeoTrack';
      Directory dbDirectory = Directory('${documentsDirectory!.path}/$folderName');
      // final String folderName = 'SmartGeoTrack';
      // Directory dbDirectory = Directory('/storage/emulated/0/Download/$folderName');
      if (!await dbDirectory.exists()) {
        await dbDirectory.create(recursive: true);
      }
      _dbPath = join(dbDirectory.path, DATABASE_NAME);
      print('The Database Path: $_dbPath');
    }
    return _palm3FoilDatabase;
  }

  Future<Database?> _openDatabase() async {
    if (_database == null) {
      _database = await openDatabase(
        _dbPath!,
        version: DATA_VERSION,
        onCreate: (Database db, int version) async {
          // Implement the onCreate function if you need to create tables
        },
        onUpgrade: (Database db, int oldVersion, int newVersion) async {
          // Implement the onUpgrade function if you need to upgrade the database schema
        },
      );
    }
    return _database;
  }

  Future<void> createDatabase() async {
    bool dbExist = await _checkDatabase();
    if (!dbExist) {
      try {
        await _copyDatabase();
        print('Database copied');
      } catch (e) {
        print('Error copying database: $e');
        throw Exception('Error copying database');
      }
      try {
        await _openDatabase();
        await printTables(); // Call printTables here
      } catch (e) {
        print('Error opening database: $e');
        throw Exception('Error opening database');
      }
    } else {
      await _openDatabase();
      await printTables(); // Call printTables here
    }
  }

  Future<bool> _checkDatabase() async {
    try {
      final dbPath = join(_dbPath!);
      _database = await openDatabase(dbPath, readOnly: true);
      return _database != null;
    } catch (e) {
      print('Database does not exist: $e');
      return false;
    }
  }

  Future<void> _copyDatabase() async {
    try {
      final data = await rootBundle.load(join('assets', DATABASE_NAME));
      final bytes = data.buffer.asUint8List();
      final dbFile = File(join(_dbPath!));
      await dbFile.writeAsBytes(bytes);
    } catch (e) {
      print('Error copying database: $e');
      throw Exception('Error copying database');
    }
  }
  Future<void> insertLocationValues({
    required double latitude,
    required double longitude,
    required int createdByUserId,
    required int updatedByUserId,
    required bool serverUpdatedStatus,
  }) async {
    try {
      final db = await _openDatabase();
      final geoBoundaryValues = {
        'Latitude': latitude,
        'Longitude': longitude,
        'Address' : 'testing',
        'CreatedByUserId': createdByUserId,
        'CreatedDate': DateTime.now().toIso8601String(),
        'ServerUpdatedStatus': false, // SQLite stores boolean as 0 or 1
      };

      await db!.insert('GeoBoundaries', geoBoundaryValues);
      print('Location values inserted');
    } catch (e) {
      print('Failed to insert location values: $e');
    }
  }
  Future<int> insertLead(Map<String, dynamic> leadData) async {
    try {
      final db = await _openDatabase();
      // Insert the lead and get the inserted ID
      return await db!.insert(
        'Leads',
        leadData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error inserting lead: $e');
      return -1; // Return an error code or handle it as needed
    }
  }


  Future<void> insertFileRepository(Map<String, dynamic> fileData) async {
    try {
      final db = await _openDatabase();
      await db!.insert(
        'FileRepositorys',
        fileData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error inserting file repository: $e');
    }
  }

  Future<void> insertLocationError(String tableName, String error) async {
    try {
      final db = await _openDatabase();
      final errorValues = {
        'TableName': tableName,
        'Error': error,
        'CreatedDate': DateTime.now().toIso8601String(),
      };
      await db!.insert('ErrorLogs', errorValues);
      print('Error Details inserted');
    } catch (e) {
      print('Error Details failed to Insert: $e');
    }
  }

  Future<void> insertActivityRight(Map<String, dynamic> values) async {
    try {
      final db = await _openDatabase();
      await db!.insert('ActivityRight', values);
      print('ActivityRight Details inserted');
    } catch (e) {
      print('Error Details failed to Insert: $e');
    }
  }

  Future<void> printTables() async {
    try {
      final db = await _openDatabase();
      var result = await db!.rawQuery('SELECT name FROM sqlite_master WHERE type="table" ORDER BY name');
      print('Tables in the database: $result');
      print('Tables in the database size: ${result.length}');
    } catch (e) {
      print('Error retrieving tables: $e');
    }
  }

  // Future<List<Map<String, dynamic>>> getleads() async {
  //   if (_database == null) {
  //     throw Exception('Database is not initialized');
  //   }
  //   // Query to get all rows from the Leads table
  //   return await _database!.query('Leads');
  // }
  Future<List<Map<String, dynamic>>> getleads() async {
    if (_database == null) {
      throw Exception('Database is not initialized');
    }

    // SQL query for debugging
    String query = 'SELECT * FROM Leads';
    print('Executing Query: $query');

    // Execute the query and get the results
    List<Map<String, dynamic>> results = await _database!.query('Leads');

    // Print the results
    print('Query Results:');
    results.forEach((row) {
      print(row);
    });

    return results;
  }

}

