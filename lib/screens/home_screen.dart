import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    },


  ];

  // Filters
  String selectedCountry = 'All Countries';
  String selectedDegree = 'All Degrees';
  String selectedMajor = 'All Majors';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF1B3C53),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Knowledge'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            // Top Bar
            Row(
              children: [
                Image.asset('assets/logo.png', width: 40, height: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 40, // Reduced search bar height
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search scholarships...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
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
                IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
              ],
            ),
            const SizedBox(height: 10),
            // Filters (Dropdowns)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FilterDropdown(
                  value: selectedCountry,
                  items: const ['All Countries', 'USA', 'UK', 'Canada'],
                  onChanged: (val) {
                    setState(() {
                      selectedCountry = val!;
                    });
                  },
                ),
                FilterDropdown(
                  value: selectedDegree,
                  items: const ['All Degrees', 'Bachelor', 'Master', 'PhD'],
                  onChanged: (val) {
                    setState(() {
                      selectedDegree = val!;
                    });
                  },
                ),
                FilterDropdown(
                  value: selectedMajor,
                  items: const ['All Majors', 'Engineering', 'Science', 'Arts'],
                  onChanged: (val) {
                    setState(() {
                      selectedMajor = val!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Carousel Slider inside scroll
            CarouselSlider(
              items: banners
                  .map(
                    (banner) => ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    banner,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              )
                  .toList(),
              options: CarouselOptions(
                height: 140,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.9,
              ),
            ),
            const SizedBox(height: 10),
            // Ad Section
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(onPressed: () {}, child: const Text('View')),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Latest Opportunities
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Latest Opportunities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('See All', style: TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 10),
            // Scholarship Cards
            ...scholarships.map((item) => ScholarshipCard(
              title: item['title']!,
              institution: item['institution']!,
              badge: item['badge']!,
              deadline: item['deadline']!,
              country: item['country']!,
            )),
          ],
        ),
      ),
    );
  }
}

// Dropdown Widget for Filter
class FilterDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final void Function(String?) onChanged;
  const FilterDropdown({super.key, required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      onChanged: onChanged,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
    );
  }
}

// Scholarship Card Widget
class ScholarshipCard extends StatelessWidget {
  final String title, institution, badge, deadline, country;
  const ScholarshipCard({
    super.key,
    required this.title,
    required this.institution,
    required this.badge,
    required this.deadline,
    required this.country,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge & Save Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(badge, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border)),
              ],
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(institution, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(deadline, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(country, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
