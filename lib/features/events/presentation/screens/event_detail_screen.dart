import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../data/models/event_model.dart';
import '../../data/repositories/event_repository.dart';
import '../providers/event_detail_provider.dart';

class EventDetailScreen extends StatelessWidget {
  final EventModel initialEvent;

  const EventDetailScreen({
    super.key,
    required this.initialEvent,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EventDetailProvider(
        repository: context.read<EventRepository>(),
        initialEvent: initialEvent,
      )..fetchDescription(),
      child: const _EventDetailView(),
    );
  }
}

class _EventDetailView extends StatelessWidget {
  const _EventDetailView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventDetailProvider>();
    final event = provider.event;

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image Header
            Container(
              width: double.infinity,
              height: 220,
              color: Colors.grey[300],
              child: event.imageUrl.isNotEmpty
                  ? Image.network(
                      event.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.grey)),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                    )
                  : const Center(child: Icon(Icons.event, size: 64, color: Colors.grey)),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Online Chip
                  Row(
                    children: [
                      Chip(
                        label: Text(
                          event.category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        side: BorderSide.none,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const SizedBox(width: 8),
                      if (event.isOnline)
                        Chip(
                          label: const Text(
                            'Online',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal),
                          ),
                          backgroundColor: Colors.teal.withValues(alpha: 0.1),
                          side: BorderSide.none,
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Event Title
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Location Info Row
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.location,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[700],
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Info Tiles (Date, Organizer, Capacity)
                  _buildInfoTile(
                    context,
                    icon: Icons.calendar_today,
                    title: 'Tarih & Saat',
                    subtitle: DateFormatter.formatRange(event.startDate, event.endDate),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoTile(
                    context,
                    icon: Icons.person_outline,
                    title: 'Organizatör',
                    subtitle: event.organizer,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoTile(
                    context,
                    icon: Icons.group_outlined,
                    title: 'Katılımcı Durumu',
                    subtitle: '${event.registeredCount} / ${event.capacity} kayıtlı kişi',
                  ),

                  // Tags Section
                  if (event.tags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Etiketler',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: event.tags
                          .map(
                            (tag) => Chip(
                              label: Text('#$tag', style: const TextStyle(fontSize: 11)),
                              backgroundColor: Colors.grey[100],
                              side: BorderSide.none,
                              padding: EdgeInsets.zero,
                            ),
                          )
                          .toList(),
                    ),
                  ],

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Description Section (Isolated State & Retry)
                  Text(
                    'Etkinlik Hakkında',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  _buildDescriptionSection(context, provider),
                  const SizedBox(height: 80), // spacing for bottom bar
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Favori özelliği Milestone 6\'da entegre edilecek.'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.favorite_border_rounded),
                  label: const Text('Favorilere Ekle'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
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
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              'Açıklama getiriliyor...',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (provider.descriptionError != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.redAccent, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                provider.descriptionError!,
                style: const TextStyle(fontSize: 13, color: Colors.redAccent),
              ),
            ),
            TextButton(
              onPressed: provider.retryDescription,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    final description = provider.event.description;
    if (description == null || description.trim().isEmpty) {
      return Text(
        'Bu etkinlik için henüz bir açıklama girilmemiş.',
        style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          description,
          maxLines: provider.isDescriptionExpanded ? null : 3,
          overflow: provider.isDescriptionExpanded ? null : TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Colors.grey[800],
          ),
        ),
        if (description.length > 80)
          GestureDetector(
            onTap: provider.toggleDescriptionExpanded,
            child: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                provider.isDescriptionExpanded ? 'Daha Az Göster' : 'Daha Fazla Göster',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

