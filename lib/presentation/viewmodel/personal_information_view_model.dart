import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/base/base_view_model.dart';
import 'package:mobile_hexy/data/models/personal_information.dart';
import 'package:mobile_hexy/data/models/request/update_personal_info_request.dart';
import 'package:mobile_hexy/domain/usecases/get_personal_information.dart';
import 'package:mobile_hexy/domain/usecases/update_personal_information.dart';
import 'package:mobile_hexy/presentation/viewmodel/profile_view_model.dart';
import 'package:mobile_hexy/extensions/show_save_profile_dialog.dart';

class PersonalInformationViewModel extends BaseViewModel {
  PersonalInformationViewModel(this._getPersonalInfo, this._updatePersonalInfo);

  final GetPersonalInformation _getPersonalInfo;
  final UpdatePersonalInformation _updatePersonalInfo;

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final displayName = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final avatarUrl = ''.obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final loadError = RxnString();
  bool _isSaveConfirmationOpen = false;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    loadError.value = null;
    try {
      _apply(await _getPersonalInfo());
    } catch (_) {
      loadError.value = 'Could not load your personal information.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> save() async {
    if (firstName.text.trim().isEmpty || lastName.text.trim().isEmpty) {
      return _showError('First name and last name are required.');
    }
    if (!GetUtils.isEmail(email.text.trim())) {
      return _showError('Please enter a valid email address.');
    }
    if (isSaving.value || _isSaveConfirmationOpen) return;

    _isSaveConfirmationOpen = true;
    final confirmed = await showSaveProfileDialog();
    _isSaveConfirmationOpen = false;
    if (!confirmed) return;

    isSaving.value = true;
    try {
      final result = await _updatePersonalInfo(
        UpdatePersonalInfoRequest(
          firstName: firstName.text.trim(),
          lastName: lastName.text.trim(),
          displayName: displayName.text.trim(),
          phone: phone.text.trim(),
          email: email.text.trim(),
        ),
      );
      _apply(result, keepAvatarWhenEmpty: true);
      if (Get.isRegistered<ProfileViewModel>()) {
        await Get.find<ProfileViewModel>().loadProfile();
      }
      Get.snackbar(
        'Profile saved',
        'Your personal information has been updated.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      _showError(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      isSaving.value = false;
    }
  }

  void _apply(PersonalInformation value, {bool keepAvatarWhenEmpty = false}) {
    firstName.text = value.firstName;
    lastName.text = value.lastName;
    displayName.text = value.displayName;
    phone.text = value.phone;
    email.text = value.email;
    if (!keepAvatarWhenEmpty || value.avatarUrl.isNotEmpty) {
      avatarUrl.value = value.avatarUrl;
    }
  }

  void _showError(String message) => Get.snackbar(
    'Unable to save',
    message,
    snackPosition: SnackPosition.BOTTOM,
  );

  @override
  void onClose() {
    firstName.dispose();
    lastName.dispose();
    displayName.dispose();
    phone.dispose();
    email.dispose();
    super.onClose();
  }
}
