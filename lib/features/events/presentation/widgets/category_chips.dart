import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

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
    final allCategories = ['Tümü', ...categories.where((c) => c != 'Tümü')];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: allCategories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = allCategories[index];
          final isSelected = (selectedCategory == null && category == 'Tümü') ||
              (selectedCategory == category);

          return GestureDetector(
            onTap: () {
              if (category == 'Tümü') {
                onCategorySelected(null);
              } else {
                onCategorySelected(category);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentGreen : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.accentGreen
                      : Colors.white.withValues(alpha: 0.06),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  category,
                  style: isSelected
                      ? AppTypography.buttonPrimary.copyWith(fontSize: 13)
                      : AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
