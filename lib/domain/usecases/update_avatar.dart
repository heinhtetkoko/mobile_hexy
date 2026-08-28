import 'package:mobile_hexy/data/models/personal_information.dart';
import 'package:mobile_hexy/domain/repositories/profile_repository.dart';

class UpdateAvatar {
  const UpdateAvatar(this._repository);

  final ProfileRepository _repository;

  Future<PersonalInformation> call(String base64Image) =>
      _repository.updateAvatar(base64Image);
}
