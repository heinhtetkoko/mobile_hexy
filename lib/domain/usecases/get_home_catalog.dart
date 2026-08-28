import 'package:mobile_hexy/data/models/home_catalog.dart';
import 'package:mobile_hexy/domain/repositories/home_catalog_repository.dart';

class GetHomeCatalog {
  const GetHomeCatalog(this._repository);

  final HomeCatalogRepository _repository;

  HomeCatalog call() => _repository.getCatalog();
}
