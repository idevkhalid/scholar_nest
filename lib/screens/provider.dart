import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'WriteReviewScreen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x9977A9FF), Colors.white],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text("Consultant Profile",
              style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
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

            String address = [
              data["street_address"],
              data["city"],
              data["state"],
              data["country"]
            ].where((s) => s != null && s.toString().isNotEmpty).join(", ");

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- AVATAR ---
                  Center(
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          user["avatar"] ?? "https://via.placeholder.com/150",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.person,
                                size: 60, color: Colors.grey);
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // --- NAME ---
                  Center(
                    child: Text(
                      user["name"] ?? "Unknown Consultant",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B3C53)),
                    ),
                  ),
                  const Divider(thickness: 1.5, height: 30),

                  // --- INFO ---
                  _buildAttribute("Title", data["professional_title"] ?? "-"),

                  if (data["experience_summary"] != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Experience Summary:",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown,
                                  fontSize: 18)),
                          const SizedBox(height: 4),
                          Text(
                            data["experience_summary"],
                            style: const TextStyle(
                                color: Color(0xFF1B3C53), height: 1.4),
                          ),
                        ],
                      ),
                    ),

                  _buildAttribute(
                      "Phone", data["phone"] ?? user["phone"] ?? "-"),
                  _buildAttribute("Website", data["company_website"] ?? "-"),
                  _buildAttribute(
                      "Address", address.isNotEmpty ? address : "No address"),
                  const Divider(),
                  _buildAttribute("Qualifications",
                      (data["qualifications"] as List?)?.join(", ") ?? "-"),
                  const Divider(),
                  _buildAttribute("Specializations",
                      (data["specializations"] as List?)?.join(", ") ?? "-"),

                  const SizedBox(height: 20),

                  // --- SOCIALS ---
                  const Text("Social Media Links",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B3C53))),
                  const SizedBox(height: 12),
                  _buildAttribute("LinkedIn", data["linkedin"] ?? "-"),
                  _buildAttribute("Twitter", data["twitter"] ?? "-"),

                  const Divider(height: 40),

                  // --- REVIEWS SECTION ---
                  ReviewsListWidget(consultantId: widget.consultantId),

                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAttribute(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text("$label:",
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black54)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: Color(0xFF1B3C53))),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------
//  REVIEWS LIST WIDGET
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
            const Text(
              "Recent Reviews",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B3C53)),
            ),
            TextButton(
              onPressed: () async {
                // Navigate to Write Review Screen
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WriteReviewScreen(
                      consultantId: widget.consultantId,
                    ),
                  ),
                );
                // Refresh list on return
                _loadReviews();
              },
              child: const Text("Write a Review",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        ),
        const SizedBox(height: 10),
        FutureBuilder<Map<String, dynamic>>(
          future: _reviewsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return const Text("Error loading reviews.");
            }

            final data = snapshot.data;
            List reviews = [];

            // Robust Parsing Logic for different API structures
            try {
              if (data != null &&
                  data['data'] is Map &&
                  data['data']['reviews'] != null) {
                // Format: { data: { reviews: { data: [...] } } }
                var rData = data['data']['reviews'];
                if (rData is Map && rData['data'] is List) {
                  reviews = rData['data'];
                } else if (rData is List) {
                  reviews = rData;
                }
              } else if (data?['data'] is List) {
                // Format: { data: [...] }
                reviews = data?['data'];
              }
            } catch (e) {
              print("Parse error: $e");
            }

            if (reviews.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "No reviews yet. Be the first to share your experience!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            return Column(
              children: reviews.map((r) {
                if (r is Map<String, dynamic>) {
                  return _ReviewItem(reviewData: r);
                } else {
                  return const SizedBox();
                }
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------
//  SINGLE REVIEW ITEM (With Safe Avatar & Reactions)
// ------------------------------------------------------------------

class _ReviewItem extends StatefulWidget {
  final Map<String, dynamic> reviewData;
  const _ReviewItem({required this.reviewData});

  @override
  State<_ReviewItem> createState() => _ReviewItemState();
}

class _ReviewItemState extends State<_ReviewItem> {
  // Counts
  int likesCount = 0;
  int dislikesCount = 0;
  int helpfulCount = 0;

  // Track current user's reaction: 'like', 'dislike', 'helpful', or null
  String? myReactionType;

  @override
  void initState() {
    super.initState();
    _parseData();
  }

  void _parseData() {
    // 1. FIX: Use keys from your API logs (singular names)
    // The log showed: "like_count": 2, "dislike_count": 0...
    likesCount = int.tryParse(widget.reviewData['like_count'].toString()) ?? 0;
    dislikesCount =
        int.tryParse(widget.reviewData['dislike_count'].toString()) ?? 0;
    helpfulCount =
        int.tryParse(widget.reviewData['helpful_count'].toString()) ?? 0;

    // 2. Parse My Reaction
    final reactionObj = widget.reviewData['my_reaction'];

    if (reactionObj != null) {
      if (reactionObj is Map && reactionObj['reaction'] != null) {
        // Backend often returns "reaction" inside the object
        myReactionType = reactionObj['reaction'].toString();
      } else if (reactionObj is Map && reactionObj['type'] != null) {
        // Or sometimes "type"
        myReactionType = reactionObj['type'].toString();
      } else if (reactionObj is String) {
        myReactionType = reactionObj;
      }
    }
  }

  // Handle Button Tap
  Future<void> _handleReaction(String newType) async {
    final reviewId = widget.reviewData['id'];

    // Save previous state for rollback
    final String? oldType = myReactionType;
    final int oldLikes = likesCount;
    final int oldDislikes = dislikesCount;
    final int oldHelpful = helpfulCount;

    setState(() {
      // 1. If clicking the SAME reaction, remove it (Toggle Off)
      if (myReactionType == newType) {
        _modifyCount(myReactionType!, -1);
        myReactionType = null;
      }
      // 2. If clicking a DIFFERENT reaction (Switch)
      else {
        // Remove old if exists
        if (myReactionType != null) {
          _modifyCount(myReactionType!, -1);
        }
        // Add new
        _modifyCount(newType, 1);
        myReactionType = newType;
      }
    });

    // --- API CALL ---
    bool success;
    if (myReactionType == null) {
      // NOTE: Ensure your ApiService has this method, or remove this logic
      // if you don't support removing reactions.
      // If no remove method, you can just return true or ignore.
      try {
        success = await ApiService.removeReaction(reviewId);
      } catch (e) {
        // Fallback if method doesn't exist
        print("Remove reaction not implemented: $e");
        success = false;
      }
    } else {
      success = await ApiService.addReaction(reviewId, myReactionType!);
    }

    // --- REVERT IF FAILED ---
    if (!success) {
      if (mounted) {
        setState(() {
          myReactionType = oldType;
          likesCount = oldLikes;
          dislikesCount = oldDislikes;
          helpfulCount = oldHelpful;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Action failed. Check connection.")),
        );
      }
    }
  }

  // Helper to update local counts
  void _modifyCount(String type, int change) {
    if (type == 'like') likesCount += change;
    if (type == 'dislike') dislikesCount += change;
    if (type == 'helpful') helpfulCount += change;
  }

  // Helper to get User Name
  String _getUserName() {
    final userObj = widget.reviewData['user'];
    if (userObj != null && userObj is Map) {
      final fName = userObj['f_name'] ?? "";
      final lName = userObj['l_name'] ?? "";
      return "$fName $lName".trim();
    }
    return "User";
  }

  // Helper to get Avatar URL safely
  String _getAvatarUrl() {
    final userObj = widget.reviewData['user'];
    if (userObj != null && userObj is Map && userObj['avatar'] != null) {
      return userObj['avatar'];
    }
    return 'https://via.placeholder.com/50';
  }

  @override
  Widget build(BuildContext context) {
    final hasReplied = widget.reviewData['has_replied'] == true;
    final reply = widget.reviewData['consultant_reply'];

    // FIX: Check 'review' first (for new data), then 'comment' (for old)
    final reviewText =
        widget.reviewData['review'] ?? widget.reviewData['comment'] ?? "";

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              // --- SAFE AVATAR ---
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[200],
                child: ClipOval(
                  child: Image.network(
                    _getAvatarUrl(),
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.person,
                          size: 20, color: Colors.grey);
                    },
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(_getUserName(),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.amber[100],
                    borderRadius: BorderRadius.circular(4)),
                child: Row(children: [
                  const Icon(Icons.star, size: 12, color: Colors.orange),
                  Text(" ${widget.reviewData['rating']}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Display Review Text
          Text(reviewText, style: const TextStyle(height: 1.4)),

          if (hasReplied && reply != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.blueGrey[50],
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.blueGrey.withOpacity(0.2))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Consultant Reply:",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(reply,
                      style: const TextStyle(
                          fontStyle: FontStyle.italic, fontSize: 13)),
                ],
              ),
            )
          ],

          const Divider(height: 20),

          // --- 3 REACTIONS ROW ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildReactionBtn("Like", 'like', likesCount,
                  Icons.thumb_up_alt_outlined, Icons.thumb_up),
              _buildReactionBtn("Dislike", 'dislike', dislikesCount,
                  Icons.thumb_down_alt_outlined, Icons.thumb_down),
              _buildReactionBtn("Helpful", 'helpful', helpfulCount,
                  Icons.lightbulb_outline, Icons.lightbulb),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReactionBtn(
      String label, String type, int count, IconData iconOff, IconData iconOn) {
    final bool isActive = myReactionType == type;
    final Color activeColor = const Color(0xFF1B3C53);
    final Color inactiveColor = Colors.grey;

    return InkWell(
      onTap: () => _handleReaction(type),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        child: Row(
          children: [
            Icon(
              isActive ? iconOn : iconOff,
              size: 18,
              color: isActive ? activeColor : inactiveColor,
            ),
            const SizedBox(width: 5),
            Text(
              "$count",
              style: TextStyle(
                color: isActive ? activeColor : inactiveColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}