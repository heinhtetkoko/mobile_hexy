import 'package:mobile_hexy/data/models/request/change_password_request.dart';
import 'package:mobile_hexy/domain/repositories/profile_repository.dart';

class ChangePassword {
  const ChangePassword(this._repository);

  final ProfileRepository _repository;

  Future<void> call(ChangePasswordRequest request) =>
      _repository.changePassword(request);
}
