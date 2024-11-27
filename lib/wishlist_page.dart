import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WishlistPage extends StatefulWidget {
  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<dynamic> wishlist = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchWishlist();
  }

  Future<void> fetchWishlist() async {
    final url = Uri.parse('https://api.example.com/api/home/wishlist');
    final headers = {
      'Authorization': 'Bearer YOUR_AUTH_TOKEN', // Replace with actual token
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        setState(() {
          wishlist = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load wishlist: ${response.reasonPhrase}';
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'An error occurred: $error';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Wishlist'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : wishlist.isEmpty
                  ? Center(child: Text('No items in your wishlist.'))
                  : ListView.builder(
                      itemCount: wishlist.length,
                      itemBuilder: (context, index) {
                        final item = wishlist[index];
                        return ListTile(
                          leading: item['image'] != null
                              ? Image.network(item['image'])
                              : null,
                          title: Text(item['name'] ?? 'Unnamed Event'),
                          subtitle: Text(item['date'] ?? ''),
                        );
                      },
                    ),
    );
  }
}
