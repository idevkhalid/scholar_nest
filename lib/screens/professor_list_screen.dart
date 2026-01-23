import 'dart:async'; // Required for Timer (Search Debounce)
import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/api_service.dart';
import 'profeesor_detail_screen.dart';
import '../widgets/premium_background.dart';
import '../widgets/shimmer_loading_card.dart'; // Ensure this exists or remove it

class ProfessorListScreen extends StatefulWidget {
  const ProfessorListScreen({super.key});

  @override
  State<ProfessorListScreen> createState() => _ProfessorListScreenState();
}

class _ProfessorListScreenState extends State<ProfessorListScreen> {
  // Data State
  List<dynamic> _professors = [];
  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  String? _errorMessage;

  // Pagination State
  int _currentPage = 1;
  int _lastPage = 1;

  // Search State
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _currentSearchQuery = "";

  // Scroll Controller for Infinite Scroll
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchProfessors(refresh: true);

    // Listen to scroll events for "Load More"
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          _currentPage < _lastPage) {
        _fetchProfessors();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- Core API Fetch Logic ---
  Future<void> _fetchProfessors({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isLoadingInitial = true;
        _errorMessage = null;
        _currentPage = 1;
        _professors = []; // Clear list on refresh
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      // Call API with current Page and Search Query
      final response = await ApiService.getProfessors(
        page: refresh ? 1 : _currentPage + 1,
        search: _currentSearchQuery,
      );

      if (mounted) {
        // Check for 'success': true based on your API response
        if (response['success'] == true) {
          final dataWrapper = response['data']; // The outer 'data' object
          final List<dynamic> newProfessors = dataWrapper['data']; // The inner list

          setState(() {
            if (refresh) {
              _professors = newProfessors;
            } else {
              _professors.addAll(newProfessors);
              _currentPage++;
            }

            // Update pagination info
            _lastPage = dataWrapper['last_page'] ?? 1;
            _isLoadingInitial = false;
            _isLoadingMore = false;
          });
        } else {
          setState(() {
            _errorMessage = response['message'] ?? "Failed to load data";
            _isLoadingInitial = false;
            _isLoadingMore = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Network Error: Please check your connection";
          _isLoadingInitial = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  // --- Search Debounce (Prevents spamming API) ---
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (_currentSearchQuery != query) {
        _currentSearchQuery = query;
        _fetchProfessors(refresh: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: PremiumBackground(
        child: Stack(
          children: [
            // ---------------- LIST CONTENT ----------------
            Positioned.fill(
              child: RefreshIndicator(
                onRefresh: () async => _fetchProfessors(refresh: true),
                color: AppColors.primary,
                child: _isLoadingInitial
                    ? ListView.builder(
                  padding: EdgeInsets.only(top: topPadding + 150),
                  itemCount: 6,
                  itemBuilder: (_, __) => const ShimmerLoadingCard(),
                )
                    : _errorMessage != null
                    ? _buildErrorView()
                    : _professors.isEmpty
                    ? _buildEmptyView()
                    : ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.only(
                      top: topPadding + 150,
                      left: 20,
                      right: 20,
                      bottom: 40
                  ),
                  itemCount: _professors.length + (_isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Loading Indicator at bottom
                    if (index == _professors.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(15.0),
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      );
                    }

                    final prof = _professors[index];
                    return _buildProfessorCard(prof, isDarkMode);
                  },
                ),
              ),
            ),

            // ---------------- GLASS HEADER ----------------
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildGlassHeader(topPadding),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- HEADER WIDGET ----------------
  Widget _buildGlassHeader(double topPadding) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(30),
        bottomRight: Radius.circular(30),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(
            top: topPadding + 10,
            bottom: 20,
            left: 20,
            right: 20,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.90), // Updated for Flutter 3.27+
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            children: [
              // Row: Back Button & Title
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Text(
                    "Find Professors",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Search Bar
              Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: "Search name, university...",
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: AppColors.primary.withValues(alpha: 0.6)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged(""); // Trigger refresh
                      },
                    )
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- CARD WIDGET ----------------
  Widget _buildProfessorCard(Map<String, dynamic> prof, bool isDarkMode) {
    // Parsing Data based on your API Response
    final String name = prof['name'] ?? "Unknown";
    final String title = prof['title'] ?? ""; // "Dr." or "Prof."
    final String fullName = title.isNotEmpty ? "$title $name" : name;

    final String uni = prof['university_name'] ?? "Unknown University";
    final String country = prof['university_country'] ?? "";
    final String department = prof['department'] ?? "";
    final bool isAccepting = prof['accepting_students'] == true;

    // Parse Research Interests (it comes as an array in your API)
    List<dynamic> interestsRaw = prof['research_interests_array'] ?? [];
    String interestsText = interestsRaw.take(2).join(", "); // Take first 2
    if (interestsRaw.length > 2) interestsText += "...";

    final String initials = _getInitials(name);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfessorDetailScreen(
              professorId: prof['id'],
              professorName: fullName,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Avatar with Initials
                Hero(
                  tag: 'avatar_${prof['id']}',
                  child: Container(
                    height: 55,
                    width: 55,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),

                // 2. Text Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Status Dot
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          if (isAccepting)
                            Container(
                              margin: const EdgeInsets.only(left: 5),
                              height: 8,
                              width: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            )
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Department & Uni
                      Text(
                        "$department • $uni",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            height: 1.2
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Tags Row (Country & Interest)
                      Row(
                        children: [
                          if (country.isNotEmpty)
                            _buildTag(country, Icons.location_on, isDarkMode),

                          if (country.isNotEmpty && interestsText.isNotEmpty)
                            const SizedBox(width: 8),

                          if (interestsText.isNotEmpty)
                            Expanded(
                              child: Text(
                                interestsText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primary.withValues(alpha: 0.8),
                                    fontStyle: FontStyle.italic
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, IconData icon, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 50, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(
            "No professors found matching your search.",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 40, color: Colors.red.shade300),
          const SizedBox(height: 10),
          Text(_errorMessage!, style: TextStyle(color: Colors.grey.shade600)),
          TextButton(
            onPressed: () => _fetchProfessors(refresh: true),
            child: const Text("Try Again"),
          )
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "P";
    List<String> parts = name.split(" ");
    if (parts.length > 1) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return name[0].toUpperCase();
  }
}