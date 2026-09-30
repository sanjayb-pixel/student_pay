class Employee {
  final String id;
  String username;
  String password;
  String vendorId;
  bool active;

  Employee({
    required this.id,
    required this.username,
    required this.password,
    required this.vendorId,
    this.active = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'password': password,
        'vendorId': vendorId,
        'active': active,
      };

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
        id: json['id'] as String,
        username: json['username'] as String,
        password: json['password'] as String,
        vendorId: json['vendorId'] as String,
        active: json['active'] as bool? ?? true,
      );
}