# Nhật ký AI (AI Journal) - Lab 11

## Mục tiêu
Thiết kế và cài đặt hợp đồng thông minh `ProjectCore.sol` tích hợp các quy tắc kinh tế (thu phí giao dịch và giới hạn trần nắm giữ token) sử dụng Solidity và thư viện OpenZeppelin v5.

## Quá trình trao đổi & Giải pháp
1. **Kế thừa chuẩn ERC20 & Ownable:** 
   - Sử dụng phiên bản Solidity `^0.8.20`.
   - Kết nối thư viện `@openzeppelin/contracts/token/ERC20/ERC20.sol` và `@openzeppelin/contracts/access/Ownable.sol`.
2. **Cài đặt logic thu phí & kiểm tra giới hạn:**
   - Ghi đè hàm chuẩn `_update` của OpenZeppelin v5 để can thiệp vào quá trình chuyển token.
   - Thêm cơ chế tính phí (`feeBps = 100` tương đương 1%) chuyển thẳng vào `classFund`.
   - Thêm điều kiện kiểm tra `maxHolding` (2% tổng cung) và định nghĩa lỗi tùy chỉnh `ExceedsMaxHolding` để tối ưu hóa chi phí gas và đảm bảo minh bạch.
3. **Kiểm thử sơ bộ:**
   - Biên dịch thành công trên Remix IDE không báo lỗi cú pháp.
