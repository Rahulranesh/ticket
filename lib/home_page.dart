import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:ticket/bookings_page.dart';
import 'dart:convert';

import 'package:ticket/event_details_page.dart';
import 'package:ticket/moviedetails_page.dart';
import 'package:ticket/profile_page.dart';
import 'package:ticket/search.dart';
import 'package:ticket/wishlist_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    ExplorePage(),
    searchPage(),
    BookingDetailsScreen(

    ),
    WishlistPage(),
    ProfilePage(
      emailController: TextEditingController(),
      userId: 'currentUserId',
      usernameController: TextEditingController(),
    ),
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

  String stripHtmlTags(String htmlString) {
    final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '').trim();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
          Uri.parse('https://api.ticketverz.com/api/home/getEventCategories'));
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
      final response = await http
          .get(Uri.parse('https://api.ticketverz.com/api/home/getEvent'));
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
      final response = await http
          .get(Uri.parse('https://api.ticketverz.com/api/home/getMovies'));
      if (response.statusCode == 200) {
        setState(() {
          trendingMovies = json.decode(response.body)['data']['movies'];
        });
      }
    } catch (e) {
      print("Error fetching trending movies: $e");
    }
  }

  SliverToBoxAdapter _buildCategorySection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const SizedBox(width: 16),
              ...categories.map((category) => _buildCategoryChip(category)),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(dynamic category) {
    final iconData = _mapIconStringToIconData(category['icon']);
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton.icon(
        onPressed: () {
          // Handle category click
        },
        icon: Icon(
          iconData ?? Icons.category,
          color: const Color.fromARGB(255, 6, 1, 66),
        ),
        label: Text(category['name'] ?? 'Unknown'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  IconData? _mapIconStringToIconData(String? icon) {
    switch (icon) {
      case 'fas fa-film':
        return Icons.movie;
      case 'fas fa-music':
        return Icons.music_note;
      case 'fas fa-chalkboard-teacher':
        return Icons.school;
      case 'fas fa-campground':
        return Icons.park;
      case 'fas fa-basketball-ball':
        return Icons.sports_basketball;
      case 'fas fa-utensils':
        return Icons.restaurant;
      case 'fas fa-cocktail':
        return Icons.nightlife;
      case 'fa fa-fw fa-heart iconpicker-component':
        return Icons.favorite;
      default:
        return null;
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
                      padding: const EdgeInsets.all(20).copyWith(bottom: 50),
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0)
                    .copyWith(top: 8),
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
          _buildCategorySection(),

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
                      bool isLiked =
                          false; // Add a state variable to track the like status

                      return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      EventDetailsPage(eventData: event)),
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
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(15)),
                                      child: Image.memory(
                                        base64Decode(
                                            event['thumbnail'].split(',')[1]),
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                          ));
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
                // In the Trending Movies Section:
                Container(
                  height: 300,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: trendingMovies.length,
                    itemBuilder: (context, index) {
                      final movie = trendingMovies[index];
                      bool isMovieLiked = false;
                      return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MovieDetailsPage(movieData: movie),
                              ),
                            );
                          },
                          child: // Add a state variable to track the like status for trending movies

                              Container(
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
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(15)),
                                      child: Image.memory(
                                        base64Decode(
                                            movie['thumbnail'].split(',')[1]),
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        movie['Movie_Name'] ?? 'No Name',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Organizer: ${movie['organizer_name']}",
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        stripHtmlTags(movie['description'] ??
                                            'No Description'),
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Price: \$${movie['price'] ?? 'Free'}",
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
                          ));
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
