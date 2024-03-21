import 'dart:io';

import 'package:flutter/material.dart';
import 'package:police_app/providers/user_provider.dart';
import 'package:police_app/screens/home_screen.dart';
import 'package:provider/provider.dart';
import '../screens/login_screen.dart';

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
    ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
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
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Home(title: "Police App",),
        routes: {
          'login': (_) => Login(),
          'home': (_) => Home(title: "Police App"),
        },
        initialRoute: 'login',
      ),
    );
  }
}
