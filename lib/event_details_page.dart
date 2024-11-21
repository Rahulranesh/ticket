import 'package:flutter/material.dart';
import 'dart:convert';

class EventDetailsPage extends StatelessWidget {
  final Map<String, dynamic> eventData;

  const EventDetailsPage({Key? key, required this.eventData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final eventName = eventData['Event_Name'] ?? 'Event Name';
    final eventAddress = eventData['Event_address'] ?? 'Event Address';
    final organizerName = eventData['organizer_name'] ?? 'Organizer';
    final startDate = eventData['start_date'] != null
        ? eventData['start_date'].split('T')[0]
        : 'Date Unavailable';
    final startTime = eventData['start_time'] ?? 'Start Time';
    final description = eventData['description']
            ?.replaceAll('<p>', '')
            .replaceAll('</p>', '') ??
        'Description';
    final refundPolicy = eventData['refund_policy'] ?? 'No Refund Policy';
    final thumbnail = eventData['thumbnail'];
    final ticketPrice = eventData['VAT'] ?? '0.00';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Event Details",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full Image Section
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey,
                image: thumbnail != null && thumbnail.contains(',')
                    ? DecorationImage(
                        image: MemoryImage(base64Decode(thumbnail.split(',')[1])),
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
            // Event Name Section
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eventName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          eventAddress,
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        "$startDate, $startTime",
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Description Section
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.grey[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "About Event",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter your input here",
                    ),
                  ),
                ],
              ),
            ),
            // Refund Policy Section
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Refund Policy: $refundPolicy",
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
            // Buy Ticket Button
            Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  "BUY TICKET \$${ticketPrice}",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
