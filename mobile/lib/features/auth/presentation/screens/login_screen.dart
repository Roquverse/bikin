import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../providers/auth_state_provider.dart';
import '../providers/login_form_provider.dart';
import '../widgets/animated_button_wrapper.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_auth_buttons.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _localAuth = LocalAuthentication();
  String _accountType = 'attendee';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final formState = ref.read(loginFormProvider);
    if (formState.isLocked) return;

    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      await ref.read(authStateProvider.notifier).login(email, password);
      // Wait for auth state to update
      final authState = ref.read(authStateProvider);
      if (authState.value != null) {
        ref.read(loginFormProvider.notifier).recordSuccess();
        if (mounted) context.go('/home-feed');
      } else if (authState.hasError) {
        ref.read(loginFormProvider.notifier).recordFailure();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authState.error.toString())),
          );
        }
      }
    } catch (e) {
      ref.read(loginFormProvider.notifier).recordFailure();
    }
  }

  Future<void> _handleBiometricAuth() async {
    try {
      final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      if (!canAuthenticate) return;

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to log in to Bikin',
        biometricOnly: true,
      );

      if (didAuthenticate && mounted) {
        // Normally, biometrics unlock an encrypted local token,
        // here we assume successful biometrics allows fetching the stored token and proceeding.
        // For full security, secure storage should be unlocked by biometrics.
        context.go('/home-feed');
      }
    } catch (e) {
      // Fallback to password
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric authentication failed. Please use password.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(loginFormProvider);
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Image with rounded bottom
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              child: Stack(
                children: [
                  Image.asset(
                    'assets/login.png',
                    height: size.height * 0.25,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  // Gradient for text/button visibility
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Title and Subtitle
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Text(
                          'Bikin',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Log in to your account',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Back Button
                  Positioned(
                    top: MediaQuery.of(context).padding.top,
                    left: 4,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                      onPressed: () => context.pop(),
                    ),
                  ),
                ],
              ),
            ),
            
            // Form Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Account Type Toggle
                    Center(
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'attendee', label: Text('Attendee')),
                          ButtonSegment(value: 'organizer', label: Text('Organizer')),
                        ],
                        selected: {_accountType},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            _accountType = newSelection.first;
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.selected)) {
                                return AppColors.accentCta;
                              }
                              return Colors.white;
                            },
                          ),
                          foregroundColor: WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.selected)) {
                                return Colors.white;
                              }
                              return Colors.black87;
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Email Field
                    const Text(
                      'Email',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    CustomTextField(
                      hintText: 'user@example.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                      isLightMode: true,
                    ),
                    const SizedBox(height: 12),
                    
                    // Password Field with Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Password',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/forgot-password'),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: AppColors.accentCta, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    CustomTextField(
                      hintText: '••••••••',
                      controller: _passwordController,
                      obscureText: true,
                      validator: Validators.validatePassword,
                      isLightMode: true,
                    ),
                    const SizedBox(height: 8),
                    
                    // Remember me (Visual only for now)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Remember me next time',
                          style: TextStyle(color: Colors.black54, fontSize: 13),
                        ),
                        Transform.scale(
                          scale: 0.85,
                          child: Checkbox(
                            value: true,
                            onChanged: (val) {},
                            activeColor: AppColors.accentCta,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    if (formState.isLocked) ...[
                      Center(
                        child: Text(
                          'Too many failed attempts.\nTry again in ${formState.lockTimeRemaining}s',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.error, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    
                    AnimatedButtonWrapper(
                      child: PrimaryButton(
                        text: 'Log In',
                        isLoading: isLoading,
                        onPressed: formState.isLocked ? null : _handleLogin,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    const SocialAuthButtons(),
                    const SizedBox(height: 16),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Don\'t have an account? ', style: TextStyle(color: Colors.black54, fontSize: 13)),
                        GestureDetector(
                          onTap: () => context.pushReplacement('/signup'),
                          child: const Text(
                            'Sign up',
                            style: TextStyle(color: AppColors.accentCta, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
