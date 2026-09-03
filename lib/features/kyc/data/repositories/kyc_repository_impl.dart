import '../../domain/repositories/kyc_repository.dart';
import '../datasources/kyc_remote_data_source.dart';

class KycRepositoryImpl implements KycRepository {
  final KycRemoteDataSource remote;
  KycRepositoryImpl(this.remote);

  @override
  Future<void> submit({required String userId, required String fullName, required String nationalId}) =>
      remote.submit(userId: userId, fullName: fullName, nationalId: nationalId);

  @override
  Stream<List<KycSubmissionEntity>> watchSubmissions(String userId) => remote.watchSubmissions(userId);
}
