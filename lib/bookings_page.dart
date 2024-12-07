import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BookingDetailsScreen extends StatefulWidget {
  @override
  _BookingDetailsScreenState createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  List<dynamic> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookingDetails();
  }

  Future<void> fetchBookingDetails() async {
    final url = Uri.parse(
        'https://api.ticketverz.com/api/bookings/allBookingCustomer?page=1&limit=10');
    final headers = {
      'Cookie': 'Attendee-Signature=c0f5b6f256',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          bookings = data['data']['bookings'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load booking details');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color navbarColor = Theme.of(context).primaryColor; // Navbar color

    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Details'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : bookings.isEmpty
              ? Center(child: Text('No bookings available'))
              : ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return Card(
                      color: navbarColor,
                      margin: EdgeInsets.all(8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow('Booking ID:', booking['booking_id']),
                            _buildDetailRow('Customer ID:', booking['customer_id']),
                            _buildDetailRow('Event ID:', booking['event_id']),
                            _buildDetailRow('Organizer ID:', booking['organizer_id']),
                            _buildDetailRow('Type:', booking['type']),
                            _buildDetailRow('First Name:', booking['first_name']),
                            _buildDetailRow('Last Name:', booking['last_name']),
                            _buildDetailRow('Email:', booking['email']),
                            _buildDetailRow('Phone:', booking['phone'] ?? 'N/A'),
                            _buildDetailRow('Price:', booking['price'].toString()),
                            _buildDetailRow('Quantity:', booking['quantity']),
                            _buildDetailRow('Tax:', booking['tax'].toString()),
                            _buildDetailRow('Gateway Type:', booking['gatewayType']),
                            _buildDetailRow(
                                'Payment Status:', booking['paymentStatus']),
                            _buildDetailRow('Event Title:',
                                booking['eventDetails']['title']),
                            _buildDetailRow('Organizer Username:',
                                booking['organizerDetails']['username']),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildDetailRow(String fieldName, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fieldName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: BookingDetailsScreen(),
    theme: ThemeData(
      primaryColor: Colors.deepPurple, // Replace with your navbar color
    ),
  ));
}
