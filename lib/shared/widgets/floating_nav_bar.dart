import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Custom floating bottom navigation bar matching the Dribbble design reference.
/// Features a dark rounded pill container with circular icon items,
/// where the active item is highlighted with an accent-green filled circle.
class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int favoriteBadgeCount;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.favoriteBadgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(34),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.explore_outlined,
                activeIcon: Icons.explore_rounded,
                tooltip: 'Keşfet',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.favorite_border_rounded,
                activeIcon: Icons.favorite_rounded,
                tooltip: 'Favoriler',
                badgeCount: favoriteBadgeCount,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String tooltip,
    int badgeCount = 0,
  }) {
    final isActive = currentIndex == index;

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: isActive ? AppColors.accentGreen : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: badgeCount > 0 && !isActive
                ? Badge(
                    label: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentGreenText,
                      ),
                    ),
                    backgroundColor: AppColors.accentGreen,
                    child: Icon(
                      isActive ? activeIcon : icon,
                      color: isActive ? AppColors.accentGreenText : AppColors.textSecondary,
                      size: 24,
                    ),
                  )
                : Icon(
                    isActive ? activeIcon : icon,
                    color: isActive ? AppColors.accentGreenText : AppColors.textSecondary,
                    size: 24,
                  ),
          ),
        ),
      ),
    );
  }
}

