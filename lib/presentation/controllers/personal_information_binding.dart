import 'package:get/get.dart';
import 'package:mobile_hexy/domain/usecases/get_personal_information.dart';
import 'package:mobile_hexy/domain/usecases/update_avatar.dart';
import 'package:mobile_hexy/domain/usecases/update_personal_information.dart';
import 'package:mobile_hexy/presentation/viewmodel/personal_information_view_model.dart';

class PersonalInformationBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(
    () => PersonalInformationViewModel(
      Get.find<GetPersonalInformation>(),
      Get.find<UpdatePersonalInformation>(),
      Get.find<UpdateAvatar>(),
    ),
  );
}
