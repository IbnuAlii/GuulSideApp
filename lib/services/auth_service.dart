import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'network_service.dart';

class AuthService {
  static String baseUrl = 'http://10.0.2.2:5000/api';
  static const int timeout = 60;
  static const int maxRetries = 5;

  static void configureBaseUrl(String url) {
    baseUrl = url;
  }

  Future<T> _retryOperation<T>(Future<T> Function() operation) async {
    int attempts = 0;
    const initialBackoff = 1000;

    while (attempts < maxRetries) {
      try {
        print('Attempting operation, attempt ${attempts + 1}');
        if (!await NetworkService.checkConnectivity()) {
          print('No network connection. Waiting for connection...');
          await NetworkService.waitForConnection();
        }

        return await operation();
      } on TimeoutException catch (e) {
        attempts++;
        print('Operation timed out: $e');
        if (attempts == maxRetries) {
          throw Exception('Operation timed out after $maxRetries attempts');
        }
      } catch (e) {
        attempts++;
        print('Operation failed: $e');
        if (attempts == maxRetries) {
          throw Exception('Operation failed after $maxRetries attempts: $e');
        }
      }

      final backoff = initialBackoff * math.pow(2, attempts - 1).toInt();
      print('Attempt $attempts failed. Retrying in ${backoff}ms...');
      await Future.delayed(Duration(milliseconds: backoff));
    }
    throw Exception('This should never be reached');
  }

  Future<String> signIn(String email, String password) async {
    return _retryOperation(() async {
      try {
        print('Attempting to sign in with email: $email');
        final response = await http
            .post(
              Uri.parse('$baseUrl/auth/signin'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'email': email,
                'password': password,
              }),
            )
            .timeout(Duration(seconds: timeout));

        print('Sign in response status code: ${response.statusCode}');
        print('Sign in response body: ${response.body}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final token = data['token'];
          if (token == null) {
            throw Exception('Token not found in response');
          }
          await _saveToken(token);
          print('Sign in successful. Token saved.');
          return token;
        } else {
          throw Exception(
              'Server error: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('Sign in error: $e');
        rethrow;
      }
    });
  }

  Future<String> signUp(String name, String email, String password) async {
    return _retryOperation(() async {
      try {
        print('Sending sign up request to $baseUrl/auth/signup');
        print('Sign up data: name=$name, email=$email');
        final response = await http
            .post(
              Uri.parse('$baseUrl/auth/signup'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'name': name,
                'email': email,
                'password': password,
              }),
            )
            .timeout(Duration(seconds: timeout));

        print('Sign up response status code: ${response.statusCode}');
        print('Sign up response body: ${response.body}');

        if (response.statusCode == 201) {
          final data = json.decode(response.body);
          final token = data['token'];
          if (token == null) {
            throw Exception('Token not found in sign-up response');
          }
          await _saveToken(token);
          print('Sign up successful. Token saved.');
          return token;
        } else {
          throw Exception(
              'Server error during sign up: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('Sign up error: $e');
        rethrow;
      }
    });
  }

  Future<bool> isSignedIn() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      return _retryOperation(() async {
        final response = await http.get(
          Uri.parse('$baseUrl/auth/verify'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(Duration(seconds: timeout));

        return response.statusCode == 200;
      });
    } catch (e) {
      print('Token verification error: $e');
      return false;
    }
  }

  Future<User> getCurrentUser() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    return _retryOperation(() async {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/auth/me'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(Duration(seconds: timeout));

        print('Get current user response status code: ${response.statusCode}');
        print('Get current user response body: ${response.body}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data == null) {
            throw Exception('No user data received from server');
          }

          try {
            return User.fromJson(data);
          } catch (e) {
            print('Error parsing user data: $e');
            throw Exception('Failed to parse user data: $e');
          }
        } else {
          throw Exception(
              'Failed to get user data: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('Get current user error: $e');
        rethrow;
      }
    });
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      final token = await getToken();
      if (token != null) {
        try {
          await _retryOperation(() async {
            await http.post(
              Uri.parse('$baseUrl/auth/signout'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
            ).timeout(Duration(seconds: timeout));
          });
        } catch (e) {
          print('Error calling signout endpoint: $e');
        }
      }
      await _removeToken();
    } catch (e) {
      print('Sign out error: $e');
      throw Exception('Failed to sign out: $e');
    }
  }

  Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      print('Token saved successfully');
    } catch (e) {
      print('Error saving token: $e');
      throw Exception('Failed to save authentication token');
    }
  }

  Future<void> _removeToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
    } catch (e) {
      print('Error removing token: $e');
      throw Exception('Failed to remove authentication token');
    }
  }

  Future<String> refreshToken() async {
    return _retryOperation(() async {
      final currentToken = await getToken();
      if (currentToken == null) {
        throw Exception('No token available for refresh');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $currentToken',
        },
      ).timeout(Duration(seconds: timeout));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newToken = data['token'];
        if (newToken == null) {
          throw Exception('New token not found in response');
        }
        await _saveToken(newToken);
        return newToken;
      } else {
        throw Exception(
            'Failed to refresh token: ${response.statusCode} - ${response.body}');
      }
    });
  }

  Future<bool> isTokenExpired(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: timeout));

      return response.statusCode != 200;
    } catch (e) {
      print('Error checking token expiration: $e');
      return true; // Assume token is expired if there's an error
    }
  }
}
