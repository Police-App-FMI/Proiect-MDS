import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:police_app/api/constants.dart';
import 'dart:async';

import 'package:police_app/main.dart';

final urlApi = url;

class User_provider with ChangeNotifier {
  String? userName;
  String? userEmail;
  String? profilePic;
  static String? token;

  Timer? tokenTimer;

  void startTokenTimer(BuildContext context) {
    tokenTimer = Timer.periodic(Duration(seconds: 45), (timer) {
      print("SALUUUUT");
      verifyToken(context);
    });
  }

  void cancelTokenTimer() {
    tokenTimer?.cancel();
  }

  Future<void> verifyToken(BuildContext context) async {
    if (token != null) {
      try {
        final response = await http.put(
          Uri.https(urlApi, '/api/Authentication/checkToken'),
          headers: <String, String>{
            'Authorization': 'Bearer $token',
          },
        );
        if (response.statusCode == 401) {
          disconnectUser(context);
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  Future<void> disconnectUser(BuildContext context) async {
    final url1 = Uri.https(urlApi, '/api/Authentication/disconnect');

    Map<String, String?> data = {'nume': userName};

    String jsonData = jsonEncode(data);

    try {
      final response = await http.put(url1,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonData);
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

  Future<void> verifyLogin(
      BuildContext context, String email, String password) async {
    final url1 = Uri.https(urlApi, '/api/Authentication/login');

    Map<String, dynamic> data = {
      'input': email,
      'password': password,
    };

    String jsonData = jsonEncode(data);
    try {
      final response = await http.post(
        url1,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );
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

  String? getJwtToken() {
    return token;
  }
}
