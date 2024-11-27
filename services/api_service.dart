// api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl =
      'https://api.ticketverse.eu'; // Update to your base URL
  final String baseUrl2 = 'https://mqnmrqvamm.us-east-1.awsapprunner.com';

  Future<dynamic> login(
      String username, String password, String roleEndpoint) async {
    final response = await http.post(
      Uri.parse(roleEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    return _handleResponse(response);
  }

  Future<dynamic> googleLogin(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/google'), // Use the provided endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode == 200) {
        print('Response: ${response.body}'); // Log the response
        return jsonDecode(response.body);
      } else {
        throw Exception('Google login failed: ${response.body}');
      }
    } catch (e) {
      print('Error: $e'); // Log any errors
      throw Exception('Error during Google login: $e');
    }
  }

  Future<dynamic> facebookLogin(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl2/auth/facebook'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
      }),
    );

    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return jsonDecode(response.body);
      default:
        throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<dynamic> register(
    String firstName,
    String lastName,
    String username,
    String email,
    String password,
    String selectedRole, {
    String? name,
  }) async {
    final roleEndpoints = {
      'User': '$baseUrl/auth/register',
      'Organizer': '$baseUrl/auth/org/register',
      'Admin': '$baseUrl/admin/register',
    };

    final String url = roleEndpoints[selectedRole]!;

    try {
      // Prepare the request body
      Map<String, dynamic> body = {
        'username': username,
        'email': email,
        'password': password,
      };

      // Include the name in the body if the role is Organizer
      if (selectedRole == 'Organizer' && name != null) {
        body['name'] = name; // Only include the name field
      } else {
        // Include first_name and last_name for User and Admin roles
        body['first_name'] = firstName;
        body['last_name'] = lastName;
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body); // Return successful response
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during registration: $e');
    }
  }
}
