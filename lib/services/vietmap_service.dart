import 'dart:math';
import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';
import 'package:appliances_flutter/config/vietmap_config.dart';
import 'package:appliances_flutter/models/distance_time.dart';

class VietmapService {
  static bool _isInitialized = false;

  /// Khởi tạo Vietmap plugin với API key
  static void initialize() {
    if (!_isInitialized) {
      Vietmap.getInstance(vietmapApiKey);
      _isInitialized = true;
      print('✅ Vietmap initialized with API key');
    }
  }

  /// Tính khoảng cách và thời gian thực tế từ điểm A đến điểm B
  ///
  /// [storeLat], [storeLng]: Tọa độ cửa hàng
  /// [customerLat], [customerLng]: Tọa độ khách hàng
  /// [pricePerKm]: Giá mỗi km (VND)
  ///
  /// Returns: DistanceTime với distance (km), time (giờ), price (VND)
  static Future<DistanceTime?> calculateDistance({
    required double storeLat,
    required double storeLng,
    required double customerLat,
    required double customerLng,
    required double pricePerKm,
  }) async {
    try {
      // Đảm bảo đã khởi tạo
      initialize();

      print('🗺️ Calling Vietmap routing API...');
      print('From: ($storeLat, $storeLng)');
      print('To: ($customerLat, $customerLng)');

      // Gọi Vietmap routing API
      final result = await Vietmap.routing(
        VietMapRoutingParams(
          points: [
            LatLng(storeLat, storeLng),
            LatLng(customerLat, customerLng),
          ],
          optimize: true,
        ),
      );

      // Xử lý kết quả
      return result.fold(
        (failure) {
          print('❌ Vietmap routing error: $failure');
          // Fallback về Haversine nếu API lỗi
          return _calculateHaversine(
            storeLat,
            storeLng,
            customerLat,
            customerLng,
            pricePerKm,
          );
        },
        (routingModel) {
          if (routingModel.paths == null || routingModel.paths!.isEmpty) {
            print('⚠️ No paths found, using Haversine fallback');
            return _calculateHaversine(
              storeLat,
              storeLng,
              customerLat,
              customerLng,
              pricePerKm,
            );
          }

          final path = routingModel.paths!.first;

          // Distance: mét → km
          final distanceKm = (path.distance ?? 0) / 1000;

          // Time: milliseconds → giờ
          final timeMs = path.time ?? 0;
          final timeHours = timeMs / (1000 * 60 * 60);

          // Giá
          final price = distanceKm * pricePerKm;

          print('✅ Vietmap routing success:');
          print('   Distance: ${distanceKm.toStringAsFixed(2)} km');
          print('   Time: ${(timeHours * 60).toStringAsFixed(0)} phút');
          print('   Price: ${price.toStringAsFixed(0)} VND');

          return DistanceTime(
            distance: distanceKm,
            time: timeHours,
            price: price,
          );
        },
      );
    } catch (e) {
      print('❌ Vietmap error: $e');
      // Fallback về Haversine
      return _calculateHaversine(
        storeLat,
        storeLng,
        customerLat,
        customerLng,
        pricePerKm,
      );
    }
  }

  /// Fallback: Tính khoảng cách đường chim bay bằng công thức Haversine
  static DistanceTime _calculateHaversine(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
    double pricePerKm,
  ) {
    print('⚠️ Using Haversine fallback...');

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

    print('   Haversine distance: ${distance.toStringAsFixed(2)} km');
    print('   Estimated time: ${(time * 60).toStringAsFixed(0)} phút');

    return DistanceTime(
      distance: distance,
      time: time,
      price: price,
    );
  }

  static double _toRadians(double degrees) {
    return degrees * (pi / 180.0);
  }
}
