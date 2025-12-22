import 'package:flutter/material.dart';
import 'provider.dart'; // Matches your local file name
import '../services/api_service.dart'; // Ensure path to ApiService is correct
import '/screens/provider.dart'; // Ensure this import exists

class ScholarshipDetailsPage extends StatefulWidget {
  final int scholarshipId;

  const ScholarshipDetailsPage({super.key, required this.scholarshipId});

  @override
  State<ScholarshipDetailsPage> createState() => _ScholarshipDetailsPageState();
}

class _ScholarshipDetailsPageState extends State<ScholarshipDetailsPage> {
  Map<String, dynamic>? scholarshipData;
  bool isLoading = true;
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
          // --- DUMMY FALLBACK FOR DETAIL PAGE ---
          // If API fails (because DB is empty), use this mock data
          scholarshipData = {
            "title": "Global Excellence Scholarship",
            "university": "Harvard University",
            "country": "USA",
            "category": "Merit-based",
            "degree_level": "Master's Degree",
            "deadline": "Dec 20, 2025",
            "amount": "45,000",
            "currency": "USD",
            "description": "This is a prestigious scholarship designed for international students who demonstrate exceptional academic achievement and leadership potential. It covers tuition and living expenses.",
            "detailed_description": "Includes full tuition waiver, monthly stipend of \$2,000, and health insurance.",
            "eligibility_criteria": [
              "Minimum GPA of 3.8",
              "Proven leadership experience",
              "International student status",
              "Proficiency in English (IELTS 7.5+)"
            ],
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

                    _buildDropdownCard(
                      title: "Scholarship Provider",
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () {
                                if (scholarshipData?['consultant'] != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ConsultantProfileScreen(
                                        consultantId: scholarshipData!['consultant']['id'],
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                scholarshipData?['university'] ?? "Not Specified",
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
                  image: scholarshipData?['consultant']?['user']?['avatar'] != null
                      ? DecorationImage(
                    image: NetworkImage(scholarshipData!['consultant']['user']['avatar']),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: scholarshipData?['consultant']?['user']?['avatar'] == null
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
          // Using eligibility_criteria list from API
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
              onPressed: () {},
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
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: ScreenColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Apply", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'serif')),
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