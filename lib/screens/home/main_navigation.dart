import 'package:code_route_flutter/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import '../auto_ecole/auto_ecole_screen.dart';
import '../candidat/candidat_screen.dart';
import '../conduite/conduite_hub_screen.dart';
import '../cours/cours_list_screen.dart';
import '../guides/guides_screen.dart';
import 'dashboard_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  static const _screens = [
    DashboardScreen(),
    GuidesScreen(),
    CandidatScreen(),
    AutoEcoleScreen(),
    CoursListScreen(),
    ConduiteHubScreen(),
  ];

  static const _destinations = [
    _NavDestination(Icons.home_outlined, Icons.home_rounded, 'Accueil'),
    _NavDestination(
        Icons.menu_book_outlined, Icons.menu_book_rounded, 'Guides'),
    _NavDestination(Icons.badge_outlined, Icons.badge_rounded, 'Dossier'),
    _NavDestination(Icons.groups_2_outlined, Icons.groups_2_rounded, 'Auto'),
    _NavDestination(Icons.school_outlined, Icons.school_rounded, 'Cours'),
    _NavDestination(
      Icons.directions_car_outlined,
      Icons.directions_car_rounded,
      'Conduite',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final useRail = MediaQuery.of(context).size.width >= 760;

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: useRail ? _buildRailLayout() : _buildMobileLayout(),
      bottomNavigationBar: useRail ? null : _buildBottomNavigation(),
    );
  }

  Widget _buildMobileLayout() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: KeyedSubtree(
        key: ValueKey(_currentIndex),
        child: _screens[_currentIndex],
      ),
    );
  }

  Widget _buildRailLayout() {
    return SafeArea(
      child: Row(
        children: [
          NavigationRail(
            backgroundColor: AppColors.backgroundDeep,
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            minWidth: 84,
            groupAlignment: -0.82,
            labelType: NavigationRailLabelType.all,
            indicatorColor: AppColors.accentCyan.withValues(alpha: 0.16),
            selectedIconTheme: const IconThemeData(
              color: AppColors.accentCyan,
              size: 24,
            ),
            unselectedIconTheme: const IconThemeData(
              color: AppColors.textMuted,
              size: 23,
            ),
            selectedLabelTextStyle: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
            unselectedLabelTextStyle: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            destinations: [
              for (final item in _destinations)
                NavigationRailDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: Text(item.label),
                ),
            ],
          ),
          Container(width: 1, color: AppColors.borderSoft),
          Expanded(child: _buildMobileLayout()),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) => setState(() => _currentIndex = index),
      height: 72,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.accentCyan.withValues(alpha: 0.16),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        for (final item in _destinations)
          NavigationDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.selectedIcon),
            label: item.label,
          ),
      ],
    );
  }
}

class _NavDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavDestination(this.icon, this.selectedIcon, this.label);
}
