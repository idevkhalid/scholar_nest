import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/api_service.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;

  int _completionPercentage = 0;
  List<dynamic> _missingFields = [];

  // --- CONTROLLERS ---
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _dobController = TextEditingController();
  final _nationalityController = TextEditingController();
  String? _selectedGender;

  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();

  String? _selectedEducation;
  final _degreeTitleController = TextEditingController();
  final _institutionController = TextEditingController();
  final _gradYearController = TextEditingController();
  final _cgpaController = TextEditingController();

  final _aboutMeController = TextEditingController();
  final _skillsController = TextEditingController();
  final _languagesController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _githubController = TextEditingController();
  final _portfolioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  // --- 1. FETCH DATA ---
  Future<void> _fetchProfileData() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getUserProfile();
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        if (response['status'] == 'success') {
          final data = response['data'];
          if (data != null && data is Map<String, dynamic>) {
            _completionPercentage = response['completion'] ?? 0;
            _missingFields = response['missing'] ?? [];
            _populateFields(data);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'] ?? "Failed to load profile")));
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  void _populateFields(Map<String, dynamic> data) {
    _phoneController.text = data['phone'] ?? '';
    _whatsappController.text = data['whatsapp'] ?? '';
    _dobController.text = data['date_of_birth'] ?? '';
    _nationalityController.text = data['nationality'] ?? 'Pakistani';

    String? rawGender = data['gender'];
    if (rawGender != null) {
      _selectedGender = rawGender.toLowerCase();
      if (!["male", "female", "other"].contains(_selectedGender)) _selectedGender = null;
    }

    _address1Controller.text = data['address_line1'] ?? '';
    _address2Controller.text = data['address_line2'] ?? '';
    _cityController.text = data['city'] ?? '';
    _stateController.text = data['state'] ?? '';
    _countryController.text = data['country'] ?? 'Pakistan';

    String? rawEducation = data['highest_education'];
    if (rawEducation != null) {
      _selectedEducation = rawEducation.toLowerCase();
      if (!["matric", "intermediate", "bachelors", "masters", "phd"].contains(_selectedEducation)) _selectedEducation = null;
    }

    _degreeTitleController.text = data['degree_title'] ?? '';
    _institutionController.text = data['institution'] ?? '';
    _gradYearController.text = data['graduation_year']?.toString() ?? '';
    _cgpaController.text = data['cgpa']?.toString() ?? '';

    _aboutMeController.text = data['about_me'] ?? '';
    _linkedinController.text = data['linkedin_url'] ?? '';
    _githubController.text = data['github_url'] ?? '';
    _portfolioController.text = data['portfolio_url'] ?? '';

    if (data['skills'] != null) {
      _skillsController.text = (data['skills'] is List) ? (data['skills'] as List).join(', ') : data['skills'].toString();
    }
    if (data['languages'] != null) {
      _languagesController.text = (data['languages'] is List) ? (data['languages'] as List).join(', ') : data['languages'].toString();
    }
  }

  // --- 2. SAVE DATA ---
  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    List<String> skillsList = _skillsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    List<String> langList = _languagesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    final Map<String, dynamic> payload = {
      "phone": _phoneController.text,
      "whatsapp": _whatsappController.text,
      "date_of_birth": _dobController.text,
      "gender": _selectedGender,
      "nationality": _nationalityController.text,
      "address_line1": _address1Controller.text,
      "address_line2": _address2Controller.text,
      "city": _cityController.text,
      "state": _stateController.text,
      "country": _countryController.text,
      "highest_education": _selectedEducation,
      "degree_title": _degreeTitleController.text,
      "institution": _institutionController.text,
      "graduation_year": int.tryParse(_gradYearController.text),
      "cgpa": double.tryParse(_cgpaController.text),
      "about_me": _aboutMeController.text,
      "linkedin_url": _linkedinController.text,
      "github_url": _githubController.text,
      "portfolio_url": _portfolioController.text,
      "skills": skillsList,
      "languages": langList,
    };

    final response = await ApiService.updateUserProfile(payload);
    setState(() => _isSaving = false);

    if (mounted) {
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated!"), backgroundColor: Colors.green));
        setState(() => _isEditing = false);
        _fetchProfileData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message']), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD), // Very light grey background
      body: Stack(
        children: [
          // Background Gradient at top only
          Container(
            height: 300,
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          ),

          Column(
            children: [
              _buildHeader(topPadding),

              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FD),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_completionPercentage < 100 && !_isEditing) _buildCompletionCard(),
                        const SizedBox(height: 20),

                        // --- SECTIONS ---
                        _buildSection("Personal Info", [
                          _buildField("Phone Number", _phoneController, icon: Icons.phone, type: TextInputType.phone),
                          _buildField("WhatsApp", _whatsappController, icon: Icons.message, type: TextInputType.phone),
                          _buildField("Date of Birth", _dobController, icon: Icons.calendar_today, isDate: true),
                          _buildDropdown("Gender", ["male", "female", "other"], _selectedGender, (v) => setState(() => _selectedGender = v)),
                          _buildField("Nationality", _nationalityController, icon: Icons.flag),
                        ]),

                        _buildSection("Address", [
                          _buildField("Address Line 1", _address1Controller, icon: Icons.home),
                          _buildField("Address Line 2", _address2Controller, icon: Icons.home_work_outlined),
                          Row(
                            children: [
                              Expanded(child: _buildField("City", _cityController, icon: Icons.location_city)),
                              const SizedBox(width: 15),
                              Expanded(child: _buildField("State", _stateController, icon: Icons.map)),
                            ],
                          ),
                          _buildField("Country", _countryController, icon: Icons.public),
                        ]),

                        _buildSection("Education", [
                          _buildDropdown("Education Level", ["matric", "intermediate", "bachelors", "masters", "phd"], _selectedEducation, (v) => setState(() => _selectedEducation = v)),
                          _buildField("Degree Title", _degreeTitleController, icon: Icons.book),
                          _buildField("Institution", _institutionController, icon: Icons.account_balance),
                          Row(
                            children: [
                              Expanded(child: _buildField("Grad Year", _gradYearController, type: TextInputType.number, icon: Icons.date_range)),
                              const SizedBox(width: 15),
                              Expanded(child: _buildField("CGPA", _cgpaController, type: TextInputType.number, icon: Icons.grade)),
                            ],
                          ),
                        ]),

                        _buildSection("Professional", [
                          _buildField("Skills", _skillsController, icon: Icons.code, hint: "Flutter, Java, Python"),
                          _buildField("Languages", _languagesController, icon: Icons.translate, hint: "English, Urdu"),
                          _buildField("LinkedIn URL", _linkedinController, icon: Icons.link),
                          _buildField("Github URL", _githubController, icon: Icons.code),
                          _buildField("Portfolio URL", _portfolioController, icon: Icons.web),
                          _buildField("About Me", _aboutMeController, icon: Icons.person, maxLines: 4),
                        ]),

                        const SizedBox(height: 30),

                        if (_isEditing)
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                elevation: 5,
                                shadowColor: AppColors.primary.withOpacity(0.4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              onPressed: _isSaving ? null : _saveProfile,
                              child: _isSaving
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text("Save Changes", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------
  // UI HELPERS (Modern Styling)
  // ----------------------------------------------------------------

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 15, top: 10),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
        const SizedBox(height: 25),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller, {IconData? icon, TextInputType type = TextInputType.text, int maxLines = 1, String? hint, bool isDate = false}) {
    // VIEW MODE
    if (!_isEditing) {
      if (controller.text.isEmpty) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon ?? Icons.circle, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(controller.text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // EDIT MODE
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LABEL IS ABOVE THE INPUT (Static)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
          ),
          // INPUT FIELD
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: controller,
              keyboardType: type,
              maxLines: maxLines,
              readOnly: isDate,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              onTap: isDate
                  ? () async {
                DateTime? picked = await showDatePicker(context: context, initialDate: DateTime(2000), firstDate: DateTime(1950), lastDate: DateTime.now());
                if (picked != null) {
                  controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                }
              }
                  : null,
              decoration: InputDecoration(
                hintText: hint ?? "Enter $label",
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: icon != null ? Icon(icon, color: Colors.grey[400], size: 20) : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? selectedValue, Function(String?) onChanged) {
    if (!_isEditing) {
      if (selectedValue == null || selectedValue.isEmpty) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.list, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(selectedValue[0].toUpperCase() + selectedValue.substring(1), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedValue,
                isExpanded: true,
                hint: Text("Select $label", style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                items: items.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value[0].toUpperCase() + value.substring(1)),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double topPadding) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding + 10, left: 20, right: 20, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 22),
            style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const Text("My Profile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),

          GestureDetector(
            onTap: () => setState(() => _isEditing = !_isEditing),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _isEditing ? Colors.white : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(_isEditing ? Icons.close : Icons.edit, size: 16, color: _isEditing ? AppColors.primary : Colors.white),
                  const SizedBox(width: 6),
                  Text(_isEditing ? "Cancel" : "Edit", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _isEditing ? AppColors.primary : Colors.white)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCompletionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.orange.shade100, Colors.orange.shade50]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Profile Strength", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[900])),
              Text("$_completionPercentage%", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[900])),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _completionPercentage / 100,
              backgroundColor: Colors.orange[100],
              color: Colors.orange[700],
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}