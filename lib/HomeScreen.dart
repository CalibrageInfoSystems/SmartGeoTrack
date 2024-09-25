import 'dart:io';
import 'dart:ui';
import 'package:dropdown_button2/dropdown_button2.dart';
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
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartgetrack/Common/Constants.dart';
import 'package:smartgetrack/LoginScreen.dart';
import 'package:smartgetrack/common_styles.dart';

import 'AddLeads.dart';
import 'Database/DataAccessHandler.dart';
import 'Database/Palm3FoilDatabase.dart';
import 'Database/SyncService.dart';
import 'ViewLeads.dart';
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
  @override
  void initState() {
    super.initState();
    getuserdata();
    backgroundService = BackgroundService(userId: 1, context: context);

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
            palm3FoilDatabase!.insertLocationValues(
              latitude: position.latitude,
              longitude: position.longitude,
              createdByUserId: 1, // Replace with actual userId
              updatedByUserId: 1, // Replace with actual userId
              serverUpdatedStatus: false,
            );
            appendLog(
                'Latitude: ${position.latitude}, Longitude: ${position.longitude}. Distance: $distance, Timestamp: $timestamp');
            //  await sendLocationToAPI(position.latitude, position.longitude, timestamp);

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
              // top: 230,
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: customBox(
                                    title: 'Total Leads', data: '123')),
                            const SizedBox(width: 20),
                            Expanded(
                                child: customBox(
                                    title: 'Today Leads', data: '321')),
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
                                    data: '255',
                                    bgImg: 'assets/bg_image2.jpg')),
                            const SizedBox(width: 20),
                            Expanded(
                                child: customBox(title: 'Leads', data: '47')),
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
                                      builder: (context) => AddLeads(),
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
                                  backgroundColor: CommonStyles.btnBlueBgColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: customBtn(
                            onPressed: () async {
                              final dataAccessHandler = Provider.of<DataAccessHandler>(context, listen: false);
                              bool isConnected = await CommonStyles.checkInternetConnectivity();
                              if (isConnected) {
                                // Call your login function here
                                final syncService = SyncService(dataAccessHandler);
                                syncService.performRefreshTransactionsSync(context);

                              } else {
                                Fluttertoast.showToast(
                                    msg: "Please Check Your Internet Connection.",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0
                                );
                                print("Please check your internet connection.");
                                //showDialogMessage(context, "Please check your internet connection.");
                              }
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
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
                        ListView.separated(
                          itemCount: 10,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) => leadTemplate(index),
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  )),
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

  Row statisticsSection() {
    return Row(children: [
      const Text(
        'Statistics',
        style: CommonStyles.txStyF16CbFF5,
      ),
      const Spacer(),
      Row(
        children: [
          Text(
            'Last 7d',
            style: CommonStyles.txStyF14CbFF5
                .copyWith(color: CommonStyles.dataTextColor),
          ),
          const Icon(Icons.keyboard_arrow_down_rounded,
              color: CommonStyles.dataTextColor),
        ],
      ),
      Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
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
      )
    ]);
  }

  Row leadsSection() {
    return Row(
      children: [
        Expanded(child: customBox(title: 'Total Leads', data: '123')),
        const SizedBox(width: 20),
        Expanded(child: customBox(title: 'Total Leads', data: '321')),
      ],
    );
  }

  Container customBox({
    required String title,
    String? data,
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
                            'M James',
                            style: CommonStyles.txStyF20CpFF5.copyWith(
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Text(
                            '23rd Sep 2024',
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
    try {
      palm3FoilDatabase = await Palm3FoilDatabase.getInstance();

      await palm3FoilDatabase
          ?.printTables(); // Call printTables after creating the databas
      // dbUpgradeCall();
    } catch (e) {
      print('Error while getting master data: ${e.toString()}');
    }
    final permission =
        await context.read<LocationControllerCubit>().enableGPSWithPermission();
    if (permission) {
      try {
        Position currentPosition = await Geolocator.getCurrentPosition();
        lastLatitude = currentPosition.latitude;
        lastLongitude = currentPosition.longitude;

        // Adding more debug prints
        print('Location permission granted');
        print(
            'Current Position: Latitude: ${currentPosition.latitude}, Longitude: ${currentPosition.longitude}');

        await context
            .read<LocationControllerCubit>()
            .locationFetchByDeviceGPS();
        await backgroundService.initializeService();
        backgroundService.setServiceAsForeground();

        // Printing after setting lastLatitude and lastLongitude
        print('lastLatitude===>$lastLatitude, lastLongitude===>$lastLongitude');
      } catch (e) {
        print('Error fetching current position: $e');
      }
    } else {
      print('Location permission denied');
    }
  }

  void stopService() {
    backgroundService.stopService();
    context.read<LocationControllerCubit>().stopLocationFetch();
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
    int? userID = prefs.getInt('userID');
    String username = prefs.getString('username') ?? '';
    String firstName = prefs.getString('firstName') ?? '';
    String email = prefs.getString('email') ?? '';
    String mobileNumber = prefs.getString('mobileNumber') ?? '';
    String roleName = prefs.getString('roleName') ?? '';
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
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (Route<dynamic> route) => false);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class BackgroundService {
  final int userId;
  final BuildContext context; // Add context

  BackgroundService(
      {required this.userId,
      required this.context}); // Add context to constructor
  final FlutterBackgroundService flutterBackgroundService =
      FlutterBackgroundService();

  FlutterBackgroundService get instance => flutterBackgroundService;

  Future<void> initializeService() async {
    await NotificationService(FlutterLocalNotificationsPlugin()).createChannel(
      const AndroidNotificationChannel(
        'location_channel',
        'Location Channel',
        importance: Importance.high,
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
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  // Retrieve context or adapt initialization
  //BuildContext context = ...; // Handle context acquisition appropriately

  Palm3FoilDatabase? palm3FoilDatabase = await Palm3FoilDatabase.getInstance();

  int userId = 1; // Replace with actual logic to get userId

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

      if (!isFirstLocationLogged) {
        lastLatitude = position.latitude;
        lastLongitude = position.longitude;
        isFirstLocationLogged = true;
        DateTime timestamp = DateTime.now();

        palm3FoilDatabase!.insertLocationValues(
          latitude: position.latitude,
          longitude: position.longitude,
          createdByUserId: userId,
          updatedByUserId: userId,
          serverUpdatedStatus: false,
        );
        appendLog(
            'Latitude: ${position.latitude}, Longitude: ${position.longitude}. Timestamp: $timestamp');
      }

      if (_isPositionAccurate(position)) {
        final distance = Geolocator.distanceBetween(
          lastLatitude,
          lastLongitude,
          position.latitude,
          position.longitude,
        );
        print('distance====$distance');
        if (distance >= 50.0) {
          lastLatitude = position.latitude;
          lastLongitude = position.longitude;
          DateTime timestamp = DateTime.now();

          palm3FoilDatabase!.insertLocationValues(
            latitude: position.latitude,
            longitude: position.longitude,
            createdByUserId: userId,
            updatedByUserId: userId,
            serverUpdatedStatus: false,
          );
          appendLog(
              'Background Latitude: ${position.latitude}, Longitude: ${position.longitude}. Distance: $distance, Timestamp: $timestamp');
        }
      }
    }
  });
}

bool _isPositionAccurate(Position position) {
  const double maxAccuracyThreshold = 10.0;
  const double maxSpeedAccuracyThreshold = 5.0;
  const double minSpeedThreshold = 0.2;

  return position.accuracy <= maxAccuracyThreshold &&
      position.speedAccuracy <= maxSpeedAccuracyThreshold &&
      position.speed >= minSpeedThreshold;
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

Future<void> sendLocationToAPI(
    double latitude, double longitude, DateTime timestamp) async {
  // void addBoundaryToDatabase() async {
  //   await insertLocationValues(
  //     latitude: 12.3456,
  //     longitude: 98.7654,
  //     createdByUserId: 101,
  //     updatedByUserId: 101,
  //     serverUpdatedStatus: false,
  //   );
  // }

  String timestamp = DateTime.now().toIso8601String();
//  await DatabaseHelper().insertLocation(latitude, longitude, timestamp);
  const String apiUrl =
      'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Location/AddLocationTracker';
  Map<String, dynamic> requestBody = {
    "Id": null,
    "UserId": "e39536e2-89d3-4cc7-ae79-3dd5291ff156",
    "Latitude": latitude,
    "Longitude": longitude,
    "Address":
        "test", // You might want to replace this with an actual address if available
    "LogDate": timestamp,
    "CreatedBy": "e39536e2-89d3-4cc7-ae79-3dd5291ff156",
    "CreatedDate": DateTime.now().toIso8601String()
  };

  try {
    var response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      if (responseBody['isSuccess'] == true) {
        print("Location added successfully: ${responseBody['endUserMessage']}");
      } else {
        print("Failed to add location: ${responseBody['endUserMessage']}");
      }
    } else {
      print("Failed to add location: ${response.statusCode}");
    }
  } catch (error) {
    print("Error: $error");
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
