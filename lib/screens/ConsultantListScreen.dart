import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/api_service.dart';
import 'provider.dart' hide AppColors; // Your ConsultantProfileScreen
import '../widgets/modern_text_field.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // --- API CALLS ---
  void _fetchTopRated() async {
    final response = await ApiService.getTopRatedConsultants();
    if (mounted) {
      setState(() {
        if (response['status'] == 'success') {
          var rawData = response['data'];
          if (rawData is List) {
            _topRatedConsultants = rawData;
          } else if (rawData is Map && rawData['data'] is List) {
            _topRatedConsultants = rawData['data'];
          }
        }
        _isLoadingTop = false;
      });
    }
  }

  void _fetchAllConsultants({String? query}) async {
    setState(() => _isLoadingAll = true);
    final response = await ApiService.getAllConsultants(query: query);

    if (mounted) {
      setState(() {
        if (response['status'] == 'success') {
          var rawData = response['data'];
          if (rawData is List) {
            _allConsultants = rawData;
          } else if (rawData is Map && rawData.containsKey('data')) {
            _allConsultants = rawData['data'];
          } else {
            _allConsultants = [];
          }
        }
        _isLoadingAll = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchAllConsultants(query: query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    // Check Theme Status
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2D3142);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // Gradient for Light Mode, Solid Color for Dark Mode
          gradient: isDarkMode ? null : AppColors.backgroundGradient,
          color: isDarkMode ? Theme.of(context).scaffoldBackgroundColor : null,
        ),
        child: Column(
          children: [
            // --- HEADER ---
            _buildGlassHeader(topPadding, isDarkMode),

            // --- BODY ---
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
                        child: Text(
                          "Top Rated Experts",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              color: textColor
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 20, right: 10),
                          itemCount: _topRatedConsultants.length,
                          itemBuilder: (context, index) {
                            return _buildTopRatedCard(_topRatedConsultants[index], isDarkMode, textColor);
                          },
                        ),
                      ),
                      const SizedBox(height: 25),
                    ],

                    // --- ALL CONSULTANTS SECTION ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text(
                        "All Consultants",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: textColor
                        ),
                      ),
                    ),

                    _isLoadingAll
                        ? const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                        : _allConsultants.isEmpty
                        ? Center(child: Padding(padding: const EdgeInsets.all(30), child: Text("No consultants found", style: TextStyle(color: textColor.withOpacity(0.6)))))
                        : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _allConsultants.length,
                      itemBuilder: (context, index) {
                        return _buildConsultantRow(_allConsultants[index], isDarkMode, textColor);
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

  // --- WIDGET: TOP RATED CARD ---
  Widget _buildTopRatedCard(Map<String, dynamic> data, bool isDarkMode, Color textColor) {
    // 1. EXTRACT DATA
    final userObj = data['user'];
    final Map<String, dynamic> user = (userObj is Map<String, dynamic>) ? userObj : {};

    String fName = user['f_name'] ?? "";
    String lName = user['l_name'] ?? "";
    String name = (fName.isNotEmpty || lName.isNotEmpty)
        ? "$fName $lName".trim()
        : (user['name'] ?? data['name'] ?? "Unknown Expert");

    final String avatar = user['avatar'] ?? data['avatar'] ?? "";
    final String specialization = data['professional_title'] ?? data['specialization'] ?? "Specialist";
    final double rating = double.tryParse(data['average_rating']?.toString() ?? data['avg_rating']?.toString() ?? "0") ?? 0.0;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ConsultantProfileScreen(consultantId: data['id']))),
      child: Container(
        width: 155,
        margin: const EdgeInsets.only(right: 15, bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // Dark Mode Card Color
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4)
            )
          ],
          border: isDarkMode ? Border.all(color: Colors.white.withOpacity(0.05)) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
              backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
              child: avatar.isEmpty ? Icon(Icons.person, size: 35, color: isDarkMode ? Colors.grey[400] : Colors.grey) : null,
            ),
            const SizedBox(height: 10),
            Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)
            ),
            Text(
                specialization,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.6))
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  Text(" $rating", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- WIDGET: ALL CONSULTANTS ROW ---
  Widget _buildConsultantRow(Map<String, dynamic> data, bool isDarkMode, Color textColor) {
    // 1. EXTRACT DATA
    final userObj = data['user'];
    final Map<String, dynamic> user = (userObj is Map<String, dynamic>) ? userObj : {};

    String fName = user['f_name'] ?? "";
    String lName = user['l_name'] ?? "";
    String name;
    if (fName.isNotEmpty || lName.isNotEmpty) {
      name = "$fName $lName".trim();
    } else {
      name = user['name'] ?? data['name'] ?? "Consultant Name";
    }

    final String avatar = user['avatar'] ?? data['avatar'] ?? "";
    final String subtitle = data['professional_title'] ?? data['specialization'] ?? "Consultant";

    final double rating = double.tryParse(data['average_rating']?.toString() ?? data['avg_rating']?.toString() ?? "0") ?? 0.0;
    final int reviews = int.tryParse(data['total_reviews']?.toString() ?? "0") ?? 0;
    final int views = int.tryParse(data['profile_views']?.toString() ?? "0") ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ConsultantProfileScreen(consultantId: data['id']),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          // Dark Mode Card Color
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: isDarkMode ? Border.all(color: Colors.white.withOpacity(0.05)) : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- AVATAR ---
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
                image: avatar.isNotEmpty ? DecorationImage(image: NetworkImage(avatar), fit: BoxFit.cover) : null,
              ),
              child: avatar.isEmpty ? Icon(Icons.person, color: isDarkMode ? Colors.grey[500] : Colors.grey) : null,
            ),

            const SizedBox(width: 15),

            // --- INFO ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      color: textColor, // Adaptive Color
                    ),
                  ),

                  // Subtitle
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: textColor.withOpacity(0.6)), // Adaptive Color
                  ),

                  const SizedBox(height: 12),

                  // --- STATS ROW ---
                  Row(
                    children: [
                      _buildStatBadge(Icons.star_rounded, "$rating", Colors.amber, isDarkMode),
                      const SizedBox(width: 15),
                      _buildStatBadge(Icons.chat_bubble_outline_rounded, "$reviews", Colors.blue, isDarkMode),
                      const SizedBox(width: 15),
                      _buildStatBadge(Icons.visibility_outlined, "$views", Colors.purple, isDarkMode),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow
            Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: textColor.withOpacity(0.3)),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for the badges
  Widget _buildStatBadge(IconData icon, String text, Color color, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        // In dark mode, we make the background slightly more opaque to be visible
        color: color.withOpacity(isDarkMode ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
              text,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  // Ensure text is readable
                  color: isDarkMode ? color.withOpacity(0.9) : color.withOpacity(0.9)
              )
          ),
        ],
      ),
    );
  }

  // --- HEADER ---
  Widget _buildGlassHeader(double topPadding, bool isDarkMode) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: topPadding + 10, bottom: 25, left: 20, right: 20),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.95),
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                      "Find Consultants",
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins')
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  // Search Bar Background: White in Light Mode, Dark Grey in Dark Mode
                  color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ModernTextField(
                  controller: _searchController,
                  hintText: "Search consultants...",
                  prefixIcon: Icons.search_rounded,
                  onChanged: _onSearchChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}