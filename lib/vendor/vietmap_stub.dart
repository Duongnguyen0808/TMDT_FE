import 'package:flutter/widgets.dart';
import 'dart:ui' show Color;

class LatLng {
  final double latitude;
  final double longitude;
  const LatLng(this.latitude, this.longitude);
}

class CameraPosition {
  final LatLng target;
  final double zoom;
  const CameraPosition({required this.target, this.zoom = 14});
}

class CameraUpdate {
  final LatLng target;
  final double zoom;
  CameraUpdate._(this.target, this.zoom);
  static CameraUpdate newLatLngZoom(LatLng target, double zoom) =>
      CameraUpdate._(target, zoom);
}

class SymbolOptions {
  final LatLng geometry;
  final String? iconImage;
  final double? iconSize;
  final Color? iconColor;
  final double? iconOpacity;
  const SymbolOptions({
    required this.geometry,
    this.iconImage,
    this.iconSize,
    this.iconColor,
    this.iconOpacity,
  });
}

class CircleOptions {
  final LatLng geometry;
  final double? circleRadius;
  final Color? circleColor;
  final double? circleOpacity;
  final double? circleStrokeWidth;
  final Color? circleStrokeColor;
  final double? circleStrokeOpacity;
  const CircleOptions({
    required this.geometry,
    this.circleRadius,
    this.circleColor,
    this.circleOpacity,
    this.circleStrokeWidth,
    this.circleStrokeColor,
    this.circleStrokeOpacity,
  });
}

class VietmapController {
  Future<void> animateCamera(CameraUpdate update) async {}
  Future<void> clearSymbols() async {}
  Future<void> clearCircles() async {}
  Future<void> addSymbol(SymbolOptions options) async {}
  Future<void> addCircle(CircleOptions options) async {}
}

typedef MapClickCallback = void Function(dynamic point, LatLng latlng);

class VietmapGL extends StatelessWidget {
  final String? styleString;
  final void Function(VietmapController)? onMapCreated;
  final CameraPosition? initialCameraPosition;
  final MapClickCallback? onMapClick;
  final VoidCallback? onStyleLoadedCallback;

  const VietmapGL({
    super.key,
    this.styleString,
    this.onMapCreated,
    this.initialCameraPosition,
    this.onMapClick,
    this.onStyleLoadedCallback,
  });

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (onMapCreated != null) {
        onMapCreated!(VietmapController());
      }
      onStyleLoadedCallback?.call();
    });
    return const SizedBox.expand();
  }
}