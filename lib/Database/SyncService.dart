// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../Model/FileRepositoryModel.dart';
import '../Model/GeoBoundariesModel.dart';
import '../Model/LeadsModel.dart';
import 'DataAccessHandler.dart';
import 'DatabaseHelper.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// other imports as necessary

class SyncService {
  static const String apiUrl =
      "http://182.18.157.215/SmartGeoTrack/API/SyncTransactions/SyncTransactions";
  static const String geoBoundariesTable = 'geoBoundaries';
  static const String leadsTable = 'leads';
  static const String fileRepositoryTable = 'FileRepositorys';

  final DataAccessHandler dataAccessHandler; // Add DataAccessHandler reference

  Map<String, List<Map<String, dynamic>>> refreshTransactionsDataMap = {};
  List<String> refreshTableNamesList = [
    geoBoundariesTable,
    leadsTable,
    fileRepositoryTable
  ];
  int transactionsCheck = 0;

  SyncService(
      this.dataAccessHandler); // Constructor to inject DataAccessHandler

  Future<List<T>> _fetchData<T>(
      Future<List<T>> Function() fetchFunction, String modelName) async {
    List<T> dataList = await fetchFunction();
    if (dataList.isEmpty) {
      print('$modelName list is empty.');
    } else {
      print('$modelName fetched: $dataList');
    }
    return dataList;
  }

  Future<void> getRefreshSyncTransDataMap() async {
    // Fetching geoBoundaries
    // Fetching geoBoundaries
    List<GeoBoundariesModel> geoBoundariesList = await _fetchData(
        DatabaseHelper.instance.getGeoBoundariesDetails, 'GeoBoundaries');

    // Check if geoBoundariesList is not empty before adding to the map
    if (geoBoundariesList.isNotEmpty) {
      List<GeoBoundariesModel> updatedGeoBoundariesList = [];

      // For each geo boundary, get the address using latitude and longitude
      for (var boundary in geoBoundariesList) {
        if (boundary.latitude != null && boundary.longitude != null) {
          String address = await getAddressFromLatLong(
              boundary.latitude!, boundary.longitude!);
          boundary.Address = address;
        }

        // Add the updated boundary to the new list
        updatedGeoBoundariesList.add(boundary);
      }

      // Now store the updated list with addresses in the map
      refreshTransactionsDataMap[geoBoundariesTable] =
          updatedGeoBoundariesList.map((model) => model.toMap()).toList();
      print(
          'Updated geoBoundariesTable map: ${refreshTransactionsDataMap[geoBoundariesTable]}');
    } else {
      print('GeoBoundaries list is empty, skipping to next.');
    }
    // Fetching leads
    List<LeadsModel> leadsList =
        await _fetchData(DatabaseHelper.instance.getLeadsDetails, 'Leads');

    // Check if leadsList is not empty before adding to the map
    if (leadsList.isNotEmpty) {
      refreshTransactionsDataMap[leadsTable] =
          leadsList.map((model) => model.toMap()).toList();
    } else {
      print('Leads list is empty, skipping to next.');
    }

    // Fetching fileRepoList
    List<FileRepositoryModel> fileRepoList = await _fetchData(
        DatabaseHelper.instance.getFileRepositoryDetails, 'FileRepositorys');

    if (fileRepoList.isNotEmpty) {
      print('File Repository list: $fileRepoList');

      List<FileRepositoryModel> updatedFileRepoList = [];

      // For each file repository, call prepareAndSendFile
      for (var model in fileRepoList) {
        if (model.fileLocation != null) {
          // Call prepareAndSendFile and update the model
          await prepareAndSendFile(model.fileLocation!, model);

          // Add the updated model to the new list
          updatedFileRepoList.add(model);
        }
      }

      // Now store the updated list in the map
      refreshTransactionsDataMap[fileRepositoryTable] =
          updatedFileRepoList.map((model) => model.toJson()).toList();

      print(
          'Updated File Repository map: ${refreshTransactionsDataMap[fileRepositoryTable]}');
    } else {
      print('File Repository list is empty.');
    }

    // If no data was fetched, print a message
    if (refreshTransactionsDataMap.isEmpty) {
      print('No data was fetched from any table.');
    } else {
      print('Fetched Data: $refreshTransactionsDataMap');
    }
  }

  // Future<void> getRefreshSyncTransDataMap() async {
  //   // Fetching geoBoundaries
  //   List<GeoBoundariesModel> geoBoundariesList = await _fetchData(DatabaseHelper.instance.getGeoBoundariesDetails, 'GeoBoundaries');
  //   refreshTransactionsDataMap[geoBoundariesTable] = geoBoundariesList.map((model) => model.toMap()).toList();
  //
  //   // Fetching leads
  //   List<LeadsModel> leadsList = await _fetchData(DatabaseHelper.instance.getLeadsDetails, 'Leads');
  //   refreshTransactionsDataMap[leadsTable] = leadsList.map((model) => model.toMap()).toList();
  //
  //   // Fetching fileRepoList
  //   List<FileRepositoryModel> fileRepoList = await _fetchData(DatabaseHelper.instance.getFileRepositoryDetails, 'File Repository');
  //   refreshTransactionsDataMap[fileRepositoryTable] = fileRepoList.map((model) => model.toJson()).toList();
  //
  //   print('Fetched Data: $refreshTransactionsDataMap');
  // }
  Future<void> performRefreshTransactionsSync(BuildContext context,
      {void Function()? showSuccessBottomSheet,
      void Function()? onComplete}) async {
    await getRefreshSyncTransDataMap();

    if (refreshTransactionsDataMap.isNotEmpty) {
      await _syncTransactionsDataToCloud(
          context, refreshTableNamesList[transactionsCheck]);
    } else {
      // _showSnackBar(context, "No transactions data to sync.");
      String tableName = "No transactions data to sync.";
      List tableData = refreshTransactionsDataMap[tableName] ?? [];

      if (tableData.isNotEmpty) {
        try {
          String data = jsonEncode({tableName: tableData});
          var response = await http.post(
            Uri.parse(apiUrl),
            headers: {"Content-Type": "application/json"},
            body: data,
          );

          if (response.statusCode == 200) {
            await _updateServerUpdatedStatus(tableName);

            transactionsCheck++;

            for (int transactionsCheck = 0;
                transactionsCheck < refreshTableNamesList.length;
                transactionsCheck++) {
              await _syncTransactionsDataToCloud(
                  context, refreshTableNamesList[transactionsCheck]);
            }

            _showSnackBar(context, "Sync is successful!");

            // Call onComplete after the loop ends
            if (onComplete != null) {
              onComplete(); // Ensure the callback is invoked
            }
          } else {
            _showSnackBar(
                context, "Sync failed for $tableName: ${response.body}");
          }
        } catch (e) {
          _showSnackBar(context, "Error syncing data for $tableName: $e");
        }
      } else {
        transactionsCheck++;
        if (transactionsCheck < refreshTableNamesList.length) {
          await _syncTransactionsDataToCloud(
              context, refreshTableNamesList[transactionsCheck]);
        } else {
          // Call showSuccessBottomSheet when loop ends
          if (showSuccessBottomSheet != null) {
            showSuccessBottomSheet(); // Ensure the callback is invoked
          }
        }
      }
    }
  }

  Future<void> _syncTransactionsDataToCloud(
      BuildContext context, String tableName) async {
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
          // Execute the SQL update query after successful sync
          await _updateServerUpdatedStatus(tableName); // Ensure this is awaited

          transactionsCheck++;
          if (transactionsCheck < refreshTableNamesList.length) {
            await _syncTransactionsDataToCloud(
                context, refreshTableNamesList[transactionsCheck]);
          } else {
            _showSnackBar(context, "Sync is successful!");
          }
        } else {
          print('Error response: ${response.body}');
          _showSnackBar(
              context, "Sync failed for $tableName: ${response.body}");
        }
      } catch (e) {
        _showSnackBar(context, "Error syncing data for $tableName: $e");
      }
    } else {
      transactionsCheck++;
      if (transactionsCheck < refreshTableNamesList.length) {
        await _syncTransactionsDataToCloud(
            context, refreshTableNamesList[transactionsCheck]);
      } else {
        _showSnackBar(context, "Sync is successful!");
      }
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _updateServerUpdatedStatus(String tableName) async {
    print(
        "Attempting to update ServerUpdatedStatus for table: $tableName"); // Debug statement
    final db = await DatabaseHelper
        .instance.database; // Accessing database from DataAccessHandler
    String query =
        "UPDATE $tableName SET ServerUpdatedStatus = '1' WHERE ServerUpdatedStatus = '0'";

    try {
      await db.rawUpdate(query);
      print("Updated ServerUpdatedStatus for $tableName successfully.");
    } catch (e) {
      print("Error updating ServerUpdatedStatus for $tableName: $e");
    }
  }

  Future<String> getAddressFromLatLong(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      }
    } catch (e) {
      print(e);
    }
    return "Unknown Location";
  }
}
