class Recharge {
  final int? id;
  final int userId;
  final String phoneNumber;
  final String provider;
  final double amount;
  final String date;

  Recharge({
    this.id,
    required this.userId,
    required this.phoneNumber,
    required this.provider,
    required this.amount,
    required this.date,
  });

  // 🔹 Convertir de JSON (SQLite) a un objeto Recharge
  factory Recharge.fromJson(Map<String, dynamic> json) {
    return Recharge(
      id: json['id'],
      userId: json['user_id'],
      phoneNumber: json['phoneNumber'],
      provider: json['provider'],
      amount: json['amount'].toDouble(),
      date: json['date'],
    );
  }

  // 🔹 Convertir un objeto Recharge a JSON para SQLite
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'phoneNumber': phoneNumber,
      'provider': provider,
      'amount': amount,
      'date': date,
    };
  }
}
