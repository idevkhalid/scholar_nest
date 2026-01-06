import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import '../services/api_service.dart';
import 'WriteReviewScreen.dart';

// --- UPDATED MODERN COLOR PALETTE ---
class ProfileColors {
  // Header gradients (lighter/softer)
  static final Color headerStart = const Color(0xFF1B3C53).withOpacity(0.85);
  static final Color headerEnd = const Color(0xFF4A90E2).withOpacity(0.85);

  // Screen Background (softer grey-blue)
  static const Color background = Color(0xFFF2F5F8);

  // Card Backgrounds
  static const Color cardColor = Colors.white;

  static const Color primary = Color(0xFF1B3C53);
  static const Color secondary = Color(0xFF4A90E2);
  static const Color textDark = Color(0xFF2D3436);
  static const Color textLight = Color(0xFF636E72);
}

class ConsultantProfileScreen extends StatefulWidget {
  final int consultantId;

  const ConsultantProfileScreen({
    super.key,
    required this.consultantId,
  });

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
    return Scaffold(
      backgroundColor: ProfileColors.background,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _consultantFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final responseData = snapshot.data;
          if (responseData == null || responseData["status"] != "success") {
            return Center(
                child: Text(
                    "Failed: ${responseData?['message'] ?? 'Unknown Error'}"));
          }

          final data = responseData["data"] ?? {};
          final user = data["user"] ?? {};
          final String name = user["name"] ?? "Consultant";
          final String title =
              data["professional_title"] ?? "Professional Consultant";

          String address = [
            data["street_address"],
            data["city"],
            data["state"],
            data["country"]
          ].where((s) => s != null && s.toString().isNotEmpty).join(", ");

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // --- 1. SHORT, LIGHTER HEADER ---
              SliverAppBar(
                expandedHeight: 150, // Made shorter
                pinned: true,
                backgroundColor: ProfileColors.headerStart,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle
                    ),
                    child: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 18),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        // Lighter, more opaque gradient colors
                        colors: [ProfileColors.headerStart, ProfileColors.headerEnd],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        // Compact Avatar and Text
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white.withOpacity(0.25),
                              child: Text(
                                _getInitials(name),
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // --- 2. LAYERED BODY CONTENT ---
              SliverToBoxAdapter(
                // Move up to create overlap effect
                child: Transform.translate(
                  offset: const Offset(0, -25),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: ProfileColors.background,
                      // Large top radius for overlap
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ABOUT SECTION (Clean Card)
                        if (data["experience_summary"] != null) ...[
                          _buildSectionTitle("About"),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: ProfileColors.cardColor,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0,5))]
                            ),
                            child: Text(
                              data["experience_summary"],
                              style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.6,
                                  color: ProfileColors.textLight),
                            ),
                          ),
                          const SizedBox(height: 25),
                        ],

                        // EXPERTISE (Rounder Chips)
                        if (data["specializations"] != null ||
                            data["qualifications"] != null) ...[
                          _buildSectionTitle("Expertise & Qualifications"),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              ...(data["specializations"] as List? ?? [])
                                  .map((s) => _buildChip(s, Colors.blue.shade50,
                                  Colors.blue.shade700)),
                              ...(data["qualifications"] as List? ?? [])
                                  .map((q) => _buildChip(q, Colors.orange.shade50,
                                  Colors.orange.shade800)),
                            ],
                          ),
                          const SizedBox(height: 25),
                        ],

                        // CONTACT DETAILS (Rounder Card)
                        _buildSectionTitle("Contact Details"),
                        Container(
                          decoration: BoxDecoration(
                              color: ProfileColors.cardColor,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0,5))]
                          ),
                          child: Column(
                            children: [
                              _buildContactTile(Icons.phone_rounded, "Phone",
                                  data["phone"] ?? user["phone"] ?? "Not available"),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Divider(height: 1, color: Colors.grey.shade100),
                              ),

                              _buildContactTile(Icons.language_rounded, "Website",
                                  data["company_website"] ?? "Not available",
                                  isLink: true),

                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Divider(height: 1, color: Colors.grey.shade100),
                              ),
                              _buildContactTile(Icons.location_on_rounded, "Address",
                                  address.isNotEmpty ? address : "Not available"),
                            ],
                          ),
                        ),

                        const SizedBox(height: 35),

                        // REVIEWS SECTION
                        ReviewsListWidget(consultantId: widget.consultantId),

                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 5),
      child: Text(title,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ProfileColors.textDark)),
    );
  }

  Widget _buildChip(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30), // Stadium shape
      ),
      child: Text(
        label,
        style:
        TextStyle(color: text, fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }

  Widget _buildContactTile(IconData icon, String title, String value,
      {bool isLink = false}) {
    final bool isClickable = isLink && value != "Not available" && value.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: isClickable ? () => _launchUrl(value) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: ProfileColors.secondary.withOpacity(0.1),
                    shape: BoxShape.circle
                ),
                child: Icon(icon, size: 20, color: ProfileColors.secondary),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isClickable
                            ? Colors.blue[700]
                            : ProfileColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              if (isClickable)
                Icon(Icons.arrow_outward_rounded, size: 18, color: Colors.blue[300]),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------
//  REVIEWS LIST WIDGET (Updated Look)
// ------------------------------------------------------------------
class ReviewsListWidget extends StatefulWidget {
  final int consultantId;
  const ReviewsListWidget({super.key, required this.consultantId});

  @override
  State<ReviewsListWidget> createState() => _ReviewsListWidgetState();
}

class _ReviewsListWidgetState extends State<ReviewsListWidget> {
  late Future<Map<String, dynamic>> _reviewsFuture;

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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 5),
              child: Text(
                "Reviews",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ProfileColors.textDark),
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => WriteReviewScreen(
                            consultantId: widget.consultantId)));
                _loadReviews();
              },
              style: TextButton.styleFrom(
                  foregroundColor: ProfileColors.secondary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
              ),
              icon: const Icon(Icons.edit_note_rounded, size: 18),
              label: const Text(
                "Write Review",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        FutureBuilder<Map<String, dynamic>>(
          future: _reviewsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator()));
            }
            if (snapshot.hasError) {
              return const Text("Unable to load reviews.");
            }

            final data = snapshot.data;
            List reviews = [];
            try {
              if (data != null &&
                  data['data'] is Map &&
                  data['data']['reviews'] != null) {
                var rData = data['data']['reviews'];
                reviews = (rData is Map && rData['data'] is List)
                    ? rData['data']
                    : (rData is List ? rData : []);
              } else if (data?['data'] is List) {
                reviews = data?['data'];
              }
            } catch (e) {
              // Ignore parse error
            }

            if (reviews.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: ProfileColors.cardColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    Icon(Icons.comments_disabled_rounded,
                        color: Colors.grey.shade300, size: 50),
                    const SizedBox(height: 15),
                    Text("No reviews yet.",
                        style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                  ],
                ),
              );
            }

            return Column(
              children: reviews.map((r) {
                if (r is Map<String, dynamic>) {
                  return _ReviewItem(reviewData: r);
                }
                return const SizedBox();
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------
//  SINGLE REVIEW ITEM (More Rounded)
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
    dislikesCount =
        int.tryParse(widget.reviewData['dislike_count'].toString()) ?? 0;
    helpfulCount =
        int.tryParse(widget.reviewData['helpful_count'].toString()) ?? 0;

    final reactionObj = widget.reviewData['my_reaction'];
    if (reactionObj != null) {
      if (reactionObj is Map && reactionObj['reaction'] != null) {
        myReactionType = reactionObj['reaction'].toString();
      } else if (reactionObj is Map && reactionObj['type'] != null) {
        myReactionType = reactionObj['type'].toString();
      } else if (reactionObj is String) {
        myReactionType = reactionObj;
      }
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
      try {
        success = await ApiService.removeReaction(reviewId);
      } catch (_) {
        success = false;
      }
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

  String _getInitials(String? fname, String? lname) {
    String f = (fname != null && fname.isNotEmpty) ? fname[0] : "";
    String l = (lname != null && lname.isNotEmpty) ? lname[0] : "";
    return (f + l).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasReplied = widget.reviewData['has_replied'] == true;
    final reply = widget.reviewData['consultant_reply'];
    final reviewText =
        widget.reviewData['review'] ?? widget.reviewData['comment'] ?? "";
    final userObj = widget.reviewData['user'] ?? {};
    final userName =
    "${userObj['f_name'] ?? ''} ${userObj['l_name'] ?? ''}".trim();
    final rating = widget.reviewData['rating'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: ProfileColors.cardColor,
          borderRadius: BorderRadius.circular(25), // Rounder reviews
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0,5))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: ProfileColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                child: Text(
                  _getInitials(userObj['f_name'], userObj['l_name']),
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ProfileColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName.isEmpty ? "Anonymous" : userName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 16,
                          color: Colors.amber,
                        );
                      }),
                    )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(reviewText,
              style: const TextStyle(
                  color: ProfileColors.textDark, height: 1.5, fontSize: 15)),
          if (hasReplied && reply != null) ...[
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: ProfileColors.background,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.reply_rounded, size: 16, color: ProfileColors.primary.withOpacity(0.7)),
                    const SizedBox(width: 8),
                    Text("Consultant Reply",
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: ProfileColors.primary.withOpacity(0.8))),
                  ]),

                  const SizedBox(height: 5),
                  Text(reply,
                      style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                          color: Colors.black87)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 15),
          Row(
            children: [
              _buildAction('like', Icons.thumb_up_outlined, Icons.thumb_up_rounded,
                  likesCount),
              const SizedBox(width: 20),
              _buildAction('dislike', Icons.thumb_down_outlined,
                  Icons.thumb_down_rounded, dislikesCount),
              const SizedBox(width: 20),
              _buildAction('helpful', Icons.lightbulb_outline_rounded, Icons.lightbulb_rounded,
                  helpfulCount),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAction(
      String type, IconData iconOff, IconData iconOn, int count) {
    bool isActive = myReactionType == type;
    return GestureDetector(
      onTap: () => _handleReaction(type),
      child: Row(
        children: [
          Icon(isActive ? iconOn : iconOff,
              size: 20,
              color: isActive ? ProfileColors.secondary : Colors.grey.shade400),
          const SizedBox(width: 6),
          if (count > 0)
            Text("$count",
                style: TextStyle(
                    fontSize: 13,
                    color: isActive ? ProfileColors.secondary : Colors.grey.shade500,
                    fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}