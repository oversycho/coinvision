import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/mfa_entities.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signUp({required String email, required String password, required String fullName});
  Future<UserModel> signIn({required String email, required String password});
  Future<void> resetPassword(String email);
  Future<void> changePassword(String newPassword);
  Future<void> signOut();
  UserModel? get currentUser;
  Stream<UserModel?> get authStateChanges;

  Future<MfaEnrollResult> enrollMfa();
  Future<void> verifyMfaEnrollment({required String factorId, required String code});
  List<MfaFactorInfo> listMfaFactors();
  Future<void> unenrollMfa(String factorId);
  Future<bool> needsMfaChallenge();
  Future<void> verifyMfaChallenge({required String factorId, required String code});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient client;
  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<UserModel> signUp({required String email, required String password, required String fullName}) async {
    try {
      final res = await client.auth.signUp(email: email, password: password, data: {'full_name': fullName});
      if (res.user == null) throw ServerException('ثبت‌نام ناموفق بود');
      return UserModel.fromSupabase(res.user!);
    } on AuthException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<UserModel> signIn({required String email, required String password}) async {
    try {
      final res = await client.auth.signInWithPassword(email: email, password: password);
      if (res.user == null) throw ServerException('ورود ناموفق بود');
      return UserModel.fromSupabase(res.user!);
    } on AuthException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<void> changePassword(String newPassword) async {
    try {
      await client.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<void> signOut() => client.auth.signOut();

  @override
  UserModel? get currentUser {
    final u = client.auth.currentUser;
    return u != null ? UserModel.fromSupabase(u) : null;
  }

  @override
  Stream<UserModel?> get authStateChanges =>
      client.auth.onAuthStateChange.map((data) => data.session?.user != null ? UserModel.fromSupabase(data.session!.user) : null);

  @override
  Future<MfaEnrollResult> enrollMfa() async {
    try {
      final res = await client.auth.mfa.enroll(factorType: FactorType.totp);
      return MfaEnrollResult(factorId: res.id, qrCodeSvg: res.totp.qrCode, secret: res.totp.secret);
    } on AuthException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<void> verifyMfaEnrollment({required String factorId, required String code}) async {
    try {
      await client.auth.mfa.challengeAndVerify(factorId: factorId, code: code);
    } on AuthException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  List<MfaFactorInfo> listMfaFactors() {
    final factors = client.auth.currentUser?.factors ?? [];
    return factors
        .where((f) => f.factorType == 'totp')
        .map((f) => MfaFactorInfo(id: f.id, status: f.status.name))
        .toList();
  }

  @override
  Future<void> unenrollMfa(String factorId) async {
    try {
      await client.auth.mfa.unenroll(factorId);
    } on AuthException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<bool> needsMfaChallenge() async {
    final res = await client.auth.mfa.getAuthenticatorAssuranceLevel();
    return res.currentLevel == AuthenticatorAssuranceLevels.aal1 && res.nextLevel == AuthenticatorAssuranceLevels.aal2;
  }

  @override
  Future<void> verifyMfaChallenge({required String factorId, required String code}) async {
    try {
      await client.auth.mfa.challengeAndVerify(factorId: factorId, code: code);
    } on AuthException catch (e) {
      throw ServerException(e.message);
    }
  }
}
