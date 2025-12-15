import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://scholarnest.codessol.com/api/auth";

  // -------------------------
  // REGISTER USER
  // -------------------------
  static Future<Map<String, dynamic>> registerUser({
    required String fName,
    required String lName,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final url = Uri.parse('$baseUrl/register');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "f_name": fName,
        "l_name": lName,
        "email": email,
        "password": password,
        "password_confirmation": passwordConfirmation,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 201) {
      return {
        "status": "error",
        "message": data["message"] ?? "Registration failed",
      };
    }

    return {
      "status": data["status"],
      "message": data["message"],
      "user": data["user"],
      "access_token": data["access_token"],
      "token_type": data["token_type"],
    };
  }

  // -------------------------
  // LOGIN
  // -------------------------
  static Future<Map<String, dynamic>> loginUser(
      String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      return {
        "status": "error",
        "message": data["message"] ?? "Login failed",
      };
    }

    return {
      "status": "success",
      "message": data["message"],
      "user": data["user"],
      "access_token": data["access_token"],
      "token_type": data["token_type"],
    };
  }

  // -------------------------
  // FORGOT PASSWORD
  // -------------------------
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl/forgot-password');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      return {
        "status": "error",
        "message": data["message"] ?? "Something went wrong",
      };
    }

    return {
      "status": "success",
      "message": data["message"],
    };
  }

  // -------------------------
  // VERIFY OTP
  // -------------------------
  static Future<Map<String, dynamic>> verifyOtp(
      {required String email, required String otp}) async {
    final url = Uri.parse('$baseUrl/verify-otp');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "otp_code": otp,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      return {
        "status": "error",
        "message": data["message"] ?? "OTP verification failed",
      };
    }

    return {
      "status": data["status"],
      "message": data["message"],
    };
  }

  // -------------------------
  // RESEND OTP
  // -------------------------
  static Future<Map<String, dynamic>> resendOtp(String email) async {
    final url = Uri.parse('$baseUrl/resend-otp');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      return {
        "status": "error",
        "message": data["message"] ?? "Failed to resend OTP",
      };
    }

    return {
      "status": data["status"],
      "message": data["message"],
    };
  }

  // -------------------------
// RESET PASSWORD
// -------------------------
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    final url = Uri.parse('$baseUrl/reset-password');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "otp_code": otp,
        "password": password,
        "password_confirmation": passwordConfirmation,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      return {
        "status": "error",
        "message": data["message"] ?? "Password reset failed",
      };
    }

    return {
      "status": data["status"],
      "message": data["message"],
    };
  }

  // -------------------------
// REFRESH TOKEN
// -------------------------
  static Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final url = Uri.parse('$baseUrl/refresh-token');

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $refreshToken",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      return {
        "status": "error",
        "message": data["message"] ?? "Token refresh failed",
      };
    }

    return {
      "status": data["status"],
      "access_token": data["access_token"],
      "token_type": data["token_type"],
      "expires_in": data["expires_in"],
    };
  }

  // -------------------------
// LOGOUT (CURRENT DEVICE)
// -------------------------
  static Future<Map<String, dynamic>> logout(String accessToken) async {
    final url = Uri.parse('$baseUrl/logout');

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      return {
        "status": "error",
        "message": data["message"] ?? "Logout failed",
      };
    }

    return {
      "status": data["status"],
      "message": data["message"],
    };
  }

// -------------------------
// LOGOUT FROM ALL DEVICES
// -------------------------
  static Future<Map<String, dynamic>> logoutAll(String accessToken) async {
    final url = Uri.parse('$baseUrl/logoutAll');

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      return {
        "status": "error",
        "message": data["message"] ?? "Logout all failed",
      };
    }

    return {
      "status": data["status"],
      "message": data["message"],
    };
  }
// -------------------------
// VERIFY PASSWORD
// -------------------------
  static Future<Map<String, dynamic>> verifyPassword({
    required String email,
    required String password,
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/verify-password'); // make sure this endpoint exists in your backend

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      return {
        "status": "error",
        "message": data["message"] ?? "Password verification failed",
      };
    }

    return {
      "status": data["status"],
      "message": data["message"],
    };
  }



}
