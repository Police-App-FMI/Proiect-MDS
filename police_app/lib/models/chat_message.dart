import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  final String nume;
  final String? mesaj;
  final Uint8List? imageBytes;
  final String profilePic;
  final String dateSend;
  final bool isCurrentUser;

  ChatMessage({
    required this.nume,
    required this.mesaj,
    required this.imageBytes,
    required this.profilePic,
    required this.dateSend,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: isCurrentUser
              ? _buildCurrentUserMessage(context)
              : _buildOtherUserMessage(context),
        ),
      ],
    );
  }

  Widget _buildCurrentUserMessage(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          nume,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 4.0),
                        CircleAvatar(
                          backgroundImage: NetworkImage(profilePic),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildTime(context),
                        SizedBox(width: 4.0),
                        _buildMessage(context),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 4.0),
            ],
          ),
          SizedBox(height: 4.0),
        ],
      ),
    );
  }

  Widget _buildOtherUserMessage(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(width: 4.0),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(profilePic),
                        ),
                        SizedBox(width: 4.0),
                        Text(
                          nume,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.0),
                    Row(
                      children: [
                        _buildMessage(context),
                        SizedBox(width: 4.0),
                        _buildTime(context),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 4.0),
        ],
      ),
    );
  }

  Widget _buildTime(BuildContext context) {
    return Text(
      dateSend.toString(),
      style: TextStyle(fontSize: 12.0, color: Colors.grey),
    );
  }

  Widget _buildMessage(BuildContext context) {
    if (mesaj != null) {
      if (imageBytes != null) {
        return Container(
          width: 250,
          height: 250,
          child: Image.memory(
            imageBytes!,
            fit: BoxFit.cover,
          ),
        );
      } else {
        return Flexible(
          child: Text(
            mesaj!,
            style: TextStyle(color: Colors.black),
            softWrap: true,
          ),
        );
      }
    } else {
      return SizedBox.shrink();
    }
  }
}
