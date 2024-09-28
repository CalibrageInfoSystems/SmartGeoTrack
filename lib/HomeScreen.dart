import 'dart:io';
import 'dart:ui';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartgetrack/Common/Constants.dart';
import 'package:smartgetrack/LoginScreen.dart';
import 'package:smartgetrack/common_styles.dart';
import 'package:smartgetrack/view_leads_info.dart';

import 'AddLeads.dart';
import 'Common/custom_lead_template.dart';
import 'Database/DataAccessHandler.dart';
import 'Database/DatabaseHelper.dart';
import 'Database/Palm3FoilDatabase.dart';
import 'Database/SyncService.dart';
import 'Database/SyncServiceB.dart';
import 'Model/LeadsModel.dart';
import 'ViewLeads.dart';
import '_showSyncingBottomSheet.dart';
import 'location_service/logic/location_controller/location_controller_cubit.dart';
import 'location_service/notification/notification.dart';
import 'location_service/tools/background_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late BackgroundService backgroundService;
  late double lastLatitude;
  late double lastLongitude;

  static const double MAX_ACCURACY_THRESHOLD = 10.0;
  static const double MAX_SPEED_ACCURACY_THRESHOLD = 5.0;
  static const double MIN_DISTANCE_THRESHOLD = 50.0;
  static const double MIN_SPEED_THRESHOLD = 0.2;
  Palm3FoilDatabase? palm3FoilDatabase;
  final dataAccessHandler = DataAccessHandler();
  String? username;
  String? formattedDate;
  bool isLocationEnabled = false;
  int? userID;
  int? totalLeadsCount;
  int? todayLeadsCount;
  int? dateRangeLeadsCount;
  late Future<List<LeadsModel>> futureLeads;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    getuserdata();
    fetchLeadCounts();

    futureLeads = loadleads();
    backgroundService =
        BackgroundService(userId: userID, dataAccessHandler: dataAccessHandler);
    checkLocationEnabled();
    startService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initializeBackgroundService();
  }

  Future<void> initializeBackgroundService() async {
    if (await backgroundService.instance.isRunning()) {
      print('Background service is already running.');
      await backgroundService.initializeService();
    } else {
      print('Background service is not running. Starting now...');
    }

    // Add logging here
    backgroundService.instance.on('on_location_changed').listen((event) async {
      print('Received location update event');

      // backgroundService.instance.on('on_location_changed').listen((event) async {
      if (event != null) {
        final position = Position(
          longitude: double.tryParse(event['longitude'].toString()) ?? 0.0,
          latitude: double.tryParse(event['latitude'].toString()) ?? 0.0,
          timestamp: DateTime.fromMillisecondsSinceEpoch(
            event['timestamp'].toInt(),
            isUtc: true,
          ),
          accuracy: double.tryParse(event['accuracy'].toString()) ?? 0.0,
          altitude: double.tryParse(event['altitude'].toString()) ?? 0.0,
          heading: double.tryParse(event['heading'].toString()) ?? 0.0,
          speed: double.tryParse(event['speed'].toString()) ?? 0.0,
          speedAccuracy:
              double.tryParse(event['speed_accuracy'].toString()) ?? 0.0,
          altitudeAccuracy:
              double.tryParse(event['altitude_accuracy'].toString()) ?? 0.0,
          headingAccuracy:
              double.tryParse(event['heading_accuracy'].toString()) ?? 0.0,
        );
        print(
            "on_location_changed: ${position.latitude} -  ${position.longitude}");
        if (_isPositionAccurate(position)) {
          double distance = Geolocator.distanceBetween(lastLatitude,
              lastLongitude, position.latitude, position.longitude);

          if (distance >= MIN_DISTANCE_THRESHOLD) {
            lastLatitude = position.latitude;
            lastLongitude = position.longitude;
            DateTime timestamp = DateTime.now();
            // Insert location into the database
            await palm3FoilDatabase!.insertLocationValues(
                latitude: position.latitude,
                longitude: position.longitude,
                createdByUserId: userID, // replace userID with the actual value
                serverUpdatedStatus: false,
                from: '116');

            appendLog(
                'Latitude: ${position.latitude}, Longitude: ${position.longitude}. Distance: $distance, Timestamp: $timestamp');
            //  await sendLocationToAPI(position.latitude, position.longitude, timestamp);
            bool isConnected = await CommonStyles.checkInternetConnectivity();
            if (isConnected) {
              // Call your login function here
              final syncService = SyncService(dataAccessHandler);
              syncService.performRefreshTransactionsSync(context);
            } else {
              Fluttertoast.showToast(
                  msg: "Please check your internet connection.",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
              print("Please check your internet connection.");
              //showDialogMessage(context, "Please check your internet connection.");
            }

            await context.read<LocationControllerCubit>().onLocationChanged(
                  location: position,
                );
          }
        } else {
          print('Position Accuracy: ${position.accuracy}');
          print('Speed Accuracy: ${position.speedAccuracy}');
          print('Speed: ${position.speed}');
        }
      }
    });
  }

  bool _isPositionAccurate(Position position) {
    print('Position Accuracy:106=== ${position.accuracy}');
    print('Speed Accuracy:107=== ${position.speedAccuracy}');
    print('Speed:108=== ${position.speed}');
    return position.accuracy <= MAX_ACCURACY_THRESHOLD &&
        position.speedAccuracy <= MAX_SPEED_ACCURACY_THRESHOLD &&
        position.speed >= MIN_SPEED_THRESHOLD;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        exit(0);
      },
      child: Scaffold(
        backgroundColor: CommonStyles.whiteColor,
        body: Stack(
          children: [
            header(size),
            Positioned.fill(
              top: 240,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Show loading indicator while data is loading
                      if (isLoading)
                        const Center(
                            child:
                                CircularProgressIndicator()) // Loading indicator
                      else ...[
                        // UI content after loading is complete
                        Row(
                          children: [
                            Expanded(
                                child: customBox(
                                    title: 'Total Leads',
                                    data: totalLeadsCount)),
                            const SizedBox(width: 20),
                            Expanded(
                                child: customBox(
                                    title: 'Today Leads',
                                    data: todayLeadsCount)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        statisticsSection(),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                                child: customBox(
                                    title: 'Km\'s Travel',
                                    data: 677,
                                    bgImg: 'assets/bg_image2.jpg')),
                            const SizedBox(width: 20),
                            Expanded(
                                child: customBox(
                                    title: 'Leads', data: dateRangeLeadsCount)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: customBtn(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AddLeads(),
                                    ),
                                  );
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      size: 18,
                                      color: CommonStyles.whiteColor,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Add Lead',
                                      style: CommonStyles.txStyF14CwFF5,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: customBtn(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ViewLeads(),
                                    ),
                                  );
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.view_list_rounded,
                                      size: 18,
                                      color: CommonStyles.whiteColor,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'View Leads',
                                      style: CommonStyles.txStyF14CwFF5,
                                    ),
                                  ],
                                ),
                                backgroundColor: CommonStyles.btnBlueBgColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: customBtn(
                            onPressed: showSyncSuccessBottomSheet,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.sync,
                                  size: 18,
                                  color: CommonStyles.whiteColor,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Sync Data',
                                  style: CommonStyles.txStyF14CwFF5,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Today Leads',
                          style: CommonStyles.txStyF16CbFF5,
                        ),
                        FutureBuilder<List<LeadsModel>>(
                          future: futureLeads,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            } else if (snapshot.hasData &&
                                snapshot.data!.isNotEmpty) {
                              List<LeadsModel> futureLeads = snapshot.data!;
                              return ListView.separated(
                                itemCount: futureLeads.length,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemBuilder: (context, index) {
                                  final lead = futureLeads[index];
                                  return CustomLeadTemplate(
                                    index: index,
                                    lead: lead,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ViewLeadsInfo(code: lead.code!),
                                        ),
                                      );
                                    },
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 10),
                              );
                            } else {
                              return const Center(
                                  child: Text('No leads available for today'));
                            }
                          },
                        ),
                      ],
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container leadTemplate(int index) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: index.isEven
            ? CommonStyles.listEvenColor
            : CommonStyles.listOddColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jessy',
                style: CommonStyles.txStyF16CbFF5,
              ),
              Icon(Icons.arrow_circle_right_outlined),
            ],
          ),
          const SizedBox(height: 3),
          listCustomText('ABCD Software Solutions'),
          listCustomText('test@test.com'),
          listCustomText('+91 1234567890'),
        ],
      ),
    );
  }

  Column listCustomText(String text) {
    return Column(
      children: [
        Text(
          text,
          style: CommonStyles.txStyF16CbFF5
              .copyWith(color: CommonStyles.dataTextColor),
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  ElevatedButton customBtn(
      {Color? backgroundColor = CommonStyles.btnRedBgColor,
      required Widget child,
      void Function()? onPressed}) {
    return ElevatedButton(
      onPressed: () {
        onPressed?.call();
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        backgroundColor: backgroundColor,
      ),
      child: child,
    );
  }

  Widget statisticsSection() {
    return Row(children: [
      const Text(
        'Statistics',
        style: CommonStyles.txStyF16CbFF5,
      ),
      const Spacer(),
      datePopupMenu(),
      /*  Row(
        children: [
          Text(
            'Last 7d',
            style: CommonStyles.txStyF14CbFF5
                .copyWith(color: CommonStyles.dataTextColor),
          ),
          const Icon(Icons.keyboard_arrow_down_rounded,
              color: CommonStyles.dataTextColor),
        ],
      ), */
      Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
        child: GestureDetector(
          onTap: () {
            final DateTime currentDate = DateTime.now();
            final DateTime firstDate = DateTime(currentDate.year - 2);

            launchDatePicker(
              context,
              firstDate: firstDate,
              lastDate: DateTime.now(),
              initialDate: DateTime.now(),
            );
          },
          child: const Row(
            children: [
              Text('March 2020', style: CommonStyles.txStyF14CbFF5),
              SizedBox(width: 5),
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
              ),
            ],
          ),
        ),
      )
    ]);
  }

  // Row leadsSection() {
  //   return Row(
  //     children: [
  //       Expanded(child: customBox(title: 'Total Leads', data: '123')),
  //       const SizedBox(width: 20),
  //       Expanded(child: customBox(title: 'Total Leads', data: '321')),
  //     ],
  //   );
  // }

  Container customBox({
    required String title,
    int? data,
    String bgImg = 'assets/bg_image1.jpg',
  }) {
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage(bgImg),
          fit: BoxFit.cover,
        ),
        border: Border.all(
          color: CommonStyles.blueTextColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: CommonStyles.txStyF20CbluFF5.copyWith(
                fontSize: 18,
              )
              /* style: const TextStyle(
                color: CommonStyles.blueTextColor, fontSize: 20), */
              ),
          Text('$data',
              style: CommonStyles.txStyF20CbFF5.copyWith(
                fontSize: 40,
              )
              /* style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold), */
              ),
        ],
      ),
    );
  }

  Positioned header(Size size) {
    getuserdata();
    return Positioned(
      top: -170,
      left: -10,
      right: -10,
      child: Container(
        width: size.width * 0.9,
        height: 400,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: const DecorationImage(
            image: AssetImage('assets/header_bg_image.jpg'),
            fit: BoxFit.cover,
          ),
          border: Border.all(
            color: CommonStyles.blueTextColor,
            width: 1.0,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: Container(
                color: Colors.grey,
              ),
            ),
            Expanded(
              flex: 6,
              child: SafeArea(
                child: Column(
                  children: [
                    customAppBar(),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text('Hello,',
                              style: CommonStyles.txStyF20CpFF5),
                          Text(
                            // 'string',
                            '$username',
                            style: CommonStyles.txStyF20CpFF5.copyWith(
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            //  '26th Sep 2024',
                            '$formattedDate',
                            style: CommonStyles.txStyF14CbFF5,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> menuItems = [
    'Profile',
    'Settings',
    'Logout',
  ];
  List<String> dateItems = [
    'Today',
    'This Week',
    'Month',
  ];

  String? selectedMenu;

  Widget displayPopupMenu() {
    return PopupMenuButton<String>(
      // key: _menuKey,
      onSelected: (String value) {
        if (value == 'Logout') {
          showLogoutDialog();
        } else {
          print('Selected: $value');
        }
      },
      itemBuilder: (BuildContext context) {
        return menuItems.map((String choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: Text(choice),
          );
        }).toList();
      },
      offset: const Offset(-5, 22),
    );
  }

  String selectedOption = 'Today';
  Widget datePopupMenu() {
    return PopupMenuButton<String>(
        offset: const Offset(-5, 22),
        onSelected: (String value) {
          setState(() {
            selectedOption = value;
          });
        },
        itemBuilder: (BuildContext context) {
          return dateItems.map((String choice) {
            return PopupMenuItem<String>(
              value: choice,
              child: Text(choice),
            );
          }).toList();
        },
        child: Row(
          children: [
            Text(
              selectedOption,
              style: CommonStyles.txStyF14CbFF5
                  .copyWith(color: CommonStyles.dataTextColor),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: CommonStyles.dataTextColor),
          ],
        ));
  }

  String? selectedDate = 'Today';
  Future<void> launchDatePicker(BuildContext context,
      {required DateTime firstDate,
      required DateTime lastDate,
      DateTime? initialDate}) async {
    // final DateTime lastDate = DateTime.now();
    // final DateTime firstDate = DateTime(lastDate.year - 100);
    final DateTime? pickedDay = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDatePickerMode: DatePickerMode.day,
    );
    if (pickedDay != null) {
      selectedDate = pickedDay.toString();
      print('pickedDay: $pickedDay');
    }
  }

  Widget customAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SvgPicture.asset(
            'assets/sgt_logo.svg',
            width: 35,
            height: 35,
          ),
          const SizedBox(width: 8),
          Text(
            'SGT',
            style: CommonStyles.txStyF20CpFF5.copyWith(
                fontWeight: FontWeight.w900, letterSpacing: 3, fontSize: 22),
          ),
          const Spacer(),
          displayPopupMenu()
          /* IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {
              displayPopupMenu();
            },
          ), */
        ],
      ),
    );
  }

  Future<void> startService() async {
    await Fluttertoast.showToast(
        msg: "Wait for a while, Initializing the service...");

    final permission =
        await context.read<LocationControllerCubit>().enableGPSWithPermission();
    if (permission) {
      try {
        Position currentPosition = await Geolocator.getCurrentPosition();
        lastLatitude = currentPosition.latitude;
        lastLongitude = currentPosition.longitude;
        try {
          palm3FoilDatabase = await Palm3FoilDatabase.getInstance();
          // Call printTables after creating the databas
          // dbUpgradeCall();
        } catch (e) {
          print('Error while getting master data: ${e.toString()}');
        }
        // Debug prints
        print('Location permission granted');
        print(
            'Current Position: Latitude: ${currentPosition.latitude}, Longitude: ${currentPosition.longitude}');

        await context
            .read<LocationControllerCubit>()
            .locationFetchByDeviceGPS();
        await backgroundService.initializeService();
        backgroundService.setServiceAsForeground();

        // Show Toast after service starts
        await Fluttertoast.showToast(msg: "Service started successfully!");

        // Debug prints
        print('lastLatitude===>$lastLatitude, lastLongitude===>$lastLongitude');
      } catch (e) {
        print('Error fetching current position: $e');
        await Fluttertoast.showToast(msg: "Error: Service could not start.");
      }
    } else {
      print('Location permission denied');
      await Fluttertoast.showToast(
          msg: "Location permission denied. Service could not start.");
    }
  }

  void stopService() {
    backgroundService.stopService();
    context.read<LocationControllerCubit>().stopLocationFetch();

    // Show Toast after service stops
    Fluttertoast.showToast(msg: "Service stopped successfully!");
  }

  void appendLog(String text) async {
    const String folderName = 'SmartGeoTrack';
    const String fileName = 'UsertrackinglogTest.file';

    Directory appFolderPath =
        Directory('/storage/emulated/0/Download/$folderName');
    if (!appFolderPath.existsSync()) {
      appFolderPath.createSync(recursive: true);
    }

    final logFile = File('${appFolderPath.path}/$fileName');
    if (!logFile.existsSync()) {
      logFile.createSync();
    }

    try {
      final buf = logFile.openWrite(mode: FileMode.append);
      buf.writeln(text);
      await buf.close();
    } catch (e) {
      print("Error appending to log file: $e");
    }
  }

  Future<void> getuserdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userID = prefs.getInt('userID');
    username = prefs.getString('username') ?? '';
    print(' username==$username');
    String firstName = prefs.getString('firstName') ?? '';
    String email = prefs.getString('email') ?? '';
    String mobileNumber = prefs.getString('mobileNumber') ?? '';
    String roleName = prefs.getString('roleName') ?? '';
    DateTime now = DateTime.now();
    formattedDate = formatDate(now);
    print(' formattedDate==$formattedDate'); // Example output: "25th Sep 2024"
  }

  void showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you wanna logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool(Constants.isLogin, false);
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String formatDate(DateTime date) {
    String day = DateFormat('d').format(date);
    String suffix = getDaySuffix(int.parse(day));
    String formattedDate =
        '$day$suffix ${DateFormat('MMM').format(date)} ${DateFormat('y').format(date)}';
    return formattedDate;
  }

  String getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  Future<void> checkLocationEnabled() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    setState(() {
      isLocationEnabled = serviceEnabled;
    });
    if (!serviceEnabled) {
      // If location services are disabled, prompt the user to enable them
      await _promptUserToEnableLocation();
    }
  }

  Future<void> _promptUserToEnableLocation() async {
    bool locationEnabled = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Location Services Disabled"),
          content:
              const Text("Please enable location services to use this app."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Enable"),
            ),
          ],
        );
      },
    );

    if (locationEnabled) {
      // Redirect the user to the device settings to enable location services
      await Geolocator.openLocationSettings();
    }
  }

  void _showSyncingBottomSheet() {
    showModalBottomSheet(
        context: context,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  color: CommonStyles.listOddColor,
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          icon: const Icon(
                            Icons.close,
                          ),
                          iconSize: 20,
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                      const Text('Sync Offline Data',
                          style: CommonStyles.txStyF20CbFF5),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                //MARK: Here
                Container(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          'Please don\'t close the app while syncing is in progress.',
                          style: CommonStyles.txStyF14CbFF5
                              .copyWith(color: CommonStyles.dataTextColor)),
                      const SizedBox(height: 10),
                      SvgPicture.asset('assets/fileDownloadIcon.svg',
                          color: CommonStyles.btnBlueBgColor,
                          width: 70,
                          height: 70),
                      const SizedBox(height: 20),
                      customRow(label: 'Total Requests', data: '3535'),
                      customRow(label: 'Pending', data: '0'),
                      customRow(label: 'Last Sync', data: '1 Hour, Ago'),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: customBtn(
                          onPressed: syncing,
                          child: const Text('Sync',
                              style: CommonStyles.txStyF14CwFF5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future<void> syncing() async {
    final dataAccessHandler =
        Provider.of<DataAccessHandler>(context, listen: false);
    bool isConnected = await CommonStyles.checkInternetConnectivity();
    if (isConnected) {
      final syncService = SyncService(dataAccessHandler);
      syncService.performRefreshTransactionsSync(context,
          showSuccessBottomSheet: showSyncSuccessBottomSheet);
    } else {
      Fluttertoast.showToast(
          msg: "Please Check Your Internet Connection.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      print("Please check your internet connection.");
    }
  }

  void showSyncSuccessBottomSheet() {
    showModalBottomSheet(
        context: context,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  color: CommonStyles.listOddColor,
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          icon: const Icon(
                            Icons.close,
                          ),
                          iconSize: 20,
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                      const Text('Sync Offline Data',
                          style: CommonStyles.txStyF20CbFF5),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                //MARK: Here
                Container(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      SvgPicture.asset('assets/fileDownloadIcon.svg',
                          color: CommonStyles.btnBlueBgColor,
                          width: 70,
                          height: 70),
                      const SizedBox(height: 20),
                      const Text('Data was synced successfully',
                          style: CommonStyles.txStyF14CbFF5),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget customRow({required String label, String? data}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('$label:', style: CommonStyles.txStyF14CbFF5),
        Text('$data',
            style: CommonStyles.txStyF14CbFF5.copyWith(
              color: CommonStyles.dataTextColor,
            )),
      ],
    );
  }

  void _showSyncSuccessBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: const Column(
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

  Future<void> _startSync() async {
    final dataAccessHandler =
        Provider.of<DataAccessHandler>(context, listen: false);
    bool isConnected = await CommonStyles.checkInternetConnectivity();
    if (isConnected) {
      // Call your login function here
      final syncService = SyncService(dataAccessHandler);
      syncService.performRefreshTransactionsSync(context);
      _showSyncSuccessBottomSheet();
    } else {
      Fluttertoast.showToast(
          msg: "Please Check Your Internet Connection.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      // Simulate a sync operation
    }
  }

  Future<void> fetchLeadCounts() async {
    setState(() {
      isLoading = true; // Start loading
    });
    String currentDate = getCurrentDate();
    totalLeadsCount = await dataAccessHandler.getOnlyOneIntValueFromDb(
        'SELECT COUNT(*) AS totalLeadsCount FROM Leads');
    todayLeadsCount = await dataAccessHandler.getOnlyOneIntValueFromDb(
        "SELECT COUNT(*) AS todayLeadsCount FROM Leads WHERE DATE(CreatedDate) = '$currentDate'");
    dateRangeLeadsCount = await dataAccessHandler.getOnlyOneIntValueFromDb(
        "SELECT COUNT(*) AS dateRangeLeadsCount FROM Leads WHERE DATE(CreatedDate) BETWEEN '$currentDate' AND '$currentDate'");

    setState(() {
      isLoading = false; // Stop loading
    });
  }

//   Future<void> fetchLeadCounts() async {
//
//
//     totalLeadsCount= (await dataAccessHandler.getOnlyOneIntValueFromDb('SELECT COUNT(*) AS totalLeadsCount FROM Leads'));
//     print('totalLeadsCount====$totalLeadsCount');
//
//     String currentDate = getCurrentDate(); // Assuming you have the getCurrentDate() function from the previous example
//
// // Update your query to include the current date
//     todayLeadsCount = await dataAccessHandler.getOnlyOneIntValueFromDb(
//         "SELECT COUNT(*) AS todayLeadsCount FROM Leads WHERE DATE(CreatedDate) = '$currentDate'"
//     );
//     dateRangeLeadsCount = await dataAccessHandler.getOnlyOneIntValueFromDb(
//         "SELECT COUNT(*) AS dateRangeLeadsCount FROM Leads WHERE DATE(CreatedDate) BETWEEN '$currentDate' AND '$currentDate'"
//     );
//     // Fetch total leads count
//     // List<Map<String, dynamic>> totalLeadsResult = await db.rawQuery('SELECT COUNT(*) AS totalLeadsCount FROM Leads');
//     //  todayLeadsCount = (await dataAccessHandler.getOnlyOneIntValueFromDb('SELECT COUNT(*) AS todayLeadsCount FROM Leads WHERE DATE(CreatedDate) = '''));
//     print('totalLeadsCount====$todayLeadsCount');
//     // Fetch today's leads count
//     // List<Map<String, dynamic>> todayLeadsResult = await db.rawQuery(
//     //     "SELECT COUNT(*) AS todayLeadsCount FROM Leads WHERE DATE(CreatedDate) = ?", ['2024-09-26']);
//     // todayLeadsCount = todayLeadsResult[0]['todayLeadsCount'];
//
//     // Fetch date range leads count
//     // List<Map<String, dynamic>> dateRangeLeadsResult = await db.rawQuery(
//     //     "SELECT COUNT(*) AS dateRangeLeadsCount FROM Leads WHERE DATE(CreatedDate) BETWEEN ? AND ?", ['2024-09-25', '2024-09-26']);
//     // dateRangeLeadsCount = dateRangeLeadsResult[0]['dateRangeLeadsCount'];
//
//     // Update the UI
//     setState(() {});
//   }
  Future<List<LeadsModel>> TodayloadLeads(String today) async {
    try {
      // final dataAccessHandler = Provider.of<DataAccessHandler>(context, listen: false);
      List<dynamic> leads = await dataAccessHandler.getTodayLeads(today);
      return leads.map((item) => LeadsModel.fromMap(item)).toList();
    } catch (e) {
      throw Exception('catch: ${e.toString()}');
    }
  }

  String getCurrentDate() {
    DateTime now = DateTime.now();
    String formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    return formattedDate;
  }

  Future<List<LeadsModel>> loadleads() async {
    try {
      final dataAccessHandler =
          Provider.of<DataAccessHandler>(context, listen: false);
      List<dynamic> leads = await dataAccessHandler.getleads();
      return leads.map((item) => LeadsModel.fromMap(item)).toList();
    } catch (e) {
      throw Exception('catch: ${e.toString()}');
    }
  }
}

class BackgroundService {
  int? userId;
  final DataAccessHandler dataAccessHandler; // Declare DataAccessHandler
  late SyncServiceB syncService; // Declare SyncService
  final FlutterBackgroundService flutterBackgroundService =
      FlutterBackgroundService();
  static const double MAX_ACCURACY_THRESHOLD = 10.0;
  static const double MAX_SPEED_ACCURACY_THRESHOLD = 5.0;
  static const double MIN_DISTANCE_THRESHOLD = 50.0;
  static const double MIN_SPEED_THRESHOLD = 0.2;
  BackgroundService({required this.userId, required this.dataAccessHandler}) {
    // Initialize SyncService with DataAccessHandler
    syncService = SyncServiceB(
        dataAccessHandler); // Make sure to initialize DataAccessHandler properly
  }

  FlutterBackgroundService get instance => flutterBackgroundService;

  Future<void> initializeService() async {
    await NotificationService(FlutterLocalNotificationsPlugin()).createChannel(
      const AndroidNotificationChannel(
        'location_channel',
        'Location Channel',
        importance: Importance.high, // Ensure high importance for visibility
      ),
    );

    await flutterBackgroundService.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'location_channel',
        foregroundServiceNotificationId: 888,
        initialNotificationTitle: 'Location Service',
        initialNotificationContent: 'Tracking location in background',
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
      ),
    );
    await flutterBackgroundService.startService();
  }

  void setServiceAsForeground() async {
    flutterBackgroundService.invoke("setAsForeground");
  }

  void stopService() {
    flutterBackgroundService.invoke("stop_service");
  }

  Future<void> syncLocationData() async {
    try {
      await syncService
          .performRefreshTransactionsSync(); // Call the sync method
      print("Location data synced successfully.");
    } catch (e) {
      print("Error syncing location data: $e");
    }
  }
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  Palm3FoilDatabase? palm3FoilDatabase = await Palm3FoilDatabase.getInstance();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? userID = prefs.getInt('userID');

  // You need to maintain a way to get the userId or DataAccessHandler here.
  //final userId = userID; // Replace with the actual way to get userId

  // Pass the DataAccessHandler to the BackgroundService
  final dataAccessHandler = DataAccessHandler(); // Initialize this properly
  final backgroundService =
      BackgroundService(userId: userID, dataAccessHandler: dataAccessHandler);

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) async {
      await service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) async {
      await service.setAsBackgroundService();
    });
  }

  service.on("stop_service").listen((event) async {
    await service.stopSelf();
  });

  double lastLatitude = 0.0;
  double lastLongitude = 0.0;
  bool isFirstLocationLogged = false;

  Geolocator.getPositionStream().listen((Position position) async {
    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.always) {
      service.invoke('on_location_changed', position.toJson());
      if (_isPositionAccurate(position)) {
        if (!isFirstLocationLogged) {
          // Log the first point
          lastLatitude = position.latitude;
          lastLongitude = position.longitude;
          isFirstLocationLogged = true;
          DateTime timestamp = DateTime.now();

          await palm3FoilDatabase!.insertLocationValues(
              latitude: position.latitude,
              longitude: position.longitude,
              createdByUserId: userID,
              // Use the actual userID
              serverUpdatedStatus: false,
              from: '997');

          appendLog(
              'Latitude: ${position.latitude}, Longitude: ${position.longitude}. Timestamp: $timestamp');

          // Sync the data to the server
          await backgroundService
              .syncLocationData(); // Use the existing instance
        }
      }
      if (_isPositionAccurate(position)) {
        final distance = Geolocator.distanceBetween(
          lastLatitude,
          lastLongitude,
          position.latitude,
          position.longitude,
        );

        if (distance >= 50.0) {
          lastLatitude = position.latitude;
          lastLongitude = position.longitude;
          DateTime timestamp = DateTime.now();

          await palm3FoilDatabase!.insertLocationValues(
              latitude: position.latitude,
              longitude: position.longitude,
              createdByUserId: userID,
              serverUpdatedStatus: false,
              from: '1023');

          appendLog(
              'Background Latitude: ${position.latitude}, Longitude: ${position.longitude}. Distance: $distance, Timestamp: $timestamp');

          // Sync the data to the server
          await backgroundService
              .syncLocationData(); // Use the existing instance
        }
      }
    }
  });
}

// Function to check if the position is accurate enough
// bool _isPositionAccurate(Position position) {
//   return position.accuracy < 20.0; // Use an accuracy threshold of 20 meters
// }
double MAX_ACCURACY_THRESHOLD = 10.0;
const double MAX_SPEED_ACCURACY_THRESHOLD = 5.0;
const double MIN_DISTANCE_THRESHOLD = 50.0;
const double MIN_SPEED_THRESHOLD = 0.2;
bool _isPositionAccurate(Position position) {
  print('Position Accuracy:957=== ${position.accuracy}');
  print('Speed Accuracy:958=== ${position.speedAccuracy}');
  print('Speed:959=== ${position.speed}');
  return position.accuracy <= MAX_ACCURACY_THRESHOLD &&
      position.speedAccuracy <= MAX_SPEED_ACCURACY_THRESHOLD &&
      position.speed >= MIN_SPEED_THRESHOLD;
}

void appendLog(String text) async {
  const String folderName = 'SmartGeoTrack';
  const String fileName = 'UsertrackinglogTest.file';

  Directory appFolderPath =
      Directory('/storage/emulated/0/Download/$folderName');
  if (!appFolderPath.existsSync()) {
    appFolderPath.createSync(recursive: true);
  }

  final logFile = File('${appFolderPath.path}/$fileName');
  if (!logFile.existsSync()) {
    logFile.createSync();
  }

  try {
    final buf = logFile.openWrite(mode: FileMode.append);
    buf.writeln(text);
    await buf.close();
  } catch (e) {
    print("Error appending to log file: $e");
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;

  const StatCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.pink[50],
      ),
      child: Column(
        children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   late BackgroundService backgroundService;
//   late double lastLatitude;
//   late double lastLongitude;
//
//   static const double MAX_ACCURACY_THRESHOLD = 10.0;
//   static const double MAX_SPEED_ACCURACY_THRESHOLD = 5.0;
//   static const double MIN_DISTANCE_THRESHOLD = 50.0;
//   static const double MIN_SPEED_THRESHOLD = 0.2;
//   @override
//   void initState() {
//     super.initState();
//     // Initialization code if needed
//   }
//   @pragma('vm:entry-point')
//   @override
//   Future<void> didChangeDependencies() async {
//     await context.read<NotificationService>().initialize(context);
//
//     //Start the service automatically if it was activated before closing the application
//     if (await backgroundService.instance.isRunning()) {
//       await backgroundService.initializeService();
//     }
//     backgroundService.instance.on('on_location_changed').listen((event) async {
//       if (event != null) {
//         final position =  Position(
//           longitude: double.tryParse(event['longitude'].toString()) ?? 0.0,
//           latitude: double.tryParse(event['latitude'].toString()) ?? 0.0,
//           timestamp: DateTime.fromMillisecondsSinceEpoch(
//             event['timestamp'].toInt(),
//             isUtc: true,
//           ),
//           accuracy: double.tryParse(event['accuracy'].toString()) ?? 0.0,
//           altitude: double.tryParse(event['altitude'].toString()) ?? 0.0,
//           heading: double.tryParse(event['heading'].toString()) ?? 0.0,
//           speed: double.tryParse(event['speed'].toString()) ?? 0.0,
//           speedAccuracy: double.tryParse(event['speed_accuracy'].toString()) ?? 0.0,
//           altitudeAccuracy:double.tryParse(event['altitude_accuracy'].toString()) ?? 0.0,
//             headingAccuracy : double.tryParse(event['heading_accuracy'].toString()) ?? 0.0,
//         );
//
//         await context
//             .read<LocationControllerCubit>()
//             .onLocationChanged(location: position);
//       }
//     });
//
//     super.didChangeDependencies();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: appBar(),
//       backgroundColor: Colors.white,
//      body:
//      Column(
//        mainAxisAlignment: MainAxisAlignment.center,
//        children: [
//          ElevatedButton(
//            onPressed: startService,
//            child: const Text("Login"),
//          ),
//          const SizedBox(height: 15),
//          ElevatedButton(
//            onPressed: stopService,
//            child: const Text("Logout"),
//          ),
//        ],
//      ),
//     );
//   }
//
//   AppBar appBar() {
//     return AppBar(
//       backgroundColor: const Color(0xffe46f5d),
//       leading: Builder(
//         builder: (context) => IconButton(
//           icon: const Icon(
//             Icons.menu,
//             color: Colors.white, // Assuming CommonStyles.whiteColor is Colors.white
//           ),
//           onPressed: () {
//             Scaffold.of(context).openDrawer();
//           },
//         ),
//       ),
//       title: const Text('Home Screen'), // Update the title as needed
//     );
//   }
//
//   Future<void> startService() async {
//     await Fluttertoast.showToast(msg: "Wait for a while, Initializing the service...");
//
//     final permission = await context.read<LocationControllerCubit>().enableGPSWithPermission();
//     if (permission) {
//       Position currentPosition = await Geolocator.getCurrentPosition();
//       lastLatitude = currentPosition.latitude;
//       lastLongitude = currentPosition.longitude;
//
//       await context.read<LocationControllerCubit>().locationFetchByDeviceGPS();
//       await backgroundService.initializeService();
//       backgroundService.setServiceAsForeGround();
//
//
//     }
//   }
//
//   void stopService() {
//     backgroundService.stopService();
//     context.read<LocationControllerCubit>().stopLocationFetch();
//   }
// }
