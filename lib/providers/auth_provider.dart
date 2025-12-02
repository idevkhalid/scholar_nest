import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;

  String _userName = "";
  String _email = "";

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get email => _email;

  // Mock login function
  void login(String username, String mail) {
    _isLoggedIn = true;
    _userName = username;
    _email = mail;

    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userName = "";
    _email = "";
    notifyListeners();
  }
}
