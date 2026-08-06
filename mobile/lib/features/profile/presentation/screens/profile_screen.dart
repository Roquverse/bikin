import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_state_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: authState.when(
          data: (user) => Column(
            children: [
              const SizedBox(height: 24),
              // Avatar
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(45),
                  border: Border.all(color: AppColors.accentCta, width: 2),
                ),
                child: const Icon(Icons.person, size: 48, color: AppColors.offWhite),
              ),
              const SizedBox(height: 16),
              Text(
                user?.name ?? 'Guest',
                style: const TextStyle(
                  color: AppColors.offWhite,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '',
                style: const TextStyle(color: AppColors.secondary, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentCta.withAlpha(40),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accentCta.withAlpha(80)),
                ),
                child: Text(
                  user?.role ?? 'ATTENDEE',
                  style: const TextStyle(
                    color: AppColors.accentCta,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _ProfileTile(
                icon: Icons.local_activity_outlined,
                label: 'My Tickets',
                onTap: () => context.push('/bookings'),
              ),
              _ProfileTile(
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: () {},
              ),
              _ProfileTile(
                icon: Icons.help_outline,
                label: 'Help & Support',
                onTap: () {},
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      await ref.read(authStateProvider.notifier).logout();
                      if (context.mounted) context.go('/login');
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Log Out',
                      style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentCta)),
          error: (_, __) => const Center(child: Text('Error', style: TextStyle(color: AppColors.error))),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.secondary),
      title: Text(label, style: const TextStyle(color: AppColors.offWhite)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.secondary),
      onTap: onTap,
    );
  }
}
