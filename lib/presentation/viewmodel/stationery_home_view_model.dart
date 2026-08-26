import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/domain/entities/home_catalog.dart';
import 'package:mobile_hexy/domain/usecases/get_home_catalog.dart';

class StationeryHomeViewModel extends GetxController {
  StationeryHomeViewModel(this._getHomeCatalog);

  final GetHomeCatalog _getHomeCatalog;
  final activeBanner = 0.obs;
  final searchQuery = ''.obs;
  final bannerController = PageController(viewportFraction: .94);
  late final HomeCatalog catalog;

  @override
  void onInit() {
    super.onInit();
    catalog = _getHomeCatalog();
  }

  void updateBanner(int index) => activeBanner.value = index;
  void updateSearch(String value) => searchQuery.value = value;

  @override
  void onClose() {
    bannerController.dispose();
    super.onClose();
  }
}
