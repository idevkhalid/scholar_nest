import 'package:flutter/material.dart';

class SavedProvider with ChangeNotifier {
  final List<Map<String, String>> _savedScholarships = [];

  List<Map<String, String>> get savedScholarships => _savedScholarships;

  void toggleSave(Map<String, String> scholarship) {
    if (_savedScholarships.contains(scholarship)) {
      _savedScholarships.remove(scholarship);
    } else {
      _savedScholarships.add(scholarship);
    }
    notifyListeners();
  }

  bool isSaved(Map<String, String> scholarship) {
    return _savedScholarships.contains(scholarship);
  }
}
