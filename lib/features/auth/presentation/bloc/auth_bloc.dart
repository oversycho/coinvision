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
      emit(user != null ? AuthAuthenticated(user) : AuthUnauthenticated());
    });

    on<AuthSignInRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await signInUseCase(email: event.email, password: event.password);
      result.fold((f) => emit(AuthError(f.message)), (u) => emit(AuthAuthenticated(u)));
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

    on<AuthSignOutRequested>((event, emit) async {
      await signOutUseCase();
      emit(AuthUnauthenticated());
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
