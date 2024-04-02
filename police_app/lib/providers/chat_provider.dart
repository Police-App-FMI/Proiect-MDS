import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:police_app/api/constants.dart';
import 'package:police_app/models/chat_user.dart';
import 'package:http/http.dart' as http;
import 'package:police_app/providers/user_provider.dart';
import 'package:provider/provider.dart';

class ChatProvider extends ChangeNotifier {
  late Stream<List<ChatUser>>? _userStream; // Initializați cu null
  List<ChatUser> _users = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _error = '';

  ChatProvider() {
    _userStream = null; // Inițializare cu null
    //_initializeUserStream(); // Așteaptă inițializarea stream-ului
  }

  Stream<List<ChatUser>> get userStream {
    if (_userStream == null) {
      throw Exception('User stream is not initialized');
    }
    return _userStream!;
  }
  List<ChatUser> get users => _users;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get error => _error;

  Future<void> _initializeUserStream() async {
  try {
    _userStream = await getChatUsers(); // Așteaptă rezultatul funcției asincrone
    _userStream?.listen((users) {
      _isLoading = false;
      _hasError = false;
      _error = '';
      _users = users;
      notifyListeners();
    }, onError: (error) {
      _isLoading = false;
      _hasError = true;
      _error = error.toString();
      notifyListeners();
    });
    } catch (e) {
      _isLoading = false;
      _hasError = true;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<Stream<List<ChatUser>>> getChatUsers() async {
    final url1 = Uri.https(url, '/api/Chat');

    final response = await http.get(url1);
    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      List<ChatUser> users =
          responseData.map((json) => ChatUser.fromJson(json)).toList();
      return Stream.value(users);
    } else {
      throw Exception('Failed to load chat users');
    }
  }

  Future<void> sendMessage(String newMessage) async {
    final token = User_provider().getJwtToken();
    final url1 = Uri.https(url, '/api/Chat/sendMessage');
    final Map<String, dynamic> data = {'newMessage': newMessage};

    if(token == null) {
      throw Exception('JWT token not available');
    }


    final response = await http.post(
      url1,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print('Mesajul a fost trimis cu succes.');
    } else {
      throw Exception('Failed to send message: ${response.body}');
    }
  }


}
