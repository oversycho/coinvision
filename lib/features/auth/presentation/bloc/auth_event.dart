abstract class AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  AuthSignInRequested({required this.email, required this.password});
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  AuthSignUpRequested({required this.email, required this.password, required this.fullName});
}

class AuthResetPasswordRequested extends AuthEvent {
  final String email;
  AuthResetPasswordRequested(this.email);
}

class AuthChangePasswordRequested extends AuthEvent {
  final String newPassword;
  AuthChangePasswordRequested(this.newPassword);
}

class AuthSignOutRequested extends AuthEvent {}

// --- MFA ---
class AuthMfaEnrollRequested extends AuthEvent {}

class AuthMfaVerifyEnrollmentRequested extends AuthEvent {
  final String factorId;
  final String code;
  AuthMfaVerifyEnrollmentRequested({required this.factorId, required this.code});
}

class AuthMfaListFactorsRequested extends AuthEvent {}

class AuthMfaUnenrollRequested extends AuthEvent {
  final String factorId;
  AuthMfaUnenrollRequested(this.factorId);
}

class AuthMfaChallengeVerifyRequested extends AuthEvent {
  final String factorId;
  final String code;
  AuthMfaChallengeVerifyRequested({required this.factorId, required this.code});
}
