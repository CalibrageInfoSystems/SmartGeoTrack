import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'Database/DataAccessHandler.dart';
import 'Database/Palm3FoilDatabase.dart';
import 'NewPassword.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smartgetrack/Common/custom_lead_template.dart';
import 'package:smartgetrack/common_styles.dart';

class ViewLeads extends StatefulWidget {
  const ViewLeads({super.key});

  @override
  State<ViewLeads> createState() => _ViewLeadsState();
}

class _ViewLeadsState extends State<ViewLeads> {
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
      appBar:
      AppBar(
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
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.person_outline, color: Colors.black),
        //     onPressed: () {
        //       // Add functionality for profile icon
        //     },
        //   ),
        // ],
      ),
      // AppBar(
      //   backgroundColor: CommonStyles.listOddColor,
      //   leading: const Icon(Icons.arrow_back),
      //   scrolledUnderElevation: 0,
      //   title: const Text(
      //     'View Lead',
      //     //  style: CommonStyles.txStyF14CbFF5,
      //   ),
      //   actions: [
      //     IconButton(
      //       onPressed: () {
      //         Navigator.pop(context);
      //       },
      //       icon: const Icon(Icons.more_vert_rounded),
      //     ),
      //   ],
      // ),
      body:
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0), // Padding below filterAndSearch
            child: filterAndSearch(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0), // Left and right padding
              child: ListView.separated(
                itemCount: _leads.length,
                itemBuilder: (context, index) {
                  final lead = _leads[index]; // _leads is a list of maps

                  return CustomLeadTemplate(index: index, lead: lead); // Pass both index and lead
                },
                separatorBuilder: (context, index) => const SizedBox(height: 10),
              ),
            ),
          ),
        ],
      )




    );
  }

  Container filterAndSearch() {
    return Container(
      height: 60,
      color: CommonStyles.listOddColor,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: CommonStyles.whiteColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                  const EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
              onPressed: () => openFilter(context),
              child: const Row(
                children: [
                  Icon(
                    Icons.filter_alt,
                    color: CommonStyles.dataTextColor,
                  ),
                  Text(
                    'Filter',
                    style: TextStyle(color: CommonStyles.dataTextColor),
                  ),
                ],
              )),
          const SizedBox(width: 10),
          Expanded(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: CommonStyles.whiteColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10)),
                  onPressed: () {},
                  child: const Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: CommonStyles.dataTextColor,
                      ),
                      Text(
                        'Search',
                        style: TextStyle(color: CommonStyles.dataTextColor),
                      ),
                    ],
                  ))),
        ],
      ),
    );
  }

  List<String> dates = ['Today', 'This Week', 'Month', 'Company', 'Individual'];
  int chipValue = 0;
  void openFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Filter(
              selectedChip: chipValue,
              dates: dates,
              onSelectedChip: (int selectedIndex) {
                setModalState(() {
                  if (selectedIndex != -1) {
                    chipValue = selectedIndex;
                    print('Selected Chip: $selectedIndex');
                  }
                });
              },
            );
          },
        );
      },
    );
  }

  Future<void> _loadLeads() async {
    try {
      // Initialize the Palm3FoilDatabase instance
      //  palm3FoilDatabase = await Palm3FoilDatabase.getInstance();
      final dataAccessHandler = Provider.of<DataAccessHandler>(context, listen: false);
      // Optionally, print the tables in the database for debugging
      //  await palm3FoilDatabase?.printTables();

      // Query the Leads table
      List<Map<String, dynamic>> leads = await dataAccessHandler!.getleads();
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

}

class Filter extends StatefulWidget {
  final int selectedChip;
  final void Function(int)? onSelectedChip;
  final List<String> dates;
  const Filter(
      {super.key,
        required this.selectedChip,
        this.onSelectedChip,
        required this.dates});

  @override
  State<Filter> createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 40),
              const Text('Filter',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                  icon: const Icon(
                    Icons.close,
                  ),
                  iconSize: 20,
                  onPressed: () {
                    Navigator.pop(context);
                  })
            ],
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(height: 10.0),
                Wrap(
                  spacing: 12.0,
                  children: List<Widget>.generate(
                    widget.dates.length,
                        (int index) {
                      return ChoiceChip(
                        label: Text(
                          widget.dates[index],
                        ),
                        selectedColor: CommonStyles.btnBlueBgColor,
                        backgroundColor: CommonStyles.whiteColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                                color: CommonStyles.btnBlueBgColor)),
                        selected: widget.selectedChip == index,
                        onSelected: (bool selected) {
                          if (widget.onSelectedChip != null) {
                            widget.onSelectedChip!(selected ? index : -1);
                          }
                        },
                      );
                    },
                  ).toList(),
                ),
                const SizedBox(height: 10.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// class ViewLeads extends StatefulWidget {
//   @override
//   _ViewLeadScreenState createState() => _ViewLeadScreenState();
// }
//
// class _ViewLeadScreenState extends State<ViewLeads> with SingleTickerProviderStateMixin {
//   // Define a list to hold the leads
//   List<Map<String, dynamic>> _leads = [];
//   Palm3FoilDatabase? palm3FoilDatabase;
//   @override
//   void initState() {
//     super.initState();
//     _loadLeads();
//
//   }
//
//   @override
//   void dispose() {
//
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar:  AppBar(
//         backgroundColor: Colors.lightBlue[50], // Background color
//         elevation: 0, // Remove the shadow under the AppBar
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             // Navigate to the previous screen
//             Navigator.pop(context);
//           },
//         ),
//         title: Row(
//           children: [
//             const Text(
//               'View Leads', // Add Leads beside the back arrow
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//
//           ],
//         ),
//         centerTitle: false, // Disable automatic center title (handled manually)
//         actions: [
//           IconButton(
//             icon: Icon(Icons.person_outline, color: Colors.black),
//             onPressed: () {
//               // Add functionality for profile icon
//             },
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//
//          _buildLeadsList(),
//
//         ],
//       ),
//     );
//   }
//
//   // Function to load the leads from the database

//   // Function to build the list of leads
//   Widget _buildLeadsList() {
//     // Use FutureBuilder if data is loaded asynchronously, or check if data is loaded
//     if (_leads.isEmpty) {
//       return Center(child: CircularProgressIndicator()); // Show loading indicator
//     }
//
//     return ListView.builder(
//       itemCount: _leads.length,
//       itemBuilder: (context, index) {
//         final lead = _leads[index];
//         return ListTile(
//           title: Text(lead['Name'] ?? 'No Name'),
//           subtitle: Text(lead['CompanyName'] ?? 'No Company'),
//           trailing: Text(lead['PhoneNumber'] ?? 'No Phone'),
//           onTap: () {
//             // Handle tap on the lead item
//           },
//         );
//       },
//     );
//   }
// }
//


