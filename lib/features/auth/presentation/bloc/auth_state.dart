import '../../domain/entities/mfa_entities.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  AuthAuthenticated(this.user);
}

/// Signed in with a valid password, but a verified TOTP factor exists and
/// the session hasn't been elevated to AAL2 yet — must verify a 6-digit
/// code before reaching AuthAuthenticated.
class AuthMfaChallengeRequired extends AuthState {
  final String factorId;
  AuthMfaChallengeRequired(this.factorId);
}

class AuthUnauthenticated extends AuthState {}

class AuthPasswordResetSent extends AuthState {}

class AuthPasswordChanged extends AuthState {}

class AuthMfaEnrolled extends AuthState {
  final MfaEnrollResult result;
  AuthMfaEnrolled(this.result);
}

class AuthMfaVerified extends AuthState {}

class AuthMfaFactorsLoaded extends AuthState {
  final List<MfaFactorInfo> factors;
  AuthMfaFactorsLoaded(this.factors);
}

class AuthMfaUnenrolled extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
