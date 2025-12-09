import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/saved_provider.dart';

class SavedScholarshipsScreen extends StatelessWidget {
  const SavedScholarshipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final savedProvider = Provider.of<SavedProvider>(context);
    final savedList = savedProvider.savedList;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC), // Soft background
      appBar: AppBar(
        title: Text(
          "Saved Scholarships",
          style: GoogleFonts.literata(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1B3C53),
        elevation: 4,
        centerTitle: true,
      ),

      body: savedList.isEmpty
          ? Center(
        child: Text(
          "No saved scholarships yet.",
          style: GoogleFonts.literata(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: savedList.length,
        itemBuilder: (context, index) {
          final item = savedList[index];

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 12),
            elevation: 6,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['badge'] ?? '',
                        style: GoogleFonts.literata(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: const Color(0xFF1B3C53),
                        ),
                      ),

                      Icon(Icons.bookmark, color: Color(0xFF1B3C53))
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Title
                  Text(
                    item['title'] ?? '',
                    style: GoogleFonts.literata(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Institution
                  Text(
                    item['institution'] ?? '',
                    style: GoogleFonts.literata(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Deadline & Country Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.timer,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text(
                            item['deadline'] ?? '',
                            style: GoogleFonts.literata(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.public,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text(
                            item['country'] ?? '',
                            style: GoogleFonts.literata(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
