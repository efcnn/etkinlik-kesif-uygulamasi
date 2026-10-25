import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../providers/event_list_provider.dart';
import '../widgets/category_chips.dart';
import '../widgets/event_list_tile.dart';
import '../widgets/featured_event_card.dart';
import '../widgets/search_field.dart';
import '../widgets/skeleton_loading_view.dart';
import '../widgets/state_views.dart';
import 'event_detail_screen.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<EventListProvider>();
      provider.fetchCategories();
      provider.fetchEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Consumer<EventListProvider>(
          builder: (context, provider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                // Custom Header (matching Dribbble reference)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Etkinlikleri Keşfet',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.headingLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'En güncel etkinlik ve atölyeler',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Refresh circular icon button
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.refresh_rounded, size: 20),
                          color: AppColors.textPrimary,
                          tooltip: 'Yenile',
                          onPressed: () {
                            provider.fetchEvents(isRefresh: true);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Search field with accent filter button
                SearchField(
                  onChanged: provider.onSearchChanged,
                  onClear: provider.clearSearch,
                ),

                // Category chips
                CategoryChips(
                  categories: provider.categories,
                  selectedCategory: provider.selectedCategory,
                  onCategorySelected: provider.setCategory,
                ),
                const SizedBox(height: 12),

                // Content area
                Expanded(
                  child: _buildContent(context, provider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, EventListProvider provider) {
    if (provider.isLoading) {
      return const EventSkeletonView();
    }

    if (provider.hasError) {
      return ErrorView(
        message: provider.errorMessage ?? 'Bir hata meydana geldi.',
        onRetry: provider.retry,
      );
    }

    if (provider.isEmpty) {
      if (provider.isFiltering) {
        return EmptyView(
          title: 'Sonuç Bulunamadı',
          message: 'Aramanızla veya seçtiğiniz kategoriyle eşleşen etkinlik bulunamadı.',
          icon: Icons.search_off_rounded,
          onAction: provider.clearFilters,
          actionButtonText: 'Filtreleri Temizle',
        );
      }
      return EmptyView(
        title: 'Henüz Etkinlik Yok',
        message: 'Şu anda listelenecek bir etkinlik bulunamadı.',
        onAction: provider.retry,
        actionButtonText: 'Yenile',
      );
    }

    final events = provider.events;
    final favoritesProvider = context.watch<FavoritesProvider>();

    // If filtering/searching, show a direct vertical list for cleaner results
    if (provider.isFiltering) {
      return RefreshIndicator(
        color: AppColors.accentGreen,
        backgroundColor: AppColors.surface,
        onRefresh: () => provider.fetchEvents(isRefresh: true),
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 4, bottom: 100),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            final isFav = favoritesProvider.isFavorite(event.id);
            return EventListTile(
              event: event,
              isFavorite: isFav,
              onFavoriteToggle: () => favoritesProvider.toggleFavorite(event),
              onTap: () => _navigateToDetail(context, event),
            );
          },
        ),
      );
    }

    // Default discover mode: Featured carousel + All events vertical list
    final featuredEvents = events.take(4).toList();

    return RefreshIndicator(
      color: AppColors.accentGreen,
      backgroundColor: AppColors.surface,
      onRefresh: () => provider.fetchEvents(isRefresh: true),
      child: CustomScrollView(
        slivers: [
          // Featured carousel section header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Öne Çıkanlar',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headingMedium,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '${featuredEvents.length} Etkinlik',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelSmall.copyWith(color: AppColors.accentGreen),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Horizontal Featured Carousel
          SliverToBoxAdapter(
            child: SizedBox(
              height: 310,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: featuredEvents.length,
                itemBuilder: (context, index) {
                  final event = featuredEvents[index];
                  final isFav = favoritesProvider.isFavorite(event.id);
                  return FeaturedEventCard(
                    event: event,
                    isFavorite: isFav,
                    onFavoriteToggle: () => favoritesProvider.toggleFavorite(event),
                    onTap: () => _navigateToDetail(context, event),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),

          // All Events section header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Tüm Etkinlikler',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headingMedium,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Toplam ${events.length}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Vertical list of compact tiles
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final event = events[index];
                final isFav = favoritesProvider.isFavorite(event.id);
                return EventListTile(
                  event: event,
                  isFavorite: isFav,
                  onFavoriteToggle: () => favoritesProvider.toggleFavorite(event),
                  onTap: () => _navigateToDetail(context, event),
                );
              },
              childCount: events.length,
            ),
          ),

          // Space for the floating bottom navigation bar
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context, event) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EventDetailScreen(initialEvent: event),
      ),
    );
  }
}
