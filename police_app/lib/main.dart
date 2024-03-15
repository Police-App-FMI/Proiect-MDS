import 'package:flutter/material.dart';
import 'package:police_app/screens/home_screen.dart';
import '../screens/login_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    );
  }
}
