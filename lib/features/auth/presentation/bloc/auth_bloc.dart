import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final SignOutUseCase signOutUseCase;
  final AuthRepository repository;
  StreamSubscription? _authSub;

  AuthBloc({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.resetPasswordUseCase,
    required this.signOutUseCase,
    required this.repository,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>((event, emit) async {
      final user = repository.currentUser;
      if (user == null) {
        emit(AuthUnauthenticated());
        return;
      }
      if (await repository.needsMfaChallenge()) {
        final factorsResult = await repository.listMfaFactors();
        final verified = factorsResult.fold<String?>(
          (_) => null,
          (list) {
            final v = list.where((f) => f.status == 'verified');
            return v.isEmpty ? null : v.first.id;
          },
        );
        if (verified != null) {
          emit(AuthMfaChallengeRequired(verified));
          return;
        }
      }
      emit(AuthAuthenticated(user));
    });

    on<AuthSignInRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await signInUseCase(email: event.email, password: event.password);
      await result.fold(
        (f) async => emit(AuthError(f.message)),
        (u) async {
          if (await repository.needsMfaChallenge()) {
            final factorsResult = await repository.listMfaFactors();
            final verified = factorsResult.fold<String?>(
              (_) => null,
              (list) {
                final v = list.where((f) => f.status == 'verified');
                return v.isEmpty ? null : v.first.id;
              },
            );
            if (verified != null) {
              emit(AuthMfaChallengeRequired(verified));
              return;
            }
          }
          emit(AuthAuthenticated(u));
        },
      );
    });

    on<AuthMfaChallengeVerifyRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await repository.verifyMfaChallenge(factorId: event.factorId, code: event.code);
      result.fold(
        (f) => emit(AuthError(f.message)),
        (_) {
          final user = repository.currentUser;
          if (user != null) emit(AuthAuthenticated(user));
        },
      );
    });

    on<AuthSignUpRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await signUpUseCase(email: event.email, password: event.password, fullName: event.fullName);
      result.fold((f) => emit(AuthError(f.message)), (u) => emit(AuthAuthenticated(u)));
    });

    on<AuthResetPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await resetPasswordUseCase(event.email);
      result.fold((f) => emit(AuthError(f.message)), (_) => emit(AuthPasswordResetSent()));
    });

    on<AuthChangePasswordRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await repository.changePassword(event.newPassword);
      result.fold((f) => emit(AuthError(f.message)), (_) => emit(AuthPasswordChanged()));
    });

    on<AuthSignOutRequested>((event, emit) async {
      await signOutUseCase();
      emit(AuthUnauthenticated());
    });

    on<AuthMfaEnrollRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await repository.enrollMfa();
      result.fold((f) => emit(AuthError(f.message)), (r) => emit(AuthMfaEnrolled(r)));
    });

    on<AuthMfaVerifyEnrollmentRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await repository.verifyMfaEnrollment(factorId: event.factorId, code: event.code);
      result.fold((f) => emit(AuthError(f.message)), (_) => emit(AuthMfaVerified()));
    });

    on<AuthMfaListFactorsRequested>((event, emit) async {
      final result = await repository.listMfaFactors();
      result.fold((f) => emit(AuthError(f.message)), (list) => emit(AuthMfaFactorsLoaded(list)));
    });

    on<AuthMfaUnenrollRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await repository.unenrollMfa(event.factorId);
      result.fold((f) => emit(AuthError(f.message)), (_) => emit(AuthMfaUnenrolled()));
    });

    _authSub = repository.authStateChanges.listen((user) {
      if (user == null && state is AuthAuthenticated) add(AuthSignOutRequested());
    });
  }

  @override
  Future<void> close() {
    _authSub?.cancel();
    return super.close();
  }
}
