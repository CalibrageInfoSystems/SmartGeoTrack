import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:smartgetrack/splash_screen.dart';

import 'Database/DataAccessHandler.dart';
import 'location_service/logic/location_controller/location_controller_cubit.dart';
import 'location_service/notification/notification.dart';
import 'location_service/repository/location_service_repository.dart';

final notificationService =
    NotificationService(FlutterLocalNotificationsPlugin());

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => DataAccessHandler(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: notificationService,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => LocationControllerCubit(
              locationServiceRepository: LocationServiceRepository(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Track Your Location',
          debugShowCheckedModeBanner: false,
          home: SplashScreen(),
        ),
      ),
    );
  }
}
