import 'package:flutter/material.dart';

class SavedProvider with ChangeNotifier {
  final List<Map<String, String>> _savedScholarships = [];

  // Getter to access the saved scholarships
  List<Map<String, String>> get savedList => _savedScholarships;

  // Toggle save/unsave a scholarship
  void toggleSave(Map<String, String> scholarship) {
    if (isSaved(scholarship)) {
      _savedScholarships.removeWhere((item) => item['title'] == scholarship['title']);
    } else {
      _savedScholarships.add(scholarship);
    }
    notifyListeners();
  }

  // Check if a scholarship is already saved
  bool isSaved(Map<String, String> scholarship) {
    return _savedScholarships.any((item) => item['title'] == scholarship['title']);
  }

  // Remove a scholarship directly (useful for SavedScholarshipsScreen)
  void remove(Map<String, String> scholarship) {
    _savedScholarships.removeWhere((item) => item['title'] == scholarship['title']);
    notifyListeners();
  }
}
