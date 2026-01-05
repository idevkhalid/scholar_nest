import 'dart:ui';
import 'package:flutter/material.dart';
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
  bool _isLoading = true;
  Map<String, dynamic>? _professor;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfessorDetails();
  }

  Future<void> _fetchProfessorDetails() async {
    final response = await ApiService.getProfessorById(widget.professorId);

    if (mounted) {
      if (response['status'] == 'success') {
        setState(() {
          _professor = response['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Stack(
          children: [
            // ---------------- CONTENT SCROLL VIEW ----------------
            Positioned.fill(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red)))
                  : SingleChildScrollView(
                padding: EdgeInsets.only(
                  // INCREASED THIS VALUE TO 120 FOR SPACING
                    top: topPadding + 120,
                    left: 20,
                    right: 20,
                    bottom: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 20),
                    _buildStatusSection(),
                    const SizedBox(height: 20),
                    _buildInfoSection(),
                    const SizedBox(height: 20),
                    if (_professor!['research_interests_array'] != null)
                      _buildResearchSection(),
                    const SizedBox(height: 20),
                    if (_professor!['scholarship_details'] != null)
                      _buildSectionTitle("Scholarship Details",
                          _professor!['scholarship_details']),
                  ],
                ),
              ),
            ),

            // ---------------- GLASS HEADER (FIXED TOP) ----------------
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
                    padding: EdgeInsets.only(
                        top: topPadding + 15, bottom: 20, left: 10, right: 20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(120),
                      border: Border(
                          bottom: BorderSide(color: Colors.white.withAlpha(60))),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.professorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
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

  // --- WIDGET: Main Profile Card ---
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary.withAlpha(30),
            child: Icon(Icons.person, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 15),
          Text(
            _professor!['name'] ?? "",
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          Text(
            "${_professor!['designation'] ?? ''} • ${_professor!['department'] ?? ''}",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            "${_professor!['university_name'] ?? ''}, ${_professor!['university_country'] ?? ''}",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: Status Tags ---
  Widget _buildStatusSection() {
    List<Widget> statuses = [];

    if (_professor!['accepting_students'] == true) {
      statuses.add(_buildStatusChip(
          "Accepting Students", Colors.green.shade100, Colors.green.shade800));
    }
    if (_professor!['offers_scholarships'] == true) {
      statuses.add(_buildStatusChip("Scholarships Available",
          Colors.amber.shade100, Colors.orange.shade800));
    }

    if (statuses.isEmpty) return const SizedBox.shrink();

    return Wrap(spacing: 10, runSpacing: 10, children: statuses);
  }

  Widget _buildStatusChip(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  // --- WIDGET: Contact & Web Info ---
  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          _buildInfoRow(Icons.email_outlined, "Email", _professor!['email']),
          if (_professor!['personal_website'] != null) ...[
            const Divider(),
            _buildInfoRow(Icons.language, "Website", _professor!['personal_website']),
          ],
          if (_professor!['google_scholar_link'] != null) ...[
            const Divider(),
            _buildInfoRow(Icons.school, "Google Scholar", "View Profile"),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  // --- WIDGET: Research Interests ---
  Widget _buildResearchSection() {
    List<dynamic> interests = _professor!['research_interests_array'] ?? [];
    if (interests.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Research Interests",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: interests.map((item) {
            return Chip(
              label: Text(item.toString()),
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 2,
              shadowColor: Colors.black.withAlpha(50),
              labelStyle: TextStyle(color: AppColors.primary, fontSize: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: AppColors.primary.withAlpha(50))),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- WIDGET: Generic Text Section ---
  Widget _buildSectionTitle(String title, String content) {
    if (content.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(content,
              style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5)),
        ],
      ),
    );
  }
}