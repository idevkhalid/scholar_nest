import 'package:flutter/material.dart';
import 'provider.dart'; // Ensure this matches your file name

class ScholarshipDetailsPage extends StatelessWidget {
  const ScholarshipDetailsPage({super.key});

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
        body: Column(
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
                        _buildBulletPoint("Monthly Allowance over \$1200"),
                        _buildBulletPoint("A round trip plane ticket"),
                        _buildBulletPoint("Health insurance"),
                        _buildBulletPoint("Cultural activities"),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // --- UPDATED SECTION START ---
                    _buildDropdownCard(
                      title: "Scholarship Provider",
                      // Removed onTitleTap from here
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              // Put the click action here
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                    const ConsultantProfileScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                "EDHEC Business School",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: ScreenColors.primary,
                                  decoration: TextDecoration.underline, // Visual cue
                                  decorationColor: ScreenColors.primary,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    // --- UPDATED SECTION END ---

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
              children: const [
                _LabelText(text: "Study in"),
                SizedBox(height: 8),
                _LabelText(text: "Type"),
                SizedBox(height: 8),
                _LabelText(text: "Degree"),
                SizedBox(height: 8),
                _LabelText(text: "Deadline"),
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
                ),
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
        children: const [
          Text(
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
          SizedBox(height: 10),
          Text(
            "EDHEC offers merit- and social-background-based scholarships\ndepending on programme and level.\n\nMerit / Excellence Scholarships: For strong academic profiles.\nFor example, in Master's programmes there's an \"Academic Excellence Scholarship\" that can provide up to 50% tuition fee reduction.",
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  // Restored original _buildDropdownCard since we handle tap inside children now
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _CriteriaItem(label: "GPA", value: "3.8"),
                    SizedBox(height: 15),
                    _CriteriaItem(label: "Grade", value: "Not Specified"),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _CriteriaItem(label: "Gender", value: "Any"),
                    SizedBox(height: 15),
                    _CriteriaItem(label: "Work Experince", value: "Not Specified"),
                  ],
                ),
              ),
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
          _buildBulletPoint("Not Specified"),
          _buildBulletPoint("Bachelor's Degree"),
          _buildBulletPoint("Excellent academic record"),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "How to Apply",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: ScreenColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Apply",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                ),
              ),
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
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: Colors.black,
      ),
    );
  }
}

class _CriteriaItem extends StatelessWidget {
  final String label;
  final String value;
  const _CriteriaItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
            color: ScreenColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text("• $value", style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class ScreenColors {
  static const Color primary = Color(0xFF1B3C53);
  static const Color cardBackground = Colors.white;
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x9977A9FF),
      Colors.white,
    ],
  );
}