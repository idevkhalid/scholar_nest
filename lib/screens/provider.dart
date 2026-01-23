import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../constants/colors.dart';
import 'WriteReviewScreen.dart';

class ConsultantProfileScreen extends StatefulWidget {
  final int consultantId;

  const ConsultantProfileScreen({super.key, required this.consultantId});

  @override
  State<ConsultantProfileScreen> createState() => _ConsultantProfileScreenState();
}

class _ConsultantProfileScreenState extends State<ConsultantProfileScreen> {
  late Future<Map<String, dynamic>> _consultantFuture;
  bool _showHours = false;

  @override
  void initState() {
    super.initState();
    _consultantFuture = ApiService.getConsultantDetails(widget.consultantId);
  }

  // --- ACTIONS ---
  Future<void> _launchAction(String? urlString, {bool isPhone = false, bool isEmail = false}) async {
    if (urlString == null || urlString.isEmpty || urlString == "Not available") return;

    Uri uri;
    if (isPhone) {
      uri = Uri(scheme: 'tel', path: urlString);
    } else if (isEmail) {
      uri = Uri(scheme: 'mailto', path: urlString);
    } else {
      String cleanUrl = urlString.trim();
      if (!cleanUrl.startsWith("http")) cleanUrl = "https://$cleanUrl";
      uri = Uri.parse(cleanUrl);
    }

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Could not launch $uri");
    }
  }

  String _getInitials(String fName, String lName) {
    return "${fName.isNotEmpty ? fName[0] : ''}${lName.isNotEmpty ? lName[0] : ''}".toUpperCase();
  }

  // --- HELPER: FORMAT TIME TO 12-HOUR ---
  String _formatWorkingHours(dynamic value) {
    if (value == null) return "Closed";

    String start = "";
    String end = "";

    // Handle Map (e.g., {from: 09:00, to: 17:00})
    if (value is Map) {
      start = value['from'] ?? value['start'] ?? value['open'] ?? "";
      end = value['to'] ?? value['end'] ?? value['close'] ?? "";
    }
    // Handle List (e.g., ["09:00", "17:00"])
    else if (value is List && value.length >= 2) {
      start = value[0].toString();
      end = value[1].toString();
    }
    // Handle String (e.g., "09:00 - 17:00")
    else if (value is String) {
      if (value.toLowerCase().contains("closed")) return "Closed";
      // Try to split by common separators if it's a single string
      if (value.contains("-")) {
        var parts = value.split("-");
        if (parts.length == 2) {
          start = parts[0];
          end = parts[1];
        } else {
          return value; // Return as is if complicated
        }
      } else {
        return value;
      }
    }

    if (start.isEmpty && end.isEmpty) return "Closed";

    String formatSingleTime(String t) {
      t = t.trim().replaceAll(RegExp(r'[^0-9:]'), ''); // Clean non-time chars
      if (t.isEmpty) return "";
      try {
        final parts = t.split(':');
        int hour = int.parse(parts[0]);
        int minute = parts.length > 1 ? int.parse(parts[1]) : 0;
        String period = hour >= 12 ? 'PM' : 'AM';
        if (hour > 12) hour -= 12;
        if (hour == 0) hour = 12;
        return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period";
      } catch (e) {
        return t;
      }
    }

    String s = formatSingleTime(start);
    String e = formatSingleTime(end);

    if (s.isEmpty) return "Closed";
    if (e.isEmpty) return s;
    return "$s - $e";
  }

  @override
  Widget build(BuildContext context) {
    // --- THEME SETTINGS ---
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FD);
    final Color cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color primaryTextColor = isDarkMode ? Colors.white : Colors.black87;
    final Color secondaryTextColor = isDarkMode ? Colors.grey[400]! : const Color(0xFF4A4A4A);
    final Color dividerColor = isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;

    // Shadow
    final List<BoxShadow> cardShadow = [
      BoxShadow(
        color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.blue.withOpacity(0.1),
        blurRadius: 15,
        offset: const Offset(0, 5),
      )
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
              color: Colors.black26,
              shape: BoxShape.circle
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _consultantFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (!snapshot.hasData || snapshot.data?['data'] == null) {
            return Center(child: Text("Profile not found", style: TextStyle(color: primaryTextColor)));
          }

          final data = snapshot.data!['data'];
          final user = data['user'] ?? {};

          // --- DATA EXTRACTION ---
          final fullName = "${user['f_name'] ?? ''} ${user['l_name'] ?? ''}".trim();
          final title = data['professional_title'] ?? 'Consultant';
          final bio = data['bio'] ?? data['experience_summary'] ?? "No details available.";
          final avatar = user['avatar'];

          final phone = data['phone'];
          final email = user['email'];
          final website = data['company_website'];
          final linkedin = data['linkedin_profile'];

          final rating = (data['average_rating'] ?? 0).toString();
          final reviewsCount = (data['total_reviews'] ?? 0).toString();
          final experience = (data['years_experience'] ?? 0).toString();

          final isAvailable = data['is_available_for_consultation'] == true || data['is_available_for_consultation'] == 1;
          final Map<String, dynamic> workingHours = data['working_hours'] is Map<String, dynamic> ? data['working_hours'] : {};

          // Lists
          final specializations = List<String>.from(data['specializations'] ?? []);
          final countries = List<String>.from(data['expertise_countries'] ?? []);
          final languages = List<String>.from(data['languages'] ?? []);
          final qualifications = List<String>.from(data['qualifications'] ?? []);

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              children: [

                // ===========================================
                // 1. HEADER
                // ===========================================
                Stack(
                  alignment: Alignment.bottomCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 280,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.3)),
                            child: CircleAvatar(
                              radius: 45,
                              backgroundColor: cardColor,
                              backgroundImage: (avatar != null && avatar.isNotEmpty) ? NetworkImage(avatar) : null,
                              child: (avatar == null)
                                  ? Text(_getInitials(user['f_name']??'', user['l_name']??''), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary))
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text(title, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),

                          const SizedBox(height: 15),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if(phone != null) _buildHeaderActionBtn(Icons.call, "Call", () => _launchAction(phone, isPhone: true)),
                              if(email != null) _buildHeaderActionBtn(Icons.email, "Email", () => _launchAction(email, isEmail: true)),
                              if(website != null) _buildHeaderActionBtn(Icons.language, "Web", () => _launchAction(website)),
                              if(linkedin != null) _buildHeaderActionBtn(Icons.link, "Link", () => _launchAction(linkedin)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ===========================================
                // 2. STATS
                // ===========================================
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: cardShadow,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildBetterStat(experience, "Years Exp", Icons.work_history, Colors.blue, primaryTextColor),
                      Container(height: 40, width: 1, color: dividerColor),
                      _buildBetterStat(rating, "Rating", Icons.star_rounded, Colors.orange, primaryTextColor),
                      Container(height: 40, width: 1, color: dividerColor),
                      _buildBetterStat(reviewsCount, "Reviews", Icons.people_alt, Colors.purple, primaryTextColor),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ===========================================
                // 3. LANGUAGES CARD
                // ===========================================
                if(languages.isNotEmpty)
                  _buildModernSection(
                      "Languages Spoken", Icons.translate,
                      _buildModernChips(languages, AppColors.primary, isDarkMode, cardColor),
                      cardColor, cardShadow, primaryTextColor
                  ),

                // ===========================================
                // 4. AVAILABILITY & HOURS (UPDATED)
                // ===========================================
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: cardShadow,
                  ),
                  child: Column(
                    children: [
                      // Status Header
                      InkWell(
                        onTap: () => setState(() => _showHours = !_showHours),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: isAvailable ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                  shape: BoxShape.circle
                              ),
                              child: Icon(Icons.access_time_filled, color: isAvailable ? Colors.green : Colors.red, size: 20),
                            ),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Consultation Status", style: TextStyle(color: secondaryTextColor, fontSize: 12)),
                                Text(isAvailable ? "Available Now" : "Currently Busy", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isAvailable ? Colors.green[700] : Colors.red[700])),
                              ],
                            ),
                            const Spacer(),
                            if(workingHours.isNotEmpty)
                              Icon(_showHours ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.grey)
                          ],
                        ),
                      ),

                      // CLEANED HOURS LIST
                      if (_showHours && workingHours.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Container(height: 1, width: double.infinity, color: dividerColor),
                        const SizedBox(height: 15),
                        ...workingHours.entries.map((e) {
                          String day = e.key[0].toUpperCase() + e.key.substring(1);
                          String formattedTime = _formatWorkingHours(e.value);
                          bool isClosed = formattedTime == "Closed";

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(day, style: TextStyle(fontWeight: FontWeight.w600, color: secondaryTextColor, fontSize: 14)),
                                isClosed
                                    ? Text("Closed", style: TextStyle(color: Colors.red[300], fontSize: 13, fontWeight: FontWeight.w500))
                                    : Text(formattedTime, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black87)),
                              ],
                            ),
                          );
                        }).toList(),
                      ]
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ===========================================
                // 5. DETAILS SECTIONS
                // ===========================================
                _buildModernSection(
                    "About", Icons.person_outline,
                    Text(bio, style: TextStyle(height: 1.6, color: secondaryTextColor)),
                    cardColor, cardShadow, primaryTextColor
                ),

                if(specializations.isNotEmpty)
                  _buildModernSection(
                      "Specializations", Icons.verified_outlined,
                      _buildModernChips(specializations, AppColors.primary, isDarkMode, cardColor),
                      cardColor, cardShadow, primaryTextColor
                  ),

                if(countries.isNotEmpty)
                  _buildModernSection(
                      "Expertise Countries", Icons.public,
                      _buildModernChips(countries, Colors.orange[700]!, isDarkMode, cardColor),
                      cardColor, cardShadow, primaryTextColor
                  ),

                if(qualifications.isNotEmpty)
                  _buildModernSection(
                      "Qualifications", Icons.school_outlined,
                      Column(
                        children: qualifications.map((q) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(children: [
                            const Icon(Icons.check_circle, size: 18, color: Colors.green),
                            const SizedBox(width: 10),
                            Expanded(child: Text(q, style: TextStyle(color: secondaryTextColor, fontWeight: FontWeight.w500)))
                          ]),
                        )).toList(),
                      ),
                      cardColor, cardShadow, primaryTextColor
                  ),

                // ===========================================
                // 6. REVIEWS
                // ===========================================
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Client Reviews", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTextColor)),
                      Text("($reviewsCount)", style: TextStyle(color: secondaryTextColor)),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: cardShadow
                  ),
                  child: ReviewsListWidget(
                      consultantId: widget.consultantId,
                      cardColor: cardColor,
                      textColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      isDarkMode: isDarkMode
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildHeaderActionBtn(IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.3))
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10))
        ],
      ),
    );
  }

  Widget _buildBetterStat(String value, String label, IconData icon, Color color, Color textColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildModernSection(String title, IconData icon, Widget content, Color cardColor, List<BoxShadow> shadow, Color titleColor) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: titleColor)),
            ],
          ),
          const SizedBox(height: 15),
          content,
        ],
      ),
    );
  }

  Widget _buildModernChips(List<String> items, Color color, bool isDarkMode, Color cardColor) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
            color: isDarkMode ? color.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: color.withOpacity(0.3)),
            boxShadow: isDarkMode ? null : [BoxShadow(color: color.withOpacity(0.05), blurRadius: 5)]
        ),
        child: Text(t, style: TextStyle(color: isDarkMode ? color.withOpacity(0.9) : color, fontSize: 12, fontWeight: FontWeight.w600)),
      )).toList(),
    );
  }
}

// --- REVIEWS LIST WIDGET ---
class ReviewsListWidget extends StatefulWidget {
  final int consultantId;
  final Color cardColor;
  final Color textColor;
  final Color secondaryTextColor;
  final bool isDarkMode;

  const ReviewsListWidget({
    super.key,
    required this.consultantId,
    required this.cardColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.isDarkMode,
  });

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
    return FutureBuilder<Map<String, dynamic>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator()));

        List reviews = [];
        try {
          if (snapshot.data != null && snapshot.data!['data'] != null) {
            var r = snapshot.data!['data']['reviews'];
            reviews = (r is Map && r['data'] is List) ? r['data'] : (r is List ? r : []);
          }
        } catch (_) {}

        if (reviews.isEmpty) return Center(
          child: Column(children: [
            Icon(Icons.rate_review_outlined, size: 40, color: widget.secondaryTextColor.withOpacity(0.5)),
            const SizedBox(height: 10),
            Text("No reviews yet", style: TextStyle(color: widget.secondaryTextColor)),
            TextButton(
                onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => WriteReviewScreen(consultantId: widget.consultantId))); _loadReviews(); },
                child: const Text("Be the first to write a review")
            )
          ]),
        );

        return Column(
          children: [
            ...reviews.take(3).map((r) => _ReviewItem(
              reviewData: r,
              cardColor: widget.cardColor,
              textColor: widget.textColor,
              secondaryTextColor: widget.secondaryTextColor,
              isDarkMode: widget.isDarkMode,
            )),

            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.edit, size: 16),
                label: const Text("Write a Review"),
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => WriteReviewScreen(consultantId: widget.consultantId))); _loadReviews(); },
              ),
            )
          ],
        );
      },
    );
  }
}

// --- REVIEW ITEM ---
class _ReviewItem extends StatefulWidget {
  final Map<String, dynamic> reviewData;
  final Color cardColor;
  final Color textColor;
  final Color secondaryTextColor;
  final bool isDarkMode;

  const _ReviewItem({
    required this.reviewData,
    required this.cardColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.isDarkMode,
  });

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
      if (r is Map && r['reaction'] != null) {
        myReactionType = r['reaction'].toString();
      } else if (r is String) {
        myReactionType = r;
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
    final rating = num.tryParse(widget.reviewData['rating'].toString()) ?? 0;
    final reviewText = widget.reviewData['review'] ?? widget.reviewData['comment'] ?? "";
    final reply = widget.reviewData['consultant_reply'];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(_getInitials(userObj['f_name'], userObj['l_name']), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName.isEmpty ? "Anonymous" : userName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: widget.textColor)),
                    const SizedBox(height: 2),
                    Row(
                      children: List.generate(5, (index) => Icon(index < rating ? Icons.star_rounded : Icons.star_outline_rounded, size: 16, color: index < rating ? Colors.amber : Colors.grey.shade300)),
                    )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(reviewText, style: TextStyle(color: widget.textColor.withOpacity(0.9), height: 1.5, fontSize: 14)),

          if (reply != null) ...[
            const SizedBox(height: 15),
            IntrinsicHeight(
              child: Row(
                children: [
                  Container(width: 3, color: AppColors.primary.withOpacity(0.5)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: widget.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.subdirectory_arrow_right, size: 16, color: widget.secondaryTextColor),
                              const SizedBox(width: 5),
                              Text("Consultant Reply", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: widget.secondaryTextColor)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(reply, style: TextStyle(fontSize: 13, color: widget.textColor.withOpacity(0.85))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 15),
          Divider(color: widget.secondaryTextColor.withOpacity(0.2)),

          Padding(
            padding: const EdgeInsets.only(top: 5),
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
    Color color = isActive ? AppColors.primary : widget.secondaryTextColor;

    return InkWell(
      onTap: () => _handleReaction(type),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(isActive ? iconOn : iconOff, size: 18, color: color),
            const SizedBox(width: 6),
            Text("$count", style: TextStyle(fontSize: 13, color: color, fontWeight: isActive ? FontWeight.bold : FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}