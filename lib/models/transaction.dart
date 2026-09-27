class Transaction {
  final String? id;
  final String rollNumber;
  final double amount;
  final bool redeemed;
  final DateTime createdAt;

  Transaction({
    this.id,
    required this.rollNumber,
    required this.amount,
    this.redeemed = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'rollNumber': rollNumber,
        'amount': amount,
        'redeemed': redeemed,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id']?.toString(),
        rollNumber: json['rollNumber'] ?? '',
        amount: (json['amount'] as num).toDouble(),
        redeemed: json['redeemed'] ?? false,
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );

  Transaction copyWith({
    String? id,
    String? rollNumber,
    double? amount,
    bool? redeemed,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      rollNumber: rollNumber ?? this.rollNumber,
      amount: amount ?? this.amount,
      redeemed: redeemed ?? this.redeemed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}