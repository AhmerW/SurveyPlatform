class User {
  final int uid;
  final String username;
  final bool admin;
  final bool owner;
  final bool verified;

  int points;
  String? email;

  User(
    this.uid,
    this.username, {
    this.email,
    required this.verified,
    this.admin = false,
    this.owner = false,
    this.points = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(json["uid"], json["username"],
        email: json["email"],
        verified: json["verified"],
        admin: json["admin"],
        owner: json["owner"]);
  }
}
