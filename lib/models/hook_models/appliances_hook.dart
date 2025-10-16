// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:appliances_flutter/models/appliances_model.dart';

class FetchAppliancess {
  final List<AppliancesModel>? data;
  final bool isLoading;
  final Exception? error;
  final VoidCallback? refetch;

  FetchAppliancess({
    this.data,
    required this.isLoading,
    this.error,
    this.refetch,
  });
}
