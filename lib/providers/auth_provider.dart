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

  // --- 1. Load User from Local Storage ---
  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    // WE USE 'access_token' HERE TO MATCH API SERVICE
    final savedToken = prefs.getString('access_token');
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

  // --- 2. Save User to Local Storage ---
  Future<void> _saveUser(Map<String, dynamic> userData, String token) async {
    final prefs = await SharedPreferences.getInstance();
    // SAVE AS 'access_token'
    await prefs.setString('access_token', token);
    await prefs.setString('user', jsonEncode(userData));

    _token = token;
    _userName = userData['name'] ??
        "${userData['f_name'] ?? ''} ${userData['l_name'] ?? ''}".trim();

    if (_userName.isEmpty) _userName = "User";

    _email = userData['email'] ?? "";
    _isLoggedIn = true;
    notifyListeners();
  }

  // --- 3. Login ---
  Future<bool> login(String email, String password) async {
    try {
      final response = await ApiService.loginUser(email, password);

      if (response['status'] == 'success') {
        final data = response;
        // Ensure we handle the response structure correctly
        String token = data['access_token'];
        Map<String, dynamic> user = data['user'];

        await _saveUser(user, token);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Login error: $e");
      return false;
    }
  }

  // --- 4. Register ---
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

      if (response['status'] == 'success') {
        final data = response;
        String token = data['access_token'];
        Map<String, dynamic> user = data['user'];

        await _saveUser(user, token);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Register error: $e");
      return false;
    }
  }

  // --- 5. Logout (Single Device) ---
  Future<void> logout() async {
    try {
      await ApiService.logout();
    } catch (e) {
      debugPrint("Logout API error: $e");
    }
    await _clearLocalData();
  }

  // --- 6. Logout All Devices (FIXED: Added this method back) ---
  Future<void> logoutAllDevices() async {
    try {
      await ApiService.logoutAll();
    } catch (e) {
      debugPrint("LogoutAll API error: $e");
    }
    await _clearLocalData();
  }

  // --- Helper: Clear Data ---
  Future<void> _clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user');

    // ADD THIS LINE: Clear the detailed profile cache too
    await prefs.remove('user_profile');

    _isLoggedIn = false;
    _userName = "";
    _email = "";
    _token = null;
    notifyListeners();
  }
}