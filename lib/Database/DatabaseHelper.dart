import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../Model/FileRepositoryModel.dart';
import '../Model/GeoBoundariesModel.dart';
import '../Model/LeadsModel.dart';



class DatabaseHelper {
  static final _databaseName = "smartgeotrack.sqlite";
  static final _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String folderName = 'SmartGeoTrack';
    Directory documentsDirectory = Directory('/storage/emulated/0/$folderName');

    if (!documentsDirectory.existsSync()) {
      documentsDirectory.createSync(recursive: true);
    }

    String path = join(documentsDirectory.path, _databaseName);

    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      ByteData data = await rootBundle.load(join("assets", _databaseName));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes);
    }

    return await openDatabase(path, version: _databaseVersion);
  }

  Future<void> executeSQL(String sql) async {
    final db = await database;
    await db.execute(sql);
  }

  Future<void> insertData(String tableName, List<Map<String, dynamic>> data) async {
    final db = await database;
    Batch batch = db.batch();
    for (var row in data) {
      batch.insert(tableName, row, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<GeoBoundariesModel>> getGeoBoundariesDetails() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'geoBoundaries',
      where: 'ServerUpdatedStatus = ?',
      whereArgs: [false],
    );

    return result.map((row) => GeoBoundariesModel.fromMap(row)).toList();
  }
  Future<List<LeadsModel>> getLeadsDetails() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'Leads',
      where: 'ServerUpdatedStatus = ?',
      whereArgs: [false],
    );
    print('Leads fetched: $result');

    return result.map((row) => LeadsModel.fromMap(row)).toList();
  }
  Future<List<FileRepositoryModel>> getFileRepositoryDetails() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'FileRepositorys',
      where: 'ServerUpdatedStatus = ?',
      whereArgs: [false],
    );
    print('fileRepository fetched: $result');

    return result.map((row) => FileRepositoryModel.fromJson(row)).toList();
  }

// Future<List<FileRepositoryModel>> getFileRepositoryDetails() async {
//   final db = await database;
//   final List<Map<String, dynamic>> result = await db.query(
//     'Leads',
//     where: 'ServerUpdatedStatus = ?',
//     whereArgs: [0],
//   );
//
//   return result.map((row) => LeadsModel.fromMap(row)).toList();
// }


}
