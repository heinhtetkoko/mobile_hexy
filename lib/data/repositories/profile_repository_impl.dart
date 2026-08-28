import 'package:mobile_hexy/data/datasources/profile_remote_data_source.dart';
import 'package:mobile_hexy/data/models/profile_summary.dart';
import 'package:mobile_hexy/data/models/personal_information.dart';
import 'package:mobile_hexy/data/models/request/update_personal_info_request.dart';
import 'package:mobile_hexy/data/models/request/change_password_request.dart';
import 'package:mobile_hexy/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._remoteDataSource);

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<ProfileSummary> getProfile() => _remoteDataSource.fetchProfile();

  @override
  Future<PersonalInformation> getPersonalInformation() =>
      _remoteDataSource.fetchPersonalInformation();

  @override
  Future<PersonalInformation> updatePersonalInformation(
    UpdatePersonalInfoRequest request,
  ) => _remoteDataSource.updatePersonalInformation(request);

  @override
  Future<PersonalInformation> updateAvatar(String base64Image) =>
      _remoteDataSource.updateAvatar(base64Image);

  @override
  Future<void> changePassword(ChangePasswordRequest request) =>
      _remoteDataSource.changePassword(request);
}
