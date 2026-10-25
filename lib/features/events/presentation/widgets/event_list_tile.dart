import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/event_network_image.dart';
import '../../data/models/event_model.dart';

class EventListTile extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const EventListTile({
    super.key,
    required this.event,
    required this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.04),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: EventNetworkImage(
                    imageUrl: event.imageUrl,
                    width: 84,
                    height: 84,
                    iconSize: 28,
                  ),
                ),
                const SizedBox(width: 14),

                // Event text information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category chip & Favorite icon row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.accentGreen.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                event.category,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accentGreen,
                                ),
                              ),
                            ),
                          ),
                          if (onFavoriteToggle != null) ...[
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: onFavoriteToggle,
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  color: isFavorite ? AppColors.favoriteRed : AppColors.textMuted,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Title
                      Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleLarge.copyWith(fontSize: 15, height: 1.25),
                      ),
                      const SizedBox(height: 8),

                      // Date & Location Row (overflow-safe)
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Flexible(
                            flex: 2,
                            child: Text(
                              DateFormatter.formatShortDate(event.startDate),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.location_on_rounded, size: 13, color: AppColors.accentPurple),
                          const SizedBox(width: 3),
                          Expanded(
                            flex: 3,
                            child: Text(
                              event.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
