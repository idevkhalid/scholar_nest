import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://scholarnest.codessol.com/api/auth";

  // Register
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

    // Handle errors
    if (response.statusCode != 201) {
      return {
        "status": "error",
        "message": data["message"] ?? "Registration failed",
      };
    }

    // Success: just return response
    return {
      "status": data["status"],
      "message": data["message"],
      "user": data["user"],
      "access_token": data["access_token"],
      "token_type": data["token_type"],
    };
  }


  // Login
  static Future<Map<String, dynamic>> loginUser(String email, String password) async {
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

    // Handle error status code
    if (response.statusCode != 200) {
      return {
        "status": "error",
        "message": data["message"] ?? "Login failed. Something went wrong.",
      };
    }

    // Success
    return {
      "status": "success",
      "message": data["message"],
      "user": data["user"],
      "access_token": data["access_token"],
      "token_type": data["token_type"],
    };
  }

  // Forgot password
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl/forgot-password');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    final data = jsonDecode(response.body);

    // If email not found or server error
    if (response.statusCode != 200) {
      return {
        "status": "error",
        "message": data["message"] ?? "Something went wrong",
      };
    }

    // Success
    return {
      "status": "success",
      "message": data["message"],
    };
  }

  // Verify OTP
  static Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
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

    // Handle errors
    if (response.statusCode != 200) {
      return {
        "status": "error",
        "message": data["message"] ?? "OTP verification failed",
      };
    }

    // Success
    return {
      "status": data["status"],
      "message": data["message"],
    };
  }

  // Resend OTP
  static Future<Map<String, dynamic>> resendOtp(String email) async {
    final url = Uri.parse('$baseUrl/resend-otp');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    final data = jsonDecode(response.body);

    // Handle errors
    if (response.statusCode != 200) {
      return {
        "status": "error",
        "message": data["message"] ?? "Failed to resend OTP",
      };
    }

    // Success
    return {
      "status": data["status"],
      "message": data["message"],
    };
  }


}
