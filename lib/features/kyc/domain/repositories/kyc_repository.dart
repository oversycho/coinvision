enum KycStatus { pending, approved, rejected }

class KycSubmissionEntity {
  final String id;
  final String fullName;
  final String nationalId;
  final KycStatus status;
  final DateTime submittedAt;

  const KycSubmissionEntity({
    required this.id,
    required this.fullName,
    required this.nationalId,
    required this.status,
    required this.submittedAt,
  });

  factory KycSubmissionEntity.fromMap(Map<String, dynamic> map) => KycSubmissionEntity(
        id: map['id'] as String,
        fullName: map['full_name'] as String,
        nationalId: map['national_id'] as String,
        status: switch (map['status'] as String) {
          'approved' => KycStatus.approved,
          'rejected' => KycStatus.rejected,
          _ => KycStatus.pending,
        },
        submittedAt: DateTime.tryParse(map['submitted_at'] as String? ?? '') ?? DateTime.now(),
      );
}

abstract class KycRepository {
  Future<void> submit({required String userId, required String fullName, required String nationalId});
  Stream<List<KycSubmissionEntity>> watchSubmissions(String userId);
}
