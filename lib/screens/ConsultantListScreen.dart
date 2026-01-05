import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/api_service.dart';
import 'provider.dart'; // <--- IMPORT YOUR EXISTING PROVIDER SCREEN HERE

class AllConsultantScreen extends StatefulWidget {
  const AllConsultantScreen({super.key});

  @override
  State<AllConsultantScreen> createState() => _AllConsultantScreenState();
}

class _AllConsultantScreenState extends State<AllConsultantScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // Data Lists
  List<dynamic> _allConsultants = [];
  List<dynamic> _topRatedConsultants = [];

  bool _isLoadingAll = true;
  bool _isLoadingTop = true;

  @override
  void initState() {
    super.initState();
    _fetchTopRated();
    _fetchAllConsultants();
  }

  // --- API CALLS ---
  void _fetchTopRated() async {
    final response = await ApiService.getTopRatedConsultants();
    if (mounted && response['status'] == 'success') {
      setState(() {
        _topRatedConsultants = response['data'];
        _isLoadingTop = false;
      });
    } else {
      setState(() => _isLoadingTop = false);
    }
  }

  void _fetchAllConsultants({String? query}) async {
    setState(() => _isLoadingAll = true);
    final response = await ApiService.getAllConsultants(query: query);

    if (mounted) {
      setState(() {
        if (response['status'] == 'success') {
          _allConsultants = response['data'];
        }
        _isLoadingAll = false;
      });
    }
  }

  // Search Debounce (Wait 500ms after typing stops)
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchAllConsultants(query: query);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Column(
          children: [
            // --- 1. GLASS HEADER WITH SEARCH ---
            _buildGlassHeader(topPadding),

            // --- 2. SCROLLABLE BODY ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 20, bottom: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // --- TOP RATED SECTION ---
                    if (!_isLoadingTop && _topRatedConsultants.isNotEmpty && _searchController.text.isEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Row(
                          children: [
                            Icon(Icons.stars, color: Colors.amber[700]),
                            const SizedBox(width: 8),
                            const Text(
                              "Top Rated Experts",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 20, right: 10),
                          itemCount: _topRatedConsultants.length,
                          itemBuilder: (context, index) {
                            return _buildTopRatedCard(_topRatedConsultants[index]);
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // --- ALL CONSULTANTS SECTION ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text(
                        "All Consultants",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),

                    _isLoadingAll
                        ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                        : _allConsultants.isEmpty
                        ? const Center(child: Padding(padding: EdgeInsets.all(30), child: Text("No consultants found")))
                        : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _allConsultants.length,
                      itemBuilder: (context, index) {
                        return _buildConsultantRow(_allConsultants[index]);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET: TOP RATED CARD (Horizontal) ---
  Widget _buildTopRatedCard(Map<String, dynamic> data) {
    // Note: Top Rated API returns name directly at root, not inside 'user'
    final String name = data['name'] ?? "Unknown";
    final String avatar = data['avatar'] ?? "";
    final String specialization = data['specialization'] ?? "";
    final double rating = (data['avg_rating'] ?? 0).toDouble();

    return GestureDetector(
      onTap: () {
        // NAVIGATE TO YOUR PROVIDER SCREEN
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ConsultantProfileScreen(consultantId: data['id']),
          ),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 15, bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 4))],
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
              child: avatar.isEmpty ? const Icon(Icons.person) : null,
            ),
            const SizedBox(height: 8),
            Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(specialization, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: AppColors.primary)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Colors.amber[100], borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 12, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text("$rating", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- WIDGET: ALL CONSULTANTS ROW (Vertical) ---
  Widget _buildConsultantRow(Map<String, dynamic> data) {
    // Note: All Consultants API returns name inside 'user' object
    final user = data['user'] ?? {};
    final String name = user['name'] ?? "Unknown";
    final String avatar = user['avatar'] ?? "";
    final String specialization = data['specialization'] ?? "";
    final double rating = (data['avg_rating'] ?? 0).toDouble();
    final String hourlyRate = data['hourly_rate']?.toString() ?? "0";

    return GestureDetector(
      onTap: () {
        // NAVIGATE TO YOUR PROVIDER SCREEN
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ConsultantProfileScreen(consultantId: data['id']),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: Offset(0, 3))],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                child: avatar.isEmpty ? const Icon(Icons.person, color: Colors.grey) : null,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(specialization, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      Text(" $rating", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const Spacer(),
                      Text("\$$hourlyRate/hr", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700], fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // --- GLASS HEADER WITH SEARCH ---
  Widget _buildGlassHeader(double topPadding) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: topPadding + 10, bottom: 20, left: 20, right: 20),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.25),
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 5),
                  const Text("Find Consultants", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 15),

              // SEARCH BAR
              Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: "Search by name or specialization...",
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: AppColors.primary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}