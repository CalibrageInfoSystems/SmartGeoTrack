import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartgetrack/Common/custom_lead_template.dart';
import 'package:smartgetrack/Common/custom_textfield.dart';
import 'package:smartgetrack/common_styles.dart';

import 'Database/DataAccessHandler.dart';
import 'Database/Palm3FoilDatabase.dart';
import 'Database/SyncService.dart';
import 'Database/SyncServiceB.dart';
import 'HomeScreen.dart';
import 'location_service/logic/location_controller/location_controller_cubit.dart';
import 'location_service/notification/notification.dart';


class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  State<Test> createState() => _TestScreenState();
}

class _TestScreenState extends State<Test> {
  late BackgroundService backgroundService;
  late double lastLatitude;
  late double lastLongitude;
  Palm3FoilDatabase? palm3FoilDatabase;
  static const double MAX_ACCURACY_THRESHOLD = 10.0;
  static const double MAX_SPEED_ACCURACY_THRESHOLD = 5.0;
  static const double MIN_DISTANCE_THRESHOLD = 50.0;
  static const double MIN_SPEED_THRESHOLD = 0.2;
  //Palm3FoilDatabase? palm3FoilDatabase;
  final dataAccessHandler = DataAccessHandler(); // Initialize this properly
  @override
  void initState() {
    super.initState();
    backgroundService = BackgroundService(userId: 6, dataAccessHandler: dataAccessHandler);
    startService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body:
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: startService,
            child: const Text("Login"),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: stopService,
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  Future<void> startService() async {
    await Fluttertoast.showToast(msg: "Wait for a while, Initializing the service...");

    // Step 1: Request location permissions (foreground & background)
    final permission = await context.read<LocationControllerCubit>().enableGPSWithPermission();

    // Step 2: Check if permission granted for foreground location
    if (permission) {
      try {
        // Step 3: Check for background location permission (if required)
        final backgroundPermission = await Geolocator.checkPermission();
        if (backgroundPermission != LocationPermission.always) {
          final result = await Geolocator.requestPermission();
          if (result != LocationPermission.always) {
            await Fluttertoast.showToast(msg: "Background location permission denied. Service could not start.");
            return;
          }
        }

        // Step 4: Fetch the current location
        Position currentPosition = await Geolocator.getCurrentPosition();
        lastLatitude = currentPosition.latitude;
        lastLongitude = currentPosition.longitude;

        // Step 5: Initialize the background service and set it as foreground
        await context.read<LocationControllerCubit>().locationFetchByDeviceGPS();
        await backgroundService.initializeService();
        backgroundService.setServiceAsForeground();

        // Debug prints to check the current position
        print('Location permission granted');
        print('Current Position: Latitude: ${currentPosition.latitude}, Longitude: ${currentPosition.longitude}');

        // Show success toast
        await Fluttertoast.showToast(msg: "Service started successfully!");

        // Debug prints for location
        print('lastLatitude===>$lastLatitude, lastLongitude===>$lastLongitude');
      } catch (e) {
        print('Error fetching current position: $e');
        await Fluttertoast.showToast(msg: "Error: Service could not start due to an error.");
      }
    } else {
      print('Location permission denied');
      await Fluttertoast.showToast(msg: "Location permission denied. Service could not start.");
    }
  }

  void stopService() {
    backgroundService.stopService();
    context.read<LocationControllerCubit>().stopLocationFetch();

    // Show Toast after service stops
    Fluttertoast.showToast(msg: "Service stopped successfully!");
  }



}

class BackgroundService {
  final int userId;
  final DataAccessHandler dataAccessHandler; // Declare DataAccessHandler
  late SyncServiceB syncService; // Declare SyncService
  final FlutterBackgroundService flutterBackgroundService = FlutterBackgroundService();

  BackgroundService({required this.userId, required this.dataAccessHandler}) {
    // Initialize SyncService with DataAccessHandler
    syncService = SyncServiceB(dataAccessHandler); // Make sure to initialize DataAccessHandler properly
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
      await syncService.performRefreshTransactionsSync(); // Call the sync method
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

  // Initialize DataAccessHandler properly
  final dataAccessHandler = DataAccessHandler();
  final backgroundService = BackgroundService(userId: userID!, dataAccessHandler: dataAccessHandler);

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

  // Start listening to location updates in the background
  Geolocator.getPositionStream(
    locationSettings: LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 50, // Minimum distance for updates in meters
    ),
  ).listen((Position position) async {
    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.always) {
      service.invoke('on_location_changed', position.toJson());

      // Log the first location point
      if (!isFirstLocationLogged) {
        lastLatitude = position.latitude;
        lastLongitude = position.longitude;
        isFirstLocationLogged = true;
        DateTime timestamp = DateTime.now();
        await palm3FoilDatabase!.insertLocationValues(
            latitude: position.latitude,
            longitude: position.longitude,
            createdByUserId: userID,
            serverUpdatedStatus: false,
            from: 'first');

        appendLog('Latitude: ${position.latitude}, Longitude: ${position.longitude}. Timestamp: $timestamp');

        // Sync the data to the server
        await backgroundService.syncLocationData();
      }

      // Check for minimum distance threshold before logging
      if (_isPositionAccurate(position)) {
        final distance = Geolocator.distanceBetween(
          lastLatitude,
          lastLongitude,
          position.latitude,
          position.longitude,
        );

        if (distance >= MIN_DISTANCE_THRESHOLD) {
          lastLatitude = position.latitude;
          lastLongitude = position.longitude;
          DateTime timestamp = DateTime.now();

          await palm3FoilDatabase!.insertLocationValues(
              latitude: position.latitude,
              longitude: position.longitude,
              createdByUserId: userID,
              serverUpdatedStatus: false,
              from: 'background');

          appendLog('Background Latitude: ${position.latitude}, Longitude: ${position.longitude}. Distance: $distance, Timestamp: $timestamp');

          // Sync the data to the server
          await backgroundService.syncLocationData();
        }
      }
    }
  });
}


// Function to check if the position is accurate enough
bool _isPositionAccurate(Position position) {
  return position.accuracy < 20.0; // Use an accuracy threshold of 20 meters
}




