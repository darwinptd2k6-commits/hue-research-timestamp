# SPEC — LAB 13: THỰC NGHIỆM MỘT VỤ MẤT TIỀN VÀ CÁCH KHẮC PHỤC (REENTRANCY EXPLOIT & HARDENING)

## Dự án: Hue Research Timestamp (HRT)
**Học phần:** Tiền điện tử & Hợp đồng thông minh (ECO2432) — Trường Đại học Kinh tế, Đại học Huế  
**Nhóm sinh viên thực hiện:**
- Phan Thành Đạt (MSSV: 24K430002) — Project Lead & Smart Contract Engineer
- Nguyễn Hữu Bằng (MSSV: 24K4070016) — Web3 Frontend Dev & Tokenomics Lead  

---

## 1. Mục đích
Thực nghiệm và tái hiện chi tiết vụ tấn công rút cạn ngân quỹ bằng lỗi tái nhập (Reentrancy Attack) trên hợp đồng mẫu `VulnerableBank.sol`, triển khai hai phương án khắc phục chuẩn mực (Checks-Effects-Interactions và OpenZeppelin `ReentrancyGuard`), đồng thời rà soát toàn diện các điểm chuyển tiền và tăng cường an toàn (hardening) kèm các ca kiểm thử thất bại (negative tests) cho hợp đồng chính `ProjectCore.sol`.

---

## 2. Đầu vào
- **Hiện trường tấn công Reentrancy (`VulnerableBank.sol`)**:
  - 3 tài khoản người dùng lương thiện (`USER_A`, `USER_B`, `USER_C`), mỗi người nạp `2.0 ETH` thông qua hàm `deposit()`. Tổng ngân quỹ ban đầu của ngân hàng: `6.0 ETH`.
  - Hợp đồng tấn công `Attacker.sol` mang vốn ban đầu `1.0 ETH` gọi hàm `attack()`.
- **Hardening & Negative Tests trên `ProjectCore.sol`**:
  - Địa chỉ ví gọi rút quỹ `msg.sender` (kiểm tra quyền `onlyOwner`).
  - Địa chỉ ví nhận tiền `recipient` (kiểu `address payable`, do Quản trị viên chỉ định).
  - Số dư ETH hiện có trong hợp đồng `address(this).balance`.
  - Hợp đồng độc hại đóng vai trò người nhận cố tình gọi lại hàm rút quỹ `withdrawFees` trong hàm `receive()` / `fallback()`.

---

## 3. Quy tắc nghiệp vụ

- **R1 (Cơ chế tái nhập có lỗi trên VulnerableBank)**: Khi `VulnerableBank` chuyển ETH bằng lệnh cấp thấp `msg.sender.call{value: balance}("")` trước khi cập nhật số dư `balances[msg.sender] = 0;`, quyền thực thi bị trao cho hợp đồng người nhận (`receive()`), cho phép người nhận gọi lại `withdraw()` liên tục khi số dư trên sổ sách chưa bị trừ.
- **R2 (Quy tắc khắc phục Cách 1 - Checks-Effects-Interactions)**: Trong `SafeBankCEI`, số dư người rút phải được gán về `0` (`balances[msg.sender] = 0;`) ngay tại bước Effects TRƯỚC KHI thực hiện lệnh chuyển ETH ra ngoài ở bước Interactions. Lần gọi lại đệ quy trong `receive()` lập tức bị từ chối vì số dư trên sổ sách đã bằng `0`.
- **R3 (Quy tắc khắc phục Cách 2 - OpenZeppelin ReentrancyGuard)**: Trong `SafeBankGuard`, hàm `withdraw()` được bảo vệ bởi modifier `nonReentrant`. Bất kỳ lệnh gọi lại nào trong cùng một chu kỳ transaction khi trạng thái khóa `_status == ENTERED` đều bị revert ngay lập tức với lỗi `ReentrancyGuardReentrantCall()`.
- **R4 (Phòng vệ chuyên sâu cho ProjectCore.withdrawFees)**: Hàm rút doanh thu phí nghiên cứu khoa học `withdrawFees(address payable recipient)` trong `ProjectCore.sol` phải áp dụng cùng lúc hai lớp bảo vệ:
  - Lớp 1 (CEI): Kiểm tra số dư và phát sự kiện `FundsWithdrawn` trước khi chuyển tiền ra ngoài.
  - Lớp 2 (Mutex Lock): Áp dụng modifier `nonReentrant` từ `ReentrancyGuard` của OpenZeppelin v5.
- **R5 (Phân quyền rút quỹ nghiêm ngặt)**: Chỉ có tài khoản Quản trị viên nhà trường (`onlyOwner`) mới được phép gọi hàm `withdrawFees`. Bất kỳ địa chỉ ví nào khác gọi hàm đều phải bị revert với Custom Error `OwnableUnauthorizedAccount(msg.sender)`.
- **R6 (Kiểm tra giá trị biên địa chỉ và số dư)**: Địa chỉ nhận tiền `recipient` không được là địa chỉ rỗng (`address(0)`), và số dư hợp đồng phải lớn hơn 0; nếu vi phạm phải revert lần lượt bằng `InvalidRecipient()` và `ZeroBalance()`.

---

## 4. Đầu ra
- Bảng đối chiếu trạng thái số dư và bằng chứng rút cạn 100% ngân quỹ trên `VulnerableBank` (từ `6.0 ETH` về `0.0 ETH`, kẻ tấn công cướp `7.0 ETH`).
- Hai bản hợp đồng đã vá `SafeBankCEI.sol` và `SafeBankGuard.sol` trong `contracts/training/SafeBank.sol` cùng minh chứng giao dịch tấn công thất bại.
- Ba câu khẳng định ngắn gọn giải thích bản chất vì sao thứ tự dòng lệnh chặn được tấn công (phục vụ vấn đáp giảng viên).
- Bộ kiểm thử tự động toàn diện `test/Lab13_ReentrancyHardening.test.js` đạt kết quả `10/10 PASS (100%)`.
- Mã nguồn hợp đồng chính `ProjectCore.sol` được gia cố với `ReentrancyGuard` và `nonReentrant`.

---

## 5. Trường hợp ngoại lệ (Negative Cases & Edge Cases)
- **TH1 (Kẻ xấu cố tình đệ quy tái nhập vào SafeBankCEI)**: Nếu hợp đồng độc hại gọi lại `withdraw()` trong hàm `receive()`, hệ thống phải từ chối ngay lập tức với lỗi `"Khong co so du"` vì biến trạng thái `balances[msg.sender]` đã được cập nhật về 0 từ trước đó.
- **TH2 (Kẻ xấu cố tình tái nhập vào SafeBankGuard hoặc ProjectCore)**: Nếu hàm `receive()` của kẻ tấn công gọi lại `withdraw()` hoặc `withdrawFees()`, hệ thống phải revert toàn bộ transaction với ngoại lệ `ReentrancyGuardReentrantCall()`.
- **TH3 (Kẻ lạ cố tình chiếm đoạt quỹ nghiên cứu)**: Nếu ví người dùng không phải Quản trị viên (`msg.sender != owner()`) gọi hàm `withdrawFees`, hệ thống phải từ chối và revert với `OwnableUnauthorizedAccount(msg.sender)`.
- **TH4 (Quản trị viên vô ý chuyển tiền vào địa chỉ 0x0)**: Nếu Quản trị viên truyền vào `recipient = address(0)`, hệ thống phải revert với `InvalidRecipient()` để ngăn ngừa mất mát tài sản vĩnh viễn vào hố đen (burn address).
- **TH5 (Rút tiền khi kho bạc trống rỗng)**: Nếu `address(this).balance == 0`, hệ thống phải revert với `ZeroBalance()`, không thực hiện lệnh gọi cấp thấp tốn gas vô ích.
- **TH6 (Sinh viên nạp thiếu phí đăng ký tài liệu)**: Nếu người đăng ký gửi `msg.value < registrationFee`, hệ thống phải revert với `InsufficientFee(requiredFee, sentFee)`.

---

## 6. Ngoài phạm vi
- Không triển khai các cơ chế chia tách quỹ phức tạp qua DAO Multi-sig trên mạng Sepolia ở giai đoạn này (đã được cắt giảm tại Gate Review 1).
- Không can thiệp vào các hàm tra cứu dữ liệu `view` vốn không làm thay đổi trạng thái và không tiềm ẩn rủi ro Reentrancy.
- Không sử dụng các giải pháp lạc hậu như giới hạn gas 2.300 qua `.transfer()` hoặc `.send()` vì có thể làm hỏng giao dịch khi ví nhận tiền là Smart Contract / Multi-sig Wallet (Safe).
