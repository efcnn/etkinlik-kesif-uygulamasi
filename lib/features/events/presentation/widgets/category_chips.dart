import 'package:flutter/material.dart';

class CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    // "Tümü" is always first
    final allCategories = ['Tümü', ...categories.where((c) => c != 'Tümü')];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: allCategories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = allCategories[index];
          final isSelected = (selectedCategory == null && category == 'Tümü') ||
              (selectedCategory == category);

          return ChoiceChip(
            label: Text(category),
            selected: isSelected,
            onSelected: (_) {
              if (category == 'Tümü') {
                onCategorySelected(null);
              } else {
                onCategorySelected(category);
              }
            },
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.black87,
            ),
            selectedColor: Theme.of(context).primaryColor,
            backgroundColor: Colors.grey[200],
            showCheckmark: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }
}

