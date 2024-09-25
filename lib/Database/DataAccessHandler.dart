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
    // Get the application documents directory
    Directory documentsDirectory =  Directory('/storage/emulated/0');
    final String folderName = 'SmartGeoTrack';
    Directory customDirectory = Directory('${documentsDirectory.path}/$folderName');

    // Check if the directory exists, and create it if it does not
    if (!await customDirectory.exists()) {
      await customDirectory.create(recursive: true);
    }

    // Construct the database file path
    String path = join(customDirectory.path, 'smartgeotrack.sqlite');
    print('Database path: $path'); // Debugging statement to check the path

    // Check if the database file exists
    bool dbExists = await _checkDatabase(path);

    // Copy the database file if it does not exist
    if (!dbExists) {
      await _copyDatabase(path);
    }

    // Open the database and handle upgrades
    return openDatabase(
      path,
      version: 2, // Increment the version number for upgrades
      onCreate: (db, version) async {
        print('Creating tables'); // Debugging statement to verify table creation
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Handle database upgrade logic here
        print('Upgrading database from version $oldVersion to $newVersion');
        if (oldVersion < 2) {
          // Add the new table when upgrading to version 2
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
        print('Opening database'); // Debugging statement to verify database opening
        await _createTables(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    // Create tables as defined

    // Add the new table here
    await db.execute('''
      CREATE TABLE IF NOT EXISTS NewTable(
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        Column1 VARCHAR(100),
        Column2 INT NOT NULL,
        Column3 FLOAT NOT NULL
      )
    ''');

    print('Table NewTable created'); // Debugging statement to verify the creation of the new table
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
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
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

  Future<void> insertData(String tableName, List<Map<String, dynamic>> data) async {
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
  // Method to insert a lead
  Future<int> insertLead(Map<String, dynamic> leadData) async {
    final db = await database;
    return await db.insert(
      'Leads',
      leadData,
      conflictAlgorithm: ConflictAlgorithm.replace, // Replace if the lead already exists
    );
  }

  // Method to insert a file repository
  Future<int> insertFileRepository(Map<String, dynamic> fileData) async {
    final db = await database;
    return await db.insert(
      'FileRepositorys',
      fileData,
      conflictAlgorithm: ConflictAlgorithm.replace, // Replace if the file already exists
    );
  }


  Future<int?> getOnlyOneIntValueFromDb(String query) async {
    debugPrint("@@@ query $query");
    try {
      List<Map<String, dynamic>> result = await (await database).rawQuery(query);
      if (result.isNotEmpty) {
        return result.first.values.first as int;
      }
      return null;
    } catch (e) {
      debugPrint("Exception: $e");
      return null;
    } finally {
      await closeDataBase();
    }
  }
  Future<String?> getOnlyOneStringValueFromDb(String query, List<dynamic> params) async {
    List<Map<String, dynamic>> result;
    try {
      final db = await database; // Ensure the database is open
      result = await db.rawQuery(query, params); // Pass the parameters

      if (result.isNotEmpty && result.first.isNotEmpty) {
        return result.first.values.first.toString(); // Return the first value as a string
      }
      return null; // Return null if no result found
    } catch (e) {
      debugPrint("Exception: $e");
      return null;
    }
  }


  // Future<String?> getOnlyOneStringValueFromDb(String query) async {
  //   debugPrint("@@@ query $query");
  //   List<Map<String, dynamic>> result;
  //   try {
  //     final db = await database; // Access the database
  //     result = await db.rawQuery(query);
  //
  //     if (result.isNotEmpty && result.first.isNotEmpty) {
  //       // Return the first value as a string
  //       return result.first.values.first.toString();
  //     }
  //     return null; // Return null if no result
  //   } catch (e) {
  //     debugPrint("Exception: $e");
  //     return null;
  //   } finally {
  //     await closeDataBase(); // Close the database connection
  //   }
  // }


  Future<void> closeDataBase() async {
    if (_database != null) {
      await _database!.close();
      _database = null; // Ensure we clear the reference after closing
    }
  }



  Future<List<Map<String, dynamic>>> getleads() async {
    // Get the database instance using the getter
    final db = await database;

    // SQL query for debugging
    String query = 'SELECT * FROM Leads';
    print('Executing Query: $query');

    // Execute the query and get the results
    List<Map<String, dynamic>> results = await db.query('Leads');

    // Print the results
    print('Query Results:');
    results.forEach((row) {
      print(row);
    });

    return results;
  }

}
