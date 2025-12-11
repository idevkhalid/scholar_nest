import 'package:flutter/material.dart';

class SavedProvider with ChangeNotifier {
  // Internal list of saved scholarships
  final List<Map<String, String>> _savedScholarships = [];

  // Loading state for async operations (optional)
  bool _isLoading = false;

  // ---------------- GETTERS ----------------
  List<Map<String, String>> get savedList => _savedScholarships;
  bool get isLoading => _isLoading;

  // ---------------- SETTERS ----------------
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ---------------- METHODS ----------------

  /// Toggle save/unsave a scholarship
  void toggleSave(Map<String, String> scholarship) {
    if (isSaved(scholarship)) {
      _savedScholarships.removeWhere((item) => item['title'] == scholarship['title']);
    } else {
      _savedScholarships.add(scholarship);
    }
    notifyListeners();
  }

  /// Check if a scholarship is already saved
  bool isSaved(Map<String, String> scholarship) {
    return _savedScholarships.any((item) => item['title'] == scholarship['title']);
  }

  /// Remove a scholarship directly (useful for SavedScholarshipsScreen)
  void remove(Map<String, String> scholarship) {
    _savedScholarships.removeWhere((item) => item['title'] == scholarship['title']);
    notifyListeners();
  }

  /// Clear all saved scholarships
  void clearAll() {
    _savedScholarships.clear();
    notifyListeners();
  }
}
