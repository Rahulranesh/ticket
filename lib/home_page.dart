import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:ticket/bookings_page.dart';
import 'dart:convert';

import 'package:ticket/event_details_page.dart';
import 'package:ticket/profile_page.dart';
import 'package:ticket/wishlist_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    ExplorePage(),
    
    BookingsPage(),
    WishlistPage(),
    ProfilePage(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  List categories = [];
  List events = [];
  List trendingMovies = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchEvents();
    fetchTrendingMovies();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
          Uri.parse('https://api.ticketverse.eu/api/home/getEventCategories'));
      if (response.statusCode == 200) {
        setState(() {
          categories = json.decode(response.body)['data'];
        });
      }
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future<void> fetchEvents() async {
    try {
      final response = await http.get(
          Uri.parse('https://api.ticketverse.eu/api/home/getEvent'));
      if (response.statusCode == 200) {
        setState(() {
          events = json.decode(response.body)['data']['events'];
        });
      }
    } catch (e) {
      print("Error fetching events: $e");
    }
  }

  Future<void> fetchTrendingMovies() async {
    try {
      final response = await http.get(
          Uri.parse('https://api.ticketverse.eu/api/home/getMovies'));
      if (response.statusCode == 200) {
        setState(() {
          trendingMovies = json.decode(response.body)['data']['movies'];
        });
      }
    } catch (e) {
      print("Error fetching trending movies: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 100.0,
            backgroundColor: Color.fromARGB(255, 6, 1, 66),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset(
                        'assets/logo.png',
                        height: 40,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(Icons.notifications, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(top: 8),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 6, 1, 66),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search...",
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: EdgeInsets.only(top: 7),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Categories Section
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Event Categories",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return Container(
                        margin: EdgeInsets.only(right: 15, left: 16),
                        width: MediaQuery.of(context).size.width * 0.25,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            SizedBox(height: 8),
                            Text(
                              category['name'] ?? 'No Category',
                              style: TextStyle(fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Upcoming Movies Section
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Upcoming Movies",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  height: 300,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EventDetailsPage(eventData: event)
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 15, left: 16),
                          width: 250,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(15)),
                                child: Image.memory(
                                  base64Decode(event['thumbnail']
                                      .split(',')[1]),
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
                                      event['Event_Name'] ?? 'No Event Name',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "${event['start_date'].split('T')[0]} - ${event['end_time']}",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Location: ${event['City']}, ${event['country']}",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "Price: \$${event['ticketPrices'][0]['price'] ?? 'Free'}",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green),
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
                ),
              ],
            ),
          ),
          // Trending Movies Section
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Trending Movies",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  height: 300,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: trendingMovies.length,
                    itemBuilder: (context, index) {
                      final movie = trendingMovies[index];
                      return Container(
                        margin: EdgeInsets.only(right: 15, left: 16),
                        width: 250,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(15)),
                              child: Image.memory(
                                base64Decode(movie['thumbnail'].split(',')[1]),
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
                                    movie['movieName'] ?? 'No Name',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Release Date: ${movie['releaseDate']}",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                  SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

