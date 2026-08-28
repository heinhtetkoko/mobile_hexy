import 'package:mobile_hexy/data/datasources/home_catalog_local_data_source.dart';
import 'package:mobile_hexy/data/models/home_catalog.dart';
import 'package:mobile_hexy/domain/repositories/home_catalog_repository.dart';

class HomeCatalogRepositoryImpl implements HomeCatalogRepository {
  const HomeCatalogRepositoryImpl(this._localDataSource);

  final HomeCatalogLocalDataSource _localDataSource;

  @override
  HomeCatalog getCatalog() => _localDataSource.getCatalog();
}
