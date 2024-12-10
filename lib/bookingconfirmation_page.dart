import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class BookingConfirmationPage extends StatefulWidget {
  final Map<String, dynamic> eventData;

  const BookingConfirmationPage({Key? key, required this.eventData})
      : super(key: key);

  @override
  State<BookingConfirmationPage> createState() =>
      _BookingConfirmationPageState();
}

class _BookingConfirmationPageState extends State<BookingConfirmationPage> {
  final storage = FlutterSecureStorage();
  final String baseUrl = "https://api.ticketverz.com/api";
  int selectedQuantity = 1;
  bool isProcessing = false;

  Future<void> initiatePayment() async {
    setState(() {
      isProcessing = true;
    });

    try {
      final signature = await storage.read(key: 'attendee_signature');
      if (signature == null) {
        print("No attendee signature found. User not logged in.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to proceed with payment'),
          ),
        );
        return;
      }

      final headers = {
        'Cookie': 'Attendee-Signature=$signature',
        'Content-Type': 'application/json',
      };

      final body = jsonEncode({
        "cartItems": {
          "type": "Event",
          "event_id": widget.eventData['event_id'],
          "organizer_id": widget.eventData['organizer_id'],
          "ticketDetails": [
            {
              "ticket_name": "GOLD", // Replace with user-selected ticket name
              "quantity": selectedQuantity, // Get this from user input
              "price":
                  "30.00", // Replace with dynamic ticket price if applicable
            }
          ],
          "tickets": [
            {
              "ticket_id": widget
                  .eventData['ticket_id'], // Replace with ticket ID from data
              "quantity": selectedQuantity, // Get this from user input
            }
          ],
          "ticket_type": "paid",
          "quantity": selectedQuantity, // Get this from user input
        },
      });

      print('Request Body: $body');

      final response = await http.post(
        Uri.parse('$baseUrl/book/payment'),
        headers: headers,
        body: body,
      );

      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final paymentUrl = responseData['url'];
        if (paymentUrl != null) {
          Navigator.pushNamed(context, '/webview', arguments: paymentUrl);
        } else {
          print("Payment URL not found in response.");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to initiate payment')),
          );
        }
      } else if (response.statusCode == 401) {
        print("Authentication failed. Please log in again.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Session expired. Please log in again.')),
        );
        await storage.delete(key: 'attendee_signature');
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        print("Failed to initiate payment: ${response.statusCode}");
        print("Response body: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to initiate payment')),
        );
      }
    } catch (e) {
      print('Error initiating payment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error initiating payment')),
      );
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventName = widget.eventData['Event_Name'] ?? '';
    final location = widget.eventData['City'] ?? '';
    final startTime = widget.eventData['start_time'] ?? '';
    final ticketPrice = widget.eventData['Price'] ?? '0.00';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Pay to confirm booking",
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 0, 10, 17),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Booking Detail",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text("Event Title: $eventName",
                      style:
                          const TextStyle(fontSize: 16, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text("Starting at: $startTime",
                      style:
                          const TextStyle(fontSize: 16, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text("Location: $location",
                      style:
                          const TextStyle(fontSize: 16, color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Offers",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("No Offers Applicable",
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Enter Code",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text("Apply"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Your Order Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Ticket Price: €$ticketPrice"),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Select Quantity:"),
                DropdownButton<int>(
                  value: selectedQuantity,
                  items: List.generate(
                    10,
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text((index + 1).toString()),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      selectedQuantity = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Total: €${(double.parse(ticketPrice) * selectedQuantity).toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: isProcessing ? null : initiatePayment,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Book Now",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
