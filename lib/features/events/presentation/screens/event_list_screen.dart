import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_provider.dart';
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
                      const SizedBox(width: 8),
                      // Theme toggle circular icon button (only shown if ThemeProvider is present in tree)
                      Builder(
                        builder: (context) {
                          final themeProvider = context.watch<ThemeProvider?>();
                          if (themeProvider == null) return const SizedBox.shrink();
                          final isDark = themeProvider.isDarkMode;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.border,
                                ),
                              ),
                              child: IconButton(
                                icon: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  transitionBuilder: (child, anim) => ScaleTransition(
                                    scale: anim,
                                    child: child,
                                  ),
                                  child: Icon(
                                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                    key: ValueKey<bool>(isDark),
                                    size: 20,
                                  ),
                                ),
                                color: isDark ? AppColors.accentGreen : AppColors.accentPurple,
                                tooltip: isDark ? 'Açık Tema' : 'Koyu Tema',
                                onPressed: themeProvider.toggleTheme,
                              ),
                            ),
                          );
                        },
                      ),
                      // Refresh circular icon button
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.border,
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
      return NotificationListener<ScrollNotification>(
        onNotification: (notification) => _handleScrollNotification(notification, provider),
        child: RefreshIndicator(
          color: AppColors.accentGreen,
          backgroundColor: AppColors.surface,
          onRefresh: () => provider.fetchEvents(isRefresh: true),
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 4, bottom: 100),
            itemCount: events.length + 1,
            itemBuilder: (context, index) {
              if (index == events.length) {
                return _buildPaginationFooter(provider);
              }
              final event = events[index];
              final isFav = favoritesProvider.isFavorite(event.id);
              final tag = 'filter-list-image-${event.id}';
              return EventListTile(
                event: event,
                isFavorite: isFav,
                heroTag: tag,
                onFavoriteToggle: () => favoritesProvider.toggleFavorite(event),
                onTap: () => _navigateToDetail(context, event, heroTag: tag),
              );
            },
          ),
        ),
      );
    }

    // Default discover mode: Featured carousel + All events vertical list
    final featuredEvents = events.take(4).toList();

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) => _handleScrollNotification(notification, provider),
      child: RefreshIndicator(
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
                    final tag = 'featured-image-${event.id}';
                    return FeaturedEventCard(
                      event: event,
                      isFavorite: isFav,
                      heroTag: tag,
                      onFavoriteToggle: () => favoritesProvider.toggleFavorite(event),
                      onTap: () => _navigateToDetail(context, event, heroTag: tag),
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
                        '${events.length} / ${provider.totalCount}',
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
                  final tag = 'all-list-image-${event.id}';
                  return EventListTile(
                    event: event,
                    isFavorite: isFav,
                    heroTag: tag,
                    onFavoriteToggle: () => favoritesProvider.toggleFavorite(event),
                    onTap: () => _navigateToDetail(context, event, heroTag: tag),
                  );
                },
                childCount: events.length,
              ),
            ),

            // Pagination footer (loading more / retry / load more button)
            SliverToBoxAdapter(
              child: _buildPaginationFooter(provider),
            ),

            // Space for the floating bottom navigation bar
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  bool _handleScrollNotification(ScrollNotification notification, EventListProvider provider) {
    if (notification.metrics.axis == Axis.vertical &&
        notification.metrics.maxScrollExtent > 0 &&
        notification.metrics.pixels >= notification.metrics.maxScrollExtent - 200) {
      if (provider.hasMore && !provider.isLoadingMore && provider.loadMoreError == null) {
        provider.loadMoreEvents();
      }
    }
    return false;
  }

  Widget _buildPaginationFooter(EventListProvider provider) {
    if (provider.isLoadingMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.accentGreen,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                'Daha fazla etkinlik yükleniyor...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    if (provider.loadMoreError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.error.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  provider.loadMoreError!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: provider.loadMoreEvents,
                child: const Text(
                  'Tekrar Dene',
                  style: TextStyle(
                    color: AppColors.accentGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Center(
          child: OutlinedButton.icon(
            onPressed: provider.loadMoreEvents,
            icon: const Icon(Icons.expand_more_rounded, size: 18),
            label: const Text(
              'Daha Fazla Göster',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _navigateToDetail(BuildContext context, event, {String? heroTag}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EventDetailScreen(
          initialEvent: event,
          heroTag: heroTag,
        ),
      ),
    );
  }
}
