import 'dart:convert';

List<ChatUser> userFromJson(String str) =>
    List<ChatUser>.from(json.decode(str).map((x) => ChatUser.fromJson(x)));

String userToJson(List<ChatUser> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ChatUser {
  ChatUser(
      {required this.nume,
      required this.profile_Pic,
      required this.mesaj,
      required this.date_send});

  final String nume;
  final String profile_Pic;
  final String mesaj;
  final DateTime date_send;

  factory ChatUser.fromJson(Map<String, dynamic> json) => ChatUser(
      profile_Pic: json["profile_pic"],
      nume: json["nume"],
      mesaj: json["message"],
      date_send: json["date_send"]);

  Map<String, dynamic> toJson() => {
        "profile_pic": profile_Pic,
        "name": nume,
        "message": mesaj,
        "date_send": date_send
      };
}
