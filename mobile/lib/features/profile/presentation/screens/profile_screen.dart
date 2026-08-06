import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/presentation/providers/auth_state_provider.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/buttons/outline_button.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showSwitchAccountTypeDialog(BuildContext context, WidgetRef ref, String currentRole) {
    String selectedType = currentRole == 'ORGANIZER' ? 'Organizer' : 'Attendee';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(color: AppColors.secondary.withAlpha(80), borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Switch Account Type',
                  style: TextStyle(color: AppColors.offWhite, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose how you want to use Bikin.',
                  style: TextStyle(color: AppColors.secondary.withAlpha(200), fontSize: 13),
                ),
                const SizedBox(height: 20),
                _AccountTypeOption(
                  title: 'Attendee',
                  subtitle: 'Discover events and book tickets easily.',
                  icon: Icons.local_activity_outlined,
                  isSelected: selectedType == 'Attendee',
                  onTap: () => setSheetState(() => selectedType = 'Attendee'),
                ),
                const SizedBox(height: 12),
                _AccountTypeOption(
                  title: 'Organizer',
                  subtitle: 'Create and manage your own live events.',
                  icon: Icons.event_available_outlined,
                  isSelected: selectedType == 'Organizer',
                  onTap: () => setSheetState(() => selectedType = 'Organizer'),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      try {
                        await ref.read(authRepositoryProvider).setAccountType(selectedType);
                        await ref.read(authStateProvider.notifier).refreshUser();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.success,
                              content: Text(
                                'Account type updated to $selectedType!',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to update: $e')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentCta,
                      foregroundColor: AppColors.primaryBackground,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: authState.when(
          data: (user) {
            final isOrganizer = user?.role == 'ORGANIZER';
            final userName = user?.name ?? 'Guest';
            final handle = '@${userName.replaceAll(' ', '_')}';
            
            return Column(
              children: [
                // Top Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.location_on_outlined, color: AppColors.offWhite, size: 20),
                          SizedBox(width: 4),
                          Text('Lagos', style: TextStyle(color: AppColors.offWhite, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.search, color: AppColors.offWhite),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) => [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            // Avatar with border ring
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.accentCta, width: 2),
                              ),
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.surfaceElevated,
                                  image: DecorationImage(
                                    image: NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026704d'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Handle
                            Text(
                              handle,
                              style: const TextStyle(
                                color: AppColors.offWhite,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Bio
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                isOrganizer 
                                  ? 'Electronic music lover & event curator in Lagos.'
                                  : 'Exploring the best events in town.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: AppColors.secondary, fontSize: 14),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Stats
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const _StatColumn(count: '1.2k', label: 'FOLLOWERS'),
                                const SizedBox(width: 24),
                                Container(height: 24, width: 1, color: AppColors.secondary),
                                const SizedBox(width: 24),
                                const _StatColumn(count: '842', label: 'FOLLOWING'),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Actions
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _showSwitchAccountTypeDialog(context, ref, user?.role ?? 'ATTENDEE'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.accentCta,
                                        foregroundColor: AppColors.primaryBackground,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      ),
                                      child: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {},
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: AppColors.secondary),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      ),
                                      child: const Text('Share', style: TextStyle(color: AppColors.offWhite, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Custom TabBar Container
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: TabBar(
                                  controller: _tabController,
                                  indicator: BoxDecoration(
                                    color: AppColors.surfaceElevated.withAlpha(200),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: AppColors.accentCta, width: 1.5),
                                  ),
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  dividerColor: Colors.transparent,
                                  labelColor: AppColors.accentCta,
                                  unselectedLabelColor: AppColors.secondary,
                                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  tabs: const [
                                    Tab(text: 'Reels'),
                                    Tab(text: 'Tickets'),
                                    Tab(text: 'Liked'),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                    body: TabBarView(
                      controller: _tabController,
                      children: [
                        // Reels Grid
                        _ProfileGrid(isOrganizer: isOrganizer),
                        
                        // Tickets tab (placeholder)
                        const Center(child: Text('Tickets List', style: TextStyle(color: AppColors.secondary))),
                        
                        // Liked tab (placeholder)
                        const Center(child: Text('Liked Reels', style: TextStyle(color: AppColors.secondary))),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentCta)),
          error: (_, __) => const Center(child: Text('Error loading profile', style: TextStyle(color: AppColors.error))),
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String count;
  final String label;

  const _StatColumn({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count, style: const TextStyle(color: AppColors.offWhite, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.secondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ],
    );
  }
}

class _ProfileGrid extends StatelessWidget {
  final bool isOrganizer;

  const _ProfileGrid({required this.isOrganizer});

  @override
  Widget build(BuildContext context) {
    // Generate dummy grid items based on mockup
    final dummyViews = ['4.2k', '8.1k', '2.5k', '11k', '900', '5.6k'];
    
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.65, // Taller aspect ratio for reels
      ),
      itemCount: dummyViews.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            image: const DecorationImage(
              image: NetworkImage('https://source.unsplash.com/random/400x600/?concert,dj,party'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: 8,
                left: 8,
                child: Row(
                  children: [
                    const Icon(Icons.play_arrow_outlined, color: Colors.white, size: 14),
                    const SizedBox(width: 2),
                    Text(
                      dummyViews[index],
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              if (index == 0) // Pin icon on the first one
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.push_pin, color: Colors.white, size: 14),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _AccountTypeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountTypeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentCta.withAlpha(20) : AppColors.primaryBackground.withAlpha(120),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.accentCta : AppColors.secondary.withAlpha(50),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentCta.withAlpha(30) : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isSelected ? AppColors.accentCta : AppColors.secondary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? AppColors.offWhite : AppColors.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: AppColors.secondary.withAlpha(180), fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.accentCta : AppColors.secondary.withAlpha(80),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.accentCta,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
