import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import '../providers/filter_provider.dart';
import '../providers/saved_provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

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

    List<Widget> screens = [
      _buildHomeTab(filterProvider, savedProvider, authProvider),
      const Center(child: Text("Knowledge Screen")),
      authProvider.isLoggedIn ? const ProfileScreen() : const LoginScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1B3C53),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Knowledge'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHomeTab(
      FilterProvider filterProvider, SavedProvider savedProvider, AuthProvider authProvider) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          // ---------------- HEADER ----------------
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.asset('assets/logo.jpeg', width: 45, height: 45),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Search scholarships...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 15),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications, color: Color(0xFF1B3C53)),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // ---------------- FILTERS ----------------
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                FilterChipDropdown(
                  value: filterProvider.country,
                  items: const ['All Countries', 'USA', 'UK', 'Canada'],
                  onChanged: filterProvider.setCountry,
                  icon: Icons.public,
                ),
                const SizedBox(width: 8),
                FilterChipDropdown(
                  value: filterProvider.degree,
                  items: const ['All Degrees', 'Bachelor', 'Master', 'PhD'],
                  onChanged: filterProvider.setDegree,
                  icon: Icons.school,
                ),
                const SizedBox(width: 8),
                FilterChipDropdown(
                  value: filterProvider.major,
                  items: const ['All Majors', 'Engineering', 'Science', 'Arts'],
                  onChanged: filterProvider.setMajor,
                  icon: Icons.menu_book,
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // ---------------- SLIDER ----------------
          CarouselSlider(
            items: banners
                .map((banner) => ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                banner,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ))
                .toList(),
            options: CarouselOptions(
              height: 160,
              autoPlay: true,
              enlargeCenterPage: true,
              autoPlayInterval: const Duration(seconds: 3),
              viewportFraction: 0.92,
            ),
          ),

          const SizedBox(height: 15),

          // ---------------- SCHOLARSHIPS ----------------
          ...scholarships.map((item) {
            bool isSaved = savedProvider.isSaved(item);
            return AnimatedScholarshipCard(
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
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
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

// ------------------ FILTER CHIP ------------------
class FilterChipDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final void Function(String) onChanged;
  final IconData icon;

  const FilterChipDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1B3C53), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: Icon(icon, size: 18, color: const Color(0xFF1B3C53)),
          onChanged: (v) => onChanged(v!),
          items: items
              .map((e) => DropdownMenuItem(
            value: e,
            child: Text(
              e,
              style: const TextStyle(fontSize: 14),
            ),
          ))
              .toList(),
        ),
      ),
    );
  }
}

// ------------------ SCHOLARSHIP CARD ------------------
class AnimatedScholarshipCard extends StatefulWidget {
  final String title, institution, badge, deadline, country;
  final void Function() onSave;
  final bool isSaved;

  const AnimatedScholarshipCard({
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
  State<AnimatedScholarshipCard> createState() => _AnimatedScholarshipCardState();
}

class _AnimatedScholarshipCardState extends State<AnimatedScholarshipCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 3,
          shadowColor: Colors.black.withOpacity(0.08),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge + Save
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDFF3E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.badge,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B3C53),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onSave,
                      icon: Icon(
                        widget.isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: const Color(0xFF1B3C53),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  widget.title,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),

                Text(
                  widget.institution,
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.deadline, style: const TextStyle(color: Colors.grey)),
                    Text(widget.country, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
