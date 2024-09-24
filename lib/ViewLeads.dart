import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'Database/Palm3FoilDatabase.dart';
import 'NewPassword.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class ViewLeads extends StatefulWidget {
  @override
  _ViewLeadScreenState createState() => _ViewLeadScreenState();
}

class _ViewLeadScreenState extends State<ViewLeads> with SingleTickerProviderStateMixin {
  // Define a list to hold the leads
  List<Map<String, dynamic>> _leads = [];
  Palm3FoilDatabase? palm3FoilDatabase;
  @override
  void initState() {
    super.initState();
    _loadLeads();

  }

  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        backgroundColor: Colors.lightBlue[50], // Background color
        elevation: 0, // Remove the shadow under the AppBar
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Navigate to the previous screen
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            const Text(
              'View Leads', // Add Leads beside the back arrow
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

          ],
        ),
        centerTitle: false, // Disable automatic center title (handled manually)
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline, color: Colors.black),
            onPressed: () {
              // Add functionality for profile icon
            },
          ),
        ],
      ),
      body: Stack(
        children: [

         _buildLeadsList(),

        ],
      ),
    );
  }

  // Function to load the leads from the database
  Future<void> _loadLeads() async {
    try {
      // Initialize the Palm3FoilDatabase instance
      palm3FoilDatabase = await Palm3FoilDatabase.getInstance();

      // Optionally, print the tables in the database for debugging
      await palm3FoilDatabase?.printTables();

      // Query the Leads table
      List<Map<String, dynamic>> leads = await palm3FoilDatabase!.getleads();
      print('Leads Retrieved:');
      // Print the leads in the UI for debugging
      print('Leads Retrieved: ${leads.length}');
      leads.forEach((lead) {
        print('=========>$lead');
      });

      // Update the state with the retrieved leads
      setState(() {
        _leads = leads;
        print('=========>$_leads');
      });
    } catch (e) {
      print('Error while getting leads: ${e.toString()}');
    }
  }

  // Function to build the list of leads
  Widget _buildLeadsList() {
    // Use FutureBuilder if data is loaded asynchronously, or check if data is loaded
    if (_leads.isEmpty) {
      return Center(child: CircularProgressIndicator()); // Show loading indicator
    }

    return ListView.builder(
      itemCount: _leads.length,
      itemBuilder: (context, index) {
        final lead = _leads[index];
        return ListTile(
          title: Text(lead['Name'] ?? 'No Name'),
          subtitle: Text(lead['CompanyName'] ?? 'No Company'),
          trailing: Text(lead['PhoneNumber'] ?? 'No Phone'),
          onTap: () {
            // Handle tap on the lead item
          },
        );
      },
    );
  }
}



