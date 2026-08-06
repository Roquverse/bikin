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
import '../widgets/main_shell.dart';
import '../../features/tickets/presentation/screens/bookings_screen.dart';

part 'app_router.g.dart';

// Slide + Fade custom transition
CustomTransitionPage<T> buildSlideFadeTransition<T>({
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

@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
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
      // Main app shell — contains bottom nav + all tabs
      GoRoute(
        path: '/home-feed',
        builder: (context, state) => const MainShell(),
      ),
      GoRoute(
        path: '/bookings',
        pageBuilder: (context, state) => buildSlideFadeTransition(
          context: context,
          state: state,
          child: const BookingsScreen(),
        ),
      ),
    ],
  );
}
