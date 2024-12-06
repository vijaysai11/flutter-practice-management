import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:practice_management/constants/config.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

 // Method to get headers (e.g., Authorization, Content-Type)
  Map<String, String> _headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? Config.token}', // Use token from Config as default
    };
  }

  // Generic GET request
  Future<dynamic> get(String endpoint, {String? token}) async {
    try {
      final url = Uri.parse('$baseUrl/getpracticeresourcedetailsbymanageremail/eswar.nowdu@cognine.com');
      final response = await http.get(url, headers: _headers(token: token));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  // Generic POST request
  Future<dynamic> post(String endpoint, List<Map<String, dynamic>> data, {String? token}) async {
    try {
      final url = Uri.parse('$baseUrl/updateprojectresourcestatus');
      final response = await http.post(
        url,
        headers: _headers(token: token),
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to post data: $e');
    }
  }


  // Handle HTTP responses
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (statusCode >= 200 && statusCode < 300) {
      return body;
    } else {
      throw Exception('Error: $statusCode, Body: $body');
    }
  }
}
