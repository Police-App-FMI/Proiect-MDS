import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:police_app/api/constants.dart';
import 'package:police_app/models/chat_user.dart';
import 'package:http/http.dart' as http;
import 'package:police_app/providers/user_provider.dart';
import 'package:path/path.dart' as path;

class ChatProvider extends ChangeNotifier {
  ChatProvider() {}

  final _messageEventController = StreamController<void>.broadcast();
  Stream<void> get messageEventStream => _messageEventController.stream;
  List<ChatUser> _chats = [];

  List<ChatUser> get chats {
    return [..._chats];
  }

  Future<void> fetchAndSetChats() async {
    final url1 = Uri.https(url, '/api/Chat');
    try {
      final response = await http.get(url1);
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      final extractedData = responseData['\$values'] as List<dynamic>;

      if (extractedData == null) {
        return;
      }

      final List<ChatUser> loadedChats = [];
      extractedData.forEach((chatData) {
        loadedChats.add(ChatUser(
            nume: chatData['nume'],
            profile_Pic: chatData['profile_Pic'],
            mesaj: chatData['mesaj'],
            date_send: DateTime.parse(chatData['date_Send'])));
      });
      loadedChats.sort((a, b) => b.date_send.compareTo(a.date_send));
      _chats = loadedChats;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> loadMessages() async {
    await fetchAndSetChats(); // sau orice altceva e necesar pentru a încărca mesajele
  }

  Future<void> sendMessage(String newMessage) async {
    final token = User_provider().getJwtToken();
    final url1 = Uri.https(url, '/api/Chat');
    final Map<String, dynamic> data = {'newMessage': newMessage};

    if (token == null) {
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
      _messageEventController.add(null);
    } else {
      throw Exception('Failed to send message: ${response.body}');
    }
  }

  Future<void> deleteMessage(DateTime dateSend) async {
    final token = User_provider().getJwtToken();
    final url1 = Uri.https(url, '/api/Chat');

    if (token == null) {
      throw Exception('JWT token not available');
    }

    final String dateSendToString = dateSend.toIso8601String();

    final Map<String, dynamic> data = {
      'newMessage': '',
      'dateSend': dateSendToString
    };

    final response = await http.delete(
      url1,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print('Mesajul a fost sters cu succes.');
      _messageEventController.add(null);
    } else {
      throw Exception('Failed to delete message: ${response.body}');
    }
  }

  Future<void> changeMessage(DateTime dateSend, String newMessage) async {
    final token = User_provider().getJwtToken();
    final url1 = Uri.https(url, '/api/Chat');

    if (token == null) {
      throw Exception('JWT token not available');
    }

    final String dateSendToString = dateSend.toIso8601String();

    final Map<String, dynamic> data = {
      'dateSend': dateSendToString,
      'newMessage': newMessage
    };

    final response = await http.put(
      url1,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print('Mesajul a fost schimbat cu succes.');
      _messageEventController.add(null);
    } else {
      throw Exception('Failed to change message: ${response.body}');
    }
  }

  Future<void> selectAndStoreImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.camera);
    if (pickedImage == null) return; // Utilizatorul a anulat

    final File imageFile = File(pickedImage.path);
    List<int> imageBytes = await imageFile.readAsBytes();

    if (imageBytes.isEmpty) {
      print('Imaginea nu a putut fi citită corect din fișier.');
      return;
    }
    String base64Image = base64Encode(imageBytes);

    String finalMessage = '[IMG]$base64Image';

    try {
      await sendMessage(finalMessage);
      print('Imagine a fost salvat cu succes în baza de date.');
    } catch (error) {
      throw Exception('Failed to save image: $error');
    }
  }

  Future<void> selectAndStoreMultipleImages() async {
    final ImagePicker picker = ImagePicker();

    final List<XFile> images = await picker.pickMultiImage(imageQuality: 70);

    for (var i in images) {
      File imageFile = File(i.path);
      List<int> imageBytes = await imageFile.readAsBytes();

      if (imageBytes.isEmpty) {
        print('Imaginea nu a putut fi citită corect din fișier.');
        return;
      }
      String base64Image = base64Encode(imageBytes);

      String finalMessage = '[IMG]$base64Image';

      try {
        await sendMessage(finalMessage);
        print('Imagine a fost salvat cu succes în baza de date.');
      } catch (error) {
        throw Exception('Failed to save image: $error');
      }
    }
  }

  @override
  void dispose() {
    _messageEventController.close();
    super.dispose();
  }
}
