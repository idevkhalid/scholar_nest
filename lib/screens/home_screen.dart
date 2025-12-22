import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';

import '../providers/filter_provider.dart';
import '../providers/saved_provider.dart';
import '../providers/auth_provider.dart';
import '../constants/colors.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'knowledge_base_screen.dart';
import 'scholarship_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late Future<Map<String, dynamic>> _scholarshipsFuture;

  final List<String> banners = const [
    'assets/images/banner1.png',
    'assets/images/banner2.png',
    'assets/images/banner3.png',
  ];

  @override
  void initState() {
    super.initState();
    _scholarshipsFuture = ApiService.getAllScholarships();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final filterProvider = Provider.of<FilterProvider>(context);
    final savedProvider = Provider.of<SavedProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final screens = [
      _buildHomeTab(filterProvider, savedProvider, authProvider),
      const KnowledgeBaseScreen(),
      authProvider.isLoggedIn ? const ProfileScreen() : const LoginScreen(),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Knowledge Base'),
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
        padding: EdgeInsets.zero,
        children: [
          /// ---------------- SEARCH BAR ----------------
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: "Search scholarships...",
                prefixIcon: Icon(Icons.search, color: Color(0xFF1B3C53)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 14),
              ),
            ),
          ),

          const SizedBox(height: 15),

          /// ---------------- FILTERS ----------------
          SizedBox(
            height: 45,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              scrollDirection: Axis.horizontal,
              children: [
                FilterChipDropdown(
                  value: filterProvider.country,
                  items: const ['All Countries', 'USA', 'UK', 'Canada'],
                  onChanged: filterProvider.setCountry,
                  icon: Icons.public,
                ),
                const SizedBox(width: 10),
                FilterChipDropdown(
                  value: filterProvider.degree,
                  items: const ['All Degrees', 'Bachelor', 'Master', 'PhD'],
                  onChanged: filterProvider.setDegree,
                  icon: Icons.school,
                ),
                const SizedBox(width: 10),
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

          /// ---------------- SLIDER ----------------
          CarouselSlider(
            items: banners.map((banner) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(banner, fit: BoxFit.cover, width: double.infinity),
                ),
              );
            }).toList(),
            options: CarouselOptions(
              height: 160,
              autoPlay: true,
              enlargeCenterPage: true,
              autoPlayInterval: const Duration(seconds: 3),
              viewportFraction: 0.92,
            ),
          ),

          const SizedBox(height: 20),

          /// ---------------- SCHOLARSHIPS (API DATA) ----------------
          FutureBuilder<Map<String, dynamic>>(
            future: _scholarshipsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              if (snapshot.hasError || snapshot.data == null) {
                return const Center(child: Text("Failed to load data"));
              }

              debugPrint("Full API Response: ${snapshot.data}");

              List<dynamic> scholarshipsList = [];

              // Check possible API keys
              if (snapshot.data!['data'] is List) {
                scholarshipsList = snapshot.data!['data'];
              } else if (snapshot.data!['data'] is Map && snapshot.data!['data']['data'] is List) {
                scholarshipsList = snapshot.data!['data']['data'];
              } else if (snapshot.data!['scholarships'] is List) {
                scholarshipsList = snapshot.data!['scholarships'];
              }

              /// ---------------- DUMMY DATA FALLBACK ----------------
              /// If the list is empty, we show these mock items for testing
              if (scholarshipsList.isEmpty) {
                scholarshipsList = [
                  {
                    'id': 101,
                    'title': 'Global Excellence Scholarship',
                    'university': 'Harvard University',
                    'amount': '45,000',
                    'currency': 'USD',
                    'deadline': 'Dec 20, 2025',
                    'country': 'USA',
                  },
                  {
                    'id': 102,
                    'title': 'STEM Future Leaders Grant',
                    'university': 'Oxford University',
                    'amount': '32,000',
                    'currency': 'GBP',
                    'deadline': 'Jan 15, 2026',
                    'country': 'UK',
                  },
                  {
                    'id': 103,
                    'title': 'DAAD Postgraduate Award',
                    'university': 'Technical University of Munich',
                    'amount': 'Fully Funded',
                    'currency': '',
                    'deadline': 'Feb 10, 2026',
                    'country': 'Germany',
                  },
                ];
              }
              /// -------------------------------------------------------

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: scholarshipsList.map((item) {
                    final isSaved = savedProvider.isSaved(item);

                    return ModernScholarshipCard(
                      title: item['title']?.toString() ?? 'No Title',
                      institution: item['university']?.toString() ?? 'No Institution',
                      badge: "${item['amount'] ?? ''} ${item['currency'] ?? ''}".trim(),
                      deadline: item['deadline']?.toString() ?? 'No Deadline',
                      country: item['country']?.toString() ?? 'N/A',
                      isSaved: isSaved,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScholarshipDetailsPage(
                              scholarshipId: int.parse(item['id'].toString()),
                            ),
                          ),
                        );
                      },
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
                  }).toList(),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// --- DEFINE THE WIDGET CLASSES OUTSIDE THE STATE CLASS ---

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
        border: Border.all(color: AppColors.primary),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: Icon(icon, size: 18, color: AppColors.primary),
          onChanged: (v) => onChanged(v!),
          items: items
              .map(
                (e) => DropdownMenuItem(
              value: e,
              child: Text(e),
            ),
          )
              .toList(),
        ),
      ),
    );
  }
}

class ModernScholarshipCard extends StatefulWidget {
  final String title, institution, badge, deadline, country;
  final VoidCallback onSave;
  final VoidCallback onTap;
  final bool isSaved;

  const ModernScholarshipCard({
    super.key,
    required this.title,
    required this.institution,
    required this.badge,
    required this.deadline,
    required this.country,
    required this.onSave,
    required this.onTap,
    required this.isSaved,
  });

  @override
  State<ModernScholarshipCard> createState() => _ModernScholarshipCardState();
}

class _ModernScholarshipCardState extends State<ModernScholarshipCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(colors: [Color(0xFF1B3C53), Color(0xFF2F5A75)]),
                      ),
                      child: Text(widget.badge, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      onPressed: widget.onSave,
                      icon: Icon(widget.isSaved ? Icons.bookmark : Icons.bookmark_border, color: const Color(0xFF1B3C53)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B3C53))),
                const SizedBox(height: 6),
                Text(widget.institution, style: TextStyle(color: Colors.grey[800])),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(widget.deadline),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(widget.country),
                      ],
                    ),
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