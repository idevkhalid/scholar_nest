import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/colors.dart';
import '../services/api_service.dart';

class ProfessorDetailScreen extends StatefulWidget {
  final int professorId;
  final String professorName;

  const ProfessorDetailScreen({
    super.key,
    required this.professorId,
    required this.professorName,
  });

  @override
  State<ProfessorDetailScreen> createState() => _ProfessorDetailScreenState();
}

class _ProfessorDetailScreenState extends State<ProfessorDetailScreen> {
  // Data State
  bool _isLoading = true;
  Map<String, dynamic>? _professor;
  String? _errorMessage;

  // UI State
  ScrollController? _scrollController;
  bool _showNameInHeader = false;

  @override
  void initState() {
    super.initState();

    // 1. Initialize Controller
    _scrollController = ScrollController();

    // 2. Add Listener safely
    _scrollController?.addListener(() {
      if (!mounted || _scrollController == null) return;
      if (_scrollController!.hasClients) {
        bool shouldShowName = _scrollController!.offset > 150;
        if (shouldShowName != _showNameInHeader) {
          setState(() {
            _showNameInHeader = shouldShowName;
          });
        }
      }
    });

    // 3. Fetch Data
    _fetchProfessorDetails();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  Future<void> _fetchProfessorDetails() async {
    final response = await ApiService.getProfessorById(widget.professorId);
    if (mounted) {
      if (response['success'] == true || response['status'] == 'success') {
        setState(() {
          _professor = response['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? "Unknown error occurred";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _launchUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    final Uri uri = Uri.parse(urlString.startsWith('http') ? urlString : 'https://$urlString');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Could not launch $uri");
    }
  }

  @override
  Widget build(BuildContext context) {
    final scrollController = _scrollController ?? ScrollController();
    final double topPadding = MediaQuery.of(context).padding.top;

    // Theme Helpers
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          // Use gradient in Light Mode, solid dark color in Dark Mode for better readability
          gradient: isDarkMode ? null : AppColors.backgroundGradient,
          color: isDarkMode ? Theme.of(context).scaffoldBackgroundColor : null,
        ),
        child: Stack(
          children: [
            // ---------------- LAYER 1: SCROLLABLE CONTENT ----------------
            Positioned.fill(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _errorMessage != null
                  ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                  : SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.only(
                  top: topPadding + 80,
                  left: 20,
                  right: 20,
                  bottom: 40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(isDarkMode, textColor),
                    const SizedBox(height: 20),
                    _buildStatusSection(isDarkMode),
                    const SizedBox(height: 20),
                    _buildContactSection(isDarkMode, textColor),
                    const SizedBox(height: 20),
                    _buildResearchSection(isDarkMode, textColor),
                    const SizedBox(height: 20),
                    if (_professor!['scholarship_details'] != null &&
                        _professor!['scholarship_details'].toString().isNotEmpty)
                      _buildSectionTitle(
                          "Scholarship Details",
                          _professor!['scholarship_details'],
                          isDarkMode,
                          textColor
                      ),
                  ],
                ),
              ),
            ),

            // ---------------- LAYER 2: GLASS HEADER ----------------
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
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: EdgeInsets.only(
                        top: topPadding + 10, bottom: 15, left: 10, right: 20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.85),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              _showNameInHeader
                                  ? (_professor?['name'] ?? widget.professorName)
                                  : "Professor Details",
                              key: ValueKey<bool>(_showNameInHeader),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
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

  // Helper to get card background color based on theme
  Color _getCardColor(bool isDarkMode) {
    return isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  }

  // --- WIDGET 1: Main Profile Card ---
  Widget _buildProfileHeader(bool isDarkMode, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: _getCardColor(isDarkMode),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                _getInitials(_professor!['name']),
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            _professor!['name'] ?? "Professor",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "${_professor!['designation'] ?? ''} • ${_professor!['department'] ?? ''}",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.7)),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${_professor!['university_name'] ?? ''}, ${_professor!['university_country'] ?? ''}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET 2: Status Chips ---
  Widget _buildStatusSection(bool isDarkMode) {
    List<Widget> statuses = [];

    // Using withOpacity to ensure colors look good on both dark & light mode
    if (_professor!['accepting_students'] == true) {
      statuses.add(_buildStatusChip("Accepting Students", Colors.green.withOpacity(0.1), Colors.green));
    } else {
      statuses.add(_buildStatusChip("Not Accepting", Colors.red.withOpacity(0.1), Colors.red));
    }

    if (_professor!['offers_scholarships'] == true) {
      statuses.add(_buildStatusChip("Scholarships Available", Colors.orange.withOpacity(0.1), Colors.orange));
    }

    if (statuses.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 10, runSpacing: 10, children: statuses);
  }

  Widget _buildStatusChip(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: text.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  // --- WIDGET 3: Contact Info ---
  Widget _buildContactSection(bool isDarkMode, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: _getCardColor(isDarkMode),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.03), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.email_outlined, "Email", _professor!['email'], textColor, isLink: false),

          if (_professor!['personal_website'] != null && _professor!['personal_website'].toString().isNotEmpty) ...[
            Divider(height: 25, color: Colors.grey.withOpacity(0.2)),
            _buildInfoRow(Icons.language, "Website", _professor!['personal_website'], textColor, isLink: true),
          ],

          if (_professor!['google_scholar_link'] != null && _professor!['google_scholar_link'].toString().isNotEmpty) ...[
            Divider(height: 25, color: Colors.grey.withOpacity(0.2)),
            _buildInfoRow(Icons.school_outlined, "Google Scholar", "View Profile", textColor,
                linkUrl: _professor!['google_scholar_link'], isLink: true),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value, Color textColor, {bool isLink = false, String? linkUrl}) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return InkWell(
      onTap: isLink ? () => _launchUrl(linkUrl ?? value) : null,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.6))),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isLink ? Colors.blueAccent : textColor,
                    decoration: isLink ? TextDecoration.underline : TextDecoration.none,
                    decorationColor: Colors.blueAccent.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          if (isLink) Icon(Icons.arrow_outward_rounded, size: 16, color: textColor.withOpacity(0.4))
        ],
      ),
    );
  }

  // --- WIDGET 4: Research Interests ---
  Widget _buildResearchSection(bool isDarkMode, Color textColor) {
    List<String> displayInterests = [];

    var listData = _professor!['research_interests_array'];
    var stringData = _professor!['research_interests'];

    if (listData != null && listData is List && listData.isNotEmpty) {
      displayInterests = listData.map((e) => e.toString()).toList();
    } else if (stringData != null && stringData is String && stringData.isNotEmpty) {
      displayInterests = stringData.split(',').map((e) => e.trim()).toList();
    }

    if (displayInterests.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getCardColor(isDarkMode),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(
                "Research Interests",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textColor),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: displayInterests.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                ),
                child: Text(
                  item,
                  style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --- WIDGET 5: Generic Section ---
  Widget _buildSectionTitle(String title, String content, bool isDarkMode, Color textColor) {
    if (content.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: _getCardColor(isDarkMode),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.03), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stars_rounded, color: Colors.amber.shade700),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textColor)),
            ],
          ),
          Divider(height: 20, color: Colors.grey.withOpacity(0.2)),
          Text(
            content,
            style: TextStyle(fontSize: 15, color: textColor, height: 1.6),
          ),
        ],
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return "P";
    List<String> parts = name.split(" ");
    if (parts.length > 1) return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    return name[0].toUpperCase();
  }
}