import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/models/address_response.dart';
import 'package:appliances_flutter/hooks/set_default_address.dart';
import 'package:appliances_flutter/views/profile/shipping_address.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';

class AddressTile extends HookWidget {
  const AddressTile({super.key, required this.address, this.onAddressUpdated});

  final AddressResponse address;
  final VoidCallback? onAddressUpdated;

  @override
  Widget build(BuildContext context) {
    final setDefaultHook = useSetDefaultAddress();

    Future<void> _setAsDefault() async {
      if (address.addressResponseDefault == true) {
        // Already default, no need to do anything
        return;
      }

      final success = await setDefaultHook.setDefaultAddress(address.id);
      if (success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Địa chỉ đã được đặt làm mặc định'),
              backgroundColor: Colors.green,
            ),
          );
        }
        // Refresh the address list
        onAddressUpdated?.call();
      } else {
        if (context.mounted) {
          String errorMessage = setDefaultHook.apiError?.message ??
              setDefaultHook.error?.toString() ??
              'Không thể đặt địa chỉ mặc định';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    Future<void> _editAddress() async {
      final result = await Get.to(() => ShippingAddress(
            initialAddress: address,
            onAddressSet: onAddressUpdated,
            shouldPopOnSave: true,
          ));

      if (result == true && onAddressUpdated != null) {
        onAddressUpdated!();
      }
    }

    return ListTile(
      onTap: setDefaultHook.isLoading ? null : _setAsDefault,
      visualDensity: VisualDensity.compact,
      leading: Icon(
        SimpleLineIcons.location_pin,
        color: address.addressResponseDefault == true ? Colors.green : kPrimary,
        size: 28.h,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (address.addressResponseDefault == true)
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20.h,
            )
          else if (setDefaultHook.isLoading)
            SizedBox(
              width: 20.w,
              height: 20.h,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              size: 20.h,
              color: kPrimary,
            ),
            tooltip: 'Chỉnh sửa địa chỉ',
            onPressed: setDefaultHook.isLoading ? null : _editAddress,
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
      ),
      title: ReusableText(
          text: address.addressLine1,
          style: appStyle(11, kDark, FontWeight.w500)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReusableText(
              text: address.addressResponseDefault == true
                  ? "Địa chỉ mặc định"
                  : "Tap to set address as default",
              style: appStyle(
                  8,
                  address.addressResponseDefault == true ? Colors.green : kGray,
                  FontWeight.w500)),
        ],
      ),
    );
  }
}
