import 'dart:math';

import 'package:appliances_flutter/models/distance_time.dart';
import 'package:appliances_flutter/services/delivery_fee.dart';

class Distance {
  DistanceTime calculateDistanceTimePrice({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
    double speedKmPerHr = 30,
    double? perKmOverride,
  }) {
    final rLat1 = _toRadians(lat1);
    final rLon1 = _toRadians(lon1);
    final rLat2 = _toRadians(lat2);
    final rLon2 = _toRadians(lon2);

    final dLat = rLat2 - rLat1;
    final dLon = rLon2 - rLon1;
    final a =
        pow(sin(dLat / 2), 2) + cos(rLat1) * cos(rLat2) * pow(sin(dLon / 2), 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    const double earthRadiusKm = 6371.0;
    final double distance = earthRadiusKm * c;
    final double timeHours = speedKmPerHr > 0 ? distance / speedKmPerHr : 0;
    final double price = calculateDeliveryFee(
      distance,
      perKmOverride: perKmOverride,
    );

    return DistanceTime(distance: distance, time: timeHours, price: price);
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }
}
