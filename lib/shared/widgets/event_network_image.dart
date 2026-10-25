import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Reusable image component with built-in dark shimmer placeholder
/// and stylized fallback for missing or failed network images.
class EventNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double iconSize;

  const EventNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.iconSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    final trimmedUrl = imageUrl.trim();
    if (trimmedUrl.isEmpty) {
      return _buildFallback();
    }

    return Image.network(
      trimmedUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _buildFallback(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: AppColors.surfaceLight,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accentGreen.withValues(alpha: 0.7),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceLight,
            AppColors.surface,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available_rounded,
              color: AppColors.accentPurple.withValues(alpha: 0.6),
              size: iconSize,
            ),
          ],
        ),
      ),
    );
  }
}

