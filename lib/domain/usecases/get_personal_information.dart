import 'package:mobile_hexy/data/models/personal_information.dart';
import 'package:mobile_hexy/domain/repositories/profile_repository.dart';

class GetPersonalInformation {
  const GetPersonalInformation(this._repository);

  final ProfileRepository _repository;

  Future<PersonalInformation> call() => _repository.getPersonalInformation();
}
