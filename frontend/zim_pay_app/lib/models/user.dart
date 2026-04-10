class User {
  final int id;
  final String email;
  final String name;
  final String phone;
  final double balance;

  User({required this.id, required this.email, required this.name, required this.phone, required this.balance});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      balance: json['balance'],
    );
  }
}