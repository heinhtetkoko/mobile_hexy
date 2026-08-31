import 'package:get/get.dart';
import 'package:mobile_hexy/core/services/app_constants.dart';
import 'package:mobile_hexy/core/services/secure_storage.dart';

class TokenExpirationHandler extends GetxService {
  TokenExpirationHandler(this._secureStorage);

  final SecureStorage _secureStorage;
  bool _handling = false;

  Future<void> handle(bool hadAccessToken) async {
    if (_handling) return;
    _handling = true;
    try {
      await _secureStorage.remove(AppConstants.accessTokenKey);
      if (Get.currentRoute != '/login') {
        await Get.offAllNamed<dynamic>('/login');
      }
      if (hadAccessToken) {
        Get.snackbar(
          'Session expired',
          'Please sign in again to continue.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      Future<void>.delayed(const Duration(seconds: 2), () => _handling = false);
    }
  }
}
