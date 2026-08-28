import 'package:mobile_hexy/data/models/profile_summary.dart';
import 'package:mobile_hexy/domain/repositories/profile_repository.dart';

class GetProfile {
  const GetProfile(this._repository);

  final ProfileRepository _repository;

  Future<ProfileSummary> call() => _repository.getProfile();
}
