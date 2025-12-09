import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/saved_provider.dart';

class SavedScholarshipScreen extends StatelessWidget {
  const SavedScholarshipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final savedProvider = Provider.of<SavedProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Saved Scholarships",
            style: TextStyle(
              fontFamily: "Literata",
              color: Color(0xFF1B3C53),
              fontWeight: FontWeight.bold,
            )),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: savedProvider.savedScholarships.isEmpty
          ? const Center(
        child: Text(
          "No saved scholarships yet",
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: savedProvider.savedScholarships.length,
          itemBuilder: (context, index) {
            final item = savedProvider.savedScholarships[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Text(
                item["title"] ?? "",
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            );
          }),
    );
  }
}
