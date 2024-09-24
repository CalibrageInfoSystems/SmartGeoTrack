import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Model/FileRepositoryModel.dart';
import '../Model/GeoBoundariesModel.dart';
import '../Model/LeadsModel.dart';
import 'DatabaseHelper.dart';

class SyncService {
  final String apiUrl = "http://182.18.157.215/SmartGeoTrack/API/SyncTransactions/SyncTransactions";
  Map<String, List<Map<String, dynamic>>> refreshTransactionsDataMap = {};
  List<String> refreshTableNamesList = ['geoBoundaries', 'leads', 'fileRepository'];
  int transactionsCheck = 0;

  // Fetch data for specified tables
  // Future<void> getRefreshSyncTransDataMap() async {
  //   // Fetching geoBoundaries and converting to List<Map<String, dynamic>>
  //   // List<GeoBoundariesModel> geoBoundariesList = await DatabaseHelper.instance.getGeoBoundariesDetails();
  //   // refreshTransactionsDataMap['geoBoundaries'] = geoBoundariesList.map((model) => model.toMap()).toList();
  //
  //   // Fetching leads and converting to List<Map<String, dynamic>>
  //   List<LeadsModel> leadsList = await DatabaseHelper.instance.getLeadsDetails();
  //   print('LeadsList: $leadsList');
  //   refreshTransactionsDataMap['leads'] = leadsList.map((model) => model.toMap()).toList();
  //
  //   // // Fetching file repository details with a sample query
  //   // String query = 'SELECT * FROM fileRepository WHERE ServerUpdatedStatus = 0';
  //   // List<FileRepositoryModel> fileRepoList = await DatabaseHelper.instance.getFileRepositoryDetails(query);
  //   // refreshTransactionsDataMap['fileRepository'] = fileRepoList.map((model) => model.toMap()).toList();
  //
  //   print('Fetched Data: $refreshTransactionsDataMap');
  // }

  Future<void> getRefreshSyncTransDataMap() async {
    // Fetching geoBoundaries
    List<GeoBoundariesModel> geoBoundariesList = await DatabaseHelper.instance.getGeoBoundariesDetails();
    print('GeoBoundariesList: $geoBoundariesList'); // Debug print
    refreshTransactionsDataMap['geoBoundaries'] = geoBoundariesList.map((model) => model.toMap()).toList();

    // Fetching leads
    List<LeadsModel> leadsList = await DatabaseHelper.instance.getLeadsDetails();
    print('Leads fetched: ${leadsList.isNotEmpty ? leadsList : "No leads found"}'); // Debug print

    if (leadsList.isNotEmpty) {
      refreshTransactionsDataMap['leads'] = leadsList.map((model) => model.toMap()).toList();
    } else {
      print('LeadsList is empty.');
    }

    // Uncomment if you're fetching file repository details
    // String query = 'SELECT * FROM fileRepository WHERE ServerUpdatedStatus = 0';
    // List<FileRepositoryModel> fileRepoList = await DatabaseHelper.instance.getFileRepositoryDetails(query);
    // refreshTransactionsDataMap['fileRepository'] = fileRepoList.map((model) => model.toMap()).toList();

    print('Fetched Data: $refreshTransactionsDataMap');
  }


  // Perform Sync Operation
  Future<void> performRefreshTransactionsSync(BuildContext context) async {
    await getRefreshSyncTransDataMap();
    if (refreshTransactionsDataMap.isNotEmpty) {
      await _syncTransactionsDataToCloud(context, refreshTableNamesList[transactionsCheck]);
    } else {
      _showSnackBar(context, "No transactions data to sync.");
    }
  }

  // Post table data to the server one by one
  Future<void> _syncTransactionsDataToCloud(BuildContext context, String tableName) async {
    List tableData = refreshTransactionsDataMap[tableName] ?? [];
    print('tableData for ${jsonEncode({tableName: tableData})}');

    if (tableData.isNotEmpty) {
      try {
        String data = jsonEncode({tableName: tableData});
        var response = await http.post(
          Uri.parse(apiUrl),
          headers: {"Content-Type": "application/json"},
          body: data,
        );

        if (response.statusCode == 200) {
          transactionsCheck++;
          if (transactionsCheck < refreshTableNamesList.length) {
            await _syncTransactionsDataToCloud(context, refreshTableNamesList[transactionsCheck]);
          } else {
            _showSnackBar(context, "Sync is successful!");
          }
        } else {
          // Enhanced error handling
          print('Error response: ${response.body}');
          _showSnackBar(context, "Sync failed for $tableName: ${response.body}");
        }
      } catch (e) {
        _showSnackBar(context, "Error syncing data for $tableName: $e");
      }
    } else {
      transactionsCheck++;
      if (transactionsCheck < refreshTableNamesList.length) {
        await _syncTransactionsDataToCloud(context, refreshTableNamesList[transactionsCheck]);
      } else {
        _showSnackBar(context, "Sync is successful!");
      }
    }
  }

  // Show Snackbar
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}



// Database Helper Mock for getting the data from geoBoundaries, leads, fileRepository
// class DatabaseHelper {
//   // Mock methods to get data from different tables
//   static Future<List<Map<String, dynamic>>> getGeoBoundaries() async {
//     // Fetch data from the local database (geoBoundaries table)
//     return [
//       {"id": 1, "name": "Boundary 1", "coordinates": "sample_coordinates_1"},
//       {"id": 2, "name": "Boundary 2", "coordinates": "sample_coordinates_2"}
//     ];
//   }
//
//   static Future<List<Map<String, dynamic>>> getLeads() async {
//     // Fetch data from the local database (leads table)
//     return [
//       {"id": 1, "name": "Lead 1", "email": "lead1@example.com"},
//       {"id": 2, "name": "Lead 2", "email": "lead2@example.com"}
//     ];
//   }
//
//   static Future<List<Map<String, dynamic>>> getFileRepository() async {
//     // Fetch data from the local database (fileRepository table)
//     return [
//       {"id": 1, "fileName": "file1.jpg", "filePath": "/files/file1.jpg"},
//       {"id": 2, "fileName": "file2.jpg", "filePath": "/files/file2.jpg"}
//     ];
//   }
// }
