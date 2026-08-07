import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/discover_provider.dart';
import '../providers/location_provider.dart';
import '../widgets/explore_event_card.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discoverState = ref.watch(discoverProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        title: const Text(
          'Discover Events',
          style: TextStyle(
            color: AppColors.offWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Location Chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ref.watch(availableLocationsProvider).when(
              data: (locations) {
                final selectedLocation = ref.watch(selectedLocationProvider);
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: locations.length,
                  itemBuilder: (context, index) {
                    final location = locations[index];
                    final isSelected = location == selectedLocation;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          ref.read(selectedLocationProvider.notifier).setLocation(location);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.accentCta : AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.accentCta : AppColors.divider,
                            ),
                          ),
                          child: Text(
                            location,
                            style: TextStyle(
                              color: isSelected ? Colors.black : AppColors.offWhite,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentCta)),
              error: (e, st) => const SizedBox.shrink(),
            ),
          ),
          
          // Discover Feed
          Expanded(
            child: discoverState.when(
        data: (videos) {
          if (videos.isEmpty) {
            return const Center(child: Text('No events found', style: TextStyle(color: AppColors.offWhite)));
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(discoverProvider);
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75, // Taller cards for images
              ),
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                return ExploreEventCard(video: video);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentCta)),
            ),
          ),
        ],
      ),
    );
  }
}

