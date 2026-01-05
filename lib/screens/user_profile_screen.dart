import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart'; // Add intl: ^0.18.0 to pubspec.yaml for date formatting
import '/services/api_service.dart';
import '/providers/auth_provider.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;
  int _completionPercent = 0;
  List<dynamic> _missingFields = [];

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);

    // 1. Try to load cached data first
    final cached = await ApiService.getCachedProfile();
    if (cached != null && mounted) {
      setState(() {
        _profileData = cached;
        _isLoading = false;
      });
    }


    // 2. Fetch fresh data from API
    final result = await ApiService.getUserProfile();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['status'] == 'success') {
          _profileData = result['profile'];
          _completionPercent = result['completion_percentage'] ?? 0;
          _missingFields = result['missing_fields'] ?? [];
        } else {
          // If we have no cache and API fails, keep _profileData as null (triggers empty state)
          if (_profileData == null) {
            // Optional: print(result['message']);
          }
        }
      });
    }
  }

  void _navigateToEditScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(existingProfile: _profileData),
      ),
    );
    // If they saved changes, refresh the data
    if (result == true) {
      _fetchProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          if (_profileData != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _navigateToEditScreen,
            )
        ],
      ),
      body: _isLoading && _profileData == null
          ? const Center(child: CircularProgressIndicator())
          : _profileData == null
          ? _buildNoDataState()
          : RefreshIndicator(
        onRefresh: _fetchProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 20),
              _buildCompletionCard(),
              const SizedBox(height: 20),
              if (_profileData!['about_me'] != null)
                _buildInfoSection("About Me", _profileData!['about_me']),
              const SizedBox(height: 16),
              _buildEducationCard(),
              const SizedBox(height: 16),
              _buildSkillsSection(),
              const SizedBox(height: 16),
              _buildContactInfo(),
              const SizedBox(height: 16),
              _buildSocialLinks(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- EMPTY STATE WIDGET ---
  Widget _buildNoDataState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Profile not created",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600]
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Create your profile to get better recommendations.",
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _navigateToEditScreen, // Opens the edit form in "Create" mode
            icon: const Icon(Icons.add, size: 18),
            label: const Text("Create Profile"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          )
        ],
      ),
    );
  }

  // --- CONTENT WIDGETS ---

  Widget _buildHeaderSection() {
    String displayChar = "U";
    if (_profileData!['first_name'] != null && _profileData!['first_name'].toString().isNotEmpty) {
      displayChar = _profileData!['first_name'][0].toUpperCase();
    }

    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.blue.shade100,
          child: Text(
            displayChar,
            style: const TextStyle(fontSize: 30, color: Colors.blue),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "User ID: ${_profileData!['user_id'] ?? 'Guest'}",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                _profileData!['nationality'] ?? "Nationality not set",
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(
                "${_profileData!['age'] != null ? '${_profileData!['age']} Years Old' : ''} ${(_profileData!['gender'] != null) ? '• ${_profileData!['gender']}' : ''}",
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _completionPercent == 100 ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _completionPercent == 100 ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Profile Completion",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _completionPercent == 100 ? Colors.green[800] : Colors.orange[800],
                ),
              ),
              Text(
                "$_completionPercent%",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _completionPercent / 100,
            backgroundColor: Colors.white,
            color: _completionPercent == 100 ? Colors.green : Colors.orange,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          if (_missingFields.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              "Missing: ${_missingFields.join(', ')}",
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    if (content.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(content, style: const TextStyle(height: 1.5, color: Colors.black87)),
        ),
      ],
    );
  }

  Widget _buildEducationCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Education", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: _profileData!['highest_education'] == null
              ? const Text("No education details added.")
              : Row(
            children: [
              const Icon(Icons.school, color: Colors.blue, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _profileData!['degree_title'] ?? "Degree",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _profileData!['institution'] ?? "Institution",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          "Graduated: ${_profileData!['graduation_year'] ?? 'N/A'}",
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(width: 10),
                        if (_profileData!['formatted_cgpa'] != null)
                          Text(
                            "CGPA: ${_profileData!['formatted_cgpa']}",
                            style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold),
                          ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsSection() {
    List<dynamic> skills = _profileData!['skills'] ?? [];
    List<dynamic> languages = _profileData!['languages'] ?? [];

    if (skills.isEmpty && languages.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Skills & Languages", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (skills.isNotEmpty) ...[
                const Text("Tech Skills", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills.map((s) => Chip(
                    label: Text(s.toString()),
                    backgroundColor: Colors.blue.shade50,
                    labelStyle: const TextStyle(color: Colors.blue),
                  )).toList(),
                ),
                const SizedBox(height: 16),
              ],
              if (languages.isNotEmpty) ...[
                const Text("Languages", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: languages.map((l) => Chip(
                    label: Text(l.toString()),
                    backgroundColor: Colors.green.shade50,
                    labelStyle: const TextStyle(color: Colors.green),
                  )).toList(),
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Contact Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              _buildRow(Icons.phone, "Phone", _profileData!['full_phone']),
              if (_profileData!['whatsapp'] != null) const Divider(),
              _buildRow(Icons.chat, "WhatsApp", _profileData!['whatsapp']),
              if (_profileData!['alternate_email'] != null) const Divider(),
              _buildRow(Icons.email, "Alt Email", _profileData!['alternate_email']),
              if (_profileData!['full_address'] != null) const Divider(),
              _buildRow(Icons.location_on, "Address", _profileData!['full_address']),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(IconData icon, String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSocialLinks() {
    final Map<String, IconData> links = {
      'linkedin_url': Icons.link,
      'github_url': Icons.code,
      'portfolio_url': Icons.web,
      'facebook_url': Icons.facebook,
    };
    final activeLinks = links.entries.where((e) => _profileData![e.key] != null).toList();
    if (activeLinks.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Social Links", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Wrap(
            spacing: 20,
            children: activeLinks.map((e) {
              return IconButton(
                icon: Icon(e.value, color: Colors.blue),
                onPressed: () {
                  // url_launcher integration here
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// EDIT PROFILE SCREEN CLASS (INTERNAL)
// =============================================================================

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? existingProfile;

  const EditProfileScreen({Key? key, this.existingProfile}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  final _phoneCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _address1Ctrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _degreeCtrl = TextEditingController();
  final _institutionCtrl = TextEditingController();
  final _cgpaCtrl = TextEditingController();
  final _aboutCtrl = TextEditingController();

  List<String> _skills = [];
  List<String> _languages = [];
  final _skillInputCtrl = TextEditingController();
  final _langInputCtrl = TextEditingController();

  String? _selectedGender;
  String? _selectedEducation;

  final List<String> _educationLevels = [
    'matric', 'intermediate', 'bachelors', 'masters', 'phd', 'post_doctoral'
  ];

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  void _populateFields() {
    if (widget.existingProfile == null) return;
    final p = widget.existingProfile!;

    _phoneCtrl.text = p['phone'] ?? '';
    _whatsappCtrl.text = p['whatsapp'] ?? '';
    _dobCtrl.text = p['date_of_birth'] ?? '';
    _address1Ctrl.text = p['address_line1'] ?? '';
    _cityCtrl.text = p['city'] ?? '';
    _countryCtrl.text = p['country'] ?? '';
    _degreeCtrl.text = p['degree_title'] ?? '';
    _institutionCtrl.text = p['institution'] ?? '';
    _cgpaCtrl.text = p['cgpa']?.toString() ?? '';
    _aboutCtrl.text = p['about_me'] ?? '';
    _selectedGender = p['gender'];
    _selectedEducation = p['highest_education'];

    if (p['skills'] != null) {
      _skills = List<String>.from(p['skills']);
    }
    if (p['languages'] != null) {
      _languages = List<String>.from(p['languages']);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _addItem(List<String> list, TextEditingController controller) {
    if (controller.text.isNotEmpty) {
      setState(() {
        list.add(controller.text.trim());
        controller.clear();
      });
    }
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final Map<String, dynamic> body = {
      "phone": _phoneCtrl.text,
      "whatsapp": _whatsappCtrl.text,
      "date_of_birth": _dobCtrl.text.isEmpty ? null : _dobCtrl.text,
      "gender": _selectedGender,
      "address_line1": _address1Ctrl.text,
      "city": _cityCtrl.text,
      "country": _countryCtrl.text,
      "highest_education": _selectedEducation,
      "degree_title": _degreeCtrl.text,
      "institution": _institutionCtrl.text,
      "cgpa": _cgpaCtrl.text.isNotEmpty ? double.tryParse(_cgpaCtrl.text) : null,
      "about_me": _aboutCtrl.text,
      "skills": _skills,
      "languages": _languages,
      "phone_country_code": "+92",
      "cgpa_scale": "4.0",
    };

    final result = await ApiService.updateUserProfile(body);

    setState(() => _isSubmitting = false);

    if (result['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
      Navigator.pop(context, true); // Return true to trigger refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Update failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existingProfile == null ? "Create Profile" : "Edit Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Personal Information"),
              _buildTextField("About Me", _aboutCtrl, maxLines: 3),
              Row(
                children: [
                  Expanded(child: _buildTextField("Phone", _phoneCtrl, keyboardType: TextInputType.phone)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTextField("WhatsApp", _whatsappCtrl, keyboardType: TextInputType.phone)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildDropdown("Gender", ["male", "female", "other"], _selectedGender, (val) => setState(() => _selectedGender = val))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: _buildTextField("Date of Birth", _dobCtrl, icon: Icons.calendar_today),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              _buildSectionTitle("Address"),
              _buildTextField("Address Line 1", _address1Ctrl),
              Row(
                children: [
                  Expanded(child: _buildTextField("City", _cityCtrl)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTextField("Country", _countryCtrl)),
                ],
              ),

              const SizedBox(height: 20),
              _buildSectionTitle("Education"),
              _buildDropdown("Highest Level", _educationLevels, _selectedEducation, (val) => setState(() => _selectedEducation = val)),
              _buildTextField("Degree Title", _degreeCtrl),
              _buildTextField("Institution", _institutionCtrl),
              _buildTextField("CGPA (out of 4.0)", _cgpaCtrl, keyboardType: TextInputType.number),

              const SizedBox(height: 20),
              _buildSectionTitle("Skills & Languages"),
              _buildTagInput("Add Skill", _skillInputCtrl, _skills),
              const SizedBox(height: 10),
              _buildTagInput("Add Language", _langInputCtrl, _languages),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitProfile,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save Profile", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, TextInputType? keyboardType, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: icon != null ? Icon(icon, size: 20) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? selectedItem, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        value: selectedItem,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTagInput(String label, TextEditingController controller, List<String> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildTextField(label, controller)),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.blue, size: 30),
              onPressed: () => _addItem(list, controller),
            )
          ],
        ),
        Wrap(
          spacing: 8.0,
          children: list.map((item) => Chip(
            label: Text(item),
            backgroundColor: Colors.blue.shade50,
            deleteIcon: const Icon(Icons.close, size: 18),
            onDeleted: () => setState(() => list.remove(item)),
          )).toList(),
        )
      ],
    );
  }
}