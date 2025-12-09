import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String _userName = "";
  String _email = "";
  String? _token;

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get email => _email;
  String? get token => _token;

  AuthProvider() {
    _loadUser();
  }

  // Load saved user info and token
  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token');
    final savedUser = prefs.getString('user');

    if (savedToken != null && savedUser != null) {
      final userData = jsonDecode(savedUser);
      _token = savedToken;
      _userName = userData['name'] ?? "${userData['f_name']} ${userData['l_name']}";
      _email = userData['email'] ?? "";
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  // Save user info and token locally
  Future<void> _saveUser(Map<String, dynamic> userData, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user', jsonEncode(userData));

    _token = token;
    _userName = userData['name'] ?? "${userData['f_name']} ${userData['l_name']}";
    _email = userData['email'] ?? "";
    _isLoggedIn = true;
    notifyListeners();
  }

  // Login via API
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await ApiService.loginUser(email, password);

    if (response['status'] == 'success') {
      await _saveUser(response['user'], response['access_token']);
    }

    return response;
  }

  // Register via API
  Future<Map<String, dynamic>> register({
    required String fName,
    required String lName,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await ApiService.registerUser(
      fName: fName,
      lName: lName,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    if (response['status'] == 'success') {
      await _saveUser(response['user'], response['access_token']);
    }

    return response;
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');

    _isLoggedIn = false;
    _userName = "";
    _email = "";
    _token = null;
    notifyListeners();
  }
}
