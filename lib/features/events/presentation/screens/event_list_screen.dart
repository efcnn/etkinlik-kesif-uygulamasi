import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../providers/event_list_provider.dart';
import '../widgets/category_chips.dart';
import '../widgets/event_list_tile.dart';
import '../widgets/search_field.dart';
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
    // Fetch events and categories on screen mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<EventListProvider>();
      provider.fetchCategories();
      provider.fetchEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Etkinlikleri Keşfet'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Yenile',
            onPressed: () {
              context.read<EventListProvider>().fetchEvents(isRefresh: true);
            },
          ),
        ],
      ),
      body: Consumer<EventListProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Search input with debounce
              SearchField(
                onChanged: provider.onSearchChanged,
                onClear: provider.clearSearch,
              ),

              // Categories row
              CategoryChips(
                categories: provider.categories,
                selectedCategory: provider.selectedCategory,
                onCategorySelected: provider.setCategory,
              ),

              const SizedBox(height: 8),

              // List / State views area
              Expanded(
                child: _buildContent(context, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, EventListProvider provider) {
    if (provider.isLoading) {
      return const LoadingView(
        message: 'Etkinlikler yükleniyor...',
      );
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

    return RefreshIndicator(
      onRefresh: () => provider.fetchEvents(isRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          final isFav = favoritesProvider.isFavorite(event.id);

          return EventListTile(
            event: event,
            isFavorite: isFav,
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
      ),
    );
  }
}
