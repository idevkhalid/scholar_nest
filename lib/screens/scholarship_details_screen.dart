import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../screens/provider.dart';
import 'how_to apply _screen.dart';


// --- LOCAL COLORS (Renamed to avoid conflict) ---
class PageColors {
  static const Color primary = Color(0xFF1B3C53);       // Dark Blue
  static const Color background = Color(0xFFEAF1F8);    // Light Blue/Grey
  static const Color textPrimary = Color(0xFF1B3C53);   // Dark Text
  static const Color textSecondary = Color(0xFF7B7B7B); // Grey Text
  static const Color cardBackground = Colors.white;
  static const Color accentGold = Color(0xFFD4AF37);    // Gold for Bookmark
}

class ScholarshipDetailsPage extends StatefulWidget {
  final int scholarshipId;

  const ScholarshipDetailsPage({super.key, required this.scholarshipId});

  @override
  State<ScholarshipDetailsPage> createState() => _ScholarshipDetailsPageState();
}

class _ScholarshipDetailsPageState extends State<ScholarshipDetailsPage> {
  Map<String, dynamic>? scholarshipData;
  bool isLoading = true;
  bool isApplying = false;
  bool isSaved = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  // --- LOGIC ---
  Future<void> _fetchDetails() async {
    final response = await ApiService.getScholarshipDetails(widget.scholarshipId);

    if (mounted) {
      setState(() {
        if (response['status'] == 'success') {
          scholarshipData = response['data'];
          if (response['meta'] != null) {
            isSaved = response['meta']['is_saved'] ?? false;
          }
        } else {
          // Fallback dummy data if API fails
          scholarshipData = {
            "title": "Global Excellence Scholarship",
            "country": "USA",
            "category": "Merit-based",
            "degree_level": "Master's Degree",
            "deadline": "2025-12-20 00:00:00", // Example with time to test formatting
            "amount": "45,000",
            "currency": "USD",
            "description": "This is a prestigious scholarship for international students.",
            "detailed_description": "Includes full tuition waiver and monthly stipend.",
            "consultant": {
              "id": 1,
              "user": {"name": "Dr. Sarah Johnson"}
            }
          };
        }
        isLoading = false;
      });
    }
  }

  Future<void> _toggleSave() async {
    setState(() => isSaved = !isSaved);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('access_token');
      if (token == null) {
        if (mounted) setState(() => isSaved = !isSaved);
        return;
      }
      await ApiService.toggleSaveScholarship(widget.scholarshipId, token);
    } catch (e) {
      if (mounted) setState(() => isSaved = !isSaved);
    }
  }

  Future<void> _handleApply() async {
    if (scholarshipData == null) return;
    final int? consultantId = scholarshipData?['consultant_id'] ?? scholarshipData?['consultant']?['id'];

    // Internal Apply
    if (consultantId != null) {
      setState(() => isApplying = true);
      final result = await ApiService.applyForScholarship(consultantId: consultantId, scholarshipId: widget.scholarshipId);

      if (mounted) {
        setState(() => isApplying = false);
        if (result['success'] == true) {
          _showSuccessDialog(result['message'] ?? "Application Sent!");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? "Failed to apply.")));
        }
      }
    }
    // External Link
    else {
      final String url = scholarshipData?['apply_link'] ?? scholarshipData?['official_website'] ?? "";
      if (url.isNotEmpty) {
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No application link found.")));
      }
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 10), Text("Success")]),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
      ),
    );
  }

  // --- HELPER TO CLEAN DATE ---
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "N/A";
    try {
      // If it has a space (e.g. 2025-10-10 00:00:00), split and take first part
      if (dateString.contains(' ')) {
        return dateString.split(' ')[0];
      }
      // If it has a T (e.g. 2025-10-10T00:00:00), split and take first part
      if (dateString.contains('T')) {
        return dateString.split('T')[0];
      }
      return dateString;
    } catch (e) {
      return dateString;
    }
  }

  // --- BEAUTIFUL UI STARTS HERE ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PageColors.primary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. HEADER (Dark Blue)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  _buildIconBtn(Icons.arrow_back_ios_new, () => Navigator.pop(context)),

                  const Text(
                    "Details",
                    style: TextStyle(fontFamily: 'serif', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),

                  // Bookmark Button
                  _buildIconBtn(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      _toggleSave,
                      iconColor: isSaved ? PageColors.accentGold : Colors.white
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 2. WHITE SHEET (Sliding up from bottom)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: PageColors.primary))
                    : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // -- TITLE --
                      Text(
                        scholarshipData?['title'] ?? "Scholarship Name",
                        style: const TextStyle(
                          fontSize: 24,
                          fontFamily: 'serif',
                          fontWeight: FontWeight.bold,
                          color: PageColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 25),

                      // -- INFO GRID --
                      Row(
                        children: [
                          Expanded(child: _buildGridItem(Icons.public, "Country", scholarshipData?['country'])),
                          const SizedBox(width: 15),
                          Expanded(child: _buildGridItem(Icons.school, "Degree", scholarshipData?['degree_level'])),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(child: _buildGridItem(Icons.category, "Type", scholarshipData?['category'])),
                          const SizedBox(width: 15),
                          // --- UPDATED DEADLINE WITH FORMATTING ---
                          Expanded(child: _buildGridItem(
                              Icons.calendar_month,
                              "Deadline",
                              _formatDate(scholarshipData?['deadline']) // Using helper here
                          )),
                        ],
                      ),

                      const SizedBox(height: 30),
                      Divider(color: Colors.grey.withOpacity(0.2), thickness: 1),
                      const SizedBox(height: 20),

                      // -- DESCRIPTION --
                      _buildSectionHeader("Description"),
                      Text(
                        scholarshipData?['description'] ?? "No description available.",
                        style: const TextStyle(fontSize: 15, color: Color(0xFF555555), height: 1.6),
                      ),

                      const SizedBox(height: 20),

                      // -- BENEFITS --
                      _buildExpansionTile(
                        title: "Scholarship Benefits",
                        icon: Icons.monetization_on_outlined,
                        children: [
                          _buildDetailRow("Amount", "${scholarshipData?['amount'] ?? 'N/A'} ${scholarshipData?['currency'] ?? ''}"),
                          if (scholarshipData?['detailed_description'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(scholarshipData!['detailed_description'], style: const TextStyle(color: Colors.black87, height: 1.4)),
                            ),
                        ],
                      ),

                      // -- ELIGIBILITY --
                      _buildExpansionTile(
                        title: "Eligibility Criteria",
                        icon: Icons.checklist_rtl,
                        children: (scholarshipData?['eligibility_criteria'] is List)
                            ? (scholarshipData!['eligibility_criteria'] as List).map((e) => _buildBullet(e.toString())).toList()
                            : [const Text("See official website for full details.")],
                      ),

                      const SizedBox(height: 25),

                      // -- PROVIDER PROFILE --
                      if (scholarshipData?['consultant'] != null) ...[
                        _buildSectionHeader("Provided By"),
                        GestureDetector(
                          onTap: () {
                            final cId = scholarshipData!['consultant']['id'];
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ConsultantProfileScreen(consultantId: cId)));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: PageColors.background,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.person, color: PageColors.primary),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        scholarshipData?['consultant']?['user']?['name'] ?? "Provider",
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'serif'),
                                      ),
                                      const Text("Tap to view profile", style: TextStyle(color: PageColors.textSecondary, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 40),

                      // -- BUTTONS --
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HowToApplyScreen())),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: const BorderSide(color: PageColors.primary),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text("How to Apply", style: TextStyle(color: PageColors.primary, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isApplying ? null : _handleApply,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PageColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: isApplying
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text("Apply Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildIconBtn(IconData icon, VoidCallback onTap, {Color iconColor = Colors.white}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  Widget _buildGridItem(IconData icon, String label, String? value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: PageColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: PageColors.primary),
          ),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 12, color: PageColors.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(
            value ?? "N/A",
            style: const TextStyle(fontSize: 14, fontFamily: 'serif', fontWeight: FontWeight.bold, color: PageColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontFamily: 'serif', fontWeight: FontWeight.bold, color: PageColors.primary),
      ),
    );
  }

  Widget _buildExpansionTile({required String title, required IconData icon, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Theme(
          data: ThemeData().copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: Icon(icon, color: PageColors.primary),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: PageColors.textPrimary)),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.bold, color: PageColors.textPrimary)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: PageColors.primary)),
          Expanded(child: Text(text, style: const TextStyle(height: 1.4))),
        ],
      ),
    );
  }
}