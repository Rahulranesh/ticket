import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

Future<void> saveSignature(String signature) async {
  await storage.write(key: 'attendee_signature', value: signature);
}

Future<String?> getSignature() async {
  return await storage.read(key: 'attendee_signature');
}

class WishlistApi {
  final String baseUrl;

  WishlistApi(this.baseUrl);

  Future<List<dynamic>> fetchWishlist(String signature) async {
    final response = await http.get(
      Uri.parse('$baseUrl/home/wishlist'),
      headers: {'Attendee-Signature': signature},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data']['wishlist'];
    } else {
      throw Exception('Failed to fetch wishlist');
    }
  }

  Future<void> likeEvent(String eventId, String signature) async {
    final response = await http.post(
      Uri.parse('$baseUrl/home/likedEvent'),
      headers: {'Attendee-Signature': signature},
      body: jsonEncode({'event_id': eventId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to like event');
    }
  }

  Future<void> dislikeEvent(String eventId, String signature) async {
    final response = await http.post(
      Uri.parse('$baseUrl/home/dislikeEvent'),
      headers: {'Attendee-Signature': signature},
      body: jsonEncode({'event_id': eventId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to dislike event');
    }
  }
}
