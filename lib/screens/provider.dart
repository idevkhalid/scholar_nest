import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import 'WriteReviewScreen.dart';

// --- YOUR COLOR FILE (Keep as is) ---
class AppColors {
  static const Color primary = Color(0xFF1B3C53);
  static const Color background = Color(0xFFEAF1F8);
  static const Color textPrimary = Color(0xFF1B3C53);
  static const Color textSecondary = Color(0xFF7B7B7B);
  static const Color cardBackground = Colors.white;

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x9977A9FF),
      Colors.white,
    ],
  );
}

class ConsultantProfileScreen extends StatefulWidget {
  final int consultantId;

  const ConsultantProfileScreen({super.key, required this.consultantId});

  @override
  State<ConsultantProfileScreen> createState() =>
      _ConsultantProfileScreenState();
}

class _ConsultantProfileScreenState extends State<ConsultantProfileScreen> {
  late Future<Map<String, dynamic>> _consultantFuture;

  @override
  void initState() {
    super.initState();
    _consultantFuture = ApiService.getConsultantDetails(widget.consultantId);
  }

  // --- ACTIONS ---
  Future<void> _launchUrl(String urlString) async {
    if (urlString.isEmpty || urlString == "Not available") return;
    if (!urlString.startsWith("http://") && !urlString.startsWith("https://")) {
      urlString = "https://$urlString";
    }
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open this link")),
        );
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _sendEmail(String email) async {
    if (email.isEmpty) return;

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Consultation Inquiry', // Optional: Adds a default subject line
    );

    try {
      // try launching directly
      await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      // If that fails, try the generic check
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not open email client: $e")),
        );
      }
    }
  }

  String _getInitials(String name) {
    List<String> parts = name.trim().split(" ");
    if (parts.length > 1) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return "C";
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final double headerHeight = topPadding + 15 + 30 + 20;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Stack(
          children: [
            // --- SCROLLABLE BODY ---
            FutureBuilder<Map<String, dynamic>>(
              future: _consultantFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final responseData = snapshot.data;
                if (responseData == null || responseData["status"] != "success") {
                  return Center(child: Text("Failed: ${responseData?['message'] ?? 'Unknown Error'}"));
                }

                // --- DATA MAPPING (UPDATED FOR NEW API) ---
                final data = responseData["data"] ?? {};
                final user = data["user"] ?? {};

                // Name & Identity
                final String fName = user["f_name"] ?? "";
                final String lName = user["l_name"] ?? "";
                final String fullName = "$fName $lName".trim().isEmpty ? "Consultant" : "$fName $lName";
                final String title = data["professional_title"] ?? "Professional Consultant";

                // Contact
                final String phone = data["phone"] ?? user["phone"] ?? "";
                final String email = user["email"] ?? "";
                final String website = data["company_website"] ?? "";

                // Stats
                final num rating = num.tryParse(data["average_rating"].toString()) ?? 0.0;
                final int totalReviews = int.tryParse(data["total_reviews"].toString()) ?? 0;
                final int yearsExp = int.tryParse(data["years_experience"].toString()) ?? 0;

                // Address
                String address = [
                  data["street_address"],
                  data["city"],
                  data["state"],
                  data["country"]
                ].where((s) => s != null && s.toString().isNotEmpty).join(", ");

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                      top: headerHeight + 20,
                      left: 20,
                      right: 20,
                      bottom: 40
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.5), width: 4),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))
                              ]
                          ),
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: AppColors.primary,
                            // You can add data['user']['avatar'] logic here if API returns an image URL
                            child: Text(
                              _getInitials(fullName),
                              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Name & Title
                      Text(fullName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      Text(title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),

                      const SizedBox(height: 20),

                      // --- NEW: QUICK STATS ROW ---
                      _buildStatsRow(yearsExp, rating, totalReviews),

                      const SizedBox(height: 25),

                      // --- UPDATED: Contact Buttons (Call, Email, Web) ---
                      Row(
                        children: [
                          if (phone.isNotEmpty)
                            Expanded(child: _buildContactButton(Icons.call, "Call", phone, () => _makePhoneCall(phone))),
                          if (phone.isNotEmpty && (email.isNotEmpty || website.isNotEmpty))
                            const SizedBox(width: 10),
                          if (email.isNotEmpty)
                            Expanded(child: _buildContactButton(Icons.email, "Email", "Send Mail", () => _sendEmail(email))),
                          if (email.isNotEmpty && website.isNotEmpty)
                            const SizedBox(width: 10),
                          if (website.isNotEmpty && website != "Not available")
                            Expanded(child: _buildContactButton(Icons.language, "Website", "Visit", () => _launchUrl(website))),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // --- NEW: SOCIAL MEDIA LINKS ---
                      _buildSocialMediaSection(data),

                      const SizedBox(height: 20),

                      // Details Sections
                      _buildDetailSection("About", data["bio"] ?? data["experience_summary"]),

                      // --- NEW: Availability Section ---
                      _buildAvailabilitySection(data["working_hours"], data["is_available_for_consultation"]),

                      if (address.isNotEmpty) _buildLocationSection(address),

                      // --- UPDATED: Expertise (Now includes Countries & Languages) ---
                      _buildExpertiseSection(
                          specializations: data["specializations"],
                          qualifications: data["qualifications"],
                          countries: data["expertise_countries"],
                          languages: data["languages"]
                      ),

                      const SizedBox(height: 10),

                      // Reviews Widget (Kept from your code)
                      ReviewsListWidget(consultantId: widget.consultantId),
                    ],
                  ),
                );
              },
            ),

            // --- GLASS HEADER (Fixed) ---
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      top: topPadding + 15,
                      bottom: 20,
                      left: 20,
                      right: 20,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.3),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      border: Border.all(color: Colors.white.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const Text(
                          "Consultant Profile",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  // 1. New Stats Row Helper
  Widget _buildStatsRow(int years, num rating, int reviews) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSingleStat("$years Yrs", "Experience"),
          Container(height: 30, width: 1, color: Colors.grey.shade300),
          _buildSingleStat(rating.toStringAsFixed(1), "Rating", icon: Icons.star, iconColor: Colors.amber),
          Container(height: 30, width: 1, color: Colors.grey.shade300),
          _buildSingleStat("$reviews", "Reviews"),
        ],
      ),
    );
  }

  Widget _buildSingleStat(String value, String label, {IconData? icon, Color? iconColor}) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            if (icon != null) ...[
              const SizedBox(width: 4),
              Icon(icon, size: 16, color: iconColor)
            ]
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  // 2. Updated Social Media Helper
  Widget _buildSocialMediaSection(Map<String, dynamic> data) {
    List<Widget> socialButtons = [];

    void addBtn(String? url, IconData icon, Color bg) {
      if (url != null && url.isNotEmpty) {
        socialButtons.add(InkWell(
          onTap: () => _launchUrl(url),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bg.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: bg, size: 22),
          ),
        ));
      }
    }

    addBtn(data['linkedin_profile'], Icons.link, const Color(0xFF0077B5)); // LinkedIn Blue
    addBtn(data['twitter_profile'], Icons.alternate_email, const Color(0xFF1DA1F2)); // Twitter Blue
    addBtn(data['facebook_profile'], Icons.facebook, const Color(0xFF4267B2)); // FB Blue

    // Portfolios
    if (data['portfolio_links'] != null && (data['portfolio_links'] as List).isNotEmpty) {
      addBtn(data['portfolio_links'][0], Icons.work_outline, Colors.orange);
    }

    if (socialButtons.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...socialButtons.expand((widget) => [widget, const SizedBox(width: 15)]).toList()..removeLast(),
      ],
    );
  }

  Widget _buildContactButton(IconData icon, String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(height: 8),
            Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, String? content) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      const SizedBox(height: 10),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withOpacity(0.1))),
        child: Text(content, style: const TextStyle(fontSize: 15, height: 1.6, color: AppColors.textSecondary)),
      ),
      const SizedBox(height: 25),
    ]);
  }

  // 3. New Availability & Hours Section
  Widget _buildAvailabilitySection(Map<String, dynamic>? hours, bool? isAvailable) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Availability", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: (isAvailable ?? false) ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)
              ),
              child: Text(
                (isAvailable ?? false) ? "Available Now" : "Unavailable",
                style: TextStyle(color: (isAvailable ?? false) ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            )
          ],
        ),
        const SizedBox(height: 10),
        if (hours != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withOpacity(0.1))),
            child: Column(
              children: hours.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                    Text(e.value.toString(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  ],
                ),
              )).toList(),
            ),
          ),
        const SizedBox(height: 25),
      ],
    );
  }

  Widget _buildLocationSection(String address) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Location", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      const SizedBox(height: 10),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withOpacity(0.1))),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.redAccent, size: 24),
            const SizedBox(width: 12),
            Expanded(child: Text(address, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500))),
          ],
        ),
      ),
      const SizedBox(height: 25),
    ]);
  }

  // 4. Updated Expertise (Groups multiple arrays)
  Widget _buildExpertiseSection({
    required dynamic specializations,
    required dynamic qualifications,
    required dynamic countries,
    required dynamic languages,
  }) {
    List<String> items = [];
    if (specializations != null) items.addAll(List<String>.from(specializations));
    if (qualifications != null) items.addAll(List<String>.from(qualifications));
    if (countries != null) items.addAll(List<String>.from(countries));
    if (languages != null) items.addAll(List<String>.from(languages));

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Expertise & Qualifications", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      const SizedBox(height: 10),
      Wrap(
        spacing: 10, runSpacing: 10,
        children: items.map((i) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.primary.withOpacity(0.2))),
          child: Text(i, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
        )).toList(),
      ),
      const SizedBox(height: 25),
    ]);
  }
}

// ... Keep your existing ReviewsListWidget and _ReviewItem code exactly as it was ...

// ------------------------------------------------------------------
//  REVIEWS LIST
// ------------------------------------------------------------------
// ------------------------------------------------------------------
//  REVIEWS LIST (Updated with "See More" logic)
// ------------------------------------------------------------------
class ReviewsListWidget extends StatefulWidget {
  final int consultantId;
  const ReviewsListWidget({super.key, required this.consultantId});

  @override
  State<ReviewsListWidget> createState() => _ReviewsListWidgetState();
}

class _ReviewsListWidgetState extends State<ReviewsListWidget> {
  late Future<Map<String, dynamic>> _reviewsFuture;

  // 1. New variable to control "See More" / "See Less"
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  void _loadReviews() {
    setState(() {
      _reviewsFuture = ApiService.getConsultantReviews(widget.consultantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Reviews",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            InkWell(
              onTap: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => WriteReviewScreen(
                            consultantId: widget.consultantId)));
                _loadReviews();
              },
              child: const Text("Write Review",
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ),
          ],
        ),
        const SizedBox(height: 15),
        FutureBuilder<Map<String, dynamic>>(
          future: _reviewsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary));
            }

            // Safe parsing
            List reviews = [];
            final data = snapshot.data;
            try {
              if (data != null &&
                  data['data'] is Map &&
                  data['data']['reviews'] != null) {
                var rData = data['data']['reviews'];
                reviews = (rData is Map && rData['data'] is List)
                    ? rData['data']
                    : (rData is List ? rData : []);
              }
            } catch (_) {}

            if (reviews.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                child: Center(
                    child: Text("No reviews yet.",
                        style: TextStyle(color: Colors.grey.shade500))),
              );
            }

            // 2. Logic to slice the list
            final int initialCount = 3; // How many to show initially
            final bool hasMore = reviews.length > initialCount;

            // If expanded, show all. If not, show only the first 4.
            final List visibleReviews = _isExpanded
                ? reviews
                : (hasMore ? reviews.sublist(0, initialCount) : reviews);

            return Column(
              children: [
                // Render the visible list
                ...visibleReviews.map((r) => r is Map<String, dynamic>
                    ? _ReviewItem(reviewData: r)
                    : const SizedBox()).toList(),

                // 3. The "See More" Button
                if (hasMore)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: AppColors.primary.withOpacity(0.2))
                            )
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isExpanded ? "Show Less" : "See More Reviews (${reviews.length - initialCount} more)",
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              color: AppColors.primary,
                              size: 20,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
// ------------------------------------------------------------------
//  REVIEW ITEM (Reactions Fixed: Left - Center - Right)
// ------------------------------------------------------------------
class _ReviewItem extends StatefulWidget {
  final Map<String, dynamic> reviewData;
  const _ReviewItem({required this.reviewData});

  @override
  State<_ReviewItem> createState() => _ReviewItemState();
}

class _ReviewItemState extends State<_ReviewItem> {
  int likesCount = 0;
  int dislikesCount = 0;
  int helpfulCount = 0;
  String? myReactionType;

  @override
  void initState() {
    super.initState();
    _parseData();
  }

  void _parseData() {
    likesCount = int.tryParse(widget.reviewData['like_count'].toString()) ?? 0;
    dislikesCount = int.tryParse(widget.reviewData['dislike_count'].toString()) ?? 0;
    helpfulCount = int.tryParse(widget.reviewData['helpful_count'].toString()) ?? 0;

    final r = widget.reviewData['my_reaction'];
    if (r != null) {
      if (r is Map && r['reaction'] != null) myReactionType = r['reaction'].toString();
      else if (r is String) myReactionType = r;
    }
  }

  Future<void> _handleReaction(String newType) async {
    final reviewId = widget.reviewData['id'];
    final String? oldType = myReactionType;
    final int oldLikes = likesCount;
    final int oldDislikes = dislikesCount;
    final int oldHelpful = helpfulCount;

    setState(() {
      if (myReactionType == newType) {
        _modifyCount(myReactionType!, -1);
        myReactionType = null;
      } else {
        if (myReactionType != null) _modifyCount(myReactionType!, -1);
        _modifyCount(newType, 1);
        myReactionType = newType;
      }
    });

    bool success;
    if (myReactionType == null) {
      try { success = await ApiService.removeReaction(reviewId); } catch (_) { success = false; }
    } else {
      success = await ApiService.addReaction(reviewId, myReactionType!);
    }

    if (!success && mounted) {
      setState(() {
        myReactionType = oldType;
        likesCount = oldLikes;
        dislikesCount = oldDislikes;
        helpfulCount = oldHelpful;
      });
    }
  }

  void _modifyCount(String type, int change) {
    if (type == 'like') likesCount += change;
    if (type == 'dislike') dislikesCount += change;
    if (type == 'helpful') helpfulCount += change;
  }

  String _getInitials(String? f, String? l) => "${(f ?? '').isNotEmpty ? f![0] : ''}${(l ?? '').isNotEmpty ? l![0] : ''}".toUpperCase();

  @override
  Widget build(BuildContext context) {
    final userObj = widget.reviewData['user'] ?? {};
    final userName = "${userObj['f_name'] ?? ''} ${userObj['l_name'] ?? ''}".trim();
    final rating = widget.reviewData['rating'] ?? 0;
    final reviewText = widget.reviewData['review'] ?? widget.reviewData['comment'] ?? "";
    final reply = widget.reviewData['consultant_reply'];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(_getInitials(userObj['f_name'], userObj['l_name']), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName.isEmpty ? "Anonymous" : userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                    Row(
                      children: List.generate(5, (index) => Icon(index < rating ? Icons.star_rounded : Icons.star_outline_rounded, size: 14, color: index < rating ? Colors.amber : Colors.grey.shade300)),
                    )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(reviewText, style: const TextStyle(color: AppColors.textPrimary, height: 1.5, fontSize: 14)),

          if (reply != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Response:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(reply, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          const Divider(),

          // --- FIXED REACTION ROW (SpaceBetween for Left/Center/Right placement) ---
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAction('like', Icons.thumb_up_alt_outlined, Icons.thumb_up_alt, likesCount),
                _buildAction('dislike', Icons.thumb_down_alt_outlined, Icons.thumb_down_alt, dislikesCount),
                _buildAction('helpful', Icons.lightbulb_outline, Icons.lightbulb, helpfulCount),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAction(String type, IconData iconOff, IconData iconOn, int count) {
    bool isActive = myReactionType == type;
    Color color = isActive ? AppColors.primary : Colors.grey.shade400;

    return InkWell(
      onTap: () => _handleReaction(type),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(isActive ? iconOn : iconOff, size: 20, color: color),
            const SizedBox(width: 6),
            Text("$count", style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}