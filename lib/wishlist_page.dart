import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class WishlistPage extends StatefulWidget {
  const WishlistPage({Key? key}) : super(key: key);

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final storage = FlutterSecureStorage();
  final String baseUrl = "https://api.ticketverz.com/api";
  List<dynamic> wishlist = []; // To store the wishlist events

  @override
  void initState() {
    super.initState();
    fetchWishlist();
  }

  Future<void> fetchWishlist() async {
    final signature = await storage.read(key: 'attendee_signature');
    if (signature == null) {
      print("No attendee signature found.");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/home/wishlist'),
        headers: {'Cookie': 'Attendee-Signature=$signature'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Fetched Wishlist: $responseData');

        // Directly access `event_list` from the root response
        if (responseData['event_list'] != null && mounted) {
          setState(() {
            wishlist = responseData['event_list'];
          });
        } else {
          print("No events found in the wishlist.");
        }
      } else {
        print("Failed to fetch wishlist: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (error) {
      print("Error fetching wishlist: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
        backgroundColor: Colors.black,
      ),
      body: wishlist.isEmpty
          ? const Center(
              child: Text(
                'Your wishlist is empty',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: wishlist.length,
              itemBuilder: (context, index) {
                final event = wishlist[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InkWell(
                    onTap: () {
                      // Navigate to event details page or perform an action
                      print("Selected event: ${event['event_id']}");
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event image
                        if (event['image'] != null)
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                            child: Image.network(
                              event['image'],
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event['title'] ?? 'Event Name',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                event['description'] ?? 'Event Description',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "ID: ${event['event_id'] ?? 'N/A'}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    event['date'] ?? 'Date',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
