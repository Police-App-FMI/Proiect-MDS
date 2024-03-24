import 'package:flutter/material.dart';
import 'package:police_app/widgets/NavBar.dart';
import 'package:police_app/widgets/chat_user_card.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<Home> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Home> {
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
        child: FloatingActionButton(onPressed: (){}, child: const Icon(Icons.add_comment_rounded, color: Colors.white), backgroundColor: Color.fromARGB(255, 30, 64, 112),),
      ),

      body: ListView.builder(
        itemCount: 5,
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * .02),
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, index) {
        return const ChatUserCard();
      })
    );
  }
}
