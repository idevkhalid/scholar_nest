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
  String get userToken => _token ?? "";

  AuthProvider() {
    _loadUser();
  }

  // BUG FIX: Added try-catch to prevent crashes on corrupted local data
  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token');
    final savedUser = prefs.getString('user');

    if (savedToken != null && savedUser != null) {
      try {
        final userData = jsonDecode(savedUser);
        _token = savedToken;
        _userName = userData['name'] ??
            "${userData['f_name'] ?? ''} ${userData['l_name'] ?? ''}".trim();
        _email = userData['email'] ?? "";
        _isLoggedIn = true;
        notifyListeners();
      } catch (e) {
        debugPrint("Error loading local user: $e");
        await _clearLocalData();
      }
    }
  }

  // BUG FIX: Handled empty f_name/l_name to avoid "null null" strings
  Future<void> _saveUser(Map<String, dynamic> userData, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user', jsonEncode(userData));

    _token = token;
    _userName = userData['name'] ??
        "${userData['f_name'] ?? ''} ${userData['l_name'] ?? ''}".trim();

    if (_userName.isEmpty) _userName = "User"; // Fallback name

    _email = userData['email'] ?? "";
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await ApiService.loginUser(email, password);

      if (response['status'] == 'success' || response['access_token'] != null) {
        await _saveUser(response['user'], response['access_token']);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Login error: $e");
      return false;
    }
  }

  Future<bool> register({
    required String fName,
    required String lName,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await ApiService.registerUser(
        fName: fName,
        lName: lName,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      // BUG FIX: Checking both status and existence of token for robustness
      if (response['status'] == 'success' || response['access_token'] != null) {
        await _saveUser(response['user'], response['access_token']);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Register error: $e");
      return false;
    }
  }

  Future<void> logout() async {
    if (_token != null) {
      try {
        await ApiService.logout(_token!);
      } catch (e) {
        debugPrint("Logout API error: $e");
      }
    }
    await _clearLocalData();
  }

  Future<void> logoutAllDevices() async {
    if (_token != null) {
      try {
        await ApiService.logoutAll(_token!);
      } catch (e) {
        debugPrint("LogoutAll API error: $e");
      }
    }
    await _clearLocalData();
  }

  Future<void> _clearLocalData() async {
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