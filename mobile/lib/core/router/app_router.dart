import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/account_type_screen.dart';
import '../widgets/theme_preview_screen.dart';

import '../../features/feed/presentation/screens/home_feed_screen.dart';

part 'app_router.g.dart';

// Slide + Fade custom transition
CustomTransitionPage buildSlideFadeTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);
      var fadeAnimation = animation.drive(CurveTween(curve: Curves.easeIn));

      return SlideTransition(
        position: offsetAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: child,
        ),
      );
    },
  );
}

// Placeholder for non-auth routes
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('Placeholder for $title')),
    );
  }
}

@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/theme-preview',
        builder: (context, state) => const ThemePreviewScreen(),
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => buildSlideFadeTransition(
          context: context,
          state: state,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => buildSlideFadeTransition(
          context: context,
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) => buildSlideFadeTransition(
          context: context,
          state: state,
          child: const SignupScreen(),
        ),
      ),
      GoRoute(
        path: '/otp',
        pageBuilder: (context, state) {
          final email = state.extra as String? ?? '';
          return buildSlideFadeTransition(
            context: context,
            state: state,
            child: OtpScreen(email: email),
          );
        },
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => buildSlideFadeTransition(
          context: context,
          state: state,
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: '/account-type',
        pageBuilder: (context, state) => buildSlideFadeTransition(
          context: context,
          state: state,
          child: const AccountTypeScreen(),
        ),
      ),
      GoRoute(
        path: '/home-feed',
        builder: (context, state) => const HomeFeedScreen(),
      ),
      GoRoute(
        path: '/booking-sheet',
        builder: (context, state) => const PlaceholderScreen(title: 'Booking Sheet'),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const PlaceholderScreen(title: 'Checkout'),
      ),
      GoRoute(
        path: '/ticket',
        builder: (context, state) => const PlaceholderScreen(title: 'Ticket'),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const PlaceholderScreen(title: 'Profile'),
      ),
    ],
  );
}
