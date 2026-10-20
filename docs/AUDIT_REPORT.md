# BÁO CÁO RÀ SOÁT CHÉO — Nhóm 8 (HCE Course Certificate) rà soát Nhóm 9 (Hue Research Timestamp)

**Học phần:** Tiền điện tử & Hợp đồng thông minh (ECO2432) — Trường Đại học Kinh tế, Đại học Huế  
**Đơn vị thực hiện audit:** Nhóm 8 — Hệ thống xác thực chứng nhận khóa học  
**Đơn vị được audit:** Nhóm 9 — Hue Research Timestamp (HRT)  
**Đối tượng rà soát:** `contracts/project/ProjectCore.sol` (425 dòng) và `docs/SPEC.md`  
**Ngày thực hiện:** 17/10/2026  
**Chuẩn kiểm toán:** Danh mục 10 hạng mục bắt buộc (Sổ tay thực hành ECO2432 - Trang 32)  

---

## I. Tóm tắt kết quả kiểm toán (Audit Executive Summary)

Đã tiến hành rà soát chéo toàn diện hợp đồng thông minh [`contracts/project/ProjectCore.sol`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/contracts/project/ProjectCore.sol) (phiên bản Solidity `^0.8.20`, OpenZeppelin v5.0.0) và bản đặc tả nghiệp vụ [`docs/SPEC.md`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/docs/SPEC.md).

### Đánh giá chung:
Hợp đồng của Nhóm 9 có chất lượng thiết kế rất cao:
- Tuân thủ nghiêm ngặt mô hình **Checks - Effects - Interactions (CEI)**.
- Đã trang bị thư viện bảo vệ chống tấn công tái nhập **OpenZeppelin `ReentrancyGuard`** (`nonReentrant`) từ Lab 13.
- Áp dụng kỹ thuật tối ưu hóa bộ nhớ **Storage Slot Packing** (đóng gói `address owner` và `bool isRevoked` vào cùng 1 slot 32 bytes).
- 100% các hàm ghi đều phát sự kiện (`event`) có chỉ mục `indexed`, các hàm tra cứu là `view` miễn phí gas.

### Thống kê phát hiện:
Tổng số vấn đề phát hiện: **3 vấn đề**
- **0 lỗi Nghiêm trọng** (Critical: 0)
- **1 lỗi Trung bình** (Medium: 1)
- **2 lỗi Nhẹ** (Low: 2)

---

## II. Bảng đối chiếu 10 hạng mục kiểm tra bắt buộc (Sổ tay Trang 32)

| STT | Hạng mục kiểm tra | Đánh giá | Ghi chú thẩm tra thực tế |
| :---: | :--- | :---: | :--- |
| **1** | **Phân quyền** | **ĐẠT** | Mọi hàm nhạy cảm (`revokeDocument`, `setRegistrationFee`, `withdrawFees`) đều có modifier `onlyOwner` bảo vệ. Hàm `updateMetadata` kiểm tra nghiêm ngặt `doc.owner == msg.sender`. |
| **2** | **Thứ tự thao tác (CEI)** | **ĐẠT** | Kiểm tra điều kiện đầu vào $\rightarrow$ Ghi nhận biến trạng thái $\rightarrow$ Phát sự kiện $\rightarrow$ Chuyển ETH ra ngoài sau cùng. |
| **3** | **Điều kiện thời gian** | **ĐẠT** | Dùng `block.timestamp` ghi nhận thời điểm bất biến; các phép so sánh `timestamp == 0` để kiểm tra sự tồn tại tài liệu chính xác tuyệt đối. |
| **4** | **Phép chia** | **ĐẠT** | Hợp đồng không thực hiện phép chia tỷ lệ số thập phân on-chain, không phát sinh lỗi làm tròn về 0. |
| **5** | **Cách chuyển ETH** | **ĐẠT** | Rút quỹ và hoàn tiền đều sử dụng lệnh gọi cấp thấp `.call{value: amount}("")`, kiểm tra kết quả `success`, không dùng `.transfer()` hoặc `.send()`. |
| **6** | **Dữ liệu riêng tư** | **ĐẠT** | Chỉ lưu trữ mã băm SHA-256 (32 bytes) và `metadataURI`, tuyệt đối không lưu nội dung tài liệu thô lên chuỗi. |
| **7** | **Vòng lặp** | **ĐẠT** | Không có bất kỳ vòng lặp `for`/`while` không giới hạn nào trên mảng động, triệt tiêu hoàn toàn rủi ro Out-of-Gas DoS. |
| **8** | **Sự kiện** | **CẦN SỬA** | Có đầy đủ sự kiện, tuy nhiên sự kiện `FundsWithdrawn` ban đầu chưa ghi nhận địa chỉ người thực hiện thao tác rút quỹ (Phát hiện 2). |
| **9** | **Trường hợp số 0** | **CẦN SỬA** | Xử lý tốt nạp 0 ETH, hash rỗng, số dư rút bằng 0. Tuy nhiên chưa có cơ chế hoàn trả ETH khi người dùng nạp thừa tiền (Phát hiện 1). |
| **10** | **Địa chỉ rỗng** | **ĐẠT** | Kiểm tra `recipient != address(0)` trong hàm `withdrawFees`, khởi tạo `Ownable` an toàn. |

---

## III. Chi tiết các phát hiện của nhóm kiểm toán

### Phát hiện 1 — Chưa có cơ chế hoàn trả tiền thừa khi người dùng gửi `msg.value > registrationFee`
- **Mức độ:** Trung bình (Medium)
- **Vị trí:** Dòng 140–180, hàm `registerDocument`
- **Mô tả:** Hàm `registerDocument` kiểm tra `if (msg.value < registrationFee) revert InsufficientFee(...)`. Khi người dùng gửi số tiền lớn hơn mức phí bắt buộc (ví dụ: gửi 0.05 ETH trong khi phí chỉ là 0.001 ETH), hợp đồng thu toàn bộ số tiền này vào số dư hợp đồng mà không tự động hoàn trả phần tiền dư `msg.value - registrationFee`.
- **Tình huống gây thiệt hại:** Người dùng bất cẩn cấu hình nhầm giá trị `value` trên ví MetaMask hoặc frontend gửi thừa tiền sẽ bị giam luôn khoản tiền thừa vào hợp đồng mà không có cách nào lấy lại.
- **Khuyến nghị:** Tính toán phần tiền thừa `uint256 excess = msg.value - registrationFee;`. Nếu `excess > 0`, thực hiện hoàn trả lại cho `msg.sender` bằng lệnh `.call` theo đúng mô hình CEI.
- **Ai phát hiện:** Thành viên Nhóm 8 (Trần Văn Bảo phát hiện).

---

### Phát hiện 2 — Sự kiện `FundsWithdrawn` thiếu thông tin người thực hiện thao tác rút quỹ
- **Mức độ:** Nhẹ (Low)
- **Vị trí:** Dòng 100, khai báo `event FundsWithdrawn(address indexed recipient, uint256 amount);`
- **Mô tả:** Khi rút quỹ, sự kiện chỉ lưu trữ địa chỉ người nhận (`recipient`) và số tiền (`amount`), thiếu địa chỉ ví của Quản trị viên trực tiếp kích hoạt giao dịch (`caller` / `authority`).
- **Tình huống gây thiệt hại:** Khi tra cứu nhật ký lịch sử trên Etherscan, chuyên viên tuân thủ (AML) hoặc kiểm toán viên nội bộ khó đối chiếu nhanh ai là người ký lệnh rút tiền nếu hợp đồng sau này chuyển giao quyền sở hữu sang mô hình Multi-sig.
- **Khuyến nghị:** Cập nhật khai báo sự kiện thành `event FundsWithdrawn(address indexed authority, address indexed recipient, uint256 amount);` và truyền `msg.sender` vào tham số đầu tiên.
- **Ai phát hiện:** Công cụ AI phát hiện.

---

### Phát hiện 3 — Chưa đặt mức trần tối đa khi Quản trị viên cập nhật mức phí dịch vụ mới
- **Mức độ:** Nhẹ (Low)
- **Vị trí:** Dòng 250, hàm `setRegistrationFee(uint256 newFee)`
- **Mô tả:** Hàm `setRegistrationFee` cho phép Quản trị viên thay đổi mức phí `registrationFee` tùy ý mà không có ngưỡng chặn trên (`MAX_REGISTRATION_FEE`).
- **Tình huống gây thiệt hại:** Nếu khóa riêng tư của Quản trị viên bị lộ hoặc quản trị viên nhập nhầm đơn vị (thêm 3 số 0), mức phí có thể bị đẩy lên 100 ETH, khiến toàn bộ người dùng bị từ chối giao dịch (Denial of Service kinh tế).
- **Khuyến nghị:** Bổ sung hằng số mức trần `uint256 public constant MAX_REGISTRATION_FEE = 0.05 ether;` và kiểm tra `if (newFee > MAX_REGISTRATION_FEE) revert FeeExceedsLimit(newFee, MAX_REGISTRATION_FEE);`.
- **Ai phát hiện:** Thành viên Nhóm 8 & AI đồng thuận.

---

## IV. Phản hồi và Biên bản khắc phục của Nhóm 9 (Remediation Actions)

Nhóm 9 đã họp tiếp thu toàn bộ báo cáo từ Nhóm 8 và thực hiện khắc phục ngay trong phiên làm việc:

| Mã phát hiện | Mức độ | Phản hồi của Nhóm 9 | Hành động khắc phục cụ thể | Tình trạng |
| :---: | :---: | :--- | :--- | :---: |
| **Phát hiện 1** | Trung bình | **ĐỒNG Ý 100%** | Bổ sung logic tính toán `uint256 excess = msg.value - registrationFee;`. Nếu `excess > 0`, hoàn tiền thừa về `msg.sender` bằng `.call{value: excess}("")` an toàn, ném `RefundFailed()` nếu thất bại. | **ĐÃ KHẮC PHỤC HOÀN TOÀN** |
| **Phát hiện 2** | Nhẹ | **ĐỒNG Ý 100%** | Cập nhật sự kiện `FundsWithdrawn` bổ sung `address indexed authority`, ghi nhận rõ `msg.sender` khi thực hiện rút quỹ. | **ĐÃ KHẮC PHỤC HOÀN TOÀN** |
| **Phát hiện 3** | Nhẹ | **ĐỒNG Ý 100%** | Đã khai báo hằng số `MAX_REGISTRATION_FEE = 0.05 ether` và kiểm tra `FeeExceedsLimit` trong hàm `setRegistrationFee`. | **ĐÃ KHẮC PHỤC HOÀN TOÀN** |

---

## V. Kết luận nghiệm thu rà soát chéo (Lab 14 Sign-off)

- Hợp đồng `ProjectCore.sol` sau khi tiếp thu và khắc phục 3 phát hiện đạt chuẩn an toàn **100% TUÂN THỦ CHECKLIST 10 HẠNG MỤC**.
- Toàn bộ các ca kiểm thử tự động (bao gồm kiểm thử hoàn tiền thừa, kiểm thử trần phí và kiểm thử thẩm tra quyền) đã được bổ sung vào `test/Lab14_CrossAudit.test.js` và vượt qua 100%.
- Đề xuất Giảng viên phụ trách phê duyệt kết quả nghiệm thu Lab 14 cho cả hai nhóm.
