import 'dart:convert';

List<ChatUser> userFromJson(String str) => List<ChatUser>.from(json.decode(str).map((x) => ChatUser.fromJson(x)));

String userToJson(List<ChatUser> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ChatUser {
  ChatUser({
    this.username,
    this.name,
    this.profile_pic,
    this.email,
    
  });

  String? username;
  String? name;
  String? profile_pic;
  String? email;

  factory ChatUser.fromJson(Map<String, dynamic> json) => ChatUser(
    username: json["username"],
    profile_pic: json["profile_pic"],
    email: json["email"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "username": username,
    "profile_pic": profile_pic,
    "email": email,
    "name": name
  };
}