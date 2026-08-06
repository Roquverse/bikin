import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../providers/auth_state_provider.dart';
import '../widgets/animated_button_wrapper.dart';
import '../widgets/otp_input.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  String _otp = '';

  Future<void> _handleVerify() async {
    if (_otp.length != 6) return;
    
    try {
      await ref.read(authStateProvider.notifier).verifyOtp(widget.email, _otp);
      if (mounted) context.go('/account-type');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authStateProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
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
                'Verify Email',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the 6-digit code sent to\n${widget.email}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.offWhite.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 48),
              OtpInput(
                onCompleted: (otp) {
                  setState(() => _otp = otp);
                  // Optionally auto-verify here
                },
              ),
              const SizedBox(height: 32),
              AnimatedButtonWrapper(
                child: PrimaryButton(
                  text: 'Verify',
                  isLoading: isLoading,
                  onPressed: _otp.length == 6 ? _handleVerify : null,
                ),
              ),
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: () {
                    // Trigger resend logic
                  },
                  child: const Text(
                    'Resend Code',
                    style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
