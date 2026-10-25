import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/theme_provider.dart';
import '../../../../shared/widgets/floating_nav_bar.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../../favorites/presentation/screens/favorites_screen.dart';
import 'event_list_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final favCount = context.watch<FavoritesProvider>().count;
    // Rebuild navigation bar and screens when theme changes
    context.watch<ThemeProvider?>();

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          EventListScreen(),
          FavoritesScreen(),
        ],
      ),
      bottomNavigationBar: FloatingNavBar(
        currentIndex: _currentIndex,
        favoriteBadgeCount: favCount,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
