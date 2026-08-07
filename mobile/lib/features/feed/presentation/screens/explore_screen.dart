import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/discover_provider.dart';
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
      body: discoverState.when(
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
        error: (error, stack) => Center(
          child: Text('Error loading events: $error', style: const TextStyle(color: AppColors.error)),
        ),
      ),
    );
  }
}

