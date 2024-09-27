// import 'dart:io';
// import 'dart:ui';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_background_service_android/flutter_background_service_android.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:smartgetrack/Common/custom_lead_template.dart';
// import 'package:smartgetrack/Common/custom_textfield.dart';
// import 'package:smartgetrack/common_styles.dart';
//
// import 'Database/DataAccessHandler.dart';
// import 'Database/Palm3FoilDatabase.dart';
// import 'Database/SyncService.dart';
// import 'Database/SyncServiceB.dart';
// import 'HomeScreen.dart';
// import 'location_service/logic/location_controller/location_controller_cubit.dart';
// import 'location_service/notification/notification.dart';
//
//
// class Test extends StatefulWidget {
//   const Test({Key? key}) : super(key: key);
//
//   @override
//   State<Test> createState() => _TestScreenState();
// }
//
// class _TestScreenState extends State<Test> {
//   late BackgroundService backgroundService;
//   late double lastLatitude;
//   late double lastLongitude;
//
//   static const double MAX_ACCURACY_THRESHOLD = 10.0;
//   static const double MAX_SPEED_ACCURACY_THRESHOLD = 5.0;
//   static const double MIN_DISTANCE_THRESHOLD = 50.0;
//   static const double MIN_SPEED_THRESHOLD = 0.2;
//   //Palm3FoilDatabase? palm3FoilDatabase;
//   final dataAccessHandler = DataAccessHandler(); // Initialize this properly
//   @override
//   void initState() {
//     super.initState();
//     backgroundService = BackgroundService(userId: 6, dataAccessHandler: dataAccessHandler);
//     startService();
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     initializeBackgroundService();
//   }
//
//   Future<void> initializeBackgroundService() async {
//     if (await backgroundService.instance.isRunning()) {
//       print('Background service is already running.');
//       await backgroundService.initializeService();
//     } else {
//       print('Background service is not running. Starting now...');
//     }
//
//     // Add logging here
//     backgroundService.instance.on('on_location_changed').listen((event) async {
//       print('Received location update event');
//
//       // backgroundService.instance.on('on_location_changed').listen((event) async {
//       if (event != null) {
//         final position = Position(
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
//           speedAccuracy:
//           double.tryParse(event['speed_accuracy'].toString()) ?? 0.0,
//           altitudeAccuracy:
//           double.tryParse(event['altitude_accuracy'].toString()) ?? 0.0,
//           headingAccuracy:
//           double.tryParse(event['heading_accuracy'].toString()) ?? 0.0,
//         );
//         print("on_location_changed: ${position.latitude} -  ${ position.longitude}");
//         if (_isPositionAccurate(position) ) {
//           double distance = Geolocator.distanceBetween(
//               lastLatitude, lastLongitude, position.latitude, position.longitude);
//
//           if (distance >= MIN_DISTANCE_THRESHOLD) {
//             lastLatitude = position.latitude;
//             lastLongitude = position.longitude;
//             DateTime timestamp = DateTime.now();
//             // Insert location into the database
//             // await dataAccessHandler!.insertLocationValues(
//             //   latitude: position.latitude,
//             //   longitude: position.longitude,
//             //   createdByUserId:6,  // replace userID with the actual value
//             //   serverUpdatedStatus: false,
//             // );
//
//             appendLog('Latitude: ${position.latitude}, Longitude: ${position.longitude}. Distance: $distance, Timestamp: $timestamp');
//             //  await sendLocationToAPI(position.latitude, position.longitude, timestamp);
//             bool isConnected = await CommonStyles.checkInternetConnectivity();
//             if (isConnected) {
//               // Call your login function here
//               final syncService = SyncService(dataAccessHandler);
//               syncService.performRefreshTransactionsSync(context);
//             } else {
//               Fluttertoast.showToast(
//                   msg: "Please check your internet connection.",
//                   toastLength: Toast.LENGTH_SHORT,
//                   gravity: ToastGravity.CENTER,
//                   timeInSecForIosWeb: 1,
//                   backgroundColor: Colors.red,
//                   textColor: Colors.white,
//                   fontSize: 16.0
//               );
//               print("Please check your internet connection.");
//               //showDialogMessage(context, "Please check your internet connection.");
//             }
//
//             await context.read<LocationControllerCubit>().onLocationChanged(
//               location: position,
//             );
//           }
//         }
//         else{
//           print('Position Accuracy: ${position.accuracy}');
//           print('Speed Accuracy: ${position.speedAccuracy}');
//           print('Speed: ${position.speed}');
//         }
//       }
//     });
//   }
//
//   bool _isPositionAccurate(Position position) {
//     print('Position Accuracy:106=== ${position.accuracy}');
//     print('Speed Accuracy:107=== ${position.speedAccuracy}');
//     print('Speed:108=== ${position.speed}');
//     return position.accuracy <= MAX_ACCURACY_THRESHOLD &&
//         position.speedAccuracy <= MAX_SPEED_ACCURACY_THRESHOLD &&
//         position.speed >= MIN_SPEED_THRESHOLD;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Home"),
//       ),
//       body:
//       Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           ElevatedButton(
//             onPressed: startService,
//             child: const Text("Login"),
//           ),
//           const SizedBox(height: 15),
//           ElevatedButton(
//             onPressed: stopService,
//             child: const Text("Logout"),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> startService() async {
//     await Fluttertoast.showToast(msg: "Wait for a while, Initializing the service...");
//
//     final permission = await context.read<LocationControllerCubit>().enableGPSWithPermission();
//     if (permission) {
//       try {
//         Position currentPosition = await Geolocator.getCurrentPosition();
//         lastLatitude = currentPosition.latitude;
//         lastLongitude = currentPosition.longitude;
//         try {
//         //  palm3FoilDatabase = await Palm3FoilDatabase.getInstance();
//  // Call printTables after creating the databas
//           // dbUpgradeCall();
//         } catch (e) {
//           print('Error while getting master data: ${e.toString()}');
//         }
//         // Debug prints
//         print('Location permission granted');
//         print('Current Position: Latitude: ${currentPosition.latitude}, Longitude: ${currentPosition.longitude}');
//
//         await context.read<LocationControllerCubit>().locationFetchByDeviceGPS();
//         await backgroundService.initializeService();
//         backgroundService.setServiceAsForeground();
//
//         // Show Toast after service starts
//         await Fluttertoast.showToast(msg: "Service started successfully!");
//
//         // Debug prints
//         print('lastLatitude===>$lastLatitude, lastLongitude===>$lastLongitude');
//       } catch (e) {
//         print('Error fetching current position: $e');
//         await Fluttertoast.showToast(msg: "Error: Service could not start.");
//       }
//     } else {
//       print('Location permission denied');
//       await Fluttertoast.showToast(msg: "Location permission denied. Service could not start.");
//     }
//   }
//
//   void stopService() {
//     backgroundService.stopService();
//     context.read<LocationControllerCubit>().stopLocationFetch();
//
//     // Show Toast after service stops
//     Fluttertoast.showToast(msg: "Service stopped successfully!");
//   }
//
//
//   void appendLog(String text) async {
//     final String folderName = 'Srikar_Groups';
//     final String fileName = 'UsertrackinglogTest.file';
//
//     Directory appFolderPath = Directory('/storage/emulated/0/Download/$folderName');
//     if (!appFolderPath.existsSync()) {
//       appFolderPath.createSync(recursive: true);
//     }
//
//     final logFile = File('${appFolderPath.path}/$fileName');
//     if (!logFile.existsSync()) {
//       logFile.createSync();
//     }
//
//     try {
//       final buf = logFile.openWrite(mode: FileMode.append);
//       buf.writeln(text);
//       await buf.close();
//     } catch (e) {
//       print("Error appending to log file: $e");
//     }
//   }
// }
//
// class BackgroundService {
//   final int userId;
//   final DataAccessHandler dataAccessHandler; // Declare DataAccessHandler
//   late SyncServiceB syncService; // Declare SyncService
//   final FlutterBackgroundService flutterBackgroundService = FlutterBackgroundService();
//
//   BackgroundService({required this.userId, required this.dataAccessHandler}) {
//     // Initialize SyncService with DataAccessHandler
//     syncService = SyncServiceB(dataAccessHandler); // Make sure to initialize DataAccessHandler properly
//   }
//
//   FlutterBackgroundService get instance => flutterBackgroundService;
//
//   Future<void> initializeService() async {
//     await NotificationService(FlutterLocalNotificationsPlugin()).createChannel(
//       const AndroidNotificationChannel(
//         'location_channel',
//         'Location Channel',
//         importance: Importance.high, // Ensure high importance for visibility
//       ),
//     );
//
//     await flutterBackgroundService.configure(
//       androidConfiguration: AndroidConfiguration(
//         onStart: onStart,
//         autoStart: false,
//         isForegroundMode: true,
//         notificationChannelId: 'location_channel',
//         foregroundServiceNotificationId: 888,
//         initialNotificationTitle: 'Location Service',
//         initialNotificationContent: 'Tracking location in background',
//       ),
//       iosConfiguration: IosConfiguration(
//         autoStart: true,
//         onForeground: onStart,
//       ),
//     );
//     await flutterBackgroundService.startService();
//   }
//
//   void setServiceAsForeground() async {
//     flutterBackgroundService.invoke("setAsForeground");
//   }
//
//   void stopService() {
//     flutterBackgroundService.invoke("stop_service");
//   }
//
//   Future<void> syncLocationData() async {
//     try {
//       await syncService.performRefreshTransactionsSync(); // Call the sync method
//       print("Location data synced successfully.");
//     } catch (e) {
//       print("Error syncing location data: $e");
//     }
//   }
// }
//
// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) async {
//   DartPluginRegistrant.ensureInitialized();
//  // Palm3FoilDatabase? palm3FoilDatabase = await Palm3FoilDatabase.getInstance();
//
//   // You need to maintain a way to get the userId or DataAccessHandler here.
//   final userId = 6; // Replace with the actual way to get userId
//
//   // Pass the DataAccessHandler to the BackgroundService
//   final dataAccessHandler = DataAccessHandler(); // Initialize this properly
//   final backgroundService = BackgroundService(userId: userId, dataAccessHandler: dataAccessHandler);
//
//   if (service is AndroidServiceInstance) {
//     service.on('setAsForeground').listen((event) async {
//       await service.setAsForegroundService();
//     });
//
//     service.on('setAsBackground').listen((event) async {
//       await service.setAsBackgroundService();
//     });
//   }
//
//   service.on("stop_service").listen((event) async {
//     await service.stopSelf();
//   });
//
//   double lastLatitude = 0.0;
//   double lastLongitude = 0.0;
//   bool isFirstLocationLogged = false;
//
//   Geolocator.getPositionStream().listen((Position position) async {
//     final permission = await Geolocator.checkPermission();
//
//     if (permission == LocationPermission.always) {
//       service.invoke('on_location_changed', position.toJson());
//
//       if (!isFirstLocationLogged) {
//         // Log the first point
//         lastLatitude = position.latitude;
//         lastLongitude = position.longitude;
//         isFirstLocationLogged = true;
//         DateTime timestamp = DateTime.now();
//
//         await palm3FoilDatabase!.insertLocationValues(
//           latitude: position.latitude,
//           longitude: position.longitude,
//           createdByUserId: userId,  // Use the actual userID
//           serverUpdatedStatus: false,
//         );
//
//         appendLog('Latitude: ${position.latitude}, Longitude: ${position.longitude}. Timestamp: $timestamp');
//
//         // Sync the data to the server
//         await backgroundService.syncLocationData(); // Use the existing instance
//       }
//
//       if (_isPositionAccurate(position)) {
//         final distance = Geolocator.distanceBetween(
//           lastLatitude,
//           lastLongitude,
//           position.latitude,
//           position.longitude,
//         );
//
//         if (distance >= 50.0) {
//           lastLatitude = position.latitude;
//           lastLongitude = position.longitude;
//           DateTime timestamp = DateTime.now();
//
//           await palm3FoilDatabase!.insertLocationValues(
//             latitude: position.latitude,
//             longitude: position.longitude,
//             createdByUserId: userId,
//             serverUpdatedStatus: false,
//           );
//
//           appendLog('Background Latitude: ${position.latitude}, Longitude: ${position.longitude}. Distance: $distance, Timestamp: $timestamp');
//
//           // Sync the data to the server
//           await backgroundService.syncLocationData(); // Use the existing instance
//         }
//       }
//     }
//   });
// }
//
//
// // Function to check if the position is accurate enough
// bool _isPositionAccurate(Position position) {
//   return position.accuracy < 20.0; // Use an accuracy threshold of 20 meters
// }
//
//
//
//
