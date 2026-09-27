import '../models/transaction.dart';

class ApiService {
  // Singleton
  ApiService._internal();
  static final ApiService instance = ApiService._internal();

  // In-memory store (replace with real backend calls)
  final List<Transaction> _store = [];

  /// Save a new transaction to the backend.
  /// Returns the saved Transaction (with server-assigned id).
  Future<Transaction> saveTransaction(Transaction tx) async {
    await Future.delayed(const Duration(milliseconds: 400)); // simulate network

    final saved = tx.copyWith(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      redeemed: false,
    );
    _store.add(saved);
    return saved;
  }

  /// Mark a transaction as redeemed on the backend.
  Future<bool> redeemTransaction(String id) async {
    await Future.delayed(const Duration(milliseconds: 400)); // simulate network

    final index = _store.indexWhere((t) => t.id == id);
    if (index == -1) return false;

    _store[index] = _store[index].copyWith(redeemed: true);
    return true;
  }

  /// (Optional) Fetch all active (non-redeemed) transactions.
  Future<List<Transaction>> fetchActiveTransactions() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _store.where((t) => !t.redeemed).toList();
  }
}