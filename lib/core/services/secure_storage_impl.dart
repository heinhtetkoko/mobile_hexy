import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_hexy/core/services/secure_storage.dart';

class SecureStorageImpl implements SecureStorage {
  const SecureStorageImpl(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> remove(String key) => _storage.delete(key: key);
}
