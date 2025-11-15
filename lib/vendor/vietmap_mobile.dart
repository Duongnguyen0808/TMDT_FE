// ignore_for_file: uri_does_not_exist
// Vietmap mobile adapter: re-export types from the official plugin
// This file is used trên di động qua vietmap_platform.dart (conditional export).
// Nếu bạn chưa cài gói vietmap_flutter_gl trong pubspec, IDE sẽ báo
// "Target of URI doesn't exist" — có thể bỏ qua vì file này chỉ dùng trên mobile.
export 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart'
    show
        VietmapGL,
        VietmapController,
        LatLng,
        CameraPosition,
        CameraUpdate,
        SymbolOptions,
        CircleOptions;
