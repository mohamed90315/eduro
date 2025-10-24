import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://mockapi.io/projects/YOUR_PROJECT_ID";

  // Fetch all courses
  static Future<List<dynamic>> getCourses() async {
    final response = await http.get(Uri.parse('$baseUrl/courses'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load courses");
    }
  }

  // Fetch course details by ID
  static Future<Map<String, dynamic>> getCourseById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/courses/$id'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load course details");
    }
  }

  // Add new course/material
  static Future<void> addCourse(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/courses'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 201) {
      throw Exception("Failed to add course");
    }
  }
}
