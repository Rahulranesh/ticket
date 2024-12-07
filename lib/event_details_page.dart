import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class EventDetailsPage extends StatefulWidget {
  final String eventId;

  const EventDetailsPage({Key? key, required this.eventId}) : super(key: key);

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  bool isLiked = false;
  Map<String, dynamic>? eventData;
  final storage = FlutterSecureStorage();
  final String baseUrl = "https://api.ticketverz.com/api";

  @override
  void initState() {
    super.initState();
    fetchEventDetails();
  }

  Future<void> fetchEventDetails() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/home/getEventContent?event_id=${widget.eventId}'),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'Ok' && responseData['code'] == 200) {
          final eventList = responseData['data'] as List<dynamic>;

          // Find the event by ID
          final event = eventList.firstWhere(
            (e) => e['event_id'] == widget.eventId,
            orElse: () => null,
          );

          if (event != null) {
            setState(() {
              eventData = event;
            });
            checkIfLiked(); // Check if the event is liked
          } else {
            print("Event not found in the response.");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Event not found')),
            );
          }
        } else {
          print("Invalid response structure: ${response.body}");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to fetch event details')),
          );
        }
      } else {
        print("Failed to fetch event details: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch event details')),
        );
      }
    } catch (e) {
      print("Error fetching event details: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching event details')),
      );
    }
  }

  // Check if the event is liked
  Future<void> checkIfLiked() async {
    final signature = await storage.read(key: 'attendee_signature');
    if (signature == null) {
      print("No attendee signature found.");
      return;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/home/wishlist'),
      headers: {'Cookie': 'Attendee-Signature=$signature'},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      if (responseData != null &&
          responseData['event_list'] != null &&
          responseData['event_list'] is List) {
        final wishlist = responseData['event_list'];
        setState(() {
          isLiked = wishlist.any((item) =>
              item['event_id'].toString() == widget.eventId.toString());
        });
      } else {
        print("Event list not found in the response.");
      }
    } else {
      print("Failed to fetch wishlist: ${response.statusCode}");
      print("Response: ${response.body}");
    }
  }

  // Toggle like status
  Future<void> toggleLike() async {
    try {
      final signature = await storage.read(key: 'attendee_signature');
      if (signature == null) {
        print("No attendee signature found. User not logged in.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to like events')),
        );
        return;
      }

      final headers = {
        'Cookie': 'Attendee-Signature=$signature',
        'Content-Type': 'application/json',
      };

      final queryParams = {
        'item_id': widget.eventId,
        'item_type': 'event',
      };

      final endpoint = isLiked ? 'home/dislikeEvent' : 'home/likedEvent';
      final uri =
          Uri.parse('$baseUrl/$endpoint').replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        setState(() {
          isLiked = !isLiked;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isLiked
                  ? 'Event added to wishlist!'
                  : 'Event removed from wishlist!',
            ),
          ),
        );
      } else if (response.statusCode == 401) {
        print("Authentication failed. Please log in again.");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Session expired. Please log in again.')));
        await storage.delete(key: 'attendee_signature');
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        print("Failed to update like status: ${response.statusCode}");
        print("Response body: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update like status')),
        );
      }
    } catch (e) {
      print('Error toggling like status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error toggling like status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (eventData == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text("Event Details",
              style: TextStyle(color: Colors.white)),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final eventName = eventData!['Event_Name'] ?? 'Event Name';
    final eventAddress = eventData!['Event_address'] ?? 'Event Address';
    final startDate =
        eventData!['start_date']?.split('T')[0] ?? 'Date Unavailable';
    final startTime = eventData!['start_time'] ?? 'Start Time';
    final description = eventData!['description'] != null
        ? eventData!['description'].replaceAll(RegExp(r'<[^>]*>'), '').trim()
        : 'Description';

    final thumbnail = eventData!['thumbnail'];
    final ticketPrice = eventData!['VAT'] ?? '0.00';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title:
            const Text("Event Details", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                image: thumbnail != null && thumbnail.contains(',')
                    ? DecorationImage(
                        image:
                            MemoryImage(base64Decode(thumbnail.split(',')[1])),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: thumbnail == null
                  ? const Center(
                      child: Icon(Icons.image, color: Colors.white, size: 50),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            // Event Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      eventName,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: toggleLike,
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          eventAddress,
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        "$startDate, $startTime",
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Description Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(16),
                child: Text(
                  description,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 5,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Buy Ticket Button
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  "BUY TICKET \$${ticketPrice}",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
