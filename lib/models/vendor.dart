class Vendor {
  final String id;
  String username;
  String password;
  bool active;

  Vendor({
    required this.id,
    required this.username,
    required this.password,
    this.active = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'password': password,
        'active': active,
      };

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(
        id: json['id'] as String,
        username: json['username'] as String,
        password: json['password'] as String,
        active: json['active'] as bool? ?? true,
      );
}