import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import '../controllers/auth_controller.dart';

class ApiService {
  static const String baseUrl =
      'http://10.0.2.2:5000/api'; // Use this for Android emulator
  // static const String baseUrl = 'http://localhost:5000/api'; // Use this for iOS simulator

  final AuthController _authProvider;

  ApiService(this._authProvider);

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authProvider.getToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<List<Task>> getTasks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tasks'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Task.fromJson(item)).toList();
      } else {
        throw _handleHttpError(response);
      }
    } catch (e) {
      throw Exception('Error getting tasks: $e');
    }
  }

  Future<Task> createTask(Task task) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tasks'),
        headers: await _getHeaders(),
        body: jsonEncode(task.toJson()),
      );

      if (response.statusCode == 201) {
        return Task.fromJson(jsonDecode(response.body));
      } else {
        throw _handleHttpError(response);
      }
    } catch (e) {
      throw Exception('Error creating task: $e');
    }
  }

  Future<Task> updateTask(Task task) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/tasks/${task.id}'),
        headers: await _getHeaders(),
        body: jsonEncode(task.toJson()),
      );

      if (response.statusCode == 200) {
        return Task.fromJson(jsonDecode(response.body));
      } else {
        throw _handleHttpError(response);
      }
    } catch (e) {
      throw Exception('Error updating task: $e');
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/tasks/$id'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200) {
        throw _handleHttpError(response);
      }
    } catch (e) {
      throw Exception('Error deleting task: $e');
    }
  }

  Exception _handleHttpError(http.Response response) {
    switch (response.statusCode) {
      case 401:
        return Exception('Unauthorized: Please log in again');
      case 403:
        return Exception(
            'Forbidden: You do not have permission to perform this action');
      case 404:
        return Exception('Not found: The requested resource does not exist');
      default:
        return Exception(
            'HTTP error ${response.statusCode}: ${response.reasonPhrase}');
    }
  }
}
