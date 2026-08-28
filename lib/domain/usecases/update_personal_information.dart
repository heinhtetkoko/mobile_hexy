import 'package:mobile_hexy/data/models/personal_information.dart';
import 'package:mobile_hexy/data/models/request/update_personal_info_request.dart';
import 'package:mobile_hexy/domain/repositories/profile_repository.dart';

class UpdatePersonalInformation {
  const UpdatePersonalInformation(this._repository);

  final ProfileRepository _repository;

  Future<PersonalInformation> call(UpdatePersonalInfoRequest request) =>
      _repository.updatePersonalInformation(request);
}
