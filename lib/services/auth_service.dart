import '../models/vendor.dart';
import '../models/employee.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  // ---------- Hardcoded admin credentials ----------
  static const String adminUsername = 'admin';
  static const String adminPassword = 'admin123';

  // ---------- In-memory stores ----------
  final List<Vendor> _vendors = [];
  final List<Employee> _employees = [];

  int _vendorSeq = 1;
  int _employeeSeq = 1;

  // ---------- Admin ----------
  bool adminLogin(String username, String password) {
    return username.trim() == adminUsername &&
        password.trim() == adminPassword;
  }

  // ---------- Vendors ----------
  List<Vendor> get vendors => List.unmodifiable(_vendors);

  bool vendorUsernameExists(String username, {String? ignoreId}) {
    return _vendors.any(
      (v) =>
          v.username.toLowerCase() == username.trim().toLowerCase() &&
          v.id != ignoreId,
    );
  }

  Vendor addVendor({required String username, required String password}) {
    final vendor = Vendor(
      id: 'V${_vendorSeq++}',
      username: username.trim(),
      password: password.trim(),
    );
    _vendors.add(vendor);
    return vendor;
  }

  void updateVendor(String id, {String? username, String? password}) {
    final v = _vendors.firstWhere((e) => e.id == id);
    if (username != null && username.trim().isNotEmpty) {
      v.username = username.trim();
    }
    if (password != null && password.trim().isNotEmpty) {
      v.password = password.trim();
    }
  }

  void deleteVendor(String id) {
    _vendors.removeWhere((e) => e.id == id);
    _employees.removeWhere((e) => e.vendorId == id);
  }

  Vendor? findVendorById(String id) {
    for (final v in _vendors) {
      if (v.id == id) return v;
    }
    return null;
  }

  Vendor? vendorLogin(String username, String password) {
    for (final v in _vendors) {
      if (v.username.toLowerCase() == username.trim().toLowerCase() &&
          v.password == password.trim()) {
        return v;
      }
    }
    return null;
  }

  // ---------- Employees ----------
  List<Employee> employeesOf(String vendorId) =>
      _employees.where((e) => e.vendorId == vendorId).toList();

  bool employeeUsernameExists(String vendorId, String username,
      {String? ignoreId}) {
    return _employees.any(
      (e) =>
          e.vendorId == vendorId &&
          e.username.toLowerCase() == username.trim().toLowerCase() &&
          e.id != ignoreId,
    );
  }

  Employee addEmployee({
    required String vendorId,
    required String username,
    required String password,
  }) {
    final emp = Employee(
      id: 'E${_employeeSeq++}',
      username: username.trim(),
      password: password.trim(),
      vendorId: vendorId,
    );
    _employees.add(emp);
    return emp;
  }

  void updateEmployee(String id,
      {String? username, String? password}) {
    final e = _employees.firstWhere((x) => x.id == id);
    if (username != null && username.trim().isNotEmpty) {
      e.username = username.trim();
    }
    if (password != null && password.trim().isNotEmpty) {
      e.password = password.trim();
    }
  }

  void deleteEmployee(String id) {
    _employees.removeWhere((e) => e.id == id);
  }

  Employee? employeeLogin(String username, String password) {
    for (final e in _employees) {
      if (e.username.toLowerCase() == username.trim().toLowerCase() &&
          e.password == password.trim()) {
        return e;
      }
    }
    return null;
  }
}