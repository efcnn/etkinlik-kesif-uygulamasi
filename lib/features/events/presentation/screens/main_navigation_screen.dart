import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  final List<Widget> _screens = const [
    EventListScreen(),
    FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final favCount = context.watch<FavoritesProvider>().count;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
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
