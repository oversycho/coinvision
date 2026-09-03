import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/kyc/domain/repositories/kyc_repository.dart';

class KycCubit extends Cubit<List<KycSubmissionEntity>> {
  final KycRepository repository;
  StreamSubscription<List<KycSubmissionEntity>>? _sub;
  String? _userId;

  KycCubit(this.repository) : super(const []);

  void start(String userId) {
    _userId = userId;
    _sub?.cancel();
    _sub = repository.watchSubmissions(userId).listen((subs) => emit(subs), onError: (e) {
      // ignore: avoid_print
      print('KycCubit stream error: $e');
    });
  }

  Future<void> submit({required String fullName, required String nationalId}) {
    if (_userId == null) throw Exception('user not set');
    return repository.submit(userId: _userId!, fullName: fullName, nationalId: nationalId);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
