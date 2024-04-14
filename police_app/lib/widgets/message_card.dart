import 'package:flutter/material.dart';
import 'package:police_app/models/chat_user.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final ChatUser message;

  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Widget _blueMessage() {
    return Container();
  }

  Widget _greenMessage() {
    return Container();
  }
}
