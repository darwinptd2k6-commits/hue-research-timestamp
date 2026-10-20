# KỊCH BẢN VÀ KẾ HOẠCH KIỂM THỬ (TEST PLAN)
## Dự án: Hue Research Timestamp (HRT)
**Hợp đồng mục tiêu**: `contracts/project/ProjectCore.sol`  
**Tuân thủ**: `AGENTS.md` và `docs/SPEC.md`

---

## 1. Tổng quan ma trận kiểm thử

Theo quy ước tại `AGENTS.md`, bộ kiểm thử phải bao quát:
- **Luồng hoạt động đúng (Happy path)**.
- **Giá trị biên và kiểm tra tính hợp lệ dữ liệu (Boundary & Validation)**.
- **Kiểm tra phân quyền (Access Control & Unauthorized)**.
- **Hành vi gian lận / Tấn công bảo mật (Fraud & Security Attack)**.

---

## 2. Danh sách ca kiểm thử chi tiết

| Mã ca | Phân loại | Tên ca kiểm thử | Điều kiện ban đầu | Thao tác thực hiện | Kết quả mong đợi | Bằng chứng cần lưu |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC01** | Happy Path | Đăng ký tài liệu hợp lệ | Hợp đồng đã triển khai, ví tác giả có đủ ETH | Gọi `registerDocument` với hash hợp lệ và kèm `0.001 ETH` | Giao dịch thành công, phát sự kiện `DocumentTimestamped` | Tx hash, Event logs |
| **TC02** | Happy Path | Tra cứu xác thực tài liệu | Tài liệu đã đăng ký ở TC01 | Gọi `verifyDocument(hash)` | Trả về `exists = true`, đúng owner, timestamp $> 0$, đúng title | Giá trị trả về |
| **TC03** | Boundary | Băm tài liệu rỗng (Zero Hash) | Hợp đồng sẵn sàng | Gọi `registerDocument` với `documentHash = bytes32(0)` | Revert với custom error `InvalidDocumentHash()` | Chuỗi revert error |
| **TC04** | Boundary | Không đủ phí dịch vụ | Phí quy định `0.001 ETH` | Gọi `registerDocument` với `msg.value = 0.0005 ETH` | Revert với custom error `InsufficientFee(0.001 ether, 0.0005 ether)` | Chuỗi revert error |
| **TC05** | Fraud | Gian lận: Đăng ký trùng mã băm | Hash đã được tác giả A đăng ký | Tác giả B gọi `registerDocument` với cùng mã băm đó | Revert với custom error `HashAlreadyExists(hash, timestamp)` | Chuỗi revert error |
| **TC06** | Happy Path | Cập nhật siêu dữ liệu | Tài liệu đã tồn tại, người gọi là Owner tài liệu | Gọi `updateMetadata(hash, "ipfs://new-hash")` | Thành công, phát sự kiện `MetadataUpdated` | Event logs |
| **TC07** | Unauthorized | Gian lận: Sửa siêu dữ liệu của người khác | Tài liệu thuộc sở hữu của tác giả A | Tác giả B gọi `updateMetadata(hash, "...")` | Revert với custom error `NotDocumentOwner()` | Chuỗi revert error |
| **TC08** | Admin | Thay đổi mức phí đăng ký | Người gọi là Quản trị viên (`owner`) | Gọi `setRegistrationFee(0.002 ether)` | Thành công, phát sự kiện `FeeUpdated` | Event logs |
| **TC09** | Unauthorized | Người lạ cố tình đổi phí | Người gọi là tài khoản sinh viên thông thường | Gọi `setRegistrationFee(0.002 ether)` | Revert với `OwnableUnauthorizedAccount` | Chuỗi revert error |
| **TC10** | Admin/Fraud | Thu hồi chứng nhận vi phạm đạo văn | Công trình bị Hội đồng kỷ luật kết luận đạo văn | Admin gọi `revokeDocument(hash, "Dao van 60%")` | Trạng thái chuyển `isRevoked = true`, phát `DocumentRevoked` | Event logs |
| **TC11** | Security | Rút quỹ an toàn (Checks-Effects-Interactions) | Hợp đồng tích lũy số dư phí $> 0$ | Admin gọi `withdrawFees(recipient)` | Tiền chuyển thành công đến `recipient`, phát `FundsWithdrawn` | Số dư biến động |
| **TC12** | Security | Tấn công Reentrancy khi rút tiền | Triển khai hợp đồng tấn công độc hại từ chối nhận tiền hoặc gọi lại | Kẻ tấn công gọi rút tiền | `ReentrancyGuard` và `onlyOwner` chặn hoàn toàn | Giao dịch revert |

---

## 3. Hướng dẫn chạy kiểm thử

### Cách 1: Chạy kiểm thử tự động bằng Node.js / Ethers
```bash
npm install
npm test
```

### Cách 2: Kiểm thử trực tiếp trên Remix IDE
1. Mở [Remix IDE](https://remix.ethereum.org).
2. Tạo tệp `ProjectCore.sol` trong thư mục `contracts/`.
3. Biên dịch với Solidity compiler `0.8.20`.
4. Trong tab **Deploy & Run Transactions**, chọn môi trường `Remix VM (Cancun)`:
   - Triển khai `ProjectCore` với tham số: `initialOwner = Account 1`, `initialFee = 1000000000000000` (0.001 ETH).
   - Đổi tài khoản sang Account 2, nạp `1000000000000000` wei và gọi `registerDocument`.
   - Kiểm tra `verifyDocument`.
   - Chuyển sang Account 3, thử đăng ký cùng hash -> Xác nhận xuất hiện lỗi `HashAlreadyExists`.
