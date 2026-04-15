class User {
  final int id;
  final String email;
  final String name;
  final String phone;
  final double balance;
  final double tapLimit;
  final bool fingerprintEnabled;
  final bool contactlessEnabled;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.balance,
    this.tapLimit = 50.0,
    this.fingerprintEnabled = true,
    this.contactlessEnabled = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      balance: (json['balance'] as num).toDouble(),
      tapLimit: (json['tapLimit'] as num?)?.toDouble() ?? 50.0,
      fingerprintEnabled: json['fingerprintEnabled'] ?? true,
      contactlessEnabled: json['contactlessEnabled'] ?? true,
    );
  }

  User copyWith({
    int? id,
    String? email,
    String? name,
    String? phone,
    double? balance,
    double? tapLimit,
    bool? fingerprintEnabled,
    bool? contactlessEnabled,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      balance: balance ?? this.balance,
      tapLimit: tapLimit ?? this.tapLimit,
      fingerprintEnabled: fingerprintEnabled ?? this.fingerprintEnabled,
      contactlessEnabled: contactlessEnabled ?? this.contactlessEnabled,
    );
  }
}
