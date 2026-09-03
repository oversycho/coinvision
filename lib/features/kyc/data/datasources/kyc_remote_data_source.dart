import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/kyc_repository.dart';

abstract class KycRemoteDataSource {
  Future<void> submit({required String userId, required String fullName, required String nationalId});
  Stream<List<KycSubmissionEntity>> watchSubmissions(String userId);
}

class KycRemoteDataSourceImpl implements KycRemoteDataSource {
  final SupabaseClient client;
  KycRemoteDataSourceImpl(this.client);

  @override
  Future<void> submit({required String userId, required String fullName, required String nationalId}) async {
    await client.from('kyc_submissions').insert({
      'user_id': userId,
      'full_name': fullName,
      'national_id': nationalId,
    });
  }

  @override
  Stream<List<KycSubmissionEntity>> watchSubmissions(String userId) {
    return client
        .from('kyc_submissions')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('submitted_at')
        .map((rows) => rows.map(KycSubmissionEntity.fromMap).toList().reversed.toList());
  }
}
