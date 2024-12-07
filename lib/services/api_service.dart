import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://api.ticketverz.com/api'; // Base URL
  final String baseUrl2 =
      'https://mqnmrqvamm.us-east-1.awsapprunner.com'; // Secondary URL

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(); // Secure storage for cookies

  /// Save the cookie to secure storage
  Future<void> _saveCookie(String rawCookie) async {
    final attendeeSignature = _extractCookieValue(rawCookie, 'Attendee-Signature');
    if (attendeeSignature != null) {
      await _secureStorage.write(
        key: 'attendee_signature',
        value: attendeeSignature,
      );
      print('Saved Cookie: attendee_signature=$attendeeSignature'); // Debugging
    } else {
      print('No Attendee-Signature found in cookie.'); // Debugging
    }
  }

  /// Retrieve the saved cookie
  Future<String?> _getCookie() async {
    return await _secureStorage.read(key: 'attendee_signature');
  }

  /// Extract cookie value from raw cookie string
  String? _extractCookieValue(String rawCookie, String key) {
    final cookieParts = rawCookie.split(';');
    for (final part in cookieParts) {
      if (part.trim().startsWith('$key=')) {
        return part.trim().substring(key.length + 1);
      }
    }
    return null;
  }

  /// Verify User Session
  Future<dynamic> verifySession() async {
    final String endpoint = '$baseUrl/auth/verify-session';
    final attendeeSignature = await _getCookie();

    if (attendeeSignature == null) {
      throw Exception('No valid authentication cookie found. Please log in.');
    }

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'Attendee-Signature=$attendeeSignature',
        },
      );

      if (response.statusCode == 200) {
        // Parse the response and return user information
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else if (response.statusCode == 401) {
        // Unauthorized session
        return {'success': false, 'message': 'Unauthorized: Invalid session'};
      } else {
        // Handle other errors
        return {
          'success': false,
          'message': 'Error: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      throw Exception('Error during session verification: $e');
    }
  }

  /// Login method
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

    // Save the cookie from the response if available
    if (response.headers.containsKey('set-cookie')) {
      print('Raw Set-Cookie Header: ${response.headers['set-cookie']}'); // Debugging
      await _saveCookie(response.headers['set-cookie']!);
    } else {
      print('No Set-Cookie header found in the response.');
    }

    return _handleResponse(response);
  }

  /// Generic response handler
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
  }

  // Google login method
  Future<dynamic> googleLogin(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'), // Google login endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      if (response.headers.containsKey('set-cookie')) {
        print(
            'Raw Set-Cookie Header: ${response.headers['set-cookie']}'); // Debugging: Print raw cookie header
        await _saveCookie(response.headers['set-cookie']!);
      }

      if (response.statusCode == 200) {
        print('Response: ${response.body}');
        return jsonDecode(response.body); // Return response if successful
      } else {
        throw Exception('Google login failed: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error during Google login: $e');
    }
  }

  // Example: Fetch the wishlist
  Future<dynamic> fetchWishlist() async {
    final attendeeSignature = await _getCookie();
    if (attendeeSignature == null) {
      throw Exception('No valid authentication cookie found. Please log in.');
    }

    // Include the saved cookie in the request header
    final response = await http.get(
      Uri.parse('$baseUrl/home/wishlist'),
      headers: {
        'Cookie': 'Attendee-Signature=$attendeeSignature', // Pass the cookie here
        'Content-Type': 'application/json',
      },
    );

    return _handleResponse(response);
  }

  // Register method
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

    // Ensure the selected role exists in the map
    if (!roleEndpoints.containsKey(selectedRole)) {
      throw Exception('Invalid role selected.');
    }

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

      if (response.headers.containsKey('set-cookie')) {
        final cookie = response.headers['set-cookie']!;
        await _saveCookie(cookie); // Save the cookie in secure storage
      }

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
