import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/saved_provider.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final savedProvider = Provider.of<SavedProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Scholarships')),
      body: savedProvider.savedScholarships.isEmpty
          ? const Center(child: Text('No saved scholarships yet.'))
          : ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: savedProvider.savedScholarships.length,
        itemBuilder: (context, index) {
          final item = savedProvider.savedScholarships[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['title']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(item['institution']!, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item['deadline']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(item['country']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
