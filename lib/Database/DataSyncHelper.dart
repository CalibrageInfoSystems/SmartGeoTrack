import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'DataAccessHandler.dart';
import 'ProgressBar.dart';

import 'dart:convert';  // For JSON encoding

class DataSyncHelper {
  static Future<void> performMasterSync(
      BuildContext context,
      bool firstTimeInsertFinished,
      Function(bool, dynamic, String) onComplete
      ) async {
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    print('currentDate===21: $currentDate');

    Map<String, String> syncDataMap = {
      "lastUpdatedDate": "2024-09-10",
    };

    print('syncDataMap===21: $syncDataMap');
    final dataAccessHandler = Provider.of<DataAccessHandler>(context, listen: false);

    ProgressBar.showProgressBar(context, "Making data ready for you...");

    // Send the request with JSON body and headers
    var response = await http.post(
      Uri.parse('http://182.18.157.215/SmartGeoTrack/API/api/SyncMasters/GetMasterData'),
      headers: {"Content-Type": "application/json"},  // Set the content type to JSON
      body: jsonEncode(syncDataMap),  // Encode the data to JSON format
    );

    print('response: ${response.statusCode}');
    if (response.statusCode == 200) {
      var masterData = json.decode(response.body);
      print('masterData===33: $masterData');

      if (masterData.isNotEmpty) {
        Set<String> tableNames = masterData.keys.toSet();
        print('tableNames===37: $tableNames');

        int countCheck = 0;

        for (String tableName in tableNames) {
          print('tableName===41: $tableName');
          countCheck++;

          if (!firstTimeInsertFinished) {
            await dataAccessHandler.deleteRow(tableName);
            if (masterData[tableName] is List<dynamic>) {
              List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(masterData[tableName]);
              await dataAccessHandler.insertData(tableName, dataList);
            }
          } else {
            await dataAccessHandler.insertData(tableName, masterData[tableName]);
          }

          if (countCheck == 3) {
            ProgressBar.hideProgressBar(context);
            onComplete(true, null, "Sync is success");
          }
        }
      } else {
        ProgressBar.hideProgressBar(context);
        onComplete(true, null, "Sync is up-to-date");
      }
    } else {
      ProgressBar.hideProgressBar(context);
      onComplete(false, null, "Master sync failed. Please try again");
    }
  }
}

