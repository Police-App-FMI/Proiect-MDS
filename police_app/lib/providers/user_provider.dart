import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:police_app/api/constants.dart';

final urlApi = url;

class User_provider with ChangeNotifier{
  String? userName;
  String? userEmail;
  String? profilePic;
  String? token;


  Future<void> verifyLogin(BuildContext context, String email, String password) async {
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
        notifyListeners();
        
        Navigator.pushReplacementNamed(context, 'home');
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

  Future<void> getAllUsers(BuildContext context) async {
    final url1 = Uri.https(urlApi, '/api/Authentication');

    try{
      final response = await http.get(url1);

      if(response.body.isNotEmpty)
      {
        final data = jsonDecode(response.body);
        
      }

    } catch (e) {
      print('Error: $e');
    }
  }

}