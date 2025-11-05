import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/models/address_response.dart';
import 'package:appliances_flutter/views/profile/widget/address_title.dart';
import 'package:appliances_flutter/hooks/delete_address.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddressListWidget extends HookWidget {
  const AddressListWidget({super.key, required this.addresses, required this.onAddressDeleted});

  final List<AddressResponse> addresses;
  final VoidCallback onAddressDeleted;

  @override
  Widget build(BuildContext context) {
    final deleteHook = useDeleteAddress();

    Future<void> _deleteAddress(String addressId, String addressLine) async {
      // Show confirmation dialog
      final bool? shouldDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Xóa địa chỉ'),
            content: Text('Bạn có chắc chắn muốn xóa địa chỉ "$addressLine"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Xóa'),
              ),
            ],
          );
        },
      );

      if (shouldDelete == true) {
        final success = await deleteHook.deleteAddress(addressId);
        if (success) {
          onAddressDeleted();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Địa chỉ đã được xóa thành công'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Không thể xóa địa chỉ. Vui lòng thử lại.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }

    return ListView.builder(
      itemCount: addresses.length,
      itemBuilder: (context, index) {
        final address = addresses[index];
        return Dismissible(
          key: Key(address.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            await _deleteAddress(address.id, address.addressLine1);
            return false; // Don't auto-dismiss, we handle it manually
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20.w),
            decoration: const BoxDecoration(
              color: Colors.red,
              border: Border(
                bottom: BorderSide(
                  color: kGray,
                  width: 0.5,
                ),
                top: BorderSide(
                  color: kGray,
                  width: 0.5,
                ),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 24.h,
                ),
                SizedBox(height: 4.h),
                Text(
                  'Xóa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          child: Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: kGray,
                    width: 0.5,
                  ),
                  top: BorderSide(
                    color: kGray,
                    width: 0.5,
                  ),
                )),
            child: AddressTile(
              address: address, 
              onAddressUpdated: onAddressDeleted,
            ),
          ),
        );
      },
    );
  }
}
