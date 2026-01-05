import 'dart:ui'; // Required for ImageFilter (Glass Effect)
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/api_service.dart';
import 'profeesor_detail_screen.dart'; // <--- IMPORT THE DETAIL SCREEN

class ProfessorListScreen extends StatefulWidget {
  const ProfessorListScreen({super.key});

  @override
  State<ProfessorListScreen> createState() => _ProfessorListScreenState();
}

class _ProfessorListScreenState extends State<ProfessorListScreen> {
  bool _isLoading = true;
  List<dynamic> _professors = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfessors();
  }

  // --- Fetch Data from API ---
  Future<void> _fetchProfessors() async {
    setState(() => _isLoading = true);

    final response = await ApiService.getProfessors();

    if (mounted) {
      if (response['status'] == 'success') {
        setState(() {
          _professors = response['data'];
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
        // Restore Background Gradient
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // ---------------- GLASS HEADER ----------------
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
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
                      color: AppColors.primary.withAlpha(120),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      border: Border.all(
                        color: Colors.white.withAlpha(60),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Professor List",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ---------------- DYNAMIC LIST ----------------
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                    ? Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
                    : _professors.isEmpty
                    ? const Center(
                    child: Text("No professors found.",
                        style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  itemCount: _professors.length,
                  itemBuilder: (context, index) {
                    final prof = _professors[index];

                    // Safely Extract Data
                    final int profId = prof['id']; // <--- Get ID
                    final name = prof['name'] ?? "Unknown";
                    final dept = prof['department'] ?? "";
                    final uni = prof['university_name'] ?? "";
                    final country = prof['university_country'] ?? "";
                    final email = prof['email'] ?? "No Email";

                    // Create Description String
                    final details = [dept, uni, country]
                        .where((s) => s.isNotEmpty)
                        .join(" • ");

                    // Wrap Card in GestureDetector to handle clicks
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProfessorDetailScreen(
                                  professorId: profId,
                                  professorName: name,
                                ),
                          ),
                        );
                      },
                      child: _knowledgeStyleCard(
                        title: name,
                        description: details,
                        email: email,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- CARD DESIGN ----------------
  Widget _knowledgeStyleCard({
    required String title,
    required String description,
    required String email,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withAlpha(25),
            ),
            child: Icon(
              Icons.school_outlined,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 28),
        ],
      ),
    );
  }
}