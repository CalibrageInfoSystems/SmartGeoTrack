
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
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AddLeads.dart';
import 'Database/Palm3FoilDatabase.dart';
import 'ViewLeads.dart';
import 'location_service/logic/location_controller/location_controller_cubit.dart';
import 'location_service/notification/notification.dart';
import 'location_service/tools/background_service.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
    backgroundService = BackgroundService(userId: 1,context: context);

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
          speedAccuracy: double.tryParse(event['speed_accuracy'].toString()) ?? 0.0,
          altitudeAccuracy:double.tryParse(event['altitude_accuracy'].toString()) ?? 0.0,
          headingAccuracy : double.tryParse(event['heading_accuracy'].toString()) ?? 0.0,
        );
        print("on_location_changed: ${position.latitude} -  ${ position.longitude}");
        if (_isPositionAccurate(position) ) {
          double distance = Geolocator.distanceBetween(
              lastLatitude, lastLongitude, position.latitude, position.longitude);

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
            appendLog('Latitude: ${position.latitude}, Longitude: ${position.longitude}. Distance: $distance, Timestamp: $timestamp');
            //  await sendLocationToAPI(position.latitude, position.longitude, timestamp);

            await context.read<LocationControllerCubit>().onLocationChanged(
              location: position,
            );
          }
        }
        else{
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

  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      // Close the app when back is pressed, do not navigate back
      exit(0);
    //  SystemNavigator.pop();
    },
    child: Scaffold(
    appBar:
    AppBar(
      backgroundColor: Colors.lightBlue[100],
      automaticallyImplyLeading: false, // Ensure no back arrow is added
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Vertically centers items
        children: [
          SvgPicture.asset(
            'assets/sgt_logo.svg', // Use flutter_svg to load SVG
            width: 40,
          ),
          SizedBox(width: 8), // Space between logo and text
          Padding(
            padding: const EdgeInsets.only(top: 10.0), // Add top padding to the text
            child: Text(
              "SGT",
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 24,
                fontFamily: "hind_semibold",
                fontWeight: FontWeight.w700,
                letterSpacing: 1, // Adjust font size as needed
              ),
            ),
          ),
        ],
      ),
    ),



      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting and Map Area
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.lightBlue[100],
                image: DecorationImage(
                  image: AssetImage('assets/map.png'), // Map image placeholder
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Hello,", style: TextStyle(color: Colors.white, fontSize: 18)),
                      Text("M James", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Statistics Section
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: "Km's Travel",
                    value: "255",
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    label: "Leads",
                    value: "47",
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Buttons Section
            ElevatedButton(
              onPressed: () {
                // Navigate to the next screen with id and username
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddLeads(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("+ Add Lead", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewLeads(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("View Leads", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    ));
  }



  Future<void> startService() async {
    await Fluttertoast.showToast(msg: "Wait for a while, Initializing the service...");
    try {
      palm3FoilDatabase = await Palm3FoilDatabase.getInstance();

      await palm3FoilDatabase?.printTables(); // Call printTables after creating the databas
      // dbUpgradeCall();
    } catch (e) {
      print('Error while getting master data: ${e.toString()}');
    }
    final permission = await context.read<LocationControllerCubit>().enableGPSWithPermission();
    if (permission) {
      try {
        Position currentPosition = await Geolocator.getCurrentPosition();
        lastLatitude = currentPosition.latitude;
        lastLongitude = currentPosition.longitude;

        // Adding more debug prints
        print('Location permission granted');
        print('Current Position: Latitude: ${currentPosition.latitude}, Longitude: ${currentPosition.longitude}');

        await context.read<LocationControllerCubit>().locationFetchByDeviceGPS();
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
    final String folderName = 'SmartGeoTrack';
    final String fileName = 'UsertrackinglogTest.file';

    Directory appFolderPath = Directory('/storage/emulated/0/Download/$folderName');
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
    int? userID = prefs.getInt('userID') ;
    String username = prefs.getString('username') ?? '';
    String firstName = prefs.getString('firstName') ?? '';
    String email = prefs.getString('email') ?? '';
    String mobileNumber = prefs.getString('mobileNumber') ?? '';
    String roleName = prefs.getString('roleName') ?? '';
  }
}
class BackgroundService {
  final int userId;
  final BuildContext context; // Add context

  BackgroundService({required this.userId, required this.context}); // Add context to constructor
  final FlutterBackgroundService flutterBackgroundService = FlutterBackgroundService();

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

  Palm3FoilDatabase? palm3FoilDatabase = await Palm3FoilDatabase.getInstance(

  );

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
  appendLog('Latitude: ${position.latitude}, Longitude: ${position.longitude}. Timestamp: $timestamp');
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
  appendLog('Background Latitude: ${position.latitude}, Longitude: ${position.longitude}. Distance: $distance, Timestamp: $timestamp');
  }
  }
  }
  });
}

bool _isPositionAccurate(Position position) {
  const double MAX_ACCURACY_THRESHOLD = 10.0;
  const double MAX_SPEED_ACCURACY_THRESHOLD = 5.0;
  const double MIN_SPEED_THRESHOLD = 0.2;

  return position.accuracy <= MAX_ACCURACY_THRESHOLD &&
      position.speedAccuracy <= MAX_SPEED_ACCURACY_THRESHOLD &&
      position.speed >= MIN_SPEED_THRESHOLD;
}



void appendLog(String text) async {
  final String folderName = 'SmartGeoTrack';
  final String fileName = 'UsertrackinglogTest.file';

  Directory appFolderPath = Directory('/storage/emulated/0/Download/$folderName');
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

Future<void> sendLocationToAPI(double latitude, double longitude, DateTime timestamp) async {
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
  final String apiUrl = 'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Location/AddLocationTracker';
  Map<String, dynamic> requestBody = {
    "Id": null,
    "UserId": "e39536e2-89d3-4cc7-ae79-3dd5291ff156",
    "Latitude": latitude,
    "Longitude": longitude,
    "Address": "test", // You might want to replace this with an actual address if available
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

  const StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.pink[50],
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 18)),
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
