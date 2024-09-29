import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:smartgetrack/common_styles.dart';
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
      child:  MyApp(),
    ),
  );
}
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App resumed from background, you can show splash screen if needed
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SplashScreen()));
    }
  }

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
    child:MaterialApp(
      title: 'Track Your Location',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // This is the initial screen
    )));
  }
}

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       // App resumed from background, you can show splash screen if needed
//       // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SplashScreen()));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return RepositoryProvider.value(
//       value: notificationService,
//       child: MultiBlocProvider(
//         providers: [
//           BlocProvider(
//             create: (context) => LocationControllerCubit(
//               locationServiceRepository: LocationServiceRepository(),
//             ),
//           ),
//         ],
//         child: MaterialApp(
//           title: 'Track Your Location',
//           /*  theme: ThemeData(
//             inputDecorationTheme: const InputDecorationTheme(
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: CommonStyles.btnBlueBgColor),
//               ),
//               errorBorder: OutlineInputBorder(
//                 borderSide:
//                     BorderSide(color: CommonStyles.formFieldErrorBorderColor),
//
//               ),
//               labelStyle: TextStyle(
//                 color: Colors.grey,
//               ),
//               floatingLabelStyle: TextStyle(
//                 color: Color.fromARGB(255, 100, 178, 250),
//               ),
//             ),
//             progressIndicatorTheme: const ProgressIndicatorThemeData(
//               color: CommonStyles.primaryTextColor,
//             ),
//           ), */
//           debugShowCheckedModeBanner: false,
//           home: SplashScreen(),
//         ),
//       ),
//     );
//   }
// }
