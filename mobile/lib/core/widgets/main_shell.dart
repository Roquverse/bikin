import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../../features/feed/presentation/screens/home_feed_screen.dart';
import '../../features/feed/presentation/screens/explore_screen.dart';
import '../../features/tickets/presentation/screens/bookings_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/auth/presentation/providers/auth_state_provider.dart';
import '../../features/tickets/presentation/screens/create_event_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeFeedScreen(),
    ExploreScreen(),
    BookingsScreen(),
    ProfileScreen(),
  ];

  void _showCreateEventSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateEventScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Feed screen: fully immersive dark mode - hide system chrome  
    // Other screens: show status bar
    final isFeed = _currentIndex == 0;
    
    final authState = ref.watch(authStateProvider);
    final isOrganizer = authState.value?.role == 'ORGANIZER';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.primaryBackground,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.primaryBackground,
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: _BikinNavBar(
          currentIndex: _currentIndex,
          isOrganizer: isOrganizer,
          onTap: (index) => setState(() => _currentIndex = index),
          onCreateTap: () => _showCreateEventSheet(context),
        ),
      ),
    );
  }
}

class _BikinNavBar extends StatelessWidget {
  final int currentIndex;
  final bool isOrganizer;
  final ValueChanged<int> onTap;
  final VoidCallback onCreateTap;

  const _BikinNavBar({
    required this.currentIndex,
    required this.isOrganizer,
    required this.onTap,
    required this.onCreateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        border: const Border(
          top: BorderSide(color: Color(0xFF1A4D3A), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(80),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_filled,
                outlinedIcon: Icons.home_outlined,
                label: 'Home',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.explore,
                outlinedIcon: Icons.explore_outlined,
                label: 'Discover',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              if (isOrganizer)
                GestureDetector(
                  onTap: onCreateTap,
                  child: Container(
                    margin: const EdgeInsets.only(top: 4, bottom: 4),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentCta.withAlpha(40),
                      border: Border.all(color: AppColors.accentCta, width: 2),
                    ),
                    child: const Icon(Icons.add_circle, color: AppColors.accentCta, size: 28),
                  ),
                ),
              _NavItem(
                icon: Icons.local_activity,
                outlinedIcon: Icons.local_activity_outlined,
                label: 'Tickets',
                isActive: currentIndex == 2, // Keep index 2 for Tickets view
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.person,
                outlinedIcon: Icons.person_outline,
                label: 'Profile',
                isActive: currentIndex == 3, // Keep index 3 for Profile view
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData outlinedIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.outlinedIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? icon : outlinedIcon,
                key: ValueKey(isActive),
                color: isActive ? AppColors.accentCta : AppColors.secondary,
                size: 26,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isActive ? AppColors.accentCta : AppColors.secondary,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
