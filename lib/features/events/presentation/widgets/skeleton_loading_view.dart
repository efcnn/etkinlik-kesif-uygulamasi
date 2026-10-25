import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Pure Flutter skeleton/shimmer placeholder view matching the Home screen layout
/// (featured carousel cards + compact list tiles), without requiring external packages.
class EventSkeletonView extends StatefulWidget {
  const EventSkeletonView({super.key});

  @override
  State<EventSkeletonView> createState() => _EventSkeletonViewState();
}

class _EventSkeletonViewState extends State<EventSkeletonView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final shimmerColor = Color.lerp(
          AppColors.surface,
          AppColors.surfaceLight.withValues(alpha: 0.9),
          _controller.value,
        )!;

        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section title placeholder
              _buildBox(width: 130, height: 20, radius: 6, color: shimmerColor),
              const SizedBox(height: 14),

              // Featured carousel skeleton row
              SizedBox(
                height: 290,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildFeaturedCardSkeleton(shimmerColor),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 60,
                      child: _buildFeaturedCardSkeleton(shimmerColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // All events title placeholder
              _buildBox(width: 140, height: 20, radius: 6, color: shimmerColor),
              const SizedBox(height: 12),

              // Compact list tile skeletons
              for (int i = 0; i < 3; i++) ...[
                _buildListTileSkeleton(shimmerColor),
                const SizedBox(height: 12),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeaturedCardSkeleton(Color shimmerColor) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.04),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildBox(width: 70, height: 18, radius: 6, color: shimmerColor),
          const SizedBox(height: 10),
          _buildBox(width: double.infinity, height: 20, radius: 6, color: shimmerColor),
          const SizedBox(height: 6),
          _buildBox(width: 140, height: 14, radius: 6, color: shimmerColor),
          const SizedBox(height: 14),
          _buildBox(width: double.infinity, height: 38, radius: 14, color: shimmerColor),
        ],
      ),
    );
  }

  Widget _buildListTileSkeleton(Color shimmerColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.04),
        ),
      ),
      child: Row(
        children: [
          _buildBox(width: 84, height: 84, radius: 16, color: shimmerColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBox(width: 60, height: 16, radius: 6, color: shimmerColor),
                const SizedBox(height: 8),
                _buildBox(width: double.infinity, height: 16, radius: 6, color: shimmerColor),
                const SizedBox(height: 6),
                _buildBox(width: 120, height: 14, radius: 6, color: shimmerColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBox({
    required double width,
    required double height,
    required double radius,
    required Color color,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

