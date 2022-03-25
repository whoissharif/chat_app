import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageHandler {
  final storage = new FlutterSecureStorage();

  Future<String> getStorageKey(String key) async {
    String? val;
    try {
      val = (await storage.read(key: key))!;
    } catch (Exception) {
      print(Exception);
    }

    return val!;
  }

  Future<void> deleteKey(String key) async {
    await storage.delete(key: key);
  }

  Future<void> setStorageKey(String key, String value) async {
    try {
      await storage.write(key: key, value: value);
    } catch (Exception) {
      print(Exception);
    }
  }
}
