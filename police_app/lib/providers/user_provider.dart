import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:police_app/api/constants.dart';
import 'dart:async';

import 'package:police_app/main.dart';

// Definirea unei clase User_provider care implementează ChangeNotifier
class User_provider with ChangeNotifier {
  // Variabile pentru a stoca informațiile utilizatorului
  String? userName;
  String? userEmail;
  String? profilePic;
  static String? token;

  Timer? tokenTimer;

  // Funcție pentru a porni un timer care verifică token-ul periodic
  void startTokenTimer(BuildContext context) {
    tokenTimer = Timer.periodic(Duration(seconds: 45), (timer) {
      print("SALUUUUT");
      verifyToken(context);
    });
  }

  // Funcție pentru a opri timer-ul
  void cancelTokenTimer() {
    tokenTimer?.cancel();
  }

  // Funcție pentru a verifica token-ul utilizatorului
  Future<void> verifyToken(BuildContext context) async {
    if (token != null) {
      try {
        final response = await http.put(
          Uri.https(Constant.url, '/api/Authentication/checkToken'),
          headers: <String, String>{
            'ngrok-skip-browser-warning': 'True',
            'Authorization': 'Bearer $token',
          },
        );
        // Dacă token-ul nu este valid, deconectează utilizatorul
        if (response.statusCode == 401) {
          disconnectUser(context);
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  // Funcție pentru a deconecta utilizatorul
  Future<void> disconnectUser(BuildContext context) async {
    final url1 = Uri.https(Constant.url, '/api/Authentication/disconnect');

    Map<String, String?> data = {
      'newMessage': userName,
    };

    String jsonData = jsonEncode(data);

    try {
      final response = await http.put(
        url1,
        headers: <String, String>{
          'ngrok-skip-browser-warning': 'True',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );
      // Dacă deconectarea a avut succes, resetează informațiile utilizatorului
      if (response.statusCode == 200) {
        userName = '';
        userEmail = '';
        profilePic = '';
        token = '';
        notifyListeners();

        cancelTokenTimer();
        navigatorKey.currentState?.pushReplacementNamed('login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nu s-a putut realiza deconectarea.'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Funcție pentru a verifica login-ul utilizatorului
  Future<void> verifyLogin(BuildContext context, String email, String password) async { 
    final url1 = Uri.https(Constant.url, '/api/Authentication/login');

    Map<String, dynamic> data = {
      'input': email,
      'password': password,
    };

    String jsonData = jsonEncode(data);
    try {
      final response = await http.post(
        url1,
        headers: <String, String>{
          'ngrok-skip-browser-warning': 'True',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );
      // Dacă login-ul este reușit, actualizează informațiile utilizatorului
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        userName = jsonResponse['nume'];
        userEmail = jsonResponse['email'];
        profilePic = jsonResponse['profilePic'];
        token = jsonResponse['token'];
        print(token);
        notifyListeners();

        startTokenTimer(context);

        await Future.microtask(() {
          navigatorKey.currentState?.pushReplacementNamed('home');
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Emailul sau parola sunt incorecte.'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Funcție pentru a obține token-ul JWT
  String? getJwtToken() {
    return token;
  }
}
