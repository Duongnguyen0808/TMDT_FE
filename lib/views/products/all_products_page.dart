import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/back_ground_container.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/common/shimmers/foodlist_shimmer.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/models/appliances_model.dart';
import 'package:appliances_flutter/views/home/widgets/appliances_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AllProductsPage extends HookWidget {
  final String? category;
  final String title;

  const AllProductsPage({
    super.key,
    this.category,
    required this.title,
  });

  Future<List<AppliancesModel>> fetchProducts() async {
    try {
      final url = category != null
          ? '$appBaseUrl/api/appliances/byCategory/$category/41007428'
          : '$appBaseUrl/api/appliances/all';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return appliancesModelFromJson(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = useState<List<AppliancesModel>?>(null);
    final isLoading = useState(true);

    useEffect(() {
      fetchProducts().then((data) {
        products.value = data;
        isLoading.value = false;
      });
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kPrimary,
        foregroundColor: kLightWhite,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: ReusableText(
          text: title,
          style: appStyle(18, kLightWhite, FontWeight.w600),
        ),
      ),
      body: BackGroundContainer(
        color: Colors.white,
        child: SizedBox(
          height: height,
          child: isLoading.value
              ? const FoodsListShimmer()
              : products.value == null || products.value!.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_basket_outlined,
                            size: 100.h,
                            color: kGrayLight,
                          ),
                          SizedBox(height: 16.h),
                          ReusableText(
                            text: 'Không có sản phẩm',
                            style: appStyle(16, kGray, FontWeight.w500),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.all(12.h),
                      child: ListView.builder(
                        itemCount: products.value!.length,
                        itemBuilder: (context, i) {
                          return AppliancesTitle(
                            appliances: products.value![i],
                          );
                        },
                      ),
                    ),
        ),
      ),
    );
  }
}
