import 'dart:ui';

import 'package:appliances_flutter/models/store_model.dart';

class FetchStore {
  final StoreModel? data;
  final bool isLoading;
  final Exception? error;
  final VoidCallback? refetch;

  FetchStore({
    required this.data,
    required this.isLoading,
    required this.error,
    required this.refetch,
  });
}
