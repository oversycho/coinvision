import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/mfa_entities.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  AuthRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, UserEntity>> signIn({required String email, required String password}) async {
    try {
      return Right(await remote.signIn(email: email, password: password));
    } on ServerException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUp({required String email, required String password, required String fullName}) async {
    try {
      return Right(await remote.signUp(email: email, password: password, fullName: fullName));
    } on ServerException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await remote.resetPassword(email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(String newPassword) async {
    try {
      await remote.changePassword(newPassword);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remote.signOut();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  UserEntity? get currentUser => remote.currentUser;

  @override
  Stream<UserEntity?> get authStateChanges => remote.authStateChanges;

  @override
  Future<Either<Failure, MfaEnrollResult>> enrollMfa() async {
    try {
      return Right(await remote.enrollMfa());
    } on ServerException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> verifyMfaEnrollment({required String factorId, required String code}) async {
    try {
      await remote.verifyMfaEnrollment(factorId: factorId, code: code);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<MfaFactorInfo>>> listMfaFactors() async {
    try {
      return Right(remote.listMfaFactors());
    } on ServerException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> unenrollMfa(String factorId) async {
    try {
      await remote.unenrollMfa(factorId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<bool> needsMfaChallenge() => remote.needsMfaChallenge();

  @override
  Future<Either<Failure, void>> verifyMfaChallenge({required String factorId, required String code}) async {
    try {
      await remote.verifyMfaChallenge(factorId: factorId, code: code);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }
}
