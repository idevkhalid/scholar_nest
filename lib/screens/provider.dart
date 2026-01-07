import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import 'WriteReviewScreen.dart';

// --- YOUR COLOR FILE (Merged for context) ---
class AppColors {
  static const Color primary = Color(0xFF1B3C53);
  static const Color background = Color(0xFFEAF1F8);
  static const Color textPrimary = Color(0xFF1B3C53);
  static const Color textSecondary = Color(0xFF7B7B7B);
  static const Color cardBackground = Colors.white;

  // Exact Gradient from your SavedScholarshipsScreen
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x9977A9FF), // Light Blue-ish
      Colors.white,      // White at bottom
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
    // Get Top Padding for Status Bar
    final double topPadding = MediaQuery.of(context).padding.top;
    // Calculate header height to push content down (Top padding + content height + bottom padding)
    final double headerHeight = topPadding + 15 + 30 + 20;

    return Scaffold(
      body: Container(
        // 1. EXACT BACKGROUND GRADIENT
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Stack(
          children: [
            // --- 2. SCROLLABLE BODY ---
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

                final data = responseData["data"] ?? {};
                final user = data["user"] ?? {};
                final String name = user["name"] ?? "Consultant";
                final String title = data["professional_title"] ?? "Professional Consultant";
                final String phone = data["phone"] ?? user["phone"] ?? "";
                final String website = data["company_website"] ?? "";

                String address = [
                  data["street_address"],
                  data["city"],
                  data["state"],
                  data["country"]
                ].where((s) => s != null && s.toString().isNotEmpty).join(", ");

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                      top: headerHeight + 20, // Push content below the fixed header
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
                            child: Text(
                              _getInitials(name),
                              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Name & Title
                      Text(name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      Text(title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),

                      const SizedBox(height: 25),

                      // Contact Buttons
                      Row(
                        children: [
                          if (phone.isNotEmpty)
                            Expanded(child: _buildContactButton(Icons.call, "Call", phone, () => _makePhoneCall(phone))),
                          if (phone.isNotEmpty && website.isNotEmpty)
                            const SizedBox(width: 15),
                          if (website.isNotEmpty && website != "Not available")
                            Expanded(child: _buildContactButton(Icons.language, "Website", "Visit Link", () => _launchUrl(website))),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Details Sections
                      _buildDetailSection("About", data["experience_summary"]),
                      if (address.isNotEmpty) _buildLocationSection(address),
                      _buildExpertiseSection(data["specializations"], data["qualifications"]),

                      const SizedBox(height: 10),

                      // Reviews
                      ReviewsListWidget(consultantId: widget.consultantId),
                    ],
                  ),
                );
              },
            ),

            // --- 3. EXACT GLASS HEADER (Fixed at Top) ---
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
                      color: AppColors.primary.withOpacity(0.3), // Matches your provided screen
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                      ),
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
                        // Empty SizedBox to balance the title centering
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

  Widget _buildContactButton(IconData icon, String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
            ),
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

  Widget _buildExpertiseSection(dynamic specs, dynamic quals) {
    List<String> items = [];
    if (specs != null) items.addAll(List<String>.from(specs));
    if (quals != null) items.addAll(List<String>.from(quals));

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Expertise", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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