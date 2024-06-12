import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:police_app/models/chat_message.dart';
import 'package:police_app/providers/chat_provider.dart';
import 'package:police_app/providers/user_provider.dart';
import 'package:police_app/widgets/navbar.dart';
import 'package:provider/provider.dart';

// Widget principal pentru Home
class Home extends StatefulWidget {
  const Home({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    // Ascultă evenimentele de mesaje și actualizează chat-urile
    Provider.of<ChatProvider>(context, listen: false)
        .messageEventStream
        .listen((_) {
      Provider.of<ChatProvider>(context, listen: false).fetchAndSetChats();
    });
    Provider.of<ChatProvider>(context, listen: false).fetchAndSetChats();
  }

  final TextEditingController _textController = TextEditingController(); // Controller pentru textul mesajului
  bool _showEmoji = false; // Afișează/ascunde picker-ul de emoji
  bool _showOptionsDialog = true; // Afișează/ascunde dialogul cu opțiuni

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<User_provider>(context); // Provider pentru utilizator
    final currentUserNume = userProvider.userName; // Numele utilizatorului curent

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Ascunde tastatura la tap pe ecran
      child: WillPopScope(
        onWillPop: () {
          if (_showEmoji) {
            setState(() {
              _showEmoji = !_showEmoji;
            });
            return Future.value(false);
          } else
            return Future.value(true);
        },
        child: Scaffold(
          drawer: NavBar(), // Bara de navigare
          appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 30, 64, 112),
            title: const Text(
              'Police App',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          body: Column(children: [
            Expanded(
              child: StreamBuilder(
                stream: Stream.empty(), // Stream-ul pentru mesaje
                builder: (ctx, chatSnapshot) {
                  if (chatSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(), // Indicator de încărcare
                    );
                  } else {
                    if (chatSnapshot.error != null) {
                      print(chatSnapshot.error);
                      return Center(child: Text('An error occurred!')); // Mesaj de eroare
                    } else {
                      return Consumer<ChatProvider>(
                        builder: (ctx, chatProvider, _) {
                          return ListView.builder(
                            itemCount: chatProvider.chats.length, // Numărul de mesaje
                            itemBuilder: (ctx, i) {
                              String? message = chatProvider.chats[i].mesaj;
                              Uint8List? imageBytes;

                              // Decodifică mesajele de tip imagine
                              if (message != null &&
                                  message.startsWith('[IMG]')) {
                                message = message.replaceFirst('[IMG]', '');
                                imageBytes = base64Decode(message);
                              } else if (message != null &&
                                  message.startsWith('[TXT]')) {
                                message = message.replaceFirst('[TXT]', '');
                              }

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                child: GestureDetector(
                                  onLongPress: () {
                                    // Dialog pentru ștergerea sau modificarea mesajelor
                                    if (chatProvider.chats[i].nume ==
                                        currentUserNume) {
                                      if (chatProvider.chats[i].mesaj
                                          .startsWith('[IMG]')) {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text('Șterge mesajul'),
                                            content: Text(
                                                'Sigur dorești să ștergi acest mesaj?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Anulează'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Provider.of<ChatProvider>(
                                                          context,
                                                          listen: false)
                                                      .deleteMessage(
                                                          chatProvider.chats[i]
                                                              .date_send); // Șterge mesajul
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Șterge'),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(
                                                'Șterge sau modifică mesajul'),
                                            content: Text(
                                                'Ce dorești să faci cu acest mesaj?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Anulează'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop();
                                                  _showEditMessageDialog(
                                                      chatProvider
                                                          .chats[i].mesaj,
                                                      chatProvider
                                                          .chats[i].date_send); // Dialog pentru modificarea mesajului
                                                },
                                                child: Text('Modifică'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Provider.of<ChatProvider>(
                                                          context,
                                                          listen: false)
                                                      .deleteMessage(
                                                          chatProvider.chats[i]
                                                              .date_send); // Șterge mesajul
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Șterge'),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: ChatMessage(
                                    nume: chatProvider.chats[i].nume,
                                    mesaj: message,
                                    imageBytes: imageBytes,
                                    profilePic:
                                        chatProvider.chats[i].profile_Pic ?? "https://github.com/Police-App-FMI/Proiect-MDS/blob/main/police_app/assets/images/pozaRares.jpeg",
                                    dateSend: DateFormat('dd/MM HH:mm').format(
                                        chatProvider.chats[i].date_send),
                                    isCurrentUser: chatProvider.chats[i].nume ==
                                        currentUserNume, // Verifică dacă mesajul este al utilizatorului curent
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }
                  }
                },
              ),
            ),
            _chatInput(), // Widget pentru introducerea mesajului
            if (_showEmoji)
              SizedBox(
                height: MediaQuery.of(context).size.height * .35,
                child: EmojiPicker(
                  textEditingController: _textController, // Picker de emoji-uri
                  config: Config(
                    columns: 7,
                    emojiSizeMax: 32 *
                        (Platform.isIOS == TargetPlatform.iOS ? 1.30 : 1.0),
                  ),
                ),
              )
          ]),
        ),
      ),
    );
  }

  // Widget pentru introducerea mesajului
  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * .01,
          horizontal: MediaQuery.of(context).size.width * .025),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() => _showEmoji = !_showEmoji); // Afișează/ascunde picker-ul de emoji-uri
                      },
                      icon: const Icon(Icons.emoji_emotions,
                          color: Colors.blueAccent, size: 25)),
                  Expanded(
                      child: TextField(
                          controller: _textController, // Controller pentru textul mesajului
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          onTap: () {
                            if (_showEmoji)
                              setState(() => _showEmoji = !_showEmoji);
                          },
                          decoration: const InputDecoration(
                              hintText: 'Type Something...',
                              hintStyle: TextStyle(color: Colors.blueAccent),
                              border: InputBorder.none))),
                  IconButton(
                      onPressed: () async {
                        Provider.of<ChatProvider>(context, listen: false)
                            .selectAndStoreMultipleImages(); // Selectează și stochează imagini multiple
                      },
                      icon: const Icon(Icons.image,
                          color: Colors.blueAccent, size: 26)),
                  IconButton(
                      onPressed: () {
                        Provider.of<ChatProvider>(context, listen: false)
                            .selectAndStoreImage(); // Selectează și stochează o imagine
                      },
                      icon: const Icon(Icons.camera_alt_rounded,
                          color: Colors.blueAccent, size: 26)),
                  SizedBox(width: MediaQuery.of(context).size.width * .02)
                ],
              ),
            ),
          ),
          MaterialButton(
            onPressed: () {
              String message = '[TXT]${_textController.text.trim()}';
              Provider.of<ChatProvider>(context, listen: false)
                  .sendMessage(message); // Trimite mesajul
              _textController.clear(); // Curăță textul
            },
            minWidth: 0,
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: CircleBorder(),
            color: Colors.green,
            child: Icon(Icons.send, color: Colors.white, size: 28),
          )
        ],
      ),
    );
  }

  // Dialog pentru modificarea mesajului
  void _showEditMessageDialog(String currentMessage, DateTime dateSend) {
    String newMessage = currentMessage.startsWith('[TXT]')
        ? currentMessage.substring(5)
        : currentMessage;
    _showOptionsDialog = false; // Ascunde widgetul cu opțiuni
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifică mesajul'),
          content: TextField(
            onChanged: (value) {
              newMessage = value;
            },
            controller: TextEditingController(text: newMessage),
            decoration: InputDecoration(hintText: "Introdu mesajul nou"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _showOptionsDialog =
                    true; // Afișează înapoi widgetul cu opțiuni
                Navigator.of(context).pop();
              },
              child: Text('Anulează'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<ChatProvider>(context, listen: false)
                    .changeMessage(dateSend, '[TXT]$newMessage'); // Modifică mesajul
                Navigator.of(context).pop();
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
