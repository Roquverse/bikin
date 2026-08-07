import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../providers/auth_state_provider.dart';
import '../widgets/animated_button_wrapper.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/password_strength_meter.dart';
import '../widgets/social_auth_buttons.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final String _accountType = 'organizer';
  
  bool _isPasswordValid = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      setState(() {
        _isPasswordValid = Validators.validatePassword(_passwordController.text) == null;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate() || !_isPasswordValid) return;

    try {
      await ref.read(authStateProvider.notifier).signup(
        _emailController.text,
        _passwordController.text,
        _nameController.text,
        _accountType,
      );
      
      if (mounted) context.push('/otp', extra: _emailController.text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign up: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Image Background with rounded bottom
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              child: Stack(
                children: [
                  Image.asset(
                    'assets/signup.png',
                    height: size.height * 0.25,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  // Gradient for text visibility
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
                  // Text
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
                          'Create an account',
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

                  
                    // Full Name Field
                    const Text(
                      'Full Name',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    CustomTextField(
                      hintText: 'John Doe',
                      controller: _nameController,
                      validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
                      isLightMode: true,
                    ),
                    const SizedBox(height: 12),
                    
                    // Email Field
                    const Text(
                      'Your Email Address',
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
                    
                    // Password Field
                    const Text(
                      'Choose a Password',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    CustomTextField(
                      hintText: 'min. 8 characters',
                      controller: _passwordController,
                      obscureText: true,
                      validator: Validators.validatePassword,
                      isLightMode: true,
                    ),
                    const SizedBox(height: 6),
                    PasswordStrengthMeter(password: _passwordController.text),
                    const SizedBox(height: 8),
                    
                    // Terms Checkbox (Visual only)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: const TextSpan(
                            text: 'I agree with ',
                            style: TextStyle(color: Colors.black54, fontSize: 13),
                            children: [
                              TextSpan(
                                text: 'terms of use',
                                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
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
                    
                    AnimatedButtonWrapper(
                      child: PrimaryButton(
                        text: 'Sign Up',
                        isLoading: isLoading,
                        onPressed: _isPasswordValid ? _handleSignup : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    const SocialAuthButtons(),
                    const SizedBox(height: 16),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ', 
                          style: TextStyle(color: Colors.black54, fontSize: 13)
                        ),
                        GestureDetector(
                          onTap: () => context.pushReplacement('/login'),
                          child: const Text(
                            'Log in',
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
