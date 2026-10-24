import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vendor.dart';
import '../models/employee.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  // ---------- Hardcoded admin credentials ----------
  static const String adminUsername = 'admin';
  static const String adminPassword = 'admin123';

  final CollectionReference<Map<String, dynamic>> _vendorCol =
      FirebaseFirestore.instance.collection('vendors');
  final CollectionReference<Map<String, dynamic>> _employeeCol =
      FirebaseFirestore.instance.collection('employees');

  // ---------- REACTIVE STREAMS ----------

  /// Real-time stream of all vendors.
  Stream<List<Vendor>> get vendorsStream => _vendorCol.snapshots().map(
        (snap) => snap.docs
            .map((doc) => Vendor.fromJson({...doc.data(), 'id': doc.id}))
            .toList(),
      );

  /// Real-time stream of employees for a specific vendor.
  Stream<List<Employee>> employeesStream(String vendorId) =>
      _employeeCol
          .where('vendorId', isEqualTo: vendorId)
          .snapshots()
          .map(
            (snap) => snap.docs
                .map((doc) =>
                    Employee.fromJson({...doc.data(), 'id': doc.id}))
                .toList(),
          );

  // ---------- Admin ----------
  bool adminLogin(String username, String password) {
    return username.trim() == adminUsername &&
        password.trim() == adminPassword;
  }

  // ---------- Vendors ----------

  /// One-shot fetch for login — quick synchronous-style lookup.
  Future<Vendor?> vendorLoginAsync(String username, String password) async {
    final snap = await _vendorCol
        .where('username', isEqualTo: username.trim())
        .where('password', isEqualTo: password.trim())
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return Vendor.fromJson({...doc.data(), 'id': doc.id});
  }

  bool vendorUsernameExistsInList(List<Vendor> vendors, String username,
      {String? ignoreId}) {
    return vendors.any(
      (v) =>
          v.username.toLowerCase() == username.trim().toLowerCase() &&
          v.id != ignoreId,
    );
  }

  Future<Vendor> addVendor(
      {required String username, required String password}) async {
    final docRef = _vendorCol.doc();
    final vendor = Vendor(
      id: docRef.id,
      username: username.trim(),
      password: password.trim(),
    );
    await docRef.set(vendor.toJson());
    return vendor;
  }

  Future<void> updateVendor(String id,
      {String? username, String? password}) async {
    final Map<String, dynamic> updates = {};
    if (username != null && username.trim().isNotEmpty) {
      updates['username'] = username.trim();
    }
    if (password != null && password.trim().isNotEmpty) {
      updates['password'] = password.trim();
    }
    if (updates.isNotEmpty) {
      await _vendorCol.doc(id).update(updates);
    }
  }

  Future<void> deleteVendor(String id) async {
    // Delete vendor's employees first
    final empSnap =
        await _employeeCol.where('vendorId', isEqualTo: id).get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in empSnap.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_vendorCol.doc(id));
    await batch.commit();
  }

  Vendor? findVendorById(String id, List<Vendor> vendors) {
    for (final v in vendors) {
      if (v.id == id) return v;
    }
    return null;
  }

  // ---------- Employees ----------

  Future<Employee?> employeeLoginAsync(
      String username, String password) async {
    final snap = await _employeeCol
        .where('username', isEqualTo: username.trim())
        .where('password', isEqualTo: password.trim())
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return Employee.fromJson({...doc.data(), 'id': doc.id});
  }

  bool employeeUsernameExistsInList(
      List<Employee> employees, String vendorId, String username,
      {String? ignoreId}) {
    return employees.any(
      (e) =>
          e.vendorId == vendorId &&
          e.username.toLowerCase() == username.trim().toLowerCase() &&
          e.id != ignoreId,
    );
  }

  Future<Employee> addEmployee({
    required String vendorId,
    required String username,
    required String password,
  }) async {
    final docRef = _employeeCol.doc();
    final emp = Employee(
      id: docRef.id,
      username: username.trim(),
      password: password.trim(),
      vendorId: vendorId,
    );
    await docRef.set(emp.toJson());
    return emp;
  }

  Future<void> updateEmployee(String id,
      {String? username, String? password}) async {
    final Map<String, dynamic> updates = {};
    if (username != null && username.trim().isNotEmpty) {
      updates['username'] = username.trim();
    }
    if (password != null && password.trim().isNotEmpty) {
      updates['password'] = password.trim();
    }
    if (updates.isNotEmpty) {
      await _employeeCol.doc(id).update(updates);
    }
  }

  Future<void> deleteEmployee(String id) async {
    await _employeeCol.doc(id).delete();
  }
}