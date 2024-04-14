import 'dart:convert';

List<User> userFromJson(String str) =>
    List<User>.from(json.decode(str).map((x) => User.fromJson(x)));

String userToJson(List<User> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class User {
  User({this.username, this.profile_pic, this.email, required this.password});

  String? username;
  String? profile_pic;
  String? email;
  String password;

  factory User.fromJson(Map<String, dynamic> json) => User(
        username: json["username"],
        profile_pic: json["profile_pic"],
        email: json["email"],
        password: json["password"],
      );

  Map<String, dynamic> toJson() => {
        "username": username,
        "profile_pic": profile_pic,
        "email": email,
        "password": password
      };
}
