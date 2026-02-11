import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../service/login_service.dart';
import '../../../core/constants/api_constants.dart';

class LoginController with ChangeNotifier {
  final LoginService _service = LoginService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> login() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final (data, error) = await _service.login(
      usernameController.text,
      passwordController.text,
    );

    if (error != null) {
      _error = error;
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (data != null && data.status) {
      if (data.token != null) {
        await _storage.write(key: ApiConstants.tokenKey, value: data.token);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = data?.message ?? 'Login failed';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
