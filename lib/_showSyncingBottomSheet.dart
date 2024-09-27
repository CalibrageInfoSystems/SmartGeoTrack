import 'package:flutter/material.dart';
class SyncOfflineDataScreen extends StatefulWidget {
  @override
  _SyncOfflineDataScreenState createState() => _SyncOfflineDataScreenState();
}

class _SyncOfflineDataScreenState extends State<SyncOfflineDataScreen> {
  void _showSyncingBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false, // Prevent closing until sync is done
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sync, size: 50, color: Colors.blue),
            SizedBox(height: 20),
            Text('Sync Offline Data'),
            SizedBox(height: 10),
            Text('Please don\'t close the app while syncing is in progress.'),
            SizedBox(height: 10),
            Text('Total Requests: 3456'),
            Text('Pending: 0'),
            SizedBox(height: 10),
            Text('Last Sync: 1 Hour, Ago'),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _startSync, // Simulate sync process
              child: Text('Sync'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSyncSuccessBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 50, color: Colors.green),
            SizedBox(height: 20),
            Text('Sync Offline Data'),
            SizedBox(height: 10),
            Text('Data was synced successfully!'),
          ],
        ),
      ),
    );
  }

  void _startSync() {
    // Simulate a sync operation
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pop(context); // Close the syncing progress bottom sheet
      _showSyncSuccessBottomSheet(); // Show success bottom sheet
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sync Offline Data'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _showSyncingBottomSheet,
          child: Text('Sync Data'),
        ),
      ),
    );
  }
}

