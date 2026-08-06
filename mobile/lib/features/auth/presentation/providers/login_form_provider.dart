import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_form_provider.g.dart';

class LoginFormState {
  final int failedAttempts;
  final int lockTimeRemaining;

  bool get isLocked => lockTimeRemaining > 0;

  const LoginFormState({
    this.failedAttempts = 0,
    this.lockTimeRemaining = 0,
  });

  LoginFormState copyWith({
    int? failedAttempts,
    int? lockTimeRemaining,
  }) {
    return LoginFormState(
      failedAttempts: failedAttempts ?? this.failedAttempts,
      lockTimeRemaining: lockTimeRemaining ?? this.lockTimeRemaining,
    );
  }
}

@riverpod
class LoginForm extends _$LoginForm {
  Timer? _lockTimer;

  @override
  LoginFormState build() {
    ref.onDispose(() {
      _lockTimer?.cancel();
    });
    return const LoginFormState();
  }

  void recordFailure() {
    final newAttempts = state.failedAttempts + 1;
    if (newAttempts >= 5) {
      _startLockout();
    } else {
      state = state.copyWith(failedAttempts: newAttempts);
    }
  }

  void recordSuccess() {
    state = const LoginFormState();
    _lockTimer?.cancel();
  }

  void _startLockout() {
    state = state.copyWith(failedAttempts: 5, lockTimeRemaining: 30);
    _lockTimer?.cancel();
    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.lockTimeRemaining > 1) {
        state = state.copyWith(lockTimeRemaining: state.lockTimeRemaining - 1);
      } else {
        timer.cancel();
        // Reset attempts after lockout period
        state = const LoginFormState();
      }
    });
  }
}
