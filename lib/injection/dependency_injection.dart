import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/constants/app_constants.dart';
import 'package:mobile_hexy/core/navigation/app_navigator.dart';
import 'package:mobile_hexy/core/navigation/getx_app_navigator.dart';
import 'package:mobile_hexy/core/network/dio_client.dart';
import 'package:mobile_hexy/core/storage/secure_storage.dart';
import 'package:mobile_hexy/core/storage/secure_storage_impl.dart';

/// Registers dependencies shared by every feature.
///
/// Feature-specific dependencies stay in each feature's route binding so they
/// are created only when that feature is opened.
class DependencyInjection extends Bindings {
  @override
  void dependencies() {
    Get.put<AppNavigator>(GetXAppNavigator(), permanent: true);
    Get.put<SecureStorage>(
      const SecureStorageImpl(FlutterSecureStorage()),
      permanent: true,
    );
    Get.put<Dio>(
      DioClient.create(
        accessTokenProvider: () =>
            Get.find<SecureStorage>().read(AppConstants.accessTokenKey),
      ),
      permanent: true,
    );
  }
}
