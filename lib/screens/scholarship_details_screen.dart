import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../screens/provider.dart' hide AppColors;
import 'how_to apply _screen.dart';

// --- STYLING IMPORTS ---
import '../widgets/modern_button.dart';
import '../constants/colors.dart';

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

  // --- LOGIC (RETAINED) ---
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
          scholarshipData = {
            "title": "Global Excellence Scholarship",
            "country": "USA",
            "category": "Merit-based",
            "degree_level": "Master's Degree",
            "deadline": "2025-12-20 00:00:00",
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
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(children: [Icon(Icons.check_circle, color: AppColors.success), const SizedBox(width: 10), const Text("Success")]),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK", style: TextStyle(color: AppColors.primary)))],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "N/A";
    try {
      if (dateString.contains(' ')) return dateString.split(' ')[0];
      if (dateString.contains('T')) return dateString.split('T')[0];
      return dateString;
    } catch (e) { return dateString; }
  }

  // --- REFINED UI ---
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.primary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildIconBtn(Icons.arrow_back_ios_new, () => Navigator.pop(context), isDark),
                  const Text(
                    "Details",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  _buildIconBtn(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      _toggleSave,
                      isDark,
                      iconColor: isSaved ? AppColors.secondary : Colors.white
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 2. MAIN SHEET
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.backgroundDark : AppColors.background,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TITLE
                      Text(
                        scholarshipData?['title'] ?? "Scholarship Name",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 25),

                      // INFO GRID
                      Row(
                        children: [
                          Expanded(child: _buildGridItem(Icons.public, "Country", scholarshipData?['country'], isDark)),
                          const SizedBox(width: 15),
                          Expanded(child: _buildGridItem(Icons.school, "Degree", scholarshipData?['degree_level'], isDark)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(child: _buildGridItem(Icons.category, "Type", scholarshipData?['category'], isDark)),
                          const SizedBox(width: 15),
                          Expanded(child: _buildGridItem(
                              Icons.calendar_month,
                              "Deadline",
                              _formatDate(scholarshipData?['deadline']),
                              isDark
                          )),
                        ],
                      ),

                      const SizedBox(height: 30),
                      Divider(color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.2), thickness: 1),
                      const SizedBox(height: 20),

                      // DESCRIPTION
                      _buildSectionHeader("Description", isDark),
                      Text(
                        scholarshipData?['description'] ?? "No description available.",
                        style: TextStyle(
                            fontSize: 15,
                            color: isDark ? Colors.white70 : AppColors.textSecondary,
                            height: 1.6
                        ),
                      ),
                      const SizedBox(height: 20),

                      // BENEFITS
                      _buildExpansionTile(
                        title: "Scholarship Benefits",
                        icon: Icons.monetization_on_outlined,
                        isDark: isDark,
                        children: [
                          _buildDetailRow("Amount", "${scholarshipData?['amount'] ?? 'N/A'} ${scholarshipData?['currency'] ?? ''}", isDark),
                          if (scholarshipData?['detailed_description'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                  scholarshipData!['detailed_description'],
                                  style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, height: 1.4)
                              ),
                            ),
                        ],
                      ),

                      // ELIGIBILITY
                      _buildExpansionTile(
                        title: "Eligibility Criteria",
                        icon: Icons.checklist_rtl,
                        isDark: isDark,
                        children: (scholarshipData?['eligibility_criteria'] is List)
                            ? (scholarshipData!['eligibility_criteria'] as List).map((e) => _buildBullet(e.toString(), isDark)).toList()
                            : [Text("See official website for full details.", style: TextStyle(color: isDark ? Colors.white70 : Colors.black87))],
                      ),

                      const SizedBox(height: 25),

                      // PROVIDER PROFILE
                      if (scholarshipData?['consultant'] != null) ...[
                        _buildSectionHeader("Provided By", isDark),
                        GestureDetector(
                          onTap: () {
                            final cId = scholarshipData!['consultant']['id'];
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ConsultantProfileScreen(consultantId: cId)));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cardDark : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                              boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50, height: 50,
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white10 : AppColors.background,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.person, color: isDark ? AppColors.secondary : AppColors.primary),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        scholarshipData?['consultant']?['user']?['name'] ?? "Provider",
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : AppColors.textPrimary),
                                      ),
                                      Text("Tap to view profile", style: TextStyle(color: isDark ? Colors.white38 : AppColors.textSecondary, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? Colors.white38 : Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 40),

                      // BUTTONS
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HowToApplyScreen())),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(color: isDark ? AppColors.secondary : AppColors.primary),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text("How to Apply", style: TextStyle(color: isDark ? AppColors.secondary : AppColors.primary, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: ModernButton(
                              text: "Apply Now",
                              onPressed: isApplying ? null : _handleApply,
                              isLoading: isApplying,
                              height: 52,
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

  // --- REUSABLE STYLED WIDGETS ---

  Widget _buildIconBtn(IconData icon, VoidCallback onTap, bool isDark, {Color iconColor = Colors.white}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  Widget _buildGridItem(IconData icon, String label, String? value, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: isDark ? AppColors.secondary : AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : AppColors.textSecondary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            value ?? "N/A",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? AppColors.secondary : AppColors.primary),
      ),
    );
  }

  Widget _buildExpansionTile({required String title, required IconData icon, required bool isDark, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Theme(
          data: ThemeData().copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: Icon(icon, color: isDark ? AppColors.secondary : AppColors.primary),
            title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : AppColors.textPrimary)),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 14),
          children: [
            TextSpan(text: "$label: ", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? AppColors.secondary : AppColors.textPrimary)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildBullet(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? AppColors.secondary : AppColors.primary)),
          Expanded(child: Text(text, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, height: 1.4))),
        ],
      ),
    );
  }
}