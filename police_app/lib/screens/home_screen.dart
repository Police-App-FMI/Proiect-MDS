import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:police_app/models/chat_user.dart';
import 'package:police_app/providers/chat_provider.dart';
import 'package:police_app/widgets/navbar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';



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
  }

  final List<ChatUser> _list = [];
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 30, 64, 112),
        title: const Text(
          'Police App',
          style: TextStyle(color: Colors.white, ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton(
          onPressed: (){},
          child: const Icon(Icons.add_comment_rounded, color: Colors.white),
          backgroundColor: Color.fromARGB(255, 30, 64, 112),
        ),
      ),
      body: Column(
        children: [
        /**
          StreamBuilder<List<ChatUser>>(
          stream: Provider.of<ChatProvider>(context).userStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final messages = snapshot.data!;
              messages.sort((a, b) => a.dateSent.compareTo(b.dateSent)); // Sortează mesajele după timpul trimiterii

              return ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return ListTile(
                    title: Text(message.name),
                    subtitle: Text(message.message),
                    trailing: Text(DateFormat('HH:mm').format(message.dateSent)), // Afisează timpul trimiterii
                  );
                },
              );
            }
          },
        ),
        */
          _chatInput()])
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * .01, horizontal: MediaQuery.of(context).size.width * .025),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Row(children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.emoji_emotions, color: Colors.blueAccent, size: 25)),
              
                Expanded(
                  child: TextField(
                  controller: _textController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'Type Something...',
                    hintStyle: TextStyle(color: Colors.blueAccent),
                    border: InputBorder.none)
                )),
              
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.image, color: Colors.blueAccent, size: 26)),
              
                IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.camera_alt_rounded, color: Colors.blueAccent, size: 26)),  

                SizedBox(width: MediaQuery.of(context).size.width * .02)
              ],),
            ),
          ),
      
          MaterialButton(
            onPressed: () {
              Provider.of<ChatProvider>(context, listen: false).sendMessage(_textController.text.trim());
            },
            minWidth: 0,
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: CircleBorder(),
            color: Colors.green,
            child: Icon(Icons.send, color: Colors.white, size:28),)
        ],
      ),
    );
  }

}
