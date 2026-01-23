import 'package:flutter/material.dart';
import '../constants/colors.dart';

class ModernScholarshipCard extends StatelessWidget {
  final String title;
  final String institution;
  final String badge; // Amount
  final String deadline;
  final String country;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onSave;

  const ModernScholarshipCard({
    super.key,
    required this.title,
    required this.institution,
    required this.badge,
    required this.deadline,
    required this.country,
    required this.isSaved,
    required this.onTap,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE0E5EC).withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- TOP ROW: BADGE & SAVE ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Amount Badge (Dark Blue Pill)
                  if (badge.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A52), // Dark Slate Blue
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    const Spacer(), // Keeps the save icon to the right if no badge

                  // Save Icon
                  GestureDetector(
                    onTap: onSave,
                    child: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border_rounded,
                      color: isSaved ? AppColors.primary : const Color(0xFF1E3A52),
                      size: 26,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // --- TITLE WITH CAP ICON ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        height: 1.3,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 🎓 Scholarship Cap Icon
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(Icons.school, size: 24, color: Color(0xFF1E3A52)),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // --- INSTITUTION ---
              Text(
                institution,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B), // Slate grey
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 20),

              // --- BOTTOM ROW: DATE & LOCATION ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Deadline
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Text(
                        deadline,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  // Location (Flexible prevents overflow)
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            country,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}