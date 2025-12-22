import 'package:flutter/material.dart';

class SavedProvider with ChangeNotifier {
  // Internal list of saved scholarships
  final List<Map<String, dynamic>> _savedScholarships = [];

  // Loading state for async operations (optional)
  bool _isLoading = false;

  // ---------------- GETTERS ----------------
  List<Map<String, dynamic>> get savedList => _savedScholarships;
  bool get isLoading => _isLoading;

  // ---------------- SETTERS ----------------
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ---------------- METHODS ----------------

  /// Toggle save/unsave a scholarship
  void toggleSave(Map<String, dynamic> scholarship) {
    if (isSaved(scholarship)) {
      _savedScholarships.removeWhere((item) => item['id'] == scholarship['id']);
    } else {
      _savedScholarships.add(scholarship);
    }
    notifyListeners();
  }

  /// Check if a scholarship is already saved
  bool isSaved(Map<String, dynamic> scholarship) {
    return _savedScholarships.any((item) => item['id'] == scholarship['id']);
  }

  /// Remove a scholarship directly (useful for SavedScholarshipsScreen)
  void remove(Map<String, dynamic> scholarship) {
    _savedScholarships.removeWhere((item) => item['id'] == scholarship['id']);
    notifyListeners();
  }

  /// Clear all saved scholarships
  void clearAll() {
    _savedScholarships.clear();
    notifyListeners();
  }
}
