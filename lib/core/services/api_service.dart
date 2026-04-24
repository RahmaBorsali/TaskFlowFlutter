import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // Use 10.0.2.2 for Android emulator, 127.0.0.1 for iOS simulator / web, or your PC's IP.
  // We'll use localhost which works for web, and we assume we run on web or windows for now.
  // For physical devices, you must change this to your computer's local IP address (e.g., 192.168.1.X)
  static const String baseUrl = 'http://192.168.1.162:3000';

  Future<List<dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('GET Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to post data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('POST Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> put(String endpoint, String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to put data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('PUT Error: $e');
      rethrow;
    }
  }

  Future<void> delete(String endpoint, String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$endpoint/$id'));
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('DELETE Error: $e');
      rethrow;
    }
  }
}
