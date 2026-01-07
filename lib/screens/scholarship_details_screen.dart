import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../screens/provider.dart';
import 'how_to apply _screen.dart';

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
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final response = await ApiService.getScholarshipDetails(widget.scholarshipId);

    if (mounted) {
      setState(() {
        if (response['status'] == 'success') {
          scholarshipData = response['data'];
        } else {
          // Fallback data
          scholarshipData = {
            "title": "Global Excellence Scholarship",
            "university": "Harvard University",
            "country": "USA",
            "category": "Merit-based",
            "degree_level": "Master's Degree",
            "deadline": "Dec 20, 2025",
            "amount": "45,000",
            "currency": "USD",
            "description": "This is a prestigious scholarship...",
            "detailed_description": "Includes full tuition waiver...",
            "eligibility_criteria": ["Minimum GPA of 3.8", "IELTS 7.5+"],
            "consultant": {
              "id": 1,
              "user": {
                "avatar": "https://i.pravatar.cc/150?u=1",
                "name": "Dr. Sarah Johnson"
              }
            }
          };
        }
        isLoading = false;
      });
    }
  }

  Future<void> _handleApply() async {
    final consultantMap = scholarshipData?['consultant'];
    if (consultantMap == null || consultantMap['id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Consultant information is missing.")),
      );
      return;
    }

    setState(() {
      isApplying = true;
    });

    final result = await ApiService.applyForScholarship(
      consultantId: consultantMap['id'],
      scholarshipId: widget.scholarshipId,
    );

    if (mounted) {
      setState(() {
        isApplying = false;
      });

      if (result['success'] == true) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 10),
                Text("Success"),
              ],
            ),
            content: Text(result['message'] ?? "Application submitted successfully!"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("OK", style: TextStyle(color: ScreenColors.primary)),
              )
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Failed to apply."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: ScreenColors.backgroundGradient,
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
          centerTitle: true,
          title: const Text(
            "Scholarship's Details",
            style: TextStyle(
              fontFamily: 'serif',
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 22,
            ),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: ScreenColors.primary))
            : errorMessage != null
            ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)))
            : Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildTopInfoCard(),
                    const SizedBox(height: 16),
                    _buildDescriptionCard(),
                    const SizedBox(height: 16),
                    _buildDropdownCard(
                      title: "Scholarship's benefits",
                      initiallyExpanded: true,
                      children: [
                        _buildBulletPoint("Amount: ${scholarshipData?['amount'] ?? 'N/A'} ${scholarshipData?['currency'] ?? ''}"),
                        if (scholarshipData?['detailed_description'] != null)
                          _buildBulletPoint(scholarshipData!['detailed_description']),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // --- SCHOLARSHIP PROVIDER CARD (FIXED) ---
                    _buildDropdownCard(
                      title: "Scholarship Provider",
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: scholarshipData?['consultant'] == null
                                  ? null
                                  : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ConsultantProfileScreen(
                                      consultantId: scholarshipData!['consultant']['id'],
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                // FIX: Check both locations for the name
                                scholarshipData?['consultant']?['user']?['name'] ??
                                    scholarshipData?['consultant']?['name'] ??
                                    "Not Available",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: ScreenColors.primary,
                                  decoration: TextDecoration.underline,
                                  decorationColor: ScreenColors.primary,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 16),
                    _buildEligibilityCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildTopInfoCard() {
    // FIX: Get avatar from either nested user object OR direct consultant object
    final avatarUrl = scholarshipData?['consultant']?['user']?['avatar'] ??
        scholarshipData?['consultant']?['avatar'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ScreenColors.cardBackground,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LabelText(text: "Study in: ${scholarshipData?['country'] ?? 'N/A'}"),
                const SizedBox(height: 8),
                _LabelText(text: "Type: ${scholarshipData?['category'] ?? 'N/A'}"),
                const SizedBox(height: 8),
                _LabelText(text: "Degree: ${scholarshipData?['degree_level'] ?? 'N/A'}"),
                const SizedBox(height: 8),
                _LabelText(text: "Deadline: ${scholarshipData?['deadline'] ?? 'N/A'}"),
              ],
            ),
          ),
          Column(
            children: [
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.bookmark_border, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                  image: avatarUrl != null
                      ? DecorationImage(
                    image: NetworkImage(avatarUrl),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: avatarUrl == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ScreenColors.cardBackground,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Scholarship's Description",
            style: TextStyle(
              fontFamily: 'serif',
              color: ScreenColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFFB0C4DE),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            scholarshipData?['description'] ?? "No description provided.",
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownCard({
    required String title,
    required List<Widget> children,
    bool initiallyExpanded = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ScreenColors.cardBackground,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          title: Text(
            title,
            style: const TextStyle(
              fontFamily: 'serif',
              color: ScreenColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFFB0C4DE),
            ),
          ),
          iconColor: Colors.black,
          collapsedIconColor: Colors.black,
          children: children,
        ),
      ),
    );
  }

  Widget _buildEligibilityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ScreenColors.cardBackground,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Eligibility Criteria",
                style: TextStyle(
                  fontFamily: 'serif',
                  color: ScreenColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFFB0C4DE),
                ),
              ),
              Icon(Icons.keyboard_arrow_down)
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Requirement Detailed",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              color: ScreenColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          if (scholarshipData?['eligibility_criteria'] != null)
            ...(scholarshipData!['eligibility_criteria'] as List).map((item) {
              return _buildBulletPoint(item.toString());
            }).toList()
          else
            _buildBulletPoint("Not Specified"),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const HowToApplyScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ScreenColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("How to Apply", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'serif')),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: ElevatedButton(
              onPressed: isApplying ? null : _handleApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: ScreenColors.primary,
                disabledBackgroundColor: ScreenColors.primary.withOpacity(0.7),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: isApplying
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Text("Apply", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'serif')),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabelText extends StatelessWidget {
  final String text;
  const _LabelText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
    );
  }
}

class ScreenColors {
  static const Color primary = Color(0xFF1B3C53);
  static const Color cardBackground = Colors.white;
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x9977A9FF), Colors.white],
  );
}