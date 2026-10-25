import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../events/presentation/screens/event_detail_screen.dart';
import '../../../events/presentation/widgets/event_list_tile.dart';
import '../../../events/presentation/widgets/state_views.dart';
import '../providers/favorites_provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorilerim'),
        elevation: 0,
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, child) {
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
            padding: const EdgeInsets.symmetric(vertical: 8),
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
        },
      ),
    );
  }
}
