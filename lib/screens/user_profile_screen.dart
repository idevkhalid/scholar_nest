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
  bool _isEditing = false; // Controls View vs Edit Mode

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

  Future<void> _fetchProfileData() async {
    setState(() => _isLoading = true);
    final response = await ApiService.getUserProfile();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response['status'] == 'success') {
          final data = response['data'];
          _completionPercentage = response['completion'];
          _missingFields = response['missing'];
          _populateFields(data);
        }
      });
    }
  }

  void _populateFields(Map<String, dynamic> data) {
    _phoneController.text = data['phone'] ?? '';
    _whatsappController.text = data['whatsapp'] ?? '';
    _dobController.text = data['date_of_birth'] ?? '';
    _nationalityController.text = data['nationality'] ?? 'Pakistani';
    _selectedGender = data['gender'];

    _address1Controller.text = data['address_line1'] ?? '';
    _address2Controller.text = data['address_line2'] ?? '';
    _cityController.text = data['city'] ?? '';
    _stateController.text = data['state'] ?? '';
    _countryController.text = data['country'] ?? 'Pakistan';

    _selectedEducation = data['highest_education'];
    _degreeTitleController.text = data['degree_title'] ?? '';
    _institutionController.text = data['institution'] ?? '';
    _gradYearController.text = data['graduation_year']?.toString() ?? '';
    _cgpaController.text = data['cgpa']?.toString() ?? '';

    _aboutMeController.text = data['about_me'] ?? '';
    _linkedinController.text = data['linkedin_url'] ?? '';
    _githubController.text = data['github_url'] ?? '';
    _portfolioController.text = data['portfolio_url'] ?? '';

    if (data['skills'] != null) {
      _skillsController.text = (data['skills'] as List).join(', ');
    }
    if (data['languages'] != null) {
      _languagesController.text = (data['languages'] as List).join(', ');
    }
  }

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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated successfully!"), backgroundColor: Colors.green));
        setState(() => _isEditing = false); // Switch back to View Mode
        _fetchProfileData(); // Refresh data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message']), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Column(
          children: [
            // --- HEADER WITH EDIT BUTTON ---
            _buildHeader(topPadding),

            // --- BODY ---
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_completionPercentage < 100 && !_isEditing) _buildCompletionCard(),
                    const SizedBox(height: 20),

                    _buildSectionHeader("Personal Information", Icons.person),
                    _buildEditableField("Phone Number", _phoneController, icon: Icons.phone, type: TextInputType.phone),
                    _buildEditableField("WhatsApp", _whatsappController, icon: Icons.message, type: TextInputType.phone),
                    _buildEditableField("Date of Birth", _dobController, isDate: true),
                    _buildDropdownOrText("Gender", ["male", "female", "other"], _selectedGender, (val) => setState(() => _selectedGender = val)),
                    _buildEditableField("Nationality", _nationalityController, icon: Icons.flag),

                    const SizedBox(height: 20),
                    _buildSectionHeader("Address Details", Icons.location_on),
                    _buildEditableField("Address Line 1", _address1Controller, icon: Icons.home),
                    _buildEditableField("City", _cityController, icon: Icons.location_city),
                    _buildEditableField("State / Province", _stateController, icon: Icons.map),
                    _buildEditableField("Country", _countryController, icon: Icons.public),

                    const SizedBox(height: 20),
                    _buildSectionHeader("Education", Icons.school),
                    _buildDropdownOrText("Highest Education", ["matric", "intermediate", "bachelors", "masters", "phd"], _selectedEducation, (val) => setState(() => _selectedEducation = val)),
                    _buildEditableField("Degree Title", _degreeTitleController, icon: Icons.book),
                    _buildEditableField("Institution", _institutionController, icon: Icons.account_balance),
                    Row(
                      children: [
                        Expanded(child: _buildEditableField("Grad Year", _gradYearController, type: TextInputType.number)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildEditableField("CGPA", _cgpaController, type: TextInputType.number)),
                      ],
                    ),

                    const SizedBox(height: 20),
                    _buildSectionHeader("Professional & Skills", Icons.work),
                    _buildEditableField("Skills", _skillsController, icon: Icons.code, hint: "Comma separated"),
                    _buildEditableField("Languages", _languagesController, icon: Icons.language, hint: "Comma separated"),
                    _buildEditableField("LinkedIn", _linkedinController, icon: Icons.link),
                    _buildEditableField("About Me", _aboutMeController, icon: Icons.description, maxLines: 3),

                    const SizedBox(height: 30),

                    // SAVE BUTTON (Only in Edit Mode)
                    if (_isEditing)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          onPressed: _isSaving ? null : _saveProfile,
                          child: _isSaving
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text("Save Changes", style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER METHODS ---

  Widget _buildEditableField(String label, TextEditingController controller, {IconData? icon, TextInputType type = TextInputType.text, int maxLines = 1, String? hint, bool isDate = false}) {
    // VIEW MODE: Show Text
    if (!_isEditing) {
      if (controller.text.isEmpty) return const SizedBox.shrink(); // Hide empty fields in view mode
      return Padding(
        padding: const EdgeInsets.only(bottom: 15, left: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(controller.text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
            Divider(color: Colors.grey.withOpacity(0.3)),
          ],
        ),
      );
    }

    // EDIT MODE: Show TextField
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: type,
        maxLines: maxLines,
        readOnly: isDate, // Date fields are read-only text fields
        onTap: isDate
            ? () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime(2000),
            firstDate: DateTime(1950),
            lastDate: DateTime.now(),
          );
          if (pickedDate != null) {
            String formattedDate = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
            controller.text = formattedDate;
          }
        }
            : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey, size: 20) : (isDate ? const Icon(Icons.calendar_today, color: Colors.grey) : null),
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildDropdownOrText(String label, List<String> items, String? selectedValue, Function(String?) onChanged) {
    // VIEW MODE
    if (!_isEditing) {
      if (selectedValue == null || selectedValue.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 15, left: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(selectedValue[0].toUpperCase() + selectedValue.substring(1), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Divider(color: Colors.grey.withOpacity(0.3)),
          ],
        ),
      );
    }

    // EDIT MODE
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value[0].toUpperCase() + value.substring(1)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildCompletionCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.amber.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Profile Completion: $_completionPercentage%", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber[900])),
              Icon(Icons.info_outline, color: Colors.amber[900], size: 20),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _completionPercentage / 100,
            backgroundColor: Colors.amber[100],
            color: Colors.amber[800],
            minHeight: 6,
            borderRadius: BorderRadius.circular(5),
          ),
          if (_missingFields.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              "Missing: ${_missingFields.take(3).join(', ')}${_missingFields.length > 3 ? '...' : ''}",
              style: TextStyle(fontSize: 12, color: Colors.amber[900]),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 15),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildHeader(double topPadding) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: topPadding + 15, bottom: 20, left: 20, right: 20),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.3),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text("My Profile", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),

              // --- EDIT BUTTON ---
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isEditing = !_isEditing;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isEditing ? Colors.redAccent : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                          _isEditing ? Icons.close : Icons.edit,
                          size: 16,
                          color: _isEditing ? Colors.white : AppColors.primary
                      ),
                      const SizedBox(width: 5),
                      Text(
                          _isEditing ? "Cancel" : "Edit",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _isEditing ? Colors.white : AppColors.primary
                          )
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}