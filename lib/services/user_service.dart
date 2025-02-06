import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../controllers/auth_controller.dart';

class UserService {
  static const String baseUrl =
      'http://10.0.2.2:5000/api'; // Use this for Android emulator
  // static const String baseUrl = 'http://localhost:5000/api'; // Use this for iOS simulator

  final AuthController _authProvider;

  UserService(this._authProvider);

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authProvider.getToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<User> getUserProfile() async {
    try {
      final headers = await _getHeaders();
      final response =
          await http.get(Uri.parse('$baseUrl/auth/profile'), headers: headers);
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('User profile not found');
      } else {
        throw Exception('Failed to load user profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getUserProfile: $e');
      rethrow;
    }
  }

  Future<User> updateUserProfile(User user) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile'),
        headers: headers,
        body: jsonEncode(user.toJson()),
      );
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('User profile not found');
      } else {
        throw Exception(
            'Failed to update user profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in updateUserProfile: $e');
      rethrow;
    }
  }

  Future<String> uploadProfileImage(File image) async {
    try {
      final headers = await _getHeaders();
      var request = http.MultipartRequest(
          'POST', Uri.parse('$baseUrl/auth/profile/image'))
        ..headers.addAll(headers)
        ..files.add(await http.MultipartFile.fromPath('image', image.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['imageUrl'];
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in uploadProfileImage: $e');
      rethrow;
    }
  }

  Future<String> getProfileImageUrl() async {
    try {
      final user = await getUserProfile();
      return user.imageUrl ?? '/placeholder.svg';
    } catch (e) {
      print('Error in getProfileImageUrl: $e');
      rethrow;
    }
  }
}
