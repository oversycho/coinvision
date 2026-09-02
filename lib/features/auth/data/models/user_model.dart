import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({required super.id, super.email, super.fullName});

  factory UserModel.fromSupabase(sb.User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      fullName: user.userMetadata?['full_name'] as String?,
    );
  }
}
