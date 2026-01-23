import 'package:flutter/material.dart';
import '../constants/colors.dart'; // Ensure this path is correct

class FilterModal extends StatefulWidget {
  final String title;
  final List<String> items;
  final String? selectedItem;
  final Function(String?) onApply;

  const FilterModal({
    super.key,
    required this.title,
    required this.items,
    this.selectedItem,
    required this.onApply,
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  String _searchQuery = '';
  String? _tempSelected;

  @override
  void initState() {
    super.initState();
    // Initialize with the currently selected item passed from Home
    _tempSelected = widget.selectedItem;
  }

  @override
  Widget build(BuildContext context) {
    // Filter the list based on local search bar inside modal
    final filteredItems = widget.items.where((item) {
      return item.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // --- 1. Draggable Handle ---
          const SizedBox(height: 12),
          Container(
              height: 5,
              width: 50,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2.5))
          ),

          // --- 2. Header ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context)
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // --- 3. Search Bar (Inside Modal) ---
          Padding(
            padding: const EdgeInsets.all(15),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: const InputDecoration(
                  hintText: "Search...",
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),

          // --- 4. List Options ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                final isSelected = item == _tempSelected;

                return ListTile(
                  title: Text(
                      item,
                      style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.primary : Colors.black87,
                          fontFamily: 'Poppins'
                      )
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : const Icon(Icons.circle_outlined, color: Colors.grey),
                  onTap: () {
                    setState(() {
                      _tempSelected = item;
                    });
                  },
                );
              },
            ),
          ),

          // --- 5. Bottom Buttons (Reset & Apply) ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                // Reset Button
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _tempSelected = null);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Reset", style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 15),
                // Apply Button
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      // Pass the selected value back to HomeScreen
                      widget.onApply(_tempSelected);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text("Apply Filters", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
        ],
      ),
    );
  }
}