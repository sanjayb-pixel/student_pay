import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import '../models/transaction.dart';

class ApiService {
  ApiService._internal();
  static final ApiService instance = ApiService._internal();

  final CollectionReference<Map<String, dynamic>> _txCol =
      FirebaseFirestore.instance.collection('transactions');

  /// Save a new transaction to Cloud Firestore.
  /// Returns the saved Transaction with the Firestore document ID.
  Future<Transaction> saveTransaction(Transaction tx) async {
    final docRef = _txCol.doc();
    final newTx = tx.copyWith(
      id: docRef.id,
      redeemed: false,
    );

    await docRef.set(newTx.toJson());
    return newTx;
  }

  /// Mark a transaction as redeemed in Cloud Firestore.
  Future<bool> redeemTransaction(String id) async {
    try {
      final docRef = _txCol.doc(id);
      final snapshot = await docRef.get();

      if (!snapshot.exists) {
        return false;
      }

      final data = snapshot.data();
      final isAlreadyRedeemed = data?['redeemed'] as bool? ?? false;
      if (isAlreadyRedeemed) {
        return false; // already redeemed
      }

      await docRef.update({
        'redeemed': true,
        'redeemedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Permanently delete a transaction document from Firestore.
  Future<void> deleteTransaction(String id) async {
    await _txCol.doc(id).delete();
  }

  /// Delete multiple transactions at once using a batch write.
  Future<void> deleteTransactions(List<String> ids) async {
    if (ids.isEmpty) return;
    final batch = FirebaseFirestore.instance.batch();
    for (final id in ids) {
      batch.delete(_txCol.doc(id));
    }
    await batch.commit();
  }

  /// Real-time stream of active (non-redeemed) transactions for a specific vendor.
  Stream<List<Transaction>> streamTransactions({required String vendorId}) {
    return _txCol
        .where('vendorId', isEqualTo: vendorId)
        .where('redeemed', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Transaction.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }
}