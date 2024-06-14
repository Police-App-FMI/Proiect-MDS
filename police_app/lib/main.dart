import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:police_app/providers/chat_provider.dart';
import 'package:police_app/providers/user_provider.dart';
import 'package:police_app/screens/callreinforcements_screen.dart';
import 'package:police_app/screens/facerecognition_screen.dart';
import 'package:police_app/screens/home_screen.dart';
import 'package:police_app/screens/missingpersons_screen.dart';
import 'package:police_app/screens/onduty_screen.dart';
import 'package:police_app/screens/platerecognition_screen.dart';
import 'package:police_app/screens/urlerror_screen.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';  // Importă pachetul Geolocator
import '../screens/login_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();  // Asigură inițializarea binding-urilor Flutter
  HttpOverrides.global = MyHttpOverrides();
  runApp(ChangeNotifierProvider(
    create: (context) => ChatProvider(),
    child: MyApp(),
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => User_provider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Home(
          title: "Police App",
        ),
        routes: {
          'login': (_) => Login(),
          'home': (_) => Home(title: "Police App"),
          'urlError': (_) => UrlError(),
          'faceRecognition': (_) => FaceRecognition(),
          'plateRecognition': (_) => PlateRecognition(),
          'callReinforcements': (_) => CallReinforcementsScreen(),
          'missingPersons': (_) => MissingPersonsScreen(),
          'onDuty': (_) => OnDutyScreen(),
        },
        initialRoute: 'login',
      ),
    );
  }
}
