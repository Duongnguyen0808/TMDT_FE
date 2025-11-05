# Test Tính Năng Lưu Vị Trí Hiện Tại

## Các bước test:

1. **Mở ứng dụng và đăng nhập**
   - Đảm bảo đã đăng nhập với tài khoản hợp lệ

2. **Vào trang Địa chỉ giao hàng**
   - Từ menu chính, chọn "Địa chỉ giao hàng"

3. **Test nút "Lưu vị trí hiện tại"**
   - Nhấn vào nút "Lưu vị trí hiện tại" (icon my_location)
   - Kiểm tra xem có xuất hiện dialog yêu cầu permission location không
   - Cấp quyền truy cập vị trí nếu được yêu cầu

4. **Test dialog đặt tên địa chỉ**
   - Sau khi cấp quyền, dialog "Lưu vị trí hiện tại" sẽ xuất hiện
   - Có thể nhập tên tùy chỉnh hoặc để trống (sẽ dùng tên mặc định)
   - Nhấn "Lưu" để lưu địa chỉ

5. **Kiểm tra kết quả**
   - Xem có thông báo thành công không
   - Kiểm tra danh sách địa chỉ có được refresh và hiển thị địa chỉ mới không
   - Thử sử dụng địa chỉ vừa lưu để đặt hàng

## Các trường hợp cần test:

- ✅ User chưa đăng nhập
- ✅ User từ chối cấp quyền location
- ✅ User cấp quyền location
- ✅ Lưu với tên tùy chỉnh
- ✅ Lưu với tên mặc định (để trống)
- ✅ Kiểm tra API call có thành công không
- ✅ Kiểm tra danh sách địa chỉ có được refresh không

## Kết quả mong đợi:

- Dialog xuất hiện đúng cách
- Permission được yêu cầu và xử lý đúng
- API call thành công
- Địa chỉ mới xuất hiện trong danh sách
- UX mượt mà, không có lỗi crash