import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/core/networks/api_service.dart';
import 'package:mobile_hexy/data/models/profile_summary.dart';
import 'package:mobile_hexy/data/models/personal_information.dart';
import 'package:mobile_hexy/data/models/request/update_personal_info_request.dart';
import 'package:mobile_hexy/data/models/request/change_password_request.dart';

class ProfileRemoteDataSource {
  const ProfileRemoteDataSource(this._apiService);

  final ApiService _apiService;

  Future<bool> canDeleteAccount() async {
    final response = await _apiService.get<dynamic>(ApiEndpoints.deleteAccount);
    final body = response.data;
    if (body is! Map || body['success'] == false) {
      throw const FormatException(
        'Could not check account deletion availability.',
      );
    }
    final data = body['data'];
    return (data is Map ? data['status'] : body['status']) == true;
  }

  Future<void> deleteAccount() async {
    final response = await _apiService.post<dynamic>(
      ApiEndpoints.deleteAccount,
      data: {'status': true},
    );
    final body = response.data;
    if (body is! Map || body['success'] != true) {
      throw FormatException(
        body is Map
            ? body['message']?.toString() ?? 'Could not delete your account.'
            : 'The server returned an invalid response.',
      );
    }
  }

  Future<ProfileSummary> fetchProfile() async {
    final response = await _apiService.get<dynamic>(ApiEndpoints.profile);
    final body = response.data;
    if (body is! Map || body['success'] == false) {
      throw const FormatException('Could not load profile.');
    }
    return ProfileSummary.fromJson(Map<String, dynamic>.from(body));
  }

  Future<PersonalInformation> fetchPersonalInformation() async {
    final response = await _apiService.get<dynamic>(ApiEndpoints.personalInfo);
    final body = response.data;
    if (body is! Map || body['success'] == false) {
      throw const FormatException('Could not load personal information.');
    }
    return PersonalInformation.fromJson(Map<String, dynamic>.from(body));
  }

  Future<PersonalInformation> updatePersonalInformation(
    UpdatePersonalInfoRequest request,
  ) async {
    final response = await _apiService.put<dynamic>(
      ApiEndpoints.personalInfo,
      data: request.toJson(),
    );
    final body = response.data;
    if (body is! Map || body['success'] == false) {
      throw const FormatException('Could not update personal information.');
    }
    if (body['data'] is! Map) {
      return PersonalInformation(
        firstName: request.firstName,
        lastName: request.lastName,
        displayName: request.displayName,
        phone: request.phone,
        email: request.email,
        avatarUrl: '',
      );
    }
    return PersonalInformation.fromJson(Map<String, dynamic>.from(body));
  }

  Future<PersonalInformation> updateAvatar(String base64Image) async {
    final response = await _apiService.post<dynamic>(
      ApiEndpoints.avatar,
      data: {'image': base64Image},
    );
    final body = response.data;
    if (body is! Map || body['success'] == false) {
      throw const FormatException('Could not update profile photo.');
    }
    return fetchPersonalInformation();
  }

  Future<void> changePassword(ChangePasswordRequest request) async {
    final response = await _apiService.post<dynamic>(
      ApiEndpoints.changePassword,
      data: request.toJson(),
    );
    final body = response.data;
    if (body is! Map || body['success'] == false) {
      throw const FormatException('Could not change password.');
    }
  }
}
