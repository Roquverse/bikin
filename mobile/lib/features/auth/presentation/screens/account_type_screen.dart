import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../domain/repositories/auth_repository.dart';
import '../providers/auth_state_provider.dart';
import '../widgets/animated_button_wrapper.dart';
import '../widgets/account_type_card.dart';

class AccountTypeScreen extends ConsumerStatefulWidget {
  const AccountTypeScreen({super.key});

  @override
  ConsumerState<AccountTypeScreen> createState() => _AccountTypeScreenState();
}

class _AccountTypeScreenState extends ConsumerState<AccountTypeScreen> {
  String _selectedType = 'Attendee'; // Default
  bool _isLoading = false;

  Future<void> _handleContinue() async {
    setState(() => _isLoading = true);
    try {
      // Call authRepository to save the selected account type in database
      await ref.read(authRepositoryProvider).setAccountType(_selectedType);
      // Reload user data so the active authState has the updated role
      await ref.read(authStateProvider.notifier).refreshUser();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to set account type: $e')),
        );
      }
    }
    setState(() => _isLoading = false);

    if (mounted) context.go('/home-feed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Type'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How will you use Bikin?',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'You can change this later in your profile settings.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 32),
              AccountTypeCard(
                title: 'Attendee',
                description: 'Discover events and book tickets easily.',
                icon: Icons.local_activity,
                isSelected: _selectedType == 'Attendee',
                onTap: () => setState(() => _selectedType = 'Attendee'),
              ),
              const SizedBox(height: 16),
              AccountTypeCard(
                title: 'Organizer',
                description: 'Create and manage your own live events.',
                icon: Icons.event_available,
                isSelected: _selectedType == 'Organizer',
                onTap: () => setState(() => _selectedType = 'Organizer'),
              ),
              const Spacer(),
              AnimatedButtonWrapper(
                child: PrimaryButton(
                  text: 'Continue',
                  isLoading: _isLoading,
                  onPressed: _handleContinue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
