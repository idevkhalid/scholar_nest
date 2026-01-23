import 'dart:convert'; // ✅ REQUIRED for saving data

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';

class SavedProvider with ChangeNotifier {
  // 1. List of saved scholarship objects (for Saved Screen)
  List<dynamic> _savedScholarships = [];

  // 2. Set of IDs (for Red Hearts)
  final Set<int> _savedIds = {};

  bool _isLoading = false;

  // Getters
  List<dynamic> get savedList => _savedScholarships;
  bool get isLoading => _isLoading;
  Set<int> get savedIds => _savedIds;

  // ---------------------------------------------------------------------------
  // ✅ 1. LOAD DATA (Engine Start)
  // ---------------------------------------------------------------------------
  Future<void> loadLocalData() async {
    print("📂 SavedProvider: Attempting to load local data...");

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData =
      prefs.getString('saved_scholarships_cache');

      if (cachedData != null && cachedData.isNotEmpty) {
        // Decode JSON string back to List
        final List<dynamic> decodedList = json.decode(cachedData);

        _savedScholarships = decodedList;

        // Rebuild the ID set so hearts turn red
        _savedIds.clear();
        for (var item in _savedScholarships) {
          if (item['id'] != null) {
            _savedIds.add(int.parse(item['id'].toString()));
          }
        }

        print(
            "✅ SavedProvider: Loaded ${_savedScholarships.length} items from storage.");
        notifyListeners();
      } else {
        print("⚠️ SavedProvider: No local data found.");
      }
    } catch (e) {
      print("❌ SavedProvider Error loading: $e");
    }
  }

  // ---------------------------------------------------------------------------
  // ✅ 2. SAVE DATA (Write to Disk)
  // ---------------------------------------------------------------------------
  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert List to String
      final String encodedData = json.encode(_savedScholarships);

      await prefs.setString('saved_scholarships_cache', encodedData);
      print(
          "💾 SavedProvider: Saved ${_savedScholarships.length} items to storage.");
    } catch (e) {
      print("❌ SavedProvider Error saving: $e");
    }
  }

  // ---------------------------------------------------------------------------
  // ✅ 3. FETCH FROM API (Background Sync)
  // ---------------------------------------------------------------------------
  Future<void> fetchSavedScholarships(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiService.getSavedScholarships(token);

      if (data.isNotEmpty) {
        _savedScholarships = data;

        // Sync IDs
        _savedIds.clear();
        for (var item in data) {
          if (item['id'] != null) {
            _savedIds.add(int.parse(item['id'].toString()));
          }
        }

        // Save fresh API data to local storage
        _saveToPrefs();
      }
    } catch (e) {
      print("⚠️ SavedProvider API Error: $e");
      // If API fails, we DO NOT clear the list. We keep showing local data.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // ✅ 4. TOGGLE SAVE (The Button Action)
  // ---------------------------------------------------------------------------
  Future<void> toggleSave(dynamic item, String token) async {
    final int id = int.parse(item['id'].toString());
    final bool currentlySaved = _savedIds.contains(id);

    // --- A. OPTIMISTIC UPDATE (Instant) ---
    if (currentlySaved) {
      _savedIds.remove(id);
      _savedScholarships
          .removeWhere((s) => s['id'].toString() == id.toString());
    } else {
      _savedIds.add(id);
      _savedScholarships.add(item);
    }

    notifyListeners();
    _saveToPrefs(); // <--- CRITICAL: Save to disk immediately

    // --- B. API CALL (Background) ---
    try {
      final response =
      await ApiService.toggleSaveScholarship(id, token);

      if (response['status'] != 'success') {
        throw Exception("API Status not success");
      }
    } catch (e) {
      print("❌ API Failed, Reverting: $e");

      // Revert if API fails
      if (currentlySaved) {
        _savedIds.add(id);
        _savedScholarships.add(item);
      } else {
        _savedIds.remove(id);
        _savedScholarships
            .removeWhere((s) => s['id'].toString() == id.toString());
      }

      notifyListeners();
      _saveToPrefs();
    }
  }

  // ---------------------------------------------------------------------------
  // Helper
  // ---------------------------------------------------------------------------
  bool isSaved(dynamic item) {
    if (item == null || item['id'] == null) return false;

    final int id = int.tryParse(item['id'].toString()) ?? -1;
    return _savedIds.contains(id);
  }

  // ---------------------------------------------------------------------------
  // Logout Clear
  // ---------------------------------------------------------------------------
  void clearAll() async {
    _savedScholarships.clear();
    _savedIds.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_scholarships_cache');

    notifyListeners();
  }
}
