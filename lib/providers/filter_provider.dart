import 'package:flutter/material.dart';

class FilterProvider with ChangeNotifier {
  String _country = 'All Countries';
  String _degree = 'All Degrees';
  String _major = 'All Majors';

  String get country => _country;
  String get degree => _degree;
  String get major => _major;

  void setCountry(String value) {
    _country = value;
    notifyListeners();
  }

  void setDegree(String value) {
    _degree = value;
    notifyListeners();
  }

  void setMajor(String value) {
    _major = value;
    notifyListeners();
  }

  void reset() {}
}
