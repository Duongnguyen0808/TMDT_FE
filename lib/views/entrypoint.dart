// ignore_for_file: must_be_immutable

import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/controllers/tab_index_controller.dart';
import 'package:appliances_flutter/controllers/cart_controller.dart';
import 'package:appliances_flutter/hooks/fetch_default.dart';
import 'package:appliances_flutter/views/cart/cart_page.dart';
import 'package:appliances_flutter/views/home/home_page.dart';
import 'package:appliances_flutter/views/profile/profile_page.dart';
import 'package:appliances_flutter/views/search/search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class MainScreen extends HookWidget {
  MainScreen({super.key});

  List<Widget> pageList = const [
    HomePage(),
    SearchPage(),
    CartPage(),
    ProfilePage()
  ];

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    String? token = box.read("token");
    debugPrint(token);
    // Hooks không được gọi có điều kiện. Gọi unconditionally;
    // bên trong hook sẽ tự bỏ qua nếu chưa đăng nhập.
    useFetchDefault(context);

    final controller = Get.put(TabIndexController());
    final cartController = Get.put(CartController());
    return Obx(
      () => Scaffold(
        body: Stack(
          children: [
            pageList[controller.tabIndex],
            Align(
              alignment: Alignment.bottomCenter,
              child: Theme(
                  data: Theme.of(context).copyWith(canvasColor: kPrimary),
                  child: BottomNavigationBar(
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                    unselectedIconTheme:
                        const IconThemeData(color: Colors.black38),
                    selectedIconTheme: const IconThemeData(color: kSecondary),
                    onTap: (value) {
                      controller.setTabIndex = value;
                      // Ghi tabIndex để các trang có thể lắng nghe
                      box.write('tabIndex', value);
                    },
                    currentIndex: controller.tabIndex,
                    items: [
                      BottomNavigationBarItem(
                          icon: controller.tabIndex == 0
                              ? const Icon(AntDesign.appstore1)
                              : const Icon(AntDesign.appstore_o),
                          label: 'Home'),
                      const BottomNavigationBarItem(
                          icon: Icon(Icons.search), label: 'Search'),
                      BottomNavigationBarItem(
                          icon: Obx(() => Badge(
                              label: Text('${cartController.cartCount}'),
                              child: const Icon(FontAwesome.opencart))),
                          label: 'Cart'),
                      BottomNavigationBarItem(
                          icon: controller.tabIndex == 3
                              ? const Icon(FontAwesome.user_circle)
                              : const Icon(FontAwesome.user_circle_o),
                          label: 'Profile'),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
