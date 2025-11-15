import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'vi': {
          // Profile Menu
          'my_orders': 'Đơn hàng của tôi',
          'favorites': 'Sản phẩm yêu thích',
          'my_reviews': 'Đánh giá của tôi',
          'vouchers': 'Phiếu giảm giá',
          'shipping_address': 'Địa chỉ giao hàng',
          'service_center': 'Trung tâm dịch vụ',
          'customer_support': 'Hỗ trợ khách hàng',
          'settings': 'Cài đặt',
          'logout': 'Đăng xuất',

          // Settings
          'general': 'Chung',
          'language': 'Ngôn ngữ',
          'app_info': 'Thông tin ứng dụng',
          'version': 'Phiên bản',
          'language_change_info':
              'Thay đổi ngôn ngữ sẽ áp dụng cho toàn bộ ứng dụng',

          // Home
          'hello': 'Giao lời',
          'deliver_to': 'Giao tới',
          'enable_location': 'Vui lòng bật dịch vụ vị trí để lấy địa chỉ',
          'search_hint': 'Tìm kiếm sản phẩm...',
          'search_products': 'Tìm kiếm sản phẩm',
          'categories': 'Danh mục',
          'hot_deals': 'Ưu đãi hot',
          'recommended': 'Gợi ý hôm nay',
          'for_you': 'Dành cho bạn',
          'featured_stores': 'Cửa hàng nổi bật',
          'explore': 'Khám phá',
          'enter_keyword': 'Nhập từ khóa để tìm sản phẩm',

          // Common
          'loading': 'Đang tải...',
          'error': 'Đã có lỗi xảy ra',
          'retry': 'Thử lại',
          'success': 'Thành công',
          'vietnamese': 'Tiếng Việt',
          'english': 'English',
          'select_language': 'Chọn ngôn ngữ',
          'language_changed': 'Đã chuyển sang',

          // Cart
          'cart': 'Giỏ hàng',
          'add_to_cart': 'Thêm vào giỏ',
          'checkout': 'Thanh toán',
          'total': 'Tổng cộng',
          'no_shipping_address': 'Chưa có địa chỉ giao hàng',
          'missing_store_info': 'Thiếu thông tin cửa hàng',
          'missing_store_msg':
              'Một số sản phẩm thiếu thông tin cửa hàng. Hãy làm mới giỏ hàng và thử lại.',
          'order_from_stores': 'Đặt hàng từ',
          'stores': 'cửa hàng',
          'split_order_msg': 'Đơn hàng sẽ được tách thành',
          'separate_orders': 'đơn riêng biệt',

          // Order & Checkout
          'place_order': 'Đặt hàng',
          'order_success': 'Đặt hàng thành công',
          'order_failed': 'Đặt hàng thất bại',
          'complete_order': 'Hoàn tất đặt hàng',
          'products_from_stores': 'sản phẩm từ',
          'products': 'sản phẩm',
          'order_will_be_split': 'Đơn hàng sẽ được tách thành',
          'ordered_products': 'Sản phẩm đặt hàng',
          'delivery_address': 'Địa chỉ giao hàng',
          'voucher_discount': 'Voucher giảm giá',
          'payment_method': 'Phương thức thanh toán',
          'continue_payment': 'Tiếp tục thanh toán',
          'cod_payment': 'Thanh toán khi nhận hàng (COD)',
          'vnpay_payment': 'Thanh toán VNPay',
          'subtotal': 'Tạm tính',
          'delivery_fee': 'Phí vận chuyển',
          'discount': 'Giảm giá',
          'quantity': 'SL',
          'order_total_amount': 'Tổng đơn hàng',
          'grand_total': 'Tổng cộng',
          'select_voucher': 'Chọn hoặc nhập mã voucher',

          // Advanced Search
          'advanced_search': 'Tìm kiếm nâng cao',
          'category': 'Danh mục',
          'price_range': 'Khoảng giá',
          'min_rating': 'Đánh giá tối thiểu',
          'sort_by': 'Sắp xếp theo',
          'default': 'Mặc định',
          'price_asc': 'Giá tăng dần',
          'price_desc': 'Giá giảm dần',
          'rating_high': 'Đánh giá cao',
          'popular': 'Phổ biến',
          'reset': 'Đặt lại',
          'apply_filter': 'Áp dụng bộ lọc',
          'all': 'Tất cả',
        },
        'en': {
          // Profile Menu
          'my_orders': 'My Orders',
          'favorites': 'Favorites',
          'my_reviews': 'My Reviews',
          'vouchers': 'Vouchers',
          'shipping_address': 'Shipping Address',
          'service_center': 'Service Center',
          'customer_support': 'Customer Support',
          'settings': 'Settings',
          'logout': 'Logout',

          // Settings
          'general': 'General',
          'language': 'Language',
          'app_info': 'App Information',
          'version': 'Version',
          'language_change_info':
              'Language changes will apply to the entire app',

          // Home
          'hello': 'Hello',
          'deliver_to': 'Deliver To',
          'enable_location': 'Please Enable Location Service to Get Address',
          'search_hint': 'Search Products...',
          'search_products': 'Search Products',
          'categories': 'Categories',
          'hot_deals': 'Hot Deals',
          'recommended': 'Recommended Today',
          'for_you': 'For You',
          'featured_stores': 'Featured Stores',
          'explore': 'Explore',
          'enter_keyword': 'Enter Keywords to Search Products',

          // Common
          'loading': 'Loading...',
          'error': 'An Error Occurred',
          'retry': 'Retry',
          'success': 'Success',
          'vietnamese': 'Tiếng Việt',
          'english': 'English',
          'select_language': 'Select Language',
          'language_changed': 'Changed to',

          // Cart
          'cart': 'Cart',
          'add_to_cart': 'Add to Cart',
          'checkout': 'Checkout',
          'total': 'Total',
          'no_shipping_address': 'No Shipping Address',
          'missing_store_info': 'Missing Store Information',
          'missing_store_msg':
              'Some products are missing store information. Please refresh your cart and try again.',
          'order_from_stores': 'Order from',
          'stores': 'stores',
          'split_order_msg': 'Order will be split into',
          'separate_orders': 'separate orders',

          // Order & Checkout
          'place_order': 'Place Order',
          'order_success': 'Order Placed Successfully',
          'order_failed': 'Order Failed',
          'complete_order': 'Complete Order',
          'products_from_stores': 'products from',
          'products': 'products',
          'order_will_be_split': 'Order will be split into',
          'ordered_products': 'Ordered Products',
          'delivery_address': 'Delivery Address',
          'voucher_discount': 'Voucher Discount',
          'payment_method': 'Payment Method',
          'continue_payment': 'Continue Payment',
          'cod_payment': 'Cash on Delivery (COD)',
          'vnpay_payment': 'VNPay Payment',
          'subtotal': 'Subtotal',
          'delivery_fee': 'Delivery Fee',
          'discount': 'Discount',
          'quantity': 'Qty',
          'order_total_amount': 'Order Total',
          'grand_total': 'Grand Total',
          'select_voucher': 'Select or Enter Voucher Code',

          // Advanced Search
          'advanced_search': 'Advanced Search',
          'category': 'Category',
          'price_range': 'Price Range',
          'min_rating': 'Minimum Rating',
          'sort_by': 'Sort By',
          'default': 'Default',
          'price_asc': 'Price: Low to High',
          'price_desc': 'Price: High to Low',
          'rating_high': 'Highest Rated',
          'popular': 'Popular',
          'reset': 'Reset',
          'apply_filter': 'Apply Filter',
          'all': 'All',
        },
      };
}
