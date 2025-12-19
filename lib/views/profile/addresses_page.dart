import 'dart:math' as math;

import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/back_ground_container.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/common/shimmers/custom_button.dart';
import 'package:appliances_flutter/common/shimmers/foodlist_shimmer.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/hooks/fetch_address.dart';
import 'package:appliances_flutter/models/address_response.dart';
import 'package:appliances_flutter/views/profile/shipping_address.dart';
import 'package:appliances_flutter/views/profile/widget/address_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

class Addresses extends HookWidget {
  const Addresses({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double buttonBottomOffset =
        math.max(mediaQuery.viewPadding.bottom, 24.h) + 10.h;
    final hookResult = useFetchAddresses();

    final List<AddressResponse> addresses = hookResult.data ?? [];
    final isLoading = hookResult.isLoading;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kPrimary,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: kLightWhite,
          ),
        ),
        title: ReusableText(
          text: 'shipping_address'.tr,
          style: appStyle(18, kLightWhite, FontWeight.w600),
        ),
      ),
      body: BackGroundContainer(
        color: kOffWhite,
        child: Stack(
          children: [
            isLoading
                ? const FoodsListShimmer()
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30.0),
                    child: AddressListWidget(
                      addresses: addresses,
                      onAddressDeleted: () {
                        hookResult.refetch!();
                      },
                    ),
                  ),
            Align(
              alignment: AlignmentDirectional.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, buttonBottomOffset),
                child: CustomButton(
                  onTap: () async {
                    final result = await Get.to(() => ShippingAddress(
                          onAddressSet: hookResult.refetch,
                          shouldPopOnSave: true,
                        ));
                    if (result == true && hookResult.refetch != null) {
                      hookResult.refetch!();
                    }
                  },
                  text: 'add_address_button'.tr,
                  btnHeight: 56.h,
                  btnWidth: double.infinity,
                  radius: 14.r,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
