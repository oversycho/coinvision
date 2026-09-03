import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../entities/mfa_entities.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> resetPassword(String email);

  Future<Either<Failure, void>> changePassword(String newPassword);

  Future<Either<Failure, void>> signOut();

  UserEntity? get currentUser;

  Stream<UserEntity?> get authStateChanges;

  // --- MFA (TOTP two-factor auth) ---
  Future<Either<Failure, MfaEnrollResult>> enrollMfa();
  Future<Either<Failure, void>> verifyMfaEnrollment({required String factorId, required String code});
  Future<Either<Failure, List<MfaFactorInfo>>> listMfaFactors();
  Future<Either<Failure, void>> unenrollMfa(String factorId);

  /// True if the current session needs a second-factor challenge before
  /// reaching full (AAL2) access — i.e. the user has a verified TOTP factor.
  Future<bool> needsMfaChallenge();
  Future<Either<Failure, void>> verifyMfaChallenge({required String factorId, required String code});
}

