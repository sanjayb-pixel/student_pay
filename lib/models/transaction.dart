class Transaction {
  final String? id;
  final String rollNumber;
  final double amount;
  final bool redeemed;
  final DateTime createdAt;
  final String vendorId; // NEW: ties transaction to a specific vendor

  Transaction({
    this.id,
    required this.rollNumber,
    required this.amount,
    this.redeemed = false,
    DateTime? createdAt,
    required this.vendorId,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'rollNumber': rollNumber,
        'amount': amount,
        'redeemed': redeemed,
        'createdAt': createdAt.toIso8601String(),
        'vendorId': vendorId,
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id']?.toString(),
        rollNumber: json['rollNumber'] ?? '',
        amount: (json['amount'] as num).toDouble(),
        redeemed: json['redeemed'] ?? false,
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        vendorId: json['vendorId'] as String? ?? '',
      );

  Transaction copyWith({
    String? id,
    String? rollNumber,
    double? amount,
    bool? redeemed,
    DateTime? createdAt,
    String? vendorId,
  }) {
    return Transaction(
      id: id ?? this.id,
      rollNumber: rollNumber ?? this.rollNumber,
      amount: amount ?? this.amount,
      redeemed: redeemed ?? this.redeemed,
      createdAt: createdAt ?? this.createdAt,
      vendorId: vendorId ?? this.vendorId,
    );
  }
}