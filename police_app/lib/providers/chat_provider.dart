import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:police_app/api/constants.dart';
import 'package:police_app/main.dart';
import 'package:police_app/models/chat_user.dart';
import 'package:http/http.dart' as http;
import 'package:police_app/providers/user_provider.dart';
import 'package:path/path.dart' as path;

// Definirea unei clase ChatProvider care extinde ChangeNotifier
class ChatProvider extends ChangeNotifier {
  ChatProvider() {}

  // StreamController pentru a notifica evenimentele mesajelor
  final _messageEventController = StreamController<void>.broadcast();
  Stream<void> get messageEventStream => _messageEventController.stream;
  List<ChatUser> _chats = [];

  List<ChatUser> get chats {
    return [..._chats];
  }

  // Funcție pentru preluarea și setarea chat-urilor
  Future<void> fetchAndSetChats() async {
    final token = User_provider().getJwtToken();
    final url1 = Uri.https(Constant.url, '/api/Chat');
    try {
      final response = await http.get(
        url1,
        headers: <String, String>{
          'ngrok-skip-browser-warning': 'True',
          'Authorization': 'Bearer $token'
        }
      ).timeout(Duration(seconds: 7));
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
      // Sortarea chat-urilor în ordine descrescătoare a datei
      loadedChats.sort((a, b) => b.date_send.compareTo(a.date_send));
      _chats = loadedChats;
      notifyListeners();
    } on TimeoutException catch(_) {
      _navigateToUrlErrorScreen();
    } on SocketException catch(_) {
      _navigateToUrlErrorScreen();
    } catch(error) {
      _navigateToUrlErrorScreen();
    }
  }

  // Funcție pentru a încărca mesajele
  Future<void> loadMessages() async {
    await fetchAndSetChats();
  }

  // Funcție pentru a trimite un mesaj nou
  Future<void> sendMessage(String newMessage) async {
    final token = User_provider().getJwtToken();
    final url1 = Uri.https(Constant.url, '/api/Chat');
    final Map<String, dynamic> data = {'newMessage': newMessage};

    if (token == null) {
      throw Exception('JWT token not available');
    }

    try {
      final response = await http.post(
        url1,
        headers: <String, String>{
          'ngrok-skip-browser-warning': 'True',
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(data),
      ).timeout(Duration(seconds: 7));
      // Notificarea stream-ului de evenimente
      _messageEventController.add(null);
    } on TimeoutException catch(_) {
      _navigateToUrlErrorScreen();
    } on SocketException catch(_) {
      _navigateToUrlErrorScreen();
    } catch(error) {
      throw (error);
    }
  }

  // Funcție pentru a șterge un mesaj
  Future<void> deleteMessage(DateTime dateSend) async {
    final token = User_provider().getJwtToken();
    final url1 = Uri.https(Constant.url, '/api/Chat');

    if (token == null) {
      throw Exception('JWT token not available');
    }

    final String dateSendToString = dateSend.toIso8601String();
    final Map<String, dynamic> data = {
      'newMessage': '',
      'dateSend': dateSendToString
    };

    try {
      final response = await http.delete(
        url1,
        headers: <String, String>{
          'ngrok-skip-browser-warning': 'True',
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(data),
      ).timeout(Duration(seconds: 7));
      // Notificarea stream-ului de evenimente
      _messageEventController.add(null);
    } on TimeoutException catch(_) {
      _navigateToUrlErrorScreen();
    } on SocketException catch(_) {
      _navigateToUrlErrorScreen();
    } catch(error) {
      throw (error);
    }
  }

  // Funcție pentru a schimba un mesaj existent
  Future<void> changeMessage(DateTime dateSend, String newMessage) async {
    final token = User_provider().getJwtToken();
    final url1 = Uri.https(Constant.url, '/api/Chat');

    if (token == null) {
      throw Exception('JWT token not available');
    }

    final String dateSendToString = dateSend.toIso8601String();
    final Map<String, dynamic> data = {
      'dateSend': dateSendToString,
      'newMessage': newMessage
    };

    try {
      final response = await http.put(
        url1,
        headers: <String, String>{
          'ngrok-skip-browser-warning': 'True',
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(data),
      );
      // Notificarea stream-ului de evenimente
      _messageEventController.add(null);
    } catch(error) {
      throw (error);
    }
  }

  // Funcție pentru a selecta și stoca o imagine
  Future<void> selectAndStoreImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.camera);
    if (pickedImage == null) return;

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

  // Funcție pentru a selecta și stoca imagini multiple
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

  // Navigarea către ecranul de eroare
  void _navigateToUrlErrorScreen() {
    navigatorKey.currentState?.pushReplacementNamed('urlError');
  }

  // Verificarea disponibilității serverului
  Future<bool> checkServerAvailability() async {
    final token = User_provider().getJwtToken();
    final url1 = Uri.https(Constant.url, '/api/Chat');
    try {
      final response = await http.get(
        url1,
        headers: <String, String>{
          'ngrok-skip-browser-warning': 'True',
          'Authorization': 'Bearer $token'
        }
      ).timeout(Duration(seconds: 7));

      if(response.statusCode == 200) {
        return true;
      }
    } on TimeoutException catch(_) {
      return false;
    } on SocketException catch(_) {
      return false;
    } catch (error) {
      return false;
    }
    return false;
  }

  // Eliberarea resurselor StreamController la dezafectarea widgetului
  @override
  void dispose() {
    _messageEventController.close();
    super.dispose();
  }
}
