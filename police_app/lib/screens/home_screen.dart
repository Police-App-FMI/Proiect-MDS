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
    Provider.of<ChatProvider>(context, listen: false)
        .messageEventStream
        .listen((_) {
      Provider.of<ChatProvider>(context, listen: false).fetchAndSetChats();
    });
    Provider.of<ChatProvider>(context, listen: false).fetchAndSetChats();
  }

  final TextEditingController _textController = TextEditingController();
  bool _showEmoji = false;
  bool _showOptionsDialog = true;

  @override
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<User_provider>(context);
    final currentUserNume = userProvider.userName;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
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
          drawer: NavBar(),
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
                stream: Stream.empty(),
                builder: (ctx, chatSnapshot) {
                  if (chatSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    if (chatSnapshot.error != null) {
                      print(chatSnapshot.error);
                      return Center(child: Text('An error occurred!'));
                    } else {
                      return Consumer<ChatProvider>(
                        builder: (ctx, chatProvider, _) {
                          return ListView.builder(
                            itemCount: chatProvider.chats.length,
                            itemBuilder: (ctx, i) {
                              String? message = chatProvider.chats[i].mesaj;
                              Uint8List? imageBytes;

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
                                                              .date_send);
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
                                                      .pop(); // Ascunde dialogul actual
                                                  _showEditMessageDialog(
                                                      chatProvider
                                                          .chats[i].mesaj,
                                                      chatProvider
                                                          .chats[i].date_send);
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
                                                              .date_send);
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
                                        chatProvider.chats[i].profile_Pic,
                                    dateSend: DateFormat('dd/MM HH:mm').format(
                                        chatProvider.chats[i].date_send),
                                    isCurrentUser: chatProvider.chats[i].nume ==
                                        currentUserNume,
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
            _chatInput(),
            if (_showEmoji)
              SizedBox(
                height: MediaQuery.of(context).size.height * .35,
                child: EmojiPicker(
                  textEditingController: _textController,
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
                        setState(() => _showEmoji = !_showEmoji);
                      },
                      icon: const Icon(Icons.emoji_emotions,
                          color: Colors.blueAccent, size: 25)),
                  Expanded(
                      child: TextField(
                          controller: _textController,
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
                            .selectAndStoreMultipleImages();
                      },
                      icon: const Icon(Icons.image,
                          color: Colors.blueAccent, size: 26)),
                  IconButton(
                      onPressed: () {
                        Provider.of<ChatProvider>(context, listen: false)
                            .selectAndStoreImage();
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
                  .sendMessage(message);
              _textController.clear();
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
                    .changeMessage(dateSend, '[TXT]$newMessage');
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
