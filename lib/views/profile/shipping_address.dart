// ignore_for_file: prefer_collection_literals

import 'dart:convert';

import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/back_ground_container.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/common/shimmers/custom_button.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/controllers/user_location_controller.dart';
import 'package:appliances_flutter/models/address_model.dart';
import 'package:appliances_flutter/views/auth/widget/email_textfield.dart';
import 'package:appliances_flutter/config/vietmap_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:geolocator/geolocator.dart';

import 'package:get/get.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import 'package:http/http.dart' as http;

class ShippingAddress extends StatefulWidget {
  const ShippingAddress({super.key, this.onAddressSet});

  final VoidCallback? onAddressSet;

  @override
  State<ShippingAddress> createState() => _ShippingAddressState();
}

class _ShippingAddressState extends State<ShippingAddress> {
  late final PageController _pageController = PageController(initialPage: 0);
  VietmapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _instructions = TextEditingController();
  // _postalCode
  LatLng? _selectedPosition;
  List<dynamic> _placeList = [];
  List<dynamic> _selectedPlace = [];

  @override
  void initState() {
    _pageController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String searchQuery) async {
    if (searchQuery.isNotEmpty) {
      // Thử sử dụng Vietmap autocomplete trước
      if (hasRealVietmapKey()) {
        try {
          final url = Uri.parse(
              'https://maps.vietmap.vn/api/autocomplete/v3?apikey=$vietmapApiKey&text=$searchQuery');

          final response = await http.get(url);

          if (response.statusCode == 200) {
            final responseBody = jsonDecode(response.body);
            setState(() {
              _placeList = responseBody ?? [];
            });
            return;
          }
        } catch (e) {
          print('Vietmap autocomplete failed: $e');
        }
      }

      // Fallback to Nominatim search
      try {
        final url = Uri.parse(
            'https://nominatim.openstreetmap.org/search?format=json&q=$searchQuery&addressdetails=1&limit=5');

        final response =
            await http.get(url, headers: {'User-Agent': 'Flutter App'});

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          setState(() {
            _placeList = responseBody ?? [];
          });
        }
      } catch (e) {
        print('Nominatim search failed: $e');
        setState(() {
          _placeList = [];
        });
      }
    } else {
      setState(() {
        _placeList = [];
      });
    }
  }

  void _getPlaceDetails(dynamic place) async {
    double? lat, lng;
    String address = '';

    // Xử lý kết quả từ Vietmap
    if (place['ref_id'] != null) {
      try {
        final url = Uri.parse(
            'https://maps.vietmap.vn/api/place/v3?apikey=$vietmapApiKey&refid=${place['ref_id']}');

        final response = await http.get(url);

        if (response.statusCode == 200) {
          final location = jsonDecode(response.body);
          lat = location['lat']?.toDouble();
          lng = location['lng']?.toDouble();
          address = place['display'] ?? '';
        }
      } catch (e) {
        print('Vietmap place details failed: $e');
      }
    }
    // Xử lý kết quả từ Nominatim
    else if (place['lat'] != null && place['lon'] != null) {
      lat = double.tryParse(place['lat'].toString());
      lng = double.tryParse(place['lon'].toString());
      address = place['display_name'] ?? '';
    }

    if (lat != null && lng != null) {
      setState(() {
        _selectedPosition = LatLng(lat!, lng!);
        _searchController.text = address;
        _placeList = [];
      });
      moveToSelectedPosition();
      _addMarker(LatLng(lat, lng)); // Thêm marker tại vị trí được chọn
    }
  }

  void moveToSelectedPosition() {
    if (_selectedPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedPosition!, 15),
      );
    }
  }

  void _addMarker(LatLng position) async {
    if (_mapController != null) {
      // Xóa marker và circle cũ nếu có
      await _mapController!.clearSymbols();
      await _mapController!.clearCircles();

      // Thêm marker mới với icon rõ ràng hơn
      await _mapController!.addSymbol(
        SymbolOptions(
          geometry: position,
          iconImage: "marker-15", // Sử dụng icon mặc định của Vietmap
          iconSize: 3.0, // Tăng kích thước để dễ nhìn hơn
          iconColor: kRed, // Màu đỏ nổi bật
          iconOpacity: 1.0, // Độ trong suốt tối đa
        ),
      );

      // Thêm circle để làm nổi bật marker
      await _mapController!.addCircle(
        CircleOptions(
          geometry: position,
          circleRadius: 8.0,
          circleColor: kRed, // Màu đỏ nổi bật
          circleOpacity: 0.3,
          circleStrokeWidth: 2.0,
          circleStrokeColor: kRed, // Màu đỏ nổi bật
          circleStrokeOpacity: 0.8,
        ),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Kiểm tra permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Lỗi', 'Quyền truy cập vị trí bị từ chối');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Lỗi', 'Quyền truy cập vị trí bị từ chối vĩnh viễn');
        return;
      }

      // Lấy vị trí hiện tại
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      LatLng currentLatLng = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _selectedPosition = currentLatLng;
      });

      // Di chuyển camera đến vị trí hiện tại
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(currentLatLng, 16.0),
      );

      // Thêm marker tại vị trí hiện tại
      _addMarker(currentLatLng);
      
      // Lấy địa chỉ từ tọa độ
      _getUserAddress(currentLatLng);
      
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể lấy vị trí hiện tại: $e');
    }
  }

  void _getUserAddress(LatLng position) async {
    // Thử sử dụng Vietmap reverse geocoding trước
    if (hasRealVietmapKey()) {
      try {
        final url = Uri.parse(
            'https://maps.vietmap.vn/api/reverse/v3?apikey=$vietmapApiKey&lng=${position.longitude}&lat=${position.latitude}');

        final response = await http.get(url);

        if (response.statusCode == 200) {
          final location = jsonDecode(response.body);
          if (location != null && location['display'] != null) {
            setState(() {
              _searchController.text = location['display'];
            });
            return;
          }
        }
      } catch (e) {
        print('Vietmap reverse geocoding failed: $e');
      }
    }

    // Fallback to Nominatim reverse geocoding
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&addressdetails=1');

      final response =
          await http.get(url, headers: {'User-Agent': 'Flutter App'});

      if (response.statusCode == 200) {
        final location = jsonDecode(response.body);
        if (location != null && location['display_name'] != null) {
          setState(() {
            _searchController.text = location['display_name'];
          });
        }
      }
    } catch (e) {
      print('Nominatim reverse geocoding failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationController = Get.put(UserLocationController());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kOffWhite,
        elevation: 0,
        title: const Text('Shipping Address'),
        leading: Obx(
          () => Padding(
            padding: EdgeInsets.only(right: 0.w),
            child: locationController.tabIndex == 0
                ? IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(
                      AntDesign.closecircleo,
                      color: kRed,
                    ),
                  )
                : IconButton(
                    onPressed: () {
                      locationController.setTabIndex = 0;
                      _pageController.previousPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn);
                    },
                    icon: const Icon(
                      AntDesign.leftcircleo,
                      color: kDark,
                    ),
                  ),
          ),
        ),
        actions: [
          Obx(() => locationController.tabIndex == 1
              ? const SizedBox.shrink()
              : Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: IconButton(
                      onPressed: () {
                        locationController.setTabIndex = 1;
                        _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeIn);
                      },
                      icon: const Icon(
                        AntDesign.rightcircleo,
                        color: kDark,
                      )),
                ))
        ],
      ),
      body: SizedBox(
        height: height,
        width: width,
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          pageSnapping: false,
          onPageChanged: (index) {
            _pageController.jumpToPage(index);
          },
          children: [
            Stack(
              children: [
                VietmapGL(
                  styleString: vietmapStyleUrl(),
                  onMapCreated: (VietmapController controller) {
                    _mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                      target: _selectedPosition ??
                          const LatLng(21.0285, 105.8542), // Hà Nội
                      zoom: 15),
                  onMapClick: (point, latlng) {
                    final locationController =
                        Get.find<UserLocationController>();
                    locationController.getUserAddress(latlng);
                    setState(() {
                      _selectedPosition = latlng;
                    });
                    _addMarker(latlng); // Thêm marker tại vị trí được click
                    _getUserAddress(latlng); // Lấy địa chỉ và hiển thị trong search bar
                  },
                  // Sử dụng onStyleLoadedCallback để thêm marker
                  onStyleLoadedCallback: () {
                    if (_selectedPosition != null) {
                      _addMarker(_selectedPosition!);
                    } else {
                      // Thêm marker mặc định tại Hà Nội
                      _addMarker(const LatLng(21.0285, 105.8542));
                    }
                  },
                ),
                // Nút vị trí hiện tại
                Positioned(
                  bottom: 100.h,
                  right: 16.w,
                  child: FloatingActionButton(
                    onPressed: _getCurrentLocation,
                    backgroundColor: kPrimary,
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.white,
                    ),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      color: kOffWhite,
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: const InputDecoration(
                          hintText: "Search for your address ...",
                        ),
                      ),
                    ),
                    _placeList.isEmpty
                        ? const SizedBox.shrink()
                        : Expanded(
                            child: ListView(
                              children:
                                  List.generate(_placeList.length, (index) {
                                final place = _placeList[index];
                                String displayText = '';

                                // Xử lý hiển thị cho Vietmap
                                if (place['display'] != null) {
                                  displayText = place['display'];
                                }
                                // Xử lý hiển thị cho Nominatim
                                else if (place['display_name'] != null) {
                                  displayText = place['display_name'];
                                }

                                return Container(
                                  color: Colors.white,
                                  child: ListTile(
                                    visualDensity: VisualDensity.compact,
                                    title: Text(displayText),
                                    onTap: () {
                                      _getPlaceDetails(place);
                                      _selectedPlace.add(place);
                                    },
                                  ),
                                );
                              }),
                            ),
                          )
                  ],
                )
              ],
            ),
            BackGroundContainer(
              color: kOffWhite,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                children: [
                  SizedBox(
                    height: 30.h,
                  ),
                  EmailTextField(
                    controller: _searchController,
                    hintText: "Address",
                    prefixIcon: const Icon(Ionicons.location_sharp),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  EmailTextField(
                    controller: _instructions,
                    hintText: "Delivery Instructions",
                    prefixIcon: const Icon(Ionicons.add_circle),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8.0.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ReusableText(
                            text: "Set address as default",
                            style: appStyle(12, kDark, FontWeight.w600)),
                        Obx(() => CupertinoSwitch(
                            thumbColor: kSecondary,
                            trackColor: kPrimary,
                            value: locationController.isDefault,
                            onChanged: (value) {
                              locationController.setIsDefault = value;
                            }))
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  CustomButton(
                      onTap: () {
                        if (_searchController.text.isNotEmpty &&
                            _instructions.text.isNotEmpty &&
                            _selectedPosition != null) {
                          AddressModel model = AddressModel(
                              addressLine1: _searchController.text,
                              addressModelDefault: locationController.isDefault,
                              deliveryInstructions: _instructions.text,
                              latitude: _selectedPosition!.latitude,
                              longitude: _selectedPosition!.longitude);

                          String data = addressModelToJson(model);

                          locationController.addAddress(data, onAddressSet: widget.onAddressSet);
                        } else {
                          Get.snackbar(
                            "Thiếu thông tin",
                            "Vui lòng điền đầy đủ thông tin và chọn vị trí trên bản đồ",
                            backgroundColor: kRed,
                            colorText: kLightWhite,
                          );
                        }
                      },
                      btnHeight: 45,
                      text: "S U B M I T")
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
