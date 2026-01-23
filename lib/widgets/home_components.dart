import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:country_picker/country_picker.dart';
import 'package:provider/provider.dart';

// --- IMPORTS ---
import '../providers/filter_provider.dart';
import '../providers/saved_provider.dart';
import '../providers/auth_provider.dart';
import '../constants/colors.dart';
import '../widgets/modern_text_field.dart';
import '../widgets/shimmer_loading_card.dart';
import '../widgets/filter_model.dart';

// Screens
import '/screens/NotificationsScreen.dart';
import '/screens/login_screen.dart';
import '/screens/scholarship_details_screen.dart';

class HomeComponents {
  // --- HEADER ---
  static SliverToBoxAdapter buildHeader(BuildContext context, bool isDark) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Find your dream",
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  "Scholarships",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.primary,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            // --- NOTIFICATION BUTTON ---
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.3)
                            : AppColors.primary.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NotificationsScreen()),
                        );
                      },
                      child: Icon(
                        Icons.notifications_outlined,
                        color: isDark ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Theme.of(context).cardColor, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- SEARCH BAR ---
  static SliverToBoxAdapter buildSearchBar(
      BuildContext context, TextEditingController controller, bool isDark) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.2)
                    : const Color(0xFF6F7EC6).withOpacity(0.1),
                blurRadius: 25,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: ModernTextField(
            controller: controller,
            hintText: "Search scholarships...",
            prefixIcon: Icons.search_rounded,
          ),
        ),
      ),
    );
  }

  // --- FILTER BUTTONS ---
  static SliverToBoxAdapter buildFilterButtons(
      BuildContext context,
      FilterProvider filterProvider,
      List<String> degreeList,
      List<String> majorList, {
        required Function(String) onCountrySelected,
        required VoidCallback onCountryCleared,
        required Function(String) onDegreeSelected,
        required Function(String) onMajorSelected,
      }) {
    bool isCountrySelected =
        filterProvider.country != null && filterProvider.country != 'All Countries';

    return SliverToBoxAdapter(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Row(
          children: [
            _buildFilterButton(
              context,
              label: filterProvider.country ?? 'All Countries',
              icon: Icons.public,
              isSelected: isCountrySelected,
              onTap: () {
                showCountryPicker(
                  context: context,
                  showPhoneCode: false,
                  countryListTheme: CountryListThemeData(
                    backgroundColor: Theme.of(context).cardColor,
                    textStyle: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color),
                    borderRadius: BorderRadius.circular(20),
                    inputDecoration: InputDecoration(
                      labelText: 'Search Country',
                      hintText: 'Start typing...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  onSelect: (Country country) {
                    onCountrySelected(country.name);
                  },
                );
              },
              onClear: isCountrySelected ? onCountryCleared : null,
            ),
            const SizedBox(width: 12),
            _buildFilterButton(
              context,
              label: filterProvider.degree ?? 'All Degrees',
              icon: Icons.school_outlined,
              isSelected:
              filterProvider.degree != null && filterProvider.degree != 'All Degrees',
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => FilterModal(
                    title: "Choose Degree",
                    items: degreeList,
                    selectedItem: filterProvider.degree,
                    onApply: (val) {
                      onDegreeSelected(val ?? 'All Degrees');
                    },
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            _buildFilterButton(
              context,
              label: filterProvider.major ?? 'All Majors',
              icon: Icons.category_outlined,
              isSelected:
              filterProvider.major != null && filterProvider.major != 'All Majors',
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => FilterModal(
                    title: "Choose Major",
                    items: majorList,
                    selectedItem: filterProvider.major,
                    onApply: (val) {
                      onMajorSelected(val ?? 'All Majors');
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- FILTER BUTTON HELPER ---
  static Widget _buildFilterButton(
      BuildContext context, {
        required String label,
        required IconData icon,
        required VoidCallback onTap,
        bool isSelected = false,
        VoidCallback? onClear,
      }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? Colors.white10 : Colors.grey.shade300),
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: isDark ? Colors.black12 : Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.grey.shade600),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 100),
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white : Colors.grey.shade800),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 4),
            if (isSelected && onClear != null)
              GestureDetector(
                onTap: onClear,
                child: const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(Icons.close, size: 18, color: Colors.white),
                ),
              )
            else
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white54 : Colors.grey.shade500),
              ),
          ],
        ),
      ),
    );
  }

  // --- CAROUSEL ---
  static SliverToBoxAdapter buildCarousel(
      List<String> banners, int currentIndex, Function(int) onPageChanged) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          SizedBox(
            height: 180,
            width: double.infinity,
            child: CarouselSlider(
              items: banners.map((banner) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(banner,
                            fit: BoxFit.cover,
                            errorBuilder: (c, o, s) =>
                                Container(color: Colors.grey[200])),
                        Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.3)
                                  ])),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              options: CarouselOptions(
                height: 180,
                autoPlay: true,
                viewportFraction: 0.92,
                enlargeCenterPage: true,
                onPageChanged: (index, reason) => onPageChanged(index),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: banners.asMap().entries.map((entry) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: currentIndex == entry.key ? 20.0 : 8.0,
                height: 6.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: currentIndex == entry.key
                      ? AppColors.primary
                      : Colors.grey.shade300,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --- EXPIRING SOON SECTION ---
  static SliverToBoxAdapter buildExpiringSection(
      List<dynamic> expiringList, BuildContext context, bool isDark) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Expiring Soon ⏳",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF2D3142),
                    fontFamily: 'Poppins',
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "URGENT (3 Days)",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 220,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: expiringList.length,
              itemBuilder: (context, index) {
                return _buildExpiringCard(expiringList[index], context);
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- EXPIRING CARD ---
  static Widget _buildExpiringCard(dynamic item, BuildContext context) {
    final title = item['title']?.toString() ?? 'No Title';
    final university = item['university']?.toString() ?? 'University';
    final String? deadlineStr = item['deadline']?.toString();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String daysLeft = item['days_remaining']?.toString() ?? '';

    if (daysLeft.isEmpty || daysLeft == '0') {
      if (deadlineStr != null) {
        try {
          String clean = deadlineStr.contains('T')
              ? deadlineStr.split('T')[0]
              : deadlineStr;
          final DateTime deadline = DateTime.parse(clean);
          final Duration diff = deadline.difference(DateTime.now());
          if (!diff.isNegative) {
            daysLeft = (diff.inDays + 1).toString();
          } else {
            daysLeft = "0";
          }
        } catch (e) {
          daysLeft = "0";
        }
      } else {
        daysLeft = "0";
      }
    }

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 15, bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (item['id'] != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScholarshipDetailsPage(
                    scholarshipId: int.parse(item['id'].toString()),
                  ),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time_filled,
                          color: Colors.red, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        "$daysLeft Days Left",
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        university,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        size: 14,
                        color: isDark ? Colors.white38 : Colors.grey),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- SECTION TITLE ---
  static SliverPadding buildSectionTitle(bool hasSearched) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: Text(
          hasSearched ? "Search Results" : "Latest Scholarships",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3142),
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  // --- RESULTS LIST ---
  static Widget buildScholarshipListSliver(
      BuildContext context,
      bool isLoading,
      bool isSearching,
      String? errorMessage,
      bool hasSearched,
      List<dynamic> scholarships,
      SavedProvider savedProvider,
      AuthProvider authProvider,
      AnimationController animationController, {
        required VoidCallback onClearFilters,
      }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading || isSearching) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ShimmerLoadingCard(),
          ),
          childCount: 5,
        ),
      );
    }

    if (errorMessage != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
              child: Text(errorMessage!,
                  style: const TextStyle(color: Colors.red))),
        ),
      );
    }

    if (scholarships.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(30),
          alignment: Alignment.center,
          child: Column(
            children: [
              Icon(Icons.search_off_rounded,
                  size: 60,
                  color: isDark ? Colors.white24 : Colors.grey[300]),
              const SizedBox(height: 10),
              Text(
                "No scholarships found.",
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              if (hasSearched)
                TextButton(
                  onPressed: onClearFilters,
                  child: const Text("Clear Filters"),
                )
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) => _buildAnimatedItem(
            index,
            scholarships[index],
            savedProvider,
            authProvider,
            animationController,
            context,
          ),
          childCount: scholarships.length,
        ),
      ),
    );
  }

  // --- ANIMATED ITEM ---
  static Widget _buildAnimatedItem(
      int index,
      dynamic item,
      SavedProvider savedProvider,
      AuthProvider authProvider,
      AnimationController animationController,
      BuildContext context,
      ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 1. Extract Data Safely
    final int id = int.tryParse(item['id']?.toString() ?? '0') ?? 0;
    final String titleStr = item['title']?.toString() ?? 'Scholarship';
    final String uniStr = item['university']?.toString() ??
        item['category'] ??
        'University';
    final String countryStr = item['country']?.toString() ?? 'Country';
    final String amountStr = item['amount']?.toString() ?? '0.00';
    final String currencyStr = item['currency']?.toString() ?? 'USD';

    // Format deadline
    String deadlineStr = item['deadline']?.toString() ?? 'Open';
    if (deadlineStr.contains(' ')) deadlineStr = deadlineStr.split(' ')[0];
    if (deadlineStr.contains('T')) deadlineStr = deadlineStr.split('T')[0];

    // 2. Check saved state
    final bool isBookmarked = savedProvider.isSaved(item);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
            .animate(CurvedAnimation(
          parent: animationController,
          curve: Interval(
            (index * 0.05).clamp(0.0, 1.0),
            1.0,
            curve: Curves.easeOut,
          ),
        )),
        child: GestureDetector(
          onTap: () {
            if (id != 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScholarshipDetailsPage(scholarshipId: id),
                ),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D3557),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "$amountStr $currencyStr",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          if (authProvider.isLoggedIn) {
                            savedProvider.toggleSave(item, authProvider.userToken);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          }
                        },
                        icon: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: const Color(0xFF004D40),
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          titleStr,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.school,
                        color: Color(0xFF1D3557),
                        size: 28,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    uniStr,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey.shade600,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 16, color: Colors.grey.shade400),
                          const SizedBox(width: 6),
                          Text(
                            deadlineStr,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 16, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            countryStr,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}