import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/utils/date_formatter.dart';
import 'features/events/data/repositories/event_repository.dart';
import 'features/events/presentation/providers/event_list_provider.dart';
import 'features/events/presentation/screens/main_navigation_screen.dart';
import 'features/favorites/data/favorites_local_storage.dart';
import 'features/favorites/presentation/providers/favorites_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Turkish date formatting with intl
  await DateFormatter.initialize();

  runApp(const EventDiscoveryApp());
}

class EventDiscoveryApp extends StatelessWidget {
  const EventDiscoveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<EventRepository>(
          create: (_) => EventRepository(),
        ),
        Provider<FavoritesLocalStorage>(
          create: (_) => FavoritesLocalStorage(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider()..loadTheme(),
        ),
        ChangeNotifierProvider<EventListProvider>(
          create: (context) => EventListProvider(
            repository: context.read<EventRepository>(),
          ),
        ),
        ChangeNotifierProvider<FavoritesProvider>(
          create: (context) => FavoritesProvider(
            storage: context.read<FavoritesLocalStorage>(),
          )..loadFavorites(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Etkinlik Keşif',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const MainNavigationScreen(),
          );
        },
      ),
    );
  }
}
