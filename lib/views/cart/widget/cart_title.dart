import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/controllers/cart_controller.dart';
import 'package:appliances_flutter/models/cart_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:appliances_flutter/utils/currency.dart';
import 'package:get/get.dart';

class CartTile extends StatelessWidget {
  CartTile({super.key, required this.cart, this.color, this.refetch});

  final CartResponse cart;
  final Color? color;
  final Function()? refetch;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CartController());

    return GestureDetector(
      onTap: () {
        // Có thể thêm điều hướng đến trang chi tiết sản phẩm nếu cần
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: color ?? kOffWhite,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Ảnh sản phẩm + đánh giá
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Image.network(
                    (cart.productId.imageUrl.isNotEmpty
                        ? cart.productId.imageUrl[0]
                        : ''),
                    width: 75.w,
                    height: 75.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 75.w,
                        height: 75.w,
                        color: kGrayLight,
                        child: Icon(Icons.image_not_supported, size: 30.w),
                      );
                    },
                  ),
                  Container(
                    width: 75.w,
                    height: 18.h,
                    color: Colors.black.withOpacity(0.4),
                    child: Center(
                      child: RatingBarIndicator(
                        rating: 5,
                        itemCount: 5,
                        itemSize: 12.h,
                        unratedColor: Colors.white24,
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: kSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),

            /// Nội dung bên phải
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Tên sản phẩm
                  ReusableText(
                    text: cart.productId.title,
                    style: appStyle(14, kDark, FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),

                  /// Tag phụ gia / Additives
                  if (cart.additives.isNotEmpty)
                    Wrap(
                      spacing: 4.w,
                      runSpacing: 2.h,
                      children: cart.additives
                          .map((additive) => Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: kSecondaryLight,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: ReusableText(
                                  text: additive,
                                  style: appStyle(9, kGray, FontWeight.w400),
                                ),
                              ))
                          .toList(),
                    ),

                  SizedBox(height: 8.h),

                  /// Hàng nút +, - và số lượng
                  Row(
                    children: [
                      /// Giảm
                      GestureDetector(
                        onTap: () {
                          controller.decrementItem(
                            cartItemId: cart.id,
                            refetch: refetch ?? () {},
                          );
                        },
                        child: Container(
                          width: 24.w,
                          height: 24.h,
                          decoration: BoxDecoration(
                            color: kGray,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: const Icon(Icons.remove,
                              color: kLightWhite, size: 16),
                        ),
                      ),

                      SizedBox(width: 8.w),
                      ReusableText(
                        text: 'x${cart.quantity}',
                        style: appStyle(12, kDark, FontWeight.bold),
                      ),
                      SizedBox(width: 8.w),

                      /// Tăng
                      GestureDetector(
                        onTap: () {
                          final int? stock = cart.productId.stock;
                          if (stock != null && cart.quantity >= stock) {
                            Get.snackbar(
                              'Vượt quá tồn kho',
                              'Chỉ còn $stock sản phẩm có sẵn',
                              colorText: kLightWhite,
                              backgroundColor: kRed,
                              icon: const Icon(Icons.error_outline),
                            );
                            return;
                          }
                          final double unitPrice = cart.quantity > 0
                              ? (cart.totalPrice / cart.quantity)
                              : cart.totalPrice;
                          controller.incrementItem(
                            productId: cart.productId.id,
                            additives: cart.additives,
                            unitPrice: unitPrice,
                            refetch: refetch ?? () {},
                          );
                        },
                        child: Container(
                          width: 24.w,
                          height: 24.h,
                          decoration: BoxDecoration(
                            color: kPrimary,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: const Icon(Icons.add,
                              color: kLightWhite, size: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// Nút xóa + Giá tiền
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    controller.removeFrom(cart.id, refetch ?? () {});
                  },
                  child: Container(
                    width: 24.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: kRed,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: const Center(
                      child: Icon(
                        MaterialCommunityIcons.trash_can,
                        size: 14,
                        color: kLightWhite,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: ReusableText(
                    text: usdToVndText(cart.totalPrice),
                    style: appStyle(12, kLightWhite, FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
