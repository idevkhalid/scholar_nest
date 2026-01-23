import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:country_picker/country_picker.dart';
import 'dart:async';

// --- IMPORTS ---
import '../providers/filter_provider.dart';
import '../providers/saved_provider.dart';
import '../providers/auth_provider.dart';
import '../constants/colors.dart';
import '../services/api_service.dart';
import '../widgets/modern_text_field.dart';
import '../widgets/filter_model.dart';
import '../widgets/premium_background.dart';

// Screens
import 'NotificationsScreen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'knowledge_base_screen.dart';
import 'scholarship_details_screen.dart';

// Components
import '/widgets/home_components.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  int _currentCarouselIndex = 0;

  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();

  // --- DATA LISTS ---
  List<dynamic> _scholarships = [];
  List<dynamic> _expiringList = [];
  Timer? _debounce;

  bool _isLoading = true;
  String? _errorMessage;
  bool _isSearching = false;
  bool _hasSearched = false;

  final Map<String, String> _degreeMap = {
    'All Degrees': 'All',
    'High School': 'High School',
    'Bachelor': 'Bachelor',
    'Master': 'Master',
    'PhD': 'phd',
    'Diploma': 'Diploma',
    'PostDoc': 'PostDoc',
  };

  List<String> get _degreeList => _degreeMap.keys.toList();

  final List<String> _majorList = [
    'All Majors',
    'Computer Science',
    'Engineering',
    'Medicine',
    'Business',
    'Arts',
    'Law',
    'Science',
    'Economics',
    'Education',
    'Psychology'
  ];

  final List<String> banners = const [
    'assets/images/banner1.png',
    'assets/images/banner2.png',
    'assets/images/banner3.png',
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialLoad();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final savedProvider = Provider.of<SavedProvider>(context, listen: false);

      if (authProvider.isLoggedIn && authProvider.userToken.isNotEmpty) {
        savedProvider.loadLocalData();
        savedProvider.fetchSavedScholarships(authProvider.userToken);
      }
    });

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _performSearch();
      }
    });
  }

  void _onItemTapped(int index) {
    if (mounted) setState(() => _selectedIndex = index);
  }

  // --- 1. INITIAL LOAD ---
  Future<void> _initialLoad() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    List<dynamic> mainList = [];
    List<dynamic> expiringListRaw = [];

    // A. FETCH MAIN SCHOLARSHIPS
    try {
      final dynamic response = await ApiService.getAllScholarships(page: 1);
      if (response is List) {
        mainList = response;
      } else if (response is Map<String, dynamic>) {
        if (response['data'] is List) {
          mainList = response['data'];
        } else if (response['data'] is Map && response['data']['data'] is List) {
          mainList = response['data']['data'];
        } else if (response['scholarships'] is List) {
          mainList = response['scholarships'];
        } else if (response['result'] is List) {
          mainList = response['result'];
        }
      }
    } catch (e) {
      debugPrint("❌ Error fetching main scholarships: $e");
      _errorMessage = "Connection error. Please check internet.";
    }

    // B. FETCH EXPIRING SCHOLARSHIPS
    try {
      final dynamic expiringResponse = await ApiService.getExpiringScholarships();

      if (expiringResponse is List) {
        expiringListRaw = expiringResponse;
      } else if (expiringResponse is Map<String, dynamic>) {
        if (expiringResponse['data'] is List) {
          expiringListRaw = expiringResponse['data'];
        } else if (expiringResponse['data'] is Map && expiringResponse['data']['data'] is List) {
          expiringListRaw = expiringResponse['data']['data'];
        }
      }

      final now = DateTime.now();
      final threeDaysFromNow = now.add(const Duration(days: 3));

      expiringListRaw = expiringListRaw.where((item) {
        final String? deadlineStr = item['deadline'];
        if (deadlineStr == null) return false;
        try {
          String cleanDate = deadlineStr;
          if (cleanDate.contains('T')) cleanDate = cleanDate.split('T')[0];
          final DateTime deadline = DateTime.parse(cleanDate);
          return deadline.isAfter(now.subtract(const Duration(days: 1))) &&
              deadline.isBefore(threeDaysFromNow);
        } catch (e) {
          return false;
        }
      }).toList();

      expiringListRaw.sort((a, b) {
        String dA = a['deadline'].toString().split('T')[0];
        String dB = b['deadline'].toString().split('T')[0];
        return DateTime.parse(dA).compareTo(DateTime.parse(dB));
      });
    } catch (e) {
      debugPrint("⚠️ Expiring API failed (ignoring): $e");
    }

    if (mounted) {
      setState(() {
        _scholarships = mainList;
        _expiringList = expiringListRaw;
        _isLoading = false;
        if (mainList.isEmpty && _errorMessage == null) {
          _errorMessage = "No scholarships found.";
        }
      });
    }
  }

  // --- 2. SEARCH LOGIC ---
  Future<void> _performSearch() async {
    if (!mounted) return;
    final filterProvider = Provider.of<FilterProvider>(context, listen: false);
    final query = _searchController.text.trim();

    final String? uiCountry = filterProvider.country;
    final String? uiDegree = filterProvider.degree;
    final String? uiMajor = filterProvider.major;

    bool hasCountry = uiCountry != null && uiCountry != 'All Countries';
    bool hasDegree = uiDegree != null && uiDegree != 'All Degrees';
    bool hasMajor = uiMajor != null && uiMajor != 'All Majors';
    bool hasQuery = query.isNotEmpty;

    if (!hasCountry && !hasDegree && !hasMajor && !hasQuery) {
      if (_hasSearched) {
        setState(() {
          _hasSearched = false;
          _isSearching = false;
          _initialLoad();
        });
      }
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      String? apiCountry;
      String? apiDegree;
      List<String>? apiMajors;

      if (hasCountry) {
        Map<String, String> countryFixes = {
          'United States': 'USA',
          'United Kingdom': 'UK',
          'South Korea': 'Korea',
        };
        apiCountry = countryFixes[uiCountry] ?? uiCountry;
      }

      if (hasDegree) {
        apiDegree = _degreeMap[uiDegree] ?? uiDegree;
      }
      if (hasMajor) {
        apiMajors = [uiMajor!];
      }

      final Map<String, dynamic> response = await ApiService.searchScholarships(
        query: query,
        country: apiCountry,
        degreeLevel: apiDegree,
        fieldOfStudy: apiMajors,
        page: 1,
        perPage: 50,
      );

      List<dynamic> rawResults = [];
      if (response.containsKey('data')) {
        final dynamic innerData = response['data'];
        if (innerData is List) {
          rawResults = innerData;
        } else if (innerData is Map && innerData['data'] is List) {
          rawResults = innerData['data'];
        }
      } else if (response.containsKey('result') && response['result'] is List) {
        rawResults = response['result'];
      } else if (response.containsKey('scholarships') && response['scholarships'] is List) {
        rawResults = response['scholarships'];
      }

      List<dynamic> filteredResults = rawResults.where((item) {
        if (hasCountry && apiCountry != null) {
          final String itemCountry = item['country']?.toString() ?? '';
          if (!itemCountry.toLowerCase().contains(apiCountry.toLowerCase()) &&
              !apiCountry.toLowerCase().contains(itemCountry.toLowerCase())) {
            if (uiCountry != null && !itemCountry.toLowerCase().contains(uiCountry.toLowerCase())) {
              return false;
            }
          }
        }
        if (hasDegree && apiDegree != null) {
          final String itemDegree = item['degree_level']?.toString() ?? '';
          if (!itemDegree.toLowerCase().contains(apiDegree.toLowerCase())) {
            return false;
          }
        }
        if (hasMajor && uiMajor != null) {
          final dynamic itemMajor = item['field_of_study'];
          if (itemMajor is List) {
            bool match = itemMajor.any((m) =>
                m.toString().toLowerCase().contains(uiMajor.toLowerCase()));
            if (!match) return false;
          } else {
            final String majStr = itemMajor?.toString() ?? '';
            if (!majStr.toLowerCase().contains(uiMajor.toLowerCase())) {
              return false;
            }
          }
        }
        return true;
      }).toList();

      if (mounted) {
        setState(() {
          _isSearching = false;
          _scholarships = filteredResults;
          if (filteredResults.isEmpty) {
            _errorMessage = null;
          }
        });
      }
    } catch (e) {
      debugPrint("❌ Search Error: $e");
      if (mounted) {
        setState(() {
          _isSearching = false;
          _scholarships = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filterProvider = Provider.of<FilterProvider>(context);
    final savedProvider = Provider.of<SavedProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      _buildHomeTab(filterProvider, savedProvider, authProvider),
      const KnowledgeBaseScreen(),
      authProvider.isLoggedIn ? const ProfileScreen() : const LoginScreen(),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).cardColor,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: isDark ? Colors.white38 : Colors.grey.shade400,
        showUnselectedLabels: true,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: "Learn"),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildHomeTab(FilterProvider filterProvider, SavedProvider savedProvider,
      AuthProvider authProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PremiumBackground(
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // --- HEADER ---
            HomeComponents.buildHeader(context, isDark),

            // --- SEARCH BAR ---
            HomeComponents.buildSearchBar(context, _searchController, isDark),

            // --- FILTER BUTTONS ---
            HomeComponents.buildFilterButtons(
              context,
              filterProvider,
              _degreeList,
              _majorList,
              onCountrySelected: (country) {
                filterProvider.setCountry(country);
                _performSearch();
              },
              onCountryCleared: () {
                filterProvider.setCountry('All Countries');
                _performSearch();
              },
              onDegreeSelected: (degree) {
                filterProvider.setDegree(degree);
                _performSearch();
              },
              onMajorSelected: (major) {
                filterProvider.setMajor(major);
                _performSearch();
              },
            ),

            // --- CAROUSEL ---
            HomeComponents.buildCarousel(banners, _currentCarouselIndex, (index) {
              if (mounted) setState(() => _currentCarouselIndex = index);
            }),

            // --- EXPIRING SOON SECTION ---
            if (!_hasSearched && !_isSearching && _expiringList.isNotEmpty)
              HomeComponents.buildExpiringSection(_expiringList, context, isDark),

            const SliverToBoxAdapter(child: SizedBox(height: 25)),

            // --- SECTION TITLE (LATEST/RESULTS) ---
            HomeComponents.buildSectionTitle(_hasSearched),

            const SliverToBoxAdapter(child: SizedBox(height: 15)),

            // --- RESULTS LIST ---
            HomeComponents.buildScholarshipListSliver(
              context,
              _isLoading,
              _isSearching,
              _errorMessage,
              _hasSearched,
              _scholarships,
              savedProvider,
              authProvider,
              _animationController,
              onClearFilters: () {
                Provider.of<FilterProvider>(context, listen: false).reset();
                _searchController.clear();
                setState(() {
                  _hasSearched = false;
                  _initialLoad();
                });
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}