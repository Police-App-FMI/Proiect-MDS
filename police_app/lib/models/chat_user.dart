import 'dart:convert';

List<ChatUser> userFromJson(String str) => List<ChatUser>.from(json.decode(str).map((x) => ChatUser.fromJson(x)));

String userToJson(List<ChatUser> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ChatUser {
  ChatUser({
    required this.name,
    required this.profilePic,
    required this.message,
    required this.dateSent
  });

  final String name;
  final String profilePic;
  final String message;
  final DateTime dateSent;

  factory ChatUser.fromJson(Map<String, dynamic> json) => ChatUser(
    profilePic: json["profile_pic"],
    name: json["nume"],
    message: json["message"],
    dateSent: json["date_send"]
  );

  Map<String, dynamic> toJson() => {
    "profile_pic": profilePic,
    "name": name,
    "message": message,
    "date_send": dateSent
  };
}