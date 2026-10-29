import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/animated_favorite_button.dart';
import '../../../../shared/widgets/event_network_image.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../data/models/event_model.dart';
import '../../data/repositories/event_repository.dart';
import '../providers/event_detail_provider.dart';

class EventDetailScreen extends StatelessWidget {
  final EventModel initialEvent;
  final String? heroTag;

  const EventDetailScreen({
    super.key,
    required this.initialEvent,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EventDetailProvider(
        repository: context.read<EventRepository>(),
        initialEvent: initialEvent,
      )..fetchDescription(),
      child: _EventDetailView(
        heroTag: heroTag ?? 'detail-image-${initialEvent.id}',
      ),
    );
  }
}

class _EventDetailView extends StatelessWidget {
  final String heroTag;

  const _EventDetailView({
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider?>();
    final provider = context.watch<EventDetailProvider>();
    final event = provider.event;
    final favoritesProvider = context.watch<FavoritesProvider>();
    final isFav = favoritesProvider.isFavorite(event.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Scrollable Body
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Image with Dark Gradient
                SizedBox(
                  height: 320,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: heroTag,
                        child: EventNetworkImage(
                          imageUrl: event.imageUrl,
                          iconSize: 64,
                        ),
                      ),
                      // Top to bottom gradient to ensure text and top buttons are visible
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.6),
                              Colors.transparent,
                              AppColors.background.withValues(alpha: 0.95),
                              AppColors.background,
                            ],
                            stops: const [0.0, 0.4, 0.85, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content Sheet
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Tag and Online Badge (Wrap prevents overflow on small screens)
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.accentGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              event.category,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentGreenText,
                              ),
                            ),
                          ),
                          if (event.isOnline)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.onlineBadge.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.onlineBadge.withValues(alpha: 0.4),
                                ),
                              ),
                              child: const Text(
                                'Online Etkinlik',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onlineBadge,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Event Title
                      Text(
                        event.title,
                        style: AppTypography.displayLarge.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 10),

                      // Location Row
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, color: AppColors.accentPurple, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              event.location,
                              style: AppTypography.bodyLarge.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Host / Organizer Card (Dribbble reference)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.cardBorder,
                          ),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.accentPurple.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  event.organizer.isNotEmpty ? event.organizer[0].toUpperCase() : 'O',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accentPurple,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.organizer,
                                    style: AppTypography.titleLarge,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Etkinlik Düzenleyicisi',
                                    style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Info Tiles (Date/Time & Registered Count)
                      _buildInfoTile(
                        icon: Icons.calendar_today_rounded,
                        title: 'Tarih & Saat',
                        subtitle: DateFormatter.formatRange(event.startDate, event.endDate),
                      ),
                      const SizedBox(height: 10),
                      _buildInfoTile(
                        icon: Icons.groups_rounded,
                        title: 'Katılımcı Kontenjanı',
                        subtitle: '${event.registeredCount} / ${event.capacity} Kayıtlı Katılımcı',
                      ),

                      // Tags
                      if (event.tags.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text(
                          'Etiketler',
                          style: AppTypography.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: event.tags
                              .map(
                                (tag) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.05),
                                    ),
                                  ),
                                  child: Text(
                                    '#$tag',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],

                      const SizedBox(height: 24),
                      Divider(color: AppColors.divider),
                      const SizedBox(height: 14),

                      // Description Section (Isolated Error & Expandable)
                      Text(
                        'Etkinlik Hakkında',
                        style: AppTypography.headingMedium,
                      ),
                      const SizedBox(height: 10),
                      _buildDescriptionSection(context, provider),

                      const SizedBox(height: 100), // Space for bottom button
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Top Floating Navigation (Back & Favorite buttons)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button circle
                  _buildCircleActionButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Geri',
                    onTap: () => Navigator.of(context).pop(),
                  ),

                  // Favorite toggle circle button with scale animation
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: AnimatedFavoriteButton(
                        isFavorite: isFav,
                        size: 20,
                        inactiveColor: Colors.white,
                        tooltip: isFav ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
                        onTap: () {
                          favoritesProvider.toggleFavorite(event);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.surfaceLight,
                              content: Text(
                                isFav
                                    ? '${event.title} favorilerden çıkarıldı.'
                                    : '${event.title} favorilere eklendi.',
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Action Bar (Non-ticketing, Favorite toggle button)
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(
                color: AppColors.cardBorder,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      favoritesProvider.toggleFavorite(event);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.surfaceLight,
                          content: Text(
                            isFav
                                ? '${event.title} favorilerden çıkarıldı.'
                                : '${event.title} favorilere eklendi.',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFav ? AppColors.favoriteRed : AppColors.accentGreenText,
                      size: 22,
                    ),
                    label: Text(
                      isFav ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.buttonPrimary.copyWith(
                        fontSize: 15,
                        color: isFav ? AppColors.textPrimary : AppColors.accentGreenText,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFav ? AppColors.surfaceLight : AppColors.accentGreen,
                      foregroundColor: isFav ? AppColors.textPrimary : AppColors.accentGreenText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                        side: isFav
                            ? BorderSide(color: AppColors.favoriteRed.withValues(alpha: 0.5))
                            : BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Center(
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cardBorder,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.badgeBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.badgeText),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(
    BuildContext context,
    EventDetailProvider provider,
  ) {
    if (provider.isLoadingDescription) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accentGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Açıklama getiriliyor...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      );
    }

    if (provider.descriptionError != null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.error, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                provider.descriptionError!,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
              ),
            ),
            TextButton(
              onPressed: provider.retryDescription,
              child: Text(
                'Tekrar Dene',
                style: TextStyle(color: AppColors.accentText, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    final description = provider.event.description;
    if (description == null || description.trim().isEmpty) {
      return Text(
        'Bu etkinlik için henüz bir açıklama girilmemiş.',
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textMuted,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topLeft,
          child: Text(
            description,
            maxLines: provider.isDescriptionExpanded ? null : 3,
            overflow: provider.isDescriptionExpanded ? null : TextOverflow.ellipsis,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ),
        if (description.length > 80)
          GestureDetector(
            onTap: provider.toggleDescriptionExpanded,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    provider.isDescriptionExpanded ? 'Daha Az Göster' : 'Daha Fazla Göster',
                    style: TextStyle(
                      color: AppColors.accentText,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    provider.isDescriptionExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.accentText,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
