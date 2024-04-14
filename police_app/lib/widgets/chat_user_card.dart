import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:police_app/models/chat_user.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * .04, vertical: MediaQuery.of(context).size.width * .01),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {},
        child: const ListTile(
          leading: CircleAvatar(child: Icon(CupertinoIcons.person)),
          title: Text('Demo User'),
          subtitle: Text('Last user message', maxLines: 1,),
          trailing: Text(
            '12:00 PM',
             style: TextStyle(color: Colors.black54)
            )
        ),
      ),
    );
  }
}