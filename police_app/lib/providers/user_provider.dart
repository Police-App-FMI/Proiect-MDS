import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:police_app/api/constants.dart';
import 'dart:async';

import 'package:police_app/main.dart';

class User_provider with ChangeNotifier {
  String? userName;
  String? userEmail;
  String? profilePic;
  String? location;
  static String? token;
  bool _isOnDuty = false;

  Timer? tokenTimer;
  Timer? updateTimer;
  List<Map<String, dynamic>> onDutyUsers = [];
  List<Map<String, dynamic>> reinforcements = [];
  List<Map<String, dynamic>> missingPersons = [];

  bool get isOnDuty => _isOnDuty;

  User_provider() {
    startUpdateTimer();
  }

  void startUpdateTimer() {
    if (updateTimer == null || !updateTimer!.isActive) {
      updateTimer = Timer.periodic(Duration(seconds: 15), (timer) {
        fetchOnDutyUsers();
      });
    }
  }

  void stopUpdateTimer() {
    updateTimer?.cancel();
  }

  Future<void> toggleOnDutyStatus() async {
    _isOnDuty = !_isOnDuty;
    notifyListeners();

    if (_isOnDuty) {
      try {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        String locationString = 'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
        location = locationString;
        final locationResponse = await http.put(
          Uri.https(Constant.url, '/api/onduty/location'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({'newMessage': locationString}),
        );

        if (locationResponse.statusCode != 200) {
          print('Failed to send location');
          location = '';
          _isOnDuty = !_isOnDuty;
          notifyListeners();
        } else {
          fetchOnDutyUsers();
        }
      } catch (e) {
        print('Error getting location: $e');
      }
    } else {
      try {
        final locationResponse = await http.put(
          Uri.https(Constant.url, '/api/onduty/location'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({'newMessage': ''}),
        );

        if (locationResponse.statusCode != 200) {
          print('Failed to send location');
          _isOnDuty = !_isOnDuty;
          notifyListeners();
        } else {
          location = '';
          fetchOnDutyUsers();
        }
      } catch (e) {
        print('Error sending location: $e');
      }
    }
  }

  Future<void> fetchOnDutyUsers() async {
    final response = await http.get(
      Uri.https(Constant.url, '/api/onduty/location'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data is List) {
        onDutyUsers = data.map((user) {
          return {
            'Nume': user['nume'],
            'Profile_Pic': user['profile_Pic'],
            'Location': user['location'],
          };
        }).toList();
      } else if (data is Map && data['\$values'] is List) {
        onDutyUsers = (data['\$values'] as List).map((user) {
          return {
            'Nume': user['nume'],
            'Profile_Pic': user['profile_Pic'],
            'Location': user['location'],
          };
        }).toList();
      }
      notifyListeners();
    } else {
      print('Failed to fetch on duty users');
    }
  }

  Future<void> fetchReinforcements() async {
    final response = await http.get(
      Uri.https(Constant.url, '/api/CallReinforcements'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data is Map && data['\$values'] is List) {
        reinforcements = (data['\$values'] as List).map((reinforcement) {
          return {
            'Id': reinforcement['id'],
            'Nume': reinforcement['nume'],
            'Mesaj': reinforcement['mesaj'],
            'Location': reinforcement['location'],
            'Time': reinforcement['time'],
          };
        }).toList();

        // Sort the reinforcements by time in descending order
        reinforcements.sort((a, b) => DateTime.parse(b['Time']).compareTo(DateTime.parse(a['Time'])));
      }
      notifyListeners();
    } else {
      print('Failed to fetch reinforcements');
    }
  }

  void startTokenTimer(BuildContext context) {
    tokenTimer = Timer.periodic(Duration(seconds: 45), (timer) {
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
          Uri.https(Constant.url, '/api/Authentication/checkToken'),
          headers: <String, String>{
            'ngrok-skip-browser-warning': 'True',
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
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        userName = jsonResponse['nume'];
        userEmail = jsonResponse['email'];
        profilePic = jsonResponse['profilePic'];
        token = jsonResponse['token'];
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

  Future<void> callReinforcements(String message, String location) async {
    final url = Uri.https(Constant.url, '/api/CallReinforcements');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'Message': message,
        'Location': location,
      }),
    );

    if (response.statusCode == 200) {
      print('Reinforcements called successfully');
      fetchReinforcements(); // Fetch reinforcements after calling for them
    } else {
      print('Failed to call reinforcements');
    }
  }

  Future<void> endReinforcement(String id) async {
    final url = Uri.https(Constant.url, '/api/CallReinforcements');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'newMessage': id,
      }),
    );

    if (response.statusCode == 200) {
      print('Reinforcement ended successfully');
      fetchReinforcements(); // Refresh the list of reinforcements after deletion
    } else {
      print('Failed to end reinforcement');
    }
  }

  Future<void> fetchMissingPersons() async {
    final response = await http.get(
      Uri.https(Constant.url, '/api/onduty/missingperson'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data is List) {
        missingPersons = data.map((person) {
          return {
            'Id': person['id'],
            'Nume': person['nume'],
            'Portret': person['portret'],
            'Descriere': person['descriere'],
            'Telefon': person['telefon'],
            'UltimaLocatie': person['ultimaLocatie'],
            'UltimaData': person['ultimaData'],
          };
        }).toList();
      } else if (data is Map && data['\$values'] is List) {
        missingPersons = (data['\$values'] as List).map((person) {
          return {
            'Id': person['id'],
            'Nume': person['nume'],
            'Portret': person['portret'],
            'Descriere': person['descriere'],
            'Telefon': person['telefon'],
            'UltimaLocatie': person['ultimaLocatie'],
            'UltimaData': person['ultimaData'],
          };
        }).toList();
      }
      notifyListeners();
    } else {
      print('Failed to fetch missing persons');
    }
  }

  Future<void> addMissingPerson(String name, String profilePic, String description, String phoneNumber, String lastSeenLocation) async {
    final url = Uri.https(Constant.url, '/api/onduty/missingperson');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'Name': name,
        'ProfilePic': profilePic,
        'Description': description,
        'PhoneNumber': phoneNumber,
        'LastSeenLocation': lastSeenLocation,
      }),
    );

    if (response.statusCode == 200) {
      print('Missing person added successfully');
      fetchMissingPersons(); // Fetch missing persons after adding one
    } else {
      print('Failed to add missing person');
    }
  }

  Future<void> updateMissingPersonLocation(String id, String newLocation) async {
    final url = Uri.https(Constant.url, '/api/onduty/missingperson');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'input': id,
        'password': newLocation,
      }),
    );

    if (response.statusCode == 200) {
      print('Missing person location updated successfully');
      fetchMissingPersons(); // Fetch missing persons after updating one
    } else {
      print('Failed to update missing person location');
    }
  }

  Future<void> deleteMissingPerson(String id) async {
    final url = Uri.https(Constant.url, '/api/onduty/missingperson');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'newMessage': id,
      }),
    );

    if (response.statusCode == 200) {
      print('Missing person deleted successfully');
      fetchMissingPersons(); // Fetch missing persons after deleting one
    } else {
      print('Failed to delete missing person');
    }
  }

  String? getJwtToken() {
    return token;
  }
}
