// Cấu hình Vietmap. Điền API key thật nếu có.
// Nếu thiếu key, tự động dùng style MapLibre demo để hiển thị bản đồ.

const String vietmapApiKey =
    "2b80a3786959d7a6f08f3d3a9ec4f35d471f93ea4fe39f40"; // Key thật từ user

bool hasRealVietmapKey([String? apiKey]) {
  final key = (apiKey ?? vietmapApiKey).trim();
  print('DEBUG hasRealVietmapKey: key="$key", length=${key.length}, isEmpty=${key.isEmpty}');
  final result = key.isNotEmpty && key.length > 20;
  print('DEBUG hasRealVietmapKey result: $result');
  return result; // Kiểm tra độ dài key hợp lệ
}

/// Trả về style URL: Vietmap với key hợp lệ, hoặc MapLibre demo khi thiếu key.
String vietmapStyleUrl([String? apiKey]) {
  final key = (apiKey ?? vietmapApiKey).trim();
  print('DEBUG vietmapStyleUrl: checking key="$key"');
  
  // Thử sử dụng Vietmap style trước, nếu không hoạt động sẽ fallback
  if (key.isNotEmpty && key.length > 20) {
    final url = "https://maps.vietmap.vn/maps/styles/tm/style.json?apikey=$key";
    print('DEBUG vietmapStyleUrl: Using Vietmap style: $url');
    return url;
  }
  
  // Fallback: style demo công khai của MapLibre (không cần API key)
  final fallbackUrl = "https://demotiles.maplibre.org/style.json";
  print('DEBUG vietmapStyleUrl: Using fallback style: $fallbackUrl');
  return fallbackUrl;
}
