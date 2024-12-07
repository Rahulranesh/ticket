import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    home: BookingPage(),
    theme: ThemeData(
      primarySwatch: Colors.deepPurple,
    ),
  ));
}

class BookingPage extends StatefulWidget {
  const BookingPage({Key? key}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final storage = FlutterSecureStorage();
  final String baseUrl = "https://api.ticketverz.com/api";
  List<dynamic> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookingDetails();
  }

  Future<void> fetchBookingDetails() async {
    try {
      final signature = await storage.read(key: 'attendee_signature');
      if (signature == null) {
        print("No attendee signature found. User not logged in.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to view bookings')),
        );
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/bookings/allBookingCustomer?page=1&limit=10'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'Attendee-Signature=$signature',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          bookings = (data['data']['bookings'] ?? []).toSet().toList(); // Removes duplicates
          isLoading = false;
        });
      } else {
        print("Error: ${response.statusCode}");
        print("Response: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch booking details')),
        );
      }
    } catch (e) {
      print("Error fetching booking details: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching booking details')),
      );
    }
  }

  Widget buildBookingCard(dynamic booking) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingDetailPage(booking: booking),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.deepPurpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.5),
              offset: const Offset(4, 4),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leading Icon
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 30,
              child: Icon(
                Icons.event_available,
                color: Colors.deepPurple,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            // Event Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking['eventDetails']['title'] ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  // Booking Details
                  buildDetailRow('Date:', booking['event_date'] ?? 'N/A'),
                  buildDetailRow(
                      'Price:', '€${booking['price']}', textColor: Colors.yellow),
                  buildDetailRow(
                      'Payment Status:', booking['paymentStatus'],
                      textColor: Colors.greenAccent),
                ],
              ),
            ),
            // Trailing Arrow
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDetailRow(String title, String value,
      {Color textColor = Colors.white}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text("Bookings", style: TextStyle(color: Colors.white)),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Bookings", style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        color: Colors.grey[100],
        child: bookings.isEmpty
            ? const Center(child: Text('No bookings found'))
            : ListView.builder(
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            return buildBookingCard(bookings[index]);
          },
        ),
      ),
    );
  }
}

class BookingDetailPage extends StatelessWidget {
  final dynamic booking;

  const BookingDetailPage({Key? key, required this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 6, 1, 66),
        title: Text(booking['eventDetails']['title'] ?? 'Booking Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildDetailRow('Date:', booking['event_date'] ?? 'N/A'),
            buildDetailRow('Price:', '€${booking['price']}'),
            buildDetailRow('Payment Status:', booking['paymentStatus']),
            buildDetailRow('Name:',
                '${booking['first_name']} ${booking['last_name']}'),
            buildDetailRow('Email:', booking['email'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8.0),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
