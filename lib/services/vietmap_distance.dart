import 'dart:convert';
import 'dart:math';
import 'package:appliances_flutter/models/distance_time.dart';
import 'package:appliances_flutter/config/vietmap_config.dart';
import 'package:http/http.dart' as http;

class VietMapDistance {
  // Sử dụng API key từ config
  static const String _apiKey = vietmapApiKey;

  /// Tính khoảng cách và thời gian thực tế bằng VietMap Directions API
  ///
  /// [lat1], [lon1]: Tọa độ điểm bắt đầu (store)
  /// [lat2], [lon2]: Tọa độ điểm kết thúc (user address)
  /// [pricePerKm]: Giá mỗi km
  ///
  /// Returns [DistanceTime] với distance (km), time (giờ), price (VND)
  Future<DistanceTime?> calculateRealDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
    required double pricePerKm,
  }) async {
    try {
      // VietMap Directions API endpoint
      final url = Uri.parse(
        'https://maps.vietmap.vn/api/route'
        '?apikey=$_apiKey'
        '&point=$lat1,$lon1'
        '&point=$lat2,$lon2'
        '&vehicle=motorcycle' // Có thể dùng car, motorcycle, bicycle, foot
        '&points_encoded=false',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // VietMap trả về paths array, lấy path đầu tiên
        if (data['paths'] != null && (data['paths'] as List).isNotEmpty) {
          final path = data['paths'][0];

          // distance: mét → chuyển sang km
          final distanceInMeters = (path['distance'] ?? 0).toDouble();
          final distanceKm = distanceInMeters / 1000;

          // time: milliseconds → chuyển sang giờ
          final timeInMs = (path['time'] ?? 0).toDouble();
          final timeInHours = timeInMs / (1000 * 60 * 60);

          // Tính giá
          final price = distanceKm * pricePerKm;

          return DistanceTime(
            distance: distanceKm,
            time: timeInHours,
            price: price,
          );
        }
      } else {
        print('VietMap API returned status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      // Nếu API lỗi, fallback về Haversine
      return _calculateHaversine(lat1, lon1, lat2, lon2, pricePerKm);
    } catch (e) {
      print('VietMap Distance API Error: $e');
      // Fallback về Haversine nếu có lỗi
      return _calculateHaversine(lat1, lon1, lat2, lon2, pricePerKm);
    }
  }

  /// Fallback: Tính khoảng cách đường chim bay bằng công thức Haversine
  DistanceTime _calculateHaversine(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
    double pricePerKm,
  ) {
    const double earthRadiusKm = 6371.0;

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = pow(sin(dLat / 2), 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * pow(sin(dLon / 2), 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadiusKm * c;

    // Giả sử tốc độ 30 km/h cho xe máy trong thành phố
    const double speedKmPerHr = 30.0;
    final time = distance / speedKmPerHr;
    final price = distance * pricePerKm;

    return DistanceTime(distance: distance, time: time, price: price);
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }
}
