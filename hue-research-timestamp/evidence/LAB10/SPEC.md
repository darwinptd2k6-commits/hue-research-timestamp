# SPEC — LAB 10: Rà Soát Mã Nguồn Do AI Sinh Ra & Thẩm Định Bảo Mật (VaultBuggy & ProjectCore)

## 1. Mục đích

Cung cấp bộ tiêu chí và quy trình thẩm định rủi ro, kiểm toán mã nguồn hợp đồng thông minh do AI sinh ra; nhận diện 4 lỗ hổng bảo mật cố ý trong hợp đồng huấn luyện `VaultBuggy.sol` và thực hiện rà soát, củng cố bảo mật cho hợp đồng chính của nhóm `ProjectCore.sol`.

---

## 2. Đầu vào

- Mã nguồn hợp đồng huấn luyện: [`contracts/training/VaultBuggy.sol`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/contracts/training/VaultBuggy.sol).
- Mã nguồn hợp đồng chính của nhóm: [`contracts/project/ProjectCore.sol`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/contracts/project/ProjectCore.sol).
- Tham số khởi tạo hợp đồng kiểm thử `VaultBuggy`:
  - `lockSeconds` (`uint256`): Thời gian khóa két (ví dụ: `120` giây).
  - `pin` (`uint256`): Mã PIN khẩn cấp (ví dụ: `123456`).
- Lệnh tra cứu trực tiếp ô nhớ storage qua RPC Ethereum: `eth_getStorageAt(contractAddress, "0x2", "latest")`.

---

## 3. Quy tắc nghiệp vụ (Kiểm toán bảo mật)

- **R1 (Kiểm soát phân quyền nghiêm ngặt)**: Mọi hàm rút tài sản hoặc thay đổi trạng thái quan trọng phải kiểm tra danh tính người gọi (`msg.sender == owner` hoặc `isIssuer[msg.sender]`). Tuyệt đối không để hàm rút tiền mở tự do cho mọi địa chỉ ví.
- **R2 (Đúng chiều logic khóa thời gian)**: Điều kiện rút tiền chỉ được thỏa mãn khi mốc thời gian khối đã vượt qua thời hạn khóa (`block.timestamp >= unlockTime`). Tuyệt đối không dùng dấu đảo ngược `<=`.
- **R3 (Nguyên lý dữ liệu công khai on-chain)**: Từ khóa `private` trong Solidity chỉ chặn truy cập giữa các smart contract, không mã hóa dữ liệu. Mọi biến lưu trữ trên blockchain đều có thể đọc được công khai qua `eth_getStorageAt`. Do đó, tuyệt đối không lưu mã PIN hay bí mật dạng rõ trên chuỗi.
- **R4 (Chuyển ETH an toàn & Chống nghẽn Gas)**: Sử dụng cú pháp `(bool ok, ) = recipient.call{value: amount}("")` và kiểm tra `require(ok)` / `revert TransferFailed()`. Tuyệt đối không dùng `.transfer()` vốn bị giới hạn cứng 2300 gas.
- **R5 (Tuân thủ mô hình Checks - Effects - Interactions & Ghi nhật ký Event)**: Kiểm tra điều kiện đầu vào trước, cập nhật trạng thái/phát sự kiện trước, và chuyển tiền ra ngoài sau cùng để triệt tiêu lỗ hổng Reentrancy.

---

## 4. Đầu ra

- **Bảng phân tích 4 lỗ hổng bảo mật của `VaultBuggy.sol`**: Xác định chính xác số dòng, mức độ nghiêm trọng, kịch bản khai thác và mã sửa đổi khắc phục.
- **Bằng chứng thực nghiệm đọc Slot 2**: Giá trị hex của `emergencyPin` trích xuất trực tiếp từ môi trường Remix/Console trình duyệt.
- **Báo cáo kiểm toán `ProjectCore.sol`**: Đảm bảo hợp đồng chính của nhóm không mắc bất kỳ lỗ hổng bảo mật nào (đã được tối ưu hóa Storage Slot Packing).

---

## 5. Trường hợp ngoại lệ

- **E1 (Kẻ xấu rút trộm tiền do thiếu phân quyền)**: Bất kỳ địa chỉ ví nào gọi `withdraw()` trên `VaultBuggy` đều rút cạn tiền -> Sửa lỗi: Bổ sung `if (msg.sender != owner) revert NotOwner();`.
- **E2 (Bị khóa vĩnh viễn tiền sau hạn)**: Khi `block.timestamp > unlockTime`, lệnh gọi `withdraw()` bị revert do dấu so sánh ngược `<=` -> Sửa lỗi: Đổi thành `if (block.timestamp < unlockTime) revert StillLocked(...);`.
- **E3 (Rút tiền thất bại do giới hạn 2300 gas của `.transfer()`)**: Người nhận là ví đa chữ ký (Multisig) hoặc Smart Contract Wallet -> Sửa lỗi: Dùng `.call{value: amount}("")`.
- **E4 (Lộ mã PIN qua `eth_getStorageAt`)**: Kẻ tấn công đọc được `emergencyPin` tại ô nhớ `0x2` -> Sửa lỗi: Loại bỏ lưu trữ PIN rõ trên chuỗi hoặc dùng Hash/Commitment Scheme.

---

## 6. Ngoài phạm vi

- Không sử dụng `VaultBuggy.sol` trên mạng chính thức (chỉ dùng làm học liệu cảnh báo rủi ro).
- Không triển khai các kỹ thuật mật mã nâng cao như Zero-Knowledge SNARKs trong phạm vi bài Lab này.
