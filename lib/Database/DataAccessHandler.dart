import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import 'DatabaseHelper.dart';

class DataAccessHandler with ChangeNotifier {



  Future<void> deleteRow(String tableName) async {
    try {
      final db = await DatabaseHelper.instance.database;
      ;
      await db.delete(tableName);
      print('Deleted all rows from $tableName');
    } catch (e) {
      print('Error deleting rows from $tableName: $e');
    }
     }

    Future<void> insertData(String tableName,
        List<Map<String, dynamic>> data) async {
      try {
        final db = await DatabaseHelper.instance.database;
        ;
        for (var item in data) {
          await db.insert(tableName, item);
        }
        print('Data inserted into $tableName');
      } catch (e) {
        print('Error inserting data into $tableName: $e');
      }
    }

    // Future<int> insertLead(Map<String, dynamic> leadData) async {
    //   final db = await database;
    //   return await db.insert(
    //     'Leads',
    //     leadData,
    //     conflictAlgorithm: ConflictAlgorithm.replace,
    //   );
    // }
    Future<int> insertLead(Map<String, dynamic> leadData) async {
      final db = await DatabaseHelper.instance.database;;

      // Validate lead data before insertion
      // if (!isValidLeadData(leadData)) {
      //   throw Exception("Invalid lead data");
      // }

      try {
        return await db.insert(
          'Leads',
          leadData,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } catch (e) {
        // Log or handle the error as needed
        print("Insert failed: $e");
        return -1; // Return an error code or handle it differently
      }
    }

    Future<int> insertFileRepository(Map<String, dynamic> fileData) async {
      final db = await DatabaseHelper.instance.database;;
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
        await (await DatabaseHelper.instance.database).rawQuery(query);
        if (result.isNotEmpty) {
          return result.first.values.first as int;
        }
        return null;
      } catch (e) {
        debugPrint("Exception: $e");
        return null;
      }
    }

    Future<String?> getOnlyOneStringValueFromDb(String query,
        List<dynamic> params) async {
      List<Map<String, dynamic>> result;
      try {
        final db = await await DatabaseHelper.instance.database;
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


    Future<List<Map<String, dynamic>>> getleads() async {
      final db = await DatabaseHelper.instance.database;
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
      final db = await DatabaseHelper.instance.database;
      String query = 'SELECT * FROM Leads WHERE DATE(CreatedDate) = $today';
      List<Map<String, dynamic>> results = await db.query(query);
/*     print('xxx: $query');
    print('xxx: ${jsonEncode(results)}'); */
      return results;
    }

    Future<List<Map<String, dynamic>>> getLeadInfoByCode(String code) async {
      try {
        final db = await DatabaseHelper.instance.database;
        String query = 'SELECT * FROM Leads Where Code = ?';
        List<Map<String, dynamic>> results = await db.rawQuery(
          query,
          [code],
        );

        return results;
      } catch (e) {
        throw Exception('catch: $e');
      }
    }

    Future<List<Map<String, dynamic>>> getLeadImagesByCode(String leadsCode,
        String fileExtension) async {
      try {
        final db = await DatabaseHelper.instance.database;
        String query =
            'SELECT * FROM FileRepositorys WHERE leadsCode = ? AND FileExtension = ?';
        List<Map<String, dynamic>> results = await db.rawQuery(
          query,
          [leadsCode, fileExtension],
        );
        print('xxx getLeadImagesByCode: ${jsonEncode(results)}');
        return results;
      } catch (e) {
        throw Exception('Error fetching data: $e');
      }
    }

// SELECT * FROM FileRepositorys WHERE FileExtension in ('.xlsx', '.pdf')
/*   Future<List<Map<String, dynamic>>> getLeadDocsByCode(String code, String fileExtension) async {
    try {
      final db = await database;
      String query =
          'SELECT * FROM FileRepositorys WHERE leadsCode = ? AND FileExtension = ?'; // Define the query
      List<Map<String, dynamic>> results = await db.rawQuery(
        query,
        [code, fileExtension],
      );
      print('Data fetched: ${jsonEncode(results)}');
      return results; // Return the results
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  } */

    Future<List<Map<String, dynamic>>> getLeadDocsByCode(String leadsCode,
        List<String> fileExtensions) async {
      try {
        final db = await DatabaseHelper.instance.database;

        String placeholders = fileExtensions.map((_) => '?').join(', ');
        String query =
            'SELECT * FROM FileRepositorys WHERE leadsCode = ? AND FileExtension IN ($placeholders)';
        print('query: $query');
        List<dynamic> parameters = [leadsCode] + fileExtensions;

        List<Map<String, dynamic>> results = await db.rawQuery(
          query,
          parameters,
        );
        print('getLeadDocsByCode: ${jsonEncode(results)}');
        return results;
      } catch (e) {
        throw Exception('Error fetching data: $e');
      }
    }

    Future<String?> fetchBase64Image(String leadCode) async {
      // Replace with your actual database path and query
      final db = await DatabaseHelper.instance.database;
      List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT FileName FROM FileRepositorys WHERE leadsCode = ?',
        [leadCode],
      );

      if (result.isNotEmpty) {
        return result.first['FileName']
        as String; // Assuming FileName contains Base64
      }
      return null; // Return null if no image found
    }

    bool isValidLeadData(Map<String, dynamic> leadData) {
      // Add your validation logic here
      return leadData.containsKey('requiredField') &&
          leadData['requiredField'] != null;
    }
  Future<List<Map<String, dynamic>>> getFilterData(String query) async {
    final db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> results = await db.rawQuery(query);
    return results;
  }

}
