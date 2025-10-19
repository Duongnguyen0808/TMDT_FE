import 'package:appliances_flutter/common/shimmers/foodlist_shimmer.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/hooks/appliances_by_store.dart';
import 'package:appliances_flutter/models/appliances_model.dart';
import 'package:appliances_flutter/views/home/widgets/appliances_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class StoreMenu extends HookWidget {
  const StoreMenu({super.key, required this.storeId});

  final String storeId;

  @override
  Widget build(BuildContext context) {
    final hookResults = useFetchStoreAppliances(storeId);
    final appliancess = hookResults.data;
    final isLoading = hookResults.isLoading;
    return Scaffold(
      backgroundColor: kLightWhite,
      body: isLoading
          ? const FoodsListShimmer()
          : SizedBox(
              height: height * 0.7,
              child: ListView(
                padding: EdgeInsets.zero,
                children: List.generate(appliancess!.length, (index) {
                  final AppliancesModel appliances = appliancess[index];
                  return AppliancesTitle(appliances: appliances);
                }),
              ),
            ),
    );
  }
}
