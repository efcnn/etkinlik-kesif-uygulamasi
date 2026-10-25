import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/event_list_provider.dart';
import '../widgets/event_list_tile.dart';
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
    // Fetch events automatically on first screen build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventListProvider>().fetchEvents();
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
            return EmptyView(
              title: 'Henüz Etkinlik Yok',
              message: 'Şu anda listelenecek bir etkinlik bulunamadı.',
              onAction: provider.retry,
              actionButtonText: 'Yenile',
            );
          }

          final events = provider.events;

          return RefreshIndicator(
            onRefresh: () => provider.fetchEvents(isRefresh: true),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return EventListTile(
                  event: event,
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
        },
      ),
    );
  }
}

