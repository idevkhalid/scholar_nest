import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import '../providers/filter_provider.dart';
import '../providers/saved_provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'profile_screen.dart'; // <-- ADD THIS (your profile page)

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<String> banners = const [
    'assets/images/banner1.png',
    'assets/images/banner2.png',
    'assets/images/banner3.png',
  ];

  final List<Map<String, String>> scholarships = const [
    {
      'title': 'Full Tuition Scholarship',
      'institution': 'Harvard University',
      'badge': '\$25,000/year',
      'deadline': 'Dec 31, 2025',
      'country': 'USA',
    },
    {
      'title': 'Merit-Based Scholarship',
      'institution': 'Oxford University',
      'badge': '\$30,000/year',
      'deadline': 'Jan 15, 2026',
      'country': 'UK',
    },
    {
      'title': 'Merit-Based Scholarship',
      'institution': 'Oxford University',
      'badge': '\$30,000/year',
      'deadline': 'Jan 15, 2026',
      'country': 'UK',
    }, {
      'title': 'Merit-Based Scholarship',
      'institution': 'Oxford University',
      'badge': '\$30,000/year',
      'deadline': 'Jan 15, 2026',
      'country': 'UK',
    }, {
      'title': 'Merit-Based Scholarship',
      'institution': 'Oxford University',
      'badge': '\$30,000/year',
      'deadline': 'Jan 15, 2026',
      'country': 'UK',
    }, {
      'title': 'Merit-Based Scholarship',
      'institution': 'Oxford University',
      'badge': '\$30,000/year',
      'deadline': 'Jan 15, 2026',
      'country': 'UK',
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filterProvider = Provider.of<FilterProvider>(context);
    final savedProvider = Provider.of<SavedProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // Screens for BottomNavigationBar
    List<Widget> screens = [
      _buildHomeTab(filterProvider, savedProvider, authProvider),
      const Center(child: Text("Knowledge Screen")),
      authProvider.isLoggedIn
          ? const ProfileScreen() // <-- NOW OPENS PROFILE
          : const LoginScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF1B3C53),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Knowledge'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHomeTab(
      FilterProvider filterProvider,
      SavedProvider savedProvider,
      AuthProvider authProvider,
      ) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          // Top Bar + Search
          Row(
            children: [
              Image.asset('assets/logo.jpeg', width: 40, height: 40),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 38, // smaller height
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search scholarships...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Filters (clean + compact)
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                FilterDropdown(
                  value: filterProvider.country,
                  items: const ['All Countries', 'USA', 'UK', 'Canada'],
                  onChanged: filterProvider.setCountry,
                  icon: Icons.public,
                ),
                const SizedBox(width: 8),
                FilterDropdown(
                  value: filterProvider.degree,
                  items: const ['All Degrees', 'Bachelor', 'Master', 'PhD'],
                  onChanged: filterProvider.setDegree,
                  icon: Icons.school,
                ),
                const SizedBox(width: 8),
                FilterDropdown(
                  value: filterProvider.major,
                  items: const ['All Majors', 'Engineering', 'Science', 'Arts'],
                  onChanged: filterProvider.setMajor,
                  icon: Icons.menu_book,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Carousel
          CarouselSlider(
            items: banners
                .map(
                  (banner) => ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  banner,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            )
                .toList(),
            options: CarouselOptions(
              height: 150,
              autoPlayInterval: const Duration(seconds: 2),
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 0.92,
            ),
          ),

          const SizedBox(height: 12),

          // Ad Container
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Special Scholarship Ad',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B3C53),
                  ),
                  child: const Text("View"),
                )
              ],
            ),
          ),

          const SizedBox(height: 15),

          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Latest Opportunities",
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "See All",
                style: TextStyle(color: Colors.grey),
              )
            ],
          ),
          const SizedBox(height: 12),

          // Scholarship Cards
          ...scholarships.map((item) {
            bool isSaved = savedProvider.isSaved(item);
            return ScholarshipCard(
              title: item['title']!,
              institution: item['institution']!,
              badge: item['badge']!,
              deadline: item['deadline']!,
              country: item['country']!,
              isSaved: isSaved,
              onSave: () {
                if (!authProvider.isLoggedIn) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                } else {
                  savedProvider.toggleSave(item);
                }
              },
            );
          }),
        ],
      ),
    );
  }
}

// -------------------- FILTER DROPDOWN --------------------

class FilterDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final void Function(String) onChanged;
  final IconData icon;

  const FilterDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: Icon(icon, size: 18, color: Colors.grey[700]),
          onChanged: (v) => onChanged(v!),
          items: items
              .map((e) => DropdownMenuItem(
            value: e,
            child: Text(
              e,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
          ))
              .toList(),
        ),
      ),
    );
  }
}

// -------------------- SCHOLARSHIP CARD --------------------

class ScholarshipCard extends StatelessWidget {
  final String title, institution, badge, deadline, country;
  final void Function() onSave;
  final bool isSaved;

  const ScholarshipCard({
    super.key,
    required this.title,
    required this.institution,
    required this.badge,
    required this.deadline,
    required this.country,
    required this.onSave,
    required this.isSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: onSave,
                  icon: Icon(
                    isSaved
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: const Color(0xFF1B3C53),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              institution,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  deadline,
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 12),
                ),
                Text(
                  country,
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
