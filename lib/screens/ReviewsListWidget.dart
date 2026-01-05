import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../screens/WriteReviewScreen.dart';

class ReviewsListWidget extends StatefulWidget {
  final int consultantId;
  const ReviewsListWidget({super.key, required this.consultantId});

  @override
  State<ReviewsListWidget> createState() => _ReviewsListWidgetState();
}

class _ReviewsListWidgetState extends State<ReviewsListWidget> {
  late Future<Map<String, dynamic>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  void _loadReviews() {
    setState(() {
      _reviewsFuture = ApiService.getConsultantReviews(widget.consultantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Recent Reviews", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B3C53))),
            TextButton(
              onPressed: () async {
                final success = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => WriteReviewScreen(consultantId: widget.consultantId)),
                );
                if (success == true) _loadReviews(); // Refresh if review submitted
              },
              child: const Text("Write a Review"),
            )
          ],
        ),
        FutureBuilder<Map<String, dynamic>>(
          future: _reviewsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return Text("Error loading reviews");

            final data = snapshot.data;
            final reviews = (data?['data'] as List?) ?? [];

            if (reviews.isEmpty) return const Text("No reviews yet. Be the first!", style: TextStyle(color: Colors.grey));

            return Column(
              children: reviews.map((r) => _ReviewItem(reviewData: r)).toList(),
            );
          },
        ),
      ],
    );
  }
}

// --- SINGLE REVIEW ITEM (With Reactions) ---
class _ReviewItem extends StatefulWidget {
  final Map<String, dynamic> reviewData;
  const _ReviewItem({required this.reviewData});

  @override
  State<_ReviewItem> createState() => _ReviewItemState();
}

class _ReviewItemState extends State<_ReviewItem> {
  late int helpfulCount;
  String? myReaction; // 'helpful' or null (API supports 'dislike' too if needed)

  @override
  void initState() {
    super.initState();
    helpfulCount = widget.reviewData['helpful_count'] ?? 0;
    // Check if I already reacted
    if (widget.reviewData['my_reaction'] != null) {
      // The API returns my_reaction as null OR an object { type: "helpful" ... }
      // Depending on parsing, it might be a Map.
      try {
        final reactionObj = widget.reviewData['my_reaction'];
        if (reactionObj is Map) {
          myReaction = reactionObj['type'];
        }
      } catch (e) {
        myReaction = null;
      }
    }
  }

  Future<void> _toggleHelpful() async {
    final reviewId = widget.reviewData['id'];
    bool success;

    // Optimistic UI Update
    setState(() {
      if (myReaction == 'helpful') {
        myReaction = null;
        helpfulCount--;
      } else {
        myReaction = 'helpful';
        helpfulCount++;
      }
    });

    if (myReaction == 'helpful') {
      success = await ApiService.addReaction(reviewId, 'helpful');
    } else {
      success = await ApiService.removeReaction(reviewId);
    }

    // Revert if API failed
    if (!success && mounted) {
      setState(() {
        if (myReaction == 'helpful') {
          myReaction = null; helpfulCount--;
        } else {
          myReaction = 'helpful'; helpfulCount++;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.reviewData['user'] ?? {};
    final hasReplied = widget.reviewData['has_replied'] == true;
    final reply = widget.reviewData['consultant_reply'];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(user['avatar'] ?? 'https://via.placeholder.com/50'),
                radius: 16,
              ),
              const SizedBox(width: 10),
              Text(user['name'] ?? "User", style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Icon(Icons.star, color: Colors.amber, size: 16),
              Text(" ${widget.reviewData['rating']}", style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(widget.reviewData['comment'] ?? ""),

          if (hasReplied && reply != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(5)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("Consultant Reply:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text(reply, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13)),
              ]),
            )
          ],

          const SizedBox(height: 10),
          InkWell(
            onTap: _toggleHelpful,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.thumb_up_alt_outlined, size: 16, color: myReaction == 'helpful' ? Colors.blue : Colors.grey),
                const SizedBox(width: 5),
                Text("$helpfulCount Helpful", style: TextStyle(color: myReaction == 'helpful' ? Colors.blue : Colors.grey, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }
}