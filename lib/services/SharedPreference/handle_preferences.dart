class TemporaryStorage {
  Map<String, dynamic> _storage = {}; // Map để lưu trữ tạm thời

  void save(String key, dynamic value) {
    _storage[key] = value; // Lưu dữ liệu
  }

  dynamic read(String key) {
    return _storage[key]; // Đọc dữ liệu
  }

  void delete(String key) {
    _storage.remove(key); // Xóa dữ liệu
  }
}
