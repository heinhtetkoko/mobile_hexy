import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/base/base_view_model.dart';

abstract class BaseView<T extends BaseViewModel> extends GetView<T> {
  const BaseView({super.key});

  Widget buildView(BuildContext context);

  @override
  Widget build(BuildContext context) => buildView(context);
}
