# SPEC — LAB 9: Két Tiết Kiệm Có Khóa Thời Gian (TimeLockVault)

## 1. Mục đích

Hệ thống cung cấp giải pháp hợp đồng thông minh két tiết kiệm có khóa thời gian (TimeLockVault) trên blockchain Ethereum, giúp người dùng gửi giữ tiền ETH có kỳ hạn và cam kết tài chính bất biến, chỉ cho phép rút tiền sau khi đã hết thời hạn khóa quy định.

## 2. Đầu vào

- `lockDurationSeconds` (`uint256`): Khoảng thời gian khóa tính bằng giây (ví dụ: `120` giây trong thử nghiệm hoặc `30 days`), do người tạo két (`owner`) thiết lập duy nhất một lần khi khởi tạo hợp đồng (`constructor`).
- `msg.value` (`uint256`): Số lượng ETH nạp vào két, do bất kỳ ai gửi kèm khi gọi hàm `deposit()`.

## 3. Quy tắc nghiệp vụ

- **R1 (Nạp tiền tự do)**: Bất kỳ địa chỉ ví nào cũng có thể nạp ETH vào két tiết kiệm thông qua hàm `deposit()`.
- **R2 (Quyền sở hữu rút tiền)**: Chỉ địa chỉ ví người khởi tạo két (`owner`) mới có thẩm quyền gọi hàm rút tiền `withdraw()`.
- **R3 (Khóa thời gian bất biến)**: Chỉ được phép rút tiền khi mốc thời gian khối hiện tại lớn hơn hoặc bằng thời điểm mở khóa (`block.timestamp >= unlockTime`). Trước mốc này, kể cả chủ sở hữu cũng không thể rút tiền.
- **R4 (Giá trị nạp hợp lệ)**: Số tiền ETH nạp vào két mỗi lần bắt buộc phải lớn hơn 0 (`msg.value > 0`).
- **R5 (Minh bạch sự kiện)**: Mọi thao tác nạp tiền (`Deposited`) và rút tiền (`Withdrawn`) bắt buộc phải phát sự kiện (event) trên chuỗi kèm tham số `indexed` để phục vụ tra cứu và kiểm toán dữ liệu on-chain.

## 4. Đầu ra

- Trạng thái số dư của két: `address(this).balance` (tính bằng wei / ETH).
- Mốc thời gian mở khóa: `unlockTime` (mốc timestamp Unix).
- Thời gian khóa còn lại: `timeLeft()` trả về số giây còn lại trước khi mở khóa (bằng 0 nếu đã đến hoặc qua hạn).
- Sự kiện ghi nhận on-chain:
  - `Deposited(address indexed from, uint256 amount)`
  - `Withdrawn(address indexed to, uint256 amount)`

## 5. Trường hợp ngoại lệ

- **E1 (Nạp 0 ETH)**: Người dùng gọi `deposit()` với `msg.value == 0` -> Hệ thống hoàn tác và kích hoạt lỗi tùy biến `ZeroAmount()`.
- **E2 (Rút tiền sai quyền)**: Tài khoản không phải chủ sở hữu gọi `withdraw()` -> Hệ thống hoàn tác và kích hoạt lỗi tùy biến `NotOwner()`.
- **E3 (Rút tiền trước hạn)**: Chủ sở hữu gọi `withdraw()` khi `block.timestamp < unlockTime` -> Hệ thống hoàn tác và kích hoạt lỗi tùy biến `StillLocked(unlockAt, currentTime)`.
- **E4 (Két rỗng)**: Gọi `withdraw()` khi số dư két bằng 0 (`address(this).balance == 0`) -> Hệ thống hoàn tác và kích hoạt lỗi tùy biến `NothingToWithdraw()`.
- **E5 (Chuyển ETH thất bại)**: Lệnh gọi cấp thấp `.call{value: ...}("")` thất bại -> Hệ thống hoàn tác và kích hoạt lỗi `TransferFailed()`.

## 6. Ngoài phạm vi

- Không hỗ trợ rút tiền từng phần (mỗi lần rút sẽ rút toàn bộ số dư có trong két).
- Không cho phép gia hạn hoặc rút ngắn thời gian khóa sau khi hợp đồng đã triển khai.
- Không hỗ trợ nạp/rút các token ERC-20 / ERC-721 (chỉ hỗ trợ ETH gốc).
