# SPEC — LAB 11: CÀI ĐẶT QUY TẮC KINH TẾ VÀO SẢN PHẨM (PROJECTCORE.SOL)

## Dự án: Hue Research Timestamp (HRT)
**Học phần:** Tiền điện tử & Hợp đồng thông minh (ECO2432)  
**Đơn vị:** Trường Đại học Kinh tế — Đại học Huế (HUE)  
**Phiên bản:** v1.1.0 (Lab 11 Milestone)  

---

## 1. Mục đích

Chuyển hóa quy tắc kinh tế vi mô đã đặc tả tại `docs/ECONOMIC_RULES.md` thành mã nguồn tự động thực thi trong Smart Contract chính của dự án `contracts/project/ProjectCore.sol`. Đảm bảo hệ thống có cơ chế tạo doanh thu bền vững, phòng chống spam lưu trữ trạng thái (state bloat), đồng thời thiết lập cơ chế quản trị và rút quỹ an toàn theo nguyên tắc Checks-Effects-Interactions (CEI).

---

## 2. Đầu vào nghiệp vụ

1. **`documentHash`** (`bytes32`):
   - Mã băm 256-bit (SHA-256) của tệp tài liệu nghiên cứu khoa học được băm tại máy khách (Client-side Hashing qua Web Crypto API).
2. **`title`** (`string`):
   - Tiêu đề đề tài nghiên cứu hoặc bài báo khoa học.
3. **`authors`** (`string`):
   - Danh sách tác giả, mã số sinh viên, đơn vị bộ môn / khoa viện thuộc Đại học Huế.
4. **`metadataURI`** (`string`):
   - Đường dẫn liên kết đến tóm tắt công trình hoặc mã IPFS/Arweave lưu trữ phân tán.
5. **`msg.value`** (`uint256`):
   - Số lượng tiền tệ ETH gửi kèm giao dịch gọi hàm `registerDocument`. Bắt buộc phải $\ge \text{registrationFee}$.
6. **`newFee`** (`uint256`):
   - Mức phí dịch vụ điều chỉnh bởi Quản trị viên (chỉ áp dụng khi gọi `setRegistrationFee`).
7. **`recipient`** (`address payable`):
   - Địa chỉ ví nhận tiền khi Quản trị viên thực hiện rút quỹ `withdrawFees`.

---

## 3. Quy tắc kinh tế và kỹ thuật (Business & Technical Rules)

- **R1 (Quy tắc phí đăng ký bắt buộc — Lab 11 Core Rule)**:
  - Mức phí đăng ký mặc định là `0.001 ETH` (`10^15 wei`).
  - Khi tác giả gửi giao dịch đăng ký đóng dấu thời gian qua `registerDocument`, hợp đồng kiểm tra điều kiện:
    $$\text{msg.value} \ge \text{registrationFee}$$
  - Nếu $\text{msg.value} < \text{registrationFee}$, giao dịch bắt buộc bị hủy bỏ (revert) ngay lập tức với Custom Error `InsufficientFee(registrationFee, msg.value)`.
- **R2 (Mục tiêu kinh tế của mức phí)**:
  - **Chống spam**: Ngăn bot hoặc kẻ phá hoại gửi hàng triệu bản ghi rác làm nghẽn dung lượng lưu trữ trên blockchain.
  - **Tự chủ tài chính**: Doanh thu dùng để duy trì hạ tầng IPFS Pinning và Dedicated RPC Endpoint cho sinh viên.
  - **Hỗ trợ học thuật**: Tích lũy quỹ để trao giải thưởng nghiên cứu khoa học xuất sắc cho sinh viên Đại học Huế.
- **R3 (Tính bất biến của bản ghi thời gian)**:
  - Dấu thời gian lấy trực tiếp từ `block.timestamp` và số hiệu khối `block.number`.
  - Nghiêm cấm mọi hành vi sửa đổi `documentHash`, `timestamp` hoặc `owner` sau khi đã đăng ký thành công.
- **R4 (Ghi nhận sự kiện tài chính & định danh)**:
  - Mọi giao dịch nạp phí thành công bắt buộc phát sự kiện `FeeCollected(address indexed payer, uint256 amount)`.
  - Phát sự kiện đóng dấu `DocumentTimestamped(bytes32 indexed documentHash, address indexed owner, uint256 timestamp, uint256 blockNumber, string title)`.
- **R5 (Quản trị mức phí — Treasury Governance)**:
  - Chỉ Quản trị viên hợp đồng (`onlyOwner` theo OpenZeppelin 5.x) mới có quyền gọi hàm `setRegistrationFee(uint256 newFee)`.
  - Mọi thay đổi về phí đều được ghi nhận qua sự kiện `FeeUpdated(uint256 oldFee, uint256 newFee)`.
- **R6 (Rút quỹ an toàn theo mô hình Checks-Effects-Interactions & Chống Reentrancy)**:
  - Hàm `withdrawFees(address payable recipient)` được bảo vệ bởi modifier `onlyOwner`.
  - **Check**: Kiểm tra `recipient != address(0)` và số dư hợp đồng `address(this).balance > 0`.
  - **Effect**: Phát sự kiện `FundsWithdrawn(recipient, amount)` trước khi chuyển tiền ra ngoài.
  - **Interaction**: Chuyển ETH bằng lệnh cấp thấp `(bool success, ) = recipient.call{value: amount}("")` kết hợp kiểm tra `if (!success) revert WithdrawFailed();`. Tuyệt đối không dùng `.transfer()` tránh lỗi giới hạn 2300 gas.

---

## 4. Đầu ra mong đợi

1. **Ca kiểm thử hợp lệ (Chuẩn đầu ra 1)**:
   - Giao dịch gửi đủ `0.001 ETH` được xác nhận trên khối.
   - Số dư hợp đồng tăng thêm `0.001 ETH`.
   - Các sự kiện `DocumentTimestamped` và `FeeCollected` được phát ra đầy đủ dữ liệu chỉ mục.
2. **Ca cố tình vi phạm (Chuẩn đầu ra 2)**:
   - Giao dịch nạp thiếu phí (ví dụ `0.0005 ETH` hoặc `0 ETH`) bị từ chối với Custom Error `InsufficientFee(1000000000000000, 500000000000000)`.
   - Trạng thái hợp đồng và số dư tài khoản người dùng được giữ nguyên vẹn (Atomic Revert).
3. **Tra cứu miễn phí (Free Gas)**:
   - Hàm `verifyDocument(documentHash)` trả về trạng thái tồn tại, chủ sở hữu, mốc thời gian, số hiệu khối mà không tốn phí gas của người đọc.

---

## 5. Các trường hợp ngoại lệ (Edge Cases & Exception Handling)

- **E1 (Nạp thiếu phí dịch vụ)**: `msg.value < registrationFee` $\rightarrow$ Revert với `InsufficientFee(registrationFee, msg.value)`.
- **E2 (Đăng ký trùng mã băm)**: `_documents[documentHash].timestamp != 0` $\rightarrow$ Revert với `HashAlreadyExists(documentHash, timestamp)`.
- **E3 (Mã băm rỗng)**: `documentHash == bytes32(0)` $\rightarrow$ Revert với `InvalidDocumentHash()`.
- **E4 (Người lạ tự ý đổi phí hoặc rút quỹ)**: `msg.sender != owner` $\rightarrow$ Revert với lỗi OpenZeppelin `OwnableUnauthorizedAccount(msg.sender)`.
- **E5 (Rút quỹ khi số dư bằng 0)**: `address(this).balance == 0` $\rightarrow$ Revert với `ZeroBalance()`.
- **E6 (Địa chỉ ví nhận tiền không hợp lệ)**: `recipient == address(0)` $\rightarrow$ Revert với `InvalidRecipient()`.

---

## 6. Ngoài phạm vi Lab 11

- Chưa triển khai phân chia tỷ lệ động Basis Points trực tiếp trong từng giao dịch nạp (chuyển sang phân bổ định kỳ qua ví kho bạc trường ở Lab 12 & 13).
- Chưa tích hợp giao diện Web3 tương tác trực tiếp với ví MetaMask (nội dung này sẽ hoàn thiện tại Lab 15).
