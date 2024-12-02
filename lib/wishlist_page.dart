import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> fetchWishlist() async {
  const String url = "https://api.ticketverse.eu/api/home/wishlist";

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Cookie":
            "Attendee-Signature=e3a2be00a4", // Replace with the actual cookie value
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load wishlist: ${response.statusCode}");
    }
  } catch (error) {
    throw Exception("Error fetching wishlist: $error");
  }
}

class WishlistPage extends StatefulWidget {
  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  Future<Map<String, dynamic>>? _wishlistData;

  @override
  void initState() {
    super.initState();
    _wishlistData = fetchWishlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Wishlist"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _wishlistData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("No data available."));
          }

          final wishlist = snapshot.data!;
          final movieList = wishlist["movie_list"] as List;
          final eventList = wishlist["event_list"] as List;

          return ListView(
            children: [
              if (movieList.isNotEmpty) ...[
                _buildSectionTitle("Movies"),
                ...movieList.map((movie) => _buildItemCard(movie)).toList(),
              ],
              if (eventList.isNotEmpty) ...[
                _buildSectionTitle("Events"),
                ...eventList.map((event) => _buildItemCard(event)).toList(),
              ],
              if (movieList.isEmpty && eventList.isEmpty)
                Center(child: Text("Your wishlist is empty!")),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildItemCard(dynamic item) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(item["name"] ?? "Unknown Item"),
        subtitle: Text(item["description"] ?? "No description available"),
      ),
    );
  }
}
