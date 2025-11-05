import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';

/// Decode a polyline string (precision=5 by default) to a list of LatLng.
/// Manual decoder để tránh phụ thuộc class có thể không tồn tại.
List<LatLng> decodePolyline(String encoded, {int precision = 5}) {
  final List<LatLng> points = [];
  int index = 0;
  int lat = 0;
  int lng = 0;

  while (index < encoded.length) {
    int b;
    int shift = 0;
    int result = 0;

    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);

    final int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
    lat += dlat;

    shift = 0;
    result = 0;

    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);

    final int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
    lng += dlng;

    final scale = precision == 6 ? 1e6 : 1e5;
    points.add(LatLng(lat / scale, lng / scale));
  }

  return points;
}