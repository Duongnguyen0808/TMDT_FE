import 'package:appliances_flutter/models/store_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key, required this.store});

  final StoreModel? store;

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(),
    );
  }
}
