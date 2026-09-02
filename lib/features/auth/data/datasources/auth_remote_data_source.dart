import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signUp({required String email, required String password, required String fullName});
  Future<UserModel> signIn({required String email, required String password});
  Future<void> resetPassword(String email);
  Future<void> signOut();
  UserModel? get currentUser;
  Stream<UserModel?> get authStateChanges;
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
  Future<void> signOut() => client.auth.signOut();

  @override
  UserModel? get currentUser {
    final u = client.auth.currentUser;
    return u != null ? UserModel.fromSupabase(u) : null;
  }

  @override
  Stream<UserModel?> get authStateChanges =>
      client.auth.onAuthStateChange.map((data) => data.session?.user != null ? UserModel.fromSupabase(data.session!.user) : null);
}
