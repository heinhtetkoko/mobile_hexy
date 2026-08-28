import 'package:mobile_hexy/data/models/profile_summary.dart';
import 'package:mobile_hexy/data/models/personal_information.dart';
import 'package:mobile_hexy/data/models/request/update_personal_info_request.dart';
import 'package:mobile_hexy/data/models/request/change_password_request.dart';

abstract interface class ProfileRepository {
  Future<ProfileSummary> getProfile();
  Future<PersonalInformation> getPersonalInformation();
  Future<PersonalInformation> updatePersonalInformation(
    UpdatePersonalInfoRequest request,
  );
  Future<void> changePassword(ChangePasswordRequest request);
}
