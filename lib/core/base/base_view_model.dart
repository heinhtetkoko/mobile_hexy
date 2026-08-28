import 'package:get/get.dart';
import 'package:mobile_hexy/core/base/request_state.dart';

abstract class BaseViewModel extends GetxController {
  final requestState = RequestState.initial.obs;
  final errorMessage = RxnString();

  bool get isBusy => requestState.value == RequestState.loading;

  void setLoading() {
    errorMessage.value = null;
    requestState.value = RequestState.loading;
  }

  void setSuccess() => requestState.value = RequestState.success;

  void setError(Object error) {
    errorMessage.value = error.toString().replaceFirst('Exception: ', '');
    requestState.value = RequestState.error;
  }
}
