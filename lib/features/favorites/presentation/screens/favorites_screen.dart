import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../events/presentation/screens/event_detail_screen.dart';
import '../../../events/presentation/widgets/event_list_tile.dart';
import '../../../events/presentation/widgets/state_views.dart';
import '../providers/favorites_provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Consumer<FavoritesProvider>(
          builder: (context, favoritesProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Favorilerim',
                            style: AppTypography.headingLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kaydettiğin tüm özel etkinlikler',
                            style: AppTypography.bodyMedium,
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                        child: Text(
                          '${favoritesProvider.count} Etkinlik',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Content
                Expanded(
                  child: _buildBody(context, favoritesProvider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, FavoritesProvider favoritesProvider) {
    if (favoritesProvider.isLoading) {
      return const LoadingView(
        message: 'Favoriler yükleniyor...',
      );
    }

    if (favoritesProvider.isEmpty) {
      return const EmptyView(
        icon: Icons.favorite_border_rounded,
        title: 'Henüz Favori Etkinliğiniz Yok',
        message: 'Etkinlikleri kalp simgesine dokunarak favorilerinize ekleyebilirsiniz. Eklediğiniz etkinlikler burada saklanacaktır.',
      );
    }

    final favorites = favoritesProvider.favorites;

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 100),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final event = favorites[index];
        return EventListTile(
          event: event,
          isFavorite: true,
          onFavoriteToggle: () {
            favoritesProvider.toggleFavorite(event);
          },
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EventDetailScreen(initialEvent: event),
              ),
            );
          },
        );
      },
    );
  }
}
