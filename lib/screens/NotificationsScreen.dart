import 'package:flutter/material.dart';
import '../constants/colors.dart'; // Assuming you have your colors file
// import '../widgets/premium_background.dart'; // Uncomment if you want the same background

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Dummy Data for Preview
  List<Map<String, dynamic>> notifications = [
    {
      "id": 1,
      "title": "Application Deadline Warning",
      "body": "The 'Tech Training Scholarship' application closes in 24 hours. Submit your SOP now!",
      "time": "2 hours ago",
      "type": "deadline", // deadline, new, system
      "isRead": false,
    },
    {
      "id": 2,
      "title": "New Scholarship Match",
      "body": "We found 3 new scholarships for 'Data Science' in Germany.",
      "time": "5 hours ago",
      "type": "new",
      "isRead": false,
    },
    {
      "id": 3,
      "title": "Video Tutorial Added",
      "body": "Check out our new guide: 'How to get a Student Visa for Canada'.",
      "time": "1 day ago",
      "type": "system",
      "isRead": true,
    },
    {
      "id": 4,
      "title": "Profile Update Successful",
      "body": "Your profile has been updated. You will now see more relevant results.",
      "time": "2 days ago",
      "type": "system",
      "isRead": true,
    },
  ];

  void _markAllAsRead() {
    setState(() {
      for (var n in notifications) {
        n['isRead'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("All notifications marked as read")),
    );
  }

  void _deleteNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });
  }

  // Helper to get Icon based on type
  Widget _getIcon(String type) {
    switch (type) {
      case 'deadline':
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.access_time_filled, color: Colors.red, size: 22),
        );
      case 'new':
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.school, color: Colors.green, size: 22),
        );
      default:
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.notifications, color: AppColors.primary, size: 22),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Or use your PremiumBackground
      appBar: AppBar(
        title: const Text("Notifications", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text("Read All", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            )
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Dismissible(
            key: Key(item['id'].toString()),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) => _deleteNotification(index),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(15)),
              child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: item['isRead'] ? Colors.white : AppColors.primary.withOpacity(0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: item['isRead'] ? Colors.grey.shade200 : AppColors.primary.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: _getIcon(item['type']),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item['title'],
                        style: TextStyle(
                          fontWeight: item['isRead'] ? FontWeight.w600 : FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (!item['isRead'])
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      item['body'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['time'],
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                    ),
                  ],
                ),
                onTap: () {
                  // Mark as read when tapped
                  setState(() => item['isRead'] = true);
                  // TODO: Navigate to specific Scholarship detail
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_off_outlined, size: 60, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          const Text(
            "No Notifications Yet",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          Text(
            "We will notify you when new scholarships\nmatch your profile.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }
}