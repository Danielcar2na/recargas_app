class Recharge {
  final int? id;
  final String phoneNumber;
  final String provider;
  final double amount;
  final String date;

  Recharge({
    this.id,
    required this.phoneNumber,
    required this.provider,
    required this.amount,
    required this.date,
  });

  // Convertir un objeto Recharge a un mapa (para guardar en SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'provider': provider,
      'amount': amount,
      'date': date,
    };
  }

  // Convertir un mapa de SQLite a un objeto Recharge
  factory Recharge.fromMap(Map<String, dynamic> map) {
    return Recharge(
      id: map['id'],
      phoneNumber: map['phoneNumber'],
      provider: map['provider'],
      amount: map['amount'],
      date: map['date'],
    );
  }
}
