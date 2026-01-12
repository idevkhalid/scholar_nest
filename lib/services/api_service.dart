import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String mainBaseUrl = "https://scholarnest.codessol.com/api";
  static const String authBaseUrl = "$mainBaseUrl/auth";
  static const String baseUrl = authBaseUrl; // alias


  // ===========================================================================
  // AUTHENTICATION METHODS
  // ===========================================================================

  static Future<Map<String, dynamic>> registerUser({
    required String fName,
    required String lName,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final url = Uri.parse('$authBaseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode({
          "f_name": fName,
          "l_name": lName,
          "email": email,
          "password": password,
          "password_confirmation": passwordConfirmation,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data["access_token"] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', data["access_token"]);
        }
        return {
          "status": "success",
          "message": data["message"],
          "user": data["user"],
          "access_token": data["access_token"],
        };
      } else {
        return {
          "status": "error",
          "message": data["message"] ?? "Registration failed",
        };
      }
    } catch (e) {
      return {"status": "error", "message": "Connection error: $e"};
    }
  }

  static Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final url = Uri.parse('$authBaseUrl/login');
    final cleanEmail = email.trim();
    final cleanPassword = password.trim();

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "email": cleanEmail,
          "password": cleanPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data["access_token"] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', data["access_token"]);
        }

        return {
          "status": "success",
          "message": data["message"],
          "user": data["user"],
          "access_token": data["access_token"],
        };
      } else {
        return {
          "status": "error",
          "message": data["message"] ?? "Login failed",
        };
      }
    } catch (e) {
      return {"status": "error", "message": "Connection error: $e"};
    }
  }

  static Future<Map<String, dynamic>> logout() async {
    final url = Uri.parse('$authBaseUrl/logout');

    try {
      final headers = await _getHeaders();
      final response = await http.post(url, headers: headers);

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      // Also clear cached profile on logout
      await prefs.remove('user_profile');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {"status": "success", "message": data["message"]};
      } else {
        return {"status": "error", "message": "Logout failed on server"};
      }
    } catch (e) {
      return {"status": "error", "message": "Connection error"};
    }
  }

  static Future<Map<String, dynamic>> logoutAll() async {
    final url = Uri.parse('$authBaseUrl/logoutAll');

    try {
      final headers = await _getHeaders();
      final response = await http.post(url, headers: headers);

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('user_profile');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {"status": "success", "message": data["message"]};
      } else {
        return {"status": "error", "message": "Logout all failed"};
      }
    } catch (e) {
      return {"status": "error", "message": "Connection error"};
    }
  }

  // ===========================================================================
  // PASSWORD MANAGEMENT
  // ===========================================================================

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl/forgot-password');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      return {"status": "error", "message": data["message"] ?? "Something went wrong"};
    }
    return {"status": "success", "message": data["message"]};
  }

  static Future<Map<String, dynamic>> verifyOtp({required String email, required String otp}) async {
    final url = Uri.parse('$baseUrl/verify-otp');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp_code": otp}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      return {"status": "error", "message": data["message"] ?? "OTP verification failed"};
    }
    return {"status": data["status"], "message": data["message"]};
  }

  static Future<Map<String, dynamic>> resendOtp(String email) async {
    final url = Uri.parse('$baseUrl/resend-otp');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      return {"status": "error", "message": data["message"] ?? "Failed to resend OTP"};
    }
    return {"status": data["status"], "message": data["message"]};
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    final url = Uri.parse('$baseUrl/reset-password');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode({
          "email": email,
          "otp": otp,
          "otp_code": otp, // Redundancy for safety
          "token": otp,
          "password": password,
          "password_confirmation": passwordConfirmation,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {"status": "success", "message": data["message"] ?? "Password reset successfully"};
      } else {
        return {"status": "error", "message": data["message"] ?? "Password reset failed"};
      }
    } catch (e) {
      return {"status": "error", "message": "Connection error. Please try again."};
    }
  }

  // --- Helper: Get Headers ---
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }


  // ===========================================================================
  // CONSULTANTS & REVIEWS
  // ===========================================================================

  static Future<Map<String, dynamic>> getConsultantDetails(int consultantId) async {
    final url = Uri.parse('$mainBaseUrl/consultants/$consultantId');
    try {
      final response = await http.get(url, headers: {"Content-Type": "application/json"});
      return response.statusCode == 200 ? jsonDecode(response.body) : {"status": "error", "message": "Server Error"};
    } catch (e) {
      return {"status": "error", "message": "Connection failed"};
    }
  }

  static Future<Map<String, dynamic>> getConsultantReviews(int consultantId, {int page = 1}) async {
    final url = Uri.parse('$mainBaseUrl/consultants/$consultantId/reviews?page=$page');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      return {"status": "error", "message": "Failed to load reviews"};
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> submitReview({
    required int consultantId,
    required int rating,
    required String comment,
  }) async {
    final url = Uri.parse('$mainBaseUrl/consultants/$consultantId/reviews');
    final headers = await _getHeaders();

    if (!headers.containsKey('Authorization')) {
      return {"status": "error", "message": "Unauthenticated"};
    }

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          "rating": rating,
          "consultant_id": consultantId,
          "comment": comment,
          "review": comment,
          "message": comment,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"status": "success", "message": "Review submitted successfully"};
      } else if (response.statusCode == 409) {
        return {"status": "error", "message": "You have already reviewed this consultant"};
      } else {
        return {"status": "error", "message": data["message"] ?? "Submission failed"};
      }
    } catch (e) {
      return {"status": "error", "message": "Connection error"};
    }
  }

  static Future<bool> addReaction(int reviewId, String type) async {
    if (reviewId == 0) return false;
    final url = Uri.parse('$mainBaseUrl/reviews/$reviewId/reactions');
    final headers = await _getHeaders();

    if (!headers.containsKey('Authorization')) return false;

    String reactionValue = type.toLowerCase();
    if (!['like', 'dislike', 'helpful'].contains(reactionValue)) {
      reactionValue = 'helpful';
    }

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({"reaction": reactionValue}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> removeReaction(int reviewId) async {
    final url = Uri.parse('$mainBaseUrl/reviews/$reviewId/reactions');
    final headers = await _getHeaders();

    if (!headers.containsKey('Authorization')) return false;

    try {
      final response = await http.delete(url, headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ===========================================================================
  // SCHOLARSHIPS
  // ===========================================================================

  static Future<Map<String, dynamic>> getAllScholarships({int page = 1}) async {
    final url = Uri.parse('$mainBaseUrl/scholarships?page=$page');
    final response = await http.get(url, headers: {"Content-Type": "application/json"});
    final data = jsonDecode(response.body);
    return response.statusCode == 200 ? data : {"status": "error", "message": data["message"] ?? "Failed"};
  }

  static Future<Map<String, dynamic>> getScholarshipDetails(int id) async {
    final url = Uri.parse('$mainBaseUrl/scholarships/$id');
    final response = await http.get(url, headers: {"Content-Type": "application/json"});
    final data = jsonDecode(response.body);
    return response.statusCode == 200 ? data : {"status": "error", "message": data["message"] ?? "Failed"};
  }

  static Future<Map<String, dynamic>> getFeaturedScholarships() async {
    final url = Uri.parse('$mainBaseUrl/scholarships/featured');
    final response = await http.get(url, headers: {"Content-Type": "application/json"});
    final data = jsonDecode(response.body);
    return response.statusCode == 200 ? data : {"status": "error", "message": data["message"] ?? "Failed"};
  }

  static Future<Map<String, dynamic>> toggleSaveScholarship(int id, String token) async {
    final headers = await _getHeaders();
    final response = await http.post(Uri.parse('$mainBaseUrl/scholarships/$id/save'), headers: headers);
    final data = jsonDecode(response.body);
    return response.statusCode == 200 ? data : {"status": "error", "message": data["message"] ?? "Failed"};
  }

  static Future<Map<String, dynamic>> searchScholarships({
    required String query,
    String? category,
    String? country,
    int? minAmount,
    int? maxAmount,
    String? degreeLevel,
    List<String>? fieldOfStudy,
    String? deadlineRange,
    String? sortBy,
    String? sortOrder,
    int page = 1,
    int perPage = 20,
  }) async {
    final url = Uri.parse("$mainBaseUrl/scholarships/search");
    final body = {
      "query": query,
      if (category != null) "category": category,
      if (country != null) "country": country,
      if (minAmount != null) "min_amount": minAmount,
      if (maxAmount != null) "max_amount": maxAmount,
      if (degreeLevel != null) "degree_level": degreeLevel,
      if (fieldOfStudy != null) "field_of_study": fieldOfStudy,
      if (deadlineRange != null) "deadline_range": deadlineRange,
      if (sortBy != null) "sort_by": sortBy,
      if (sortOrder != null) "sort_order": sortOrder,
      "page": page,
      "per_page": perPage,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"status": "error", "message": "Failed to search scholarships"};
      }
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }
// ---------------------------------------------------------
  // 4. GET PROFESSORS (DEBUG VERSION)
  // ---------------------------------------------------------
  static Future<Map<String, dynamic>> getProfessors({int page = 1}) async {
    final url = Uri.parse('$mainBaseUrl/professors?page=$page');

    print("------------------------------------------------");
    print("🚀 API REQUEST: $url");

    try {
      final headers = await _getHeaders();
      // Debug: Check if token exists
      if (headers['Authorization'] == null) {
        print("⚠️ WARNING: No Auth Token found!");
      }

      final response = await http.get(url, headers: headers);

      print("📡 STATUS CODE: ${response.statusCode}");
      print("📦 BODY: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Correct path based on your provided JSON
        final List<dynamic> professorList = data['data']['data'] ?? [];

        return {
          "status": "success",
          "data": professorList,
        };
      } else {
        return {"status": "error", "message": data["message"] ?? "Error ${response.statusCode}"};
      }
    } catch (e) {
      print("❌ EXCEPTION: $e");
      return {"status": "error", "message": "Connection error"};
    }
  }
  // ---------------------------------------------------------
  // 5. GET SINGLE PROFESSOR DETAILS
  // ---------------------------------------------------------
  static Future<Map<String, dynamic>> getProfessorById(int id) async {
    final url = Uri.parse('$mainBaseUrl/professors/$id');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "status": "success",
          "data": data['data'], // The professor object is inside 'data'
        };
      } else {
        return {
          "status": "error",
          "message": data["message"] ?? "Failed to load details"
        };
      }
    } catch (e) {
      return {"status": "error", "message": "Connection error: $e"};
    }
  }
  // ---------------------------------------------------------
  // 6. GET GUIDELINE VIDEOS (With Search)
  // ---------------------------------------------------------
  static Future<Map<String, dynamic>> getGuidelineVideos({String? query}) async {
    // If query exists, append it to URL: .../apply-guideline-videos?search=scholarship
    String baseUrl = '$mainBaseUrl/apply-guideline-videos';
    if (query != null && query.isNotEmpty) {
      baseUrl += '?search=$query';
    }

    final url = Uri.parse(baseUrl);

    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "status": "success",
          "data": data['data']['data'] ?? [],
        };
      } else {
        return {
          "status": "error",
          "message": data["message"] ?? "Failed to load videos"
        };
      }
    } catch (e) {
      return {"status": "error", "message": "Connection error: $e"};
    }
  }
  // ---------------------------------------------------------
  // ---------------------------------------------------------
  // 11. GET ALL CONSULTANTS (Fixed for Pagination)
  // ---------------------------------------------------------
  static Future<Map<String, dynamic>> getAllConsultants({String? query, int page = 1}) async {
    String baseUrl = '$mainBaseUrl/consultants?page=$page';
    if (query != null && query.isNotEmpty) {
      baseUrl += '&search=$query';
    }

    final url = Uri.parse(baseUrl);
    try {
      final headers = await _getHeaders();
      print("DEBUG: Fetching consultants from $url");

      final response = await http.get(url, headers: headers);
      print("DEBUG: Response Status: ${response.statusCode}");
      print("DEBUG: Response Body: ${response.body}"); // <--- Check your console for this!

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && (data['status'] == 'success' || data['success'] == true)) {

        var fetchedData = data['data'];
        List<dynamic> finalList = [];

        // CHECK 1: Is it a Paginated Response? (Map with a 'data' key inside)
        if (fetchedData is Map<String, dynamic> && fetchedData.containsKey('data')) {
          finalList = fetchedData['data'];
        }
        // CHECK 2: Is it a direct List?
        else if (fetchedData is List) {
          finalList = fetchedData;
        }

        return {
          "status": "success",
          "data": finalList,
        };
      } else {
        return {"status": "error", "message": data['message'] ?? "Failed to load"};
      }
    } catch (e) {
      print("DEBUG: Error in getAllConsultants: $e");
      return {"status": "error", "message": "Connection error"};
    }
  }
  // ---------------------------------------------------------
  // 12. GET TOP RATED CONSULTANTS
  // ---------------------------------------------------------
  static Future<Map<String, dynamic>> getTopRatedConsultants() async {
    final url = Uri.parse('$mainBaseUrl/consultants/top-rated?limit=5');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        return {
          "status": "success",
          "data": data['data'] ?? [],
        };
      } else {
        return {"status": "error", "message": "Failed to load top rated"};
      }
    } catch (e) {
      return {"status": "error", "message": "Connection error"};
    }
  }
  // ---------------------------------------------------------
  // 13. SUBMIT CONTACT FORM
  // ---------------------------------------------------------
  static Future<Map<String, dynamic>> submitContactForm({
    required String fullName,
    required String contactNumber,
    required String email,
    required String message,
  }) async {
    final url = Uri.parse('$mainBaseUrl/contact/submit');

    try {
      final headers = await _getHeaders(); // Includes token if logged in
      final body = jsonEncode({
        "full_name": fullName,
        "contact_number": contactNumber,
        "email_address": email,
        "message": message,
      });

      final response = await http.post(url, headers: headers, body: body);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "status": "success",
          "message": data['message'] ?? "Message sent successfully",
        };
      } else if (response.statusCode == 422) {
        // Handle validation errors (e.g., email already taken or invalid format)
        final errors = data['errors'];
        String errorMessage = data['message'];

        // If there are specific field errors, try to grab the first one
        if (errors != null && errors is Map) {
          final firstKey = errors.keys.first;
          if (errors[firstKey] is List && errors[firstKey].isNotEmpty) {
            errorMessage = errors[firstKey][0];
          }
        }
        return {"status": "error", "message": errorMessage};
      } else {
        return {"status": "error", "message": data['message'] ?? "Something went wrong"};
      }
    } catch (e) {
      return {"status": "error", "message": "Connection error. Please check your internet."};
    }
  }
  // ---------------------------------------------------------
  // 14. GET USER PROFILE
  // ---------------------------------------------------------
  static Future<Map<String, dynamic>> getUserProfile() async {
    // Ensure this matches your variable name (baseUrl or mainBaseUrl)
    final url = Uri.parse('$mainBaseUrl/user/profile');

    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      // DEBUG LOG: See what the server actually sends
      print("PROFILE API: ${response.statusCode} - ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Safe check: ensure 'profile' exists, otherwise send empty map
        final profileData = data['profile'] ?? data['data'] ?? {};

        return {
          "status": "success",
          "data": profileData,
          "completion": data['completion_percentage'] ?? 0,
          "missing": data['missing_fields'] ?? []
        };
      } else {
        return {
          "status": "error",
          "message": data['message'] ?? "Failed to load profile"
        };
      }
    } catch (e) {
      print("PROFILE ERROR: $e");
      return {"status": "error", "message": "Connection error: $e"};
    }
  }


  // ---------------------------------------------------------
  // 15. UPDATE USER PROFILE (Using PUT)
  // ---------------------------------------------------------
  static Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> profileData) async {
    final url = Uri.parse('$mainBaseUrl/user/profile');
    try {
      final headers = await _getHeaders();
      final body = jsonEncode(profileData);

      // Changed from http.post to http.put
      final response = await http.put(url, headers: headers, body: body);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "status": "success",
          "message": data['message'] ?? "Profile updated",
          "data": data['profile']
        };
      } else {
        // Handle validation errors
        String message = data['message'] ?? "Update failed";
        if (data['errors'] != null) {
          // Extract the first error message available
          if (data['errors'] is Map) {
            final firstError = data['errors'].values.first;
            if (firstError is List && firstError.isNotEmpty) {
              message = firstError[0];
            }
          }
        }
        return {"status": "error", "message": message};
      }
    } catch (e) {
      return {"status": "error", "message": "Connection error"};
    }
  }
  // --- UPDATED APPLY METHOD ---
  static Future<Map<String, dynamic>> applyForScholarship({
    required int consultantId,
    required int scholarshipId,
  }) async {
    // 1. URL: Use mainBaseUrl (No /auth)
    final url = Uri.parse("$mainBaseUrl/apply-to-consultant");

    // 2. HEADERS: Use your existing helper to get the correct 'access_token'
    final headers = await _getHeaders();

    // Debug check: Ensure Authorization header exists
    if (!headers.containsKey('Authorization')) {
      return {"success": false, "message": "User not logged in (Token missing)"};
    }

    try {
      print("Attempting to apply...");
      print("URL: $url");

      final response = await http.post(
        url,
        headers: headers, // Uses the headers from your helper
        body: jsonEncode({
          "consultant_id": consultantId,
          "scholarship_id": scholarshipId,
        }),
      );

      print("Status Code: ${response.statusCode}");

      // 3. Handle HTML errors safely
      if (response.headers['content-type']?.contains('html') == true) {
        return {"success": false, "message": "Server returned HTML error (Status: ${response.statusCode})"};
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          "success": true,
          "message": data['message'] ?? "Application submitted successfully"
        };
      } else {
        return {
          "success": false,
          "message": data['message'] ?? "Failed with status ${response.statusCode}"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Network Error: $e"};
    }
  }
  // --- DELETE ACCOUNT ---
  static Future<Map<String, dynamic>> deleteAccount(String password) async {
    // URL: https://scholarnest.codessol.com/api/auth/delete-account
    final url = Uri.parse('$authBaseUrl/delete-account');

    try {
      final headers = await _getHeaders();

      // The http.delete method supports a body, which is required by your API
      final response = await http.delete(
        url,
        headers: headers,
        body: jsonEncode({
          "password": password
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "status": "success",
          "message": data["message"] ?? "Account deleted successfully."
        };
      } else if (response.statusCode == 401) {
        return {
          "status": "error",
          "message": "Invalid password. Please try again."
        };
      } else {
        return {
          "status": "error",
          "message": data["message"] ?? "Failed to delete account."
        };
      }
    } catch (e) {
      return {"status": "error", "message": "Connection error: $e"};
    }
  }
  // 3. RESTORE ACCOUNT
  static Future<Map<String, dynamic>> restoreAccount({
    required String email,
    required String password,
  }) async {
    // This uses a public endpoint, so we don't need _getHeaders() (No token needed)
    try {
      final response = await http.post(
        Uri.parse('$authBaseUrl/restore-account'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': 'success',
          'message': data['message'] ?? 'Account restored successfully'
        };
      }
      else if (response.statusCode == 410) {
        return {
          'status': 'error',
          'message': data['message'] ??
              'Account permanently deleted. Cannot restore.'
        };
      }
      else {
        return {
          'status': 'error',
          'message': data['message'] ?? 'Restoration failed'
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Network error: $e'};
    }
  }
  }