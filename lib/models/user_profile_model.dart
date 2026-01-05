class UserProfile {
  final String? phone;
  final String? phoneCountryCode;
  final String? whatsapp;
  final String? alternateEmail;
  final String? dateOfBirth;
  final String? gender;
  final String? nationality;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? country;
  final String? highestEducation;
  final String? degreeTitle;
  final String? institution;
  final int? graduationYear;
  final double? cgpa;
  final String? cgpaScale;
  final String? aboutMe;
  final List<String>? skills;
  final List<String>? languages;

  UserProfile({
    this.phone,
    this.phoneCountryCode,
    this.whatsapp,
    this.alternateEmail,
    this.dateOfBirth,
    this.gender,
    this.nationality,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.country,
    this.highestEducation,
    this.degreeTitle,
    this.institution,
    this.graduationYear,
    this.cgpa,
    this.cgpaScale,
    this.aboutMe,
    this.skills,
    this.languages,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      phone: json['phone'],
      phoneCountryCode: json['phone_country_code'],
      whatsapp: json['whatsapp'],
      alternateEmail: json['alternate_email'],
      dateOfBirth: json['date_of_birth'],
      gender: json['gender'],
      nationality: json['nationality'],
      addressLine1: json['address_line1'],
      addressLine2: json['address_line2'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      highestEducation: json['highest_education'],
      degreeTitle: json['degree_title'],
      institution: json['institution'],
      graduationYear: json['graduation_year'],
      cgpa: json['cgpa'] != null
          ? double.parse(json['cgpa'].toString())
          : null,
      cgpaScale: json['cgpa_scale'],
      aboutMe: json['about_me'],
      skills: json['skills'] != null ? List<String>.from(json['skills']) : [],
      languages:
      json['languages'] != null ? List<String>.from(json['languages']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "phone": phone,
      "phone_country_code": phoneCountryCode,
      "whatsapp": whatsapp,
      "alternate_email": alternateEmail,
      "date_of_birth": dateOfBirth,
      "gender": gender,
      "nationality": nationality,
      "address_line1": addressLine1,
      "address_line2": addressLine2,
      "city": city,
      "state": state,
      "country": country,
      "highest_education": highestEducation,
      "degree_title": degreeTitle,
      "institution": institution,
      "graduation_year": graduationYear,
      "cgpa": cgpa,
      "cgpa_scale": cgpaScale,
      "about_me": aboutMe,
      "skills": skills,
      "languages": languages,
    };
  }
}
