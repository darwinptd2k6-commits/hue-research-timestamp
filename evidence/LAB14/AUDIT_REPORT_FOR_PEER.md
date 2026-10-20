# BÁO CÁO RÀ SOÁT CHÉO — Nhóm 9 (Hue Research Timestamp) rà soát Nhóm 8 (HCE Course Certificate)

**Học phần:** Tiền điện tử & Hợp đồng thông minh (ECO2432) — Trường Đại học Kinh tế, Đại học Huế  
**Đơn vị audit:** Nhóm 9 — Hue Research Timestamp  
**Thành viên thực hiện audit:**  
- Phan Thành Đạt (MSSV: 24K430002) — Project Lead & Smart Contract Engineer  
- Nguyễn Hữu Bằng (MSSV: 24K4070016) — Web3 Frontend Dev & Tokenomics Lead  
**Đối tượng rà soát:** `contracts/training/PeerCertificateRegistry.sol` và `docs/SPEC.md` của Nhóm 8  
**Ngày thực hiện:** 14/10/2026  

---

## Tóm tắt
Đã rà soát tệp `PeerCertificateRegistry.sol`, 75 dòng mã nguồn Solidity. Đối chiếu toàn diện theo **Danh mục kiểm tra bắt buộc 10 hạng mục** tại Trang 32 của Sổ tay thực hành ECO2432.  
Phát hiện **4 vấn đề**:
- **1 lỗi Nghiêm trọng** (Critical - Lỗ hổng phân quyền có thể phá hoại toàn bộ hệ thống)
- **1 lỗi Trung bình** (Medium - Nguy cơ vượt giới hạn Gas DoS)
- **2 lỗi Nhẹ** (Low - Vi phạm quy ước chuyển ETH an toàn và thiếu kiểm tra địa chỉ rỗng)

---

## Chi tiết các phát hiện theo Danh mục 10 hạng mục Sổ tay

### Phát hiện 1 — Hàm thu hồi chứng chỉ nhạy cảm bỏ quên kiểm tra phân quyền (Hạng mục 1: Phân quyền)
- **Mức độ:** Nghiêm trọng (Critical)
- **Vị trí:** Dòng 45-49, hàm `revokeCertificate(bytes32 certHash)`
- **Mô tả:** Hàm `revokeCertificate` thay đổi trạng thái có hiệu lực của chứng chỉ học thuật nhưng hoàn toàn không có modifier kiểm tra quyền hạn (như `onlyAdmin` hoặc `require(msg.sender == admin)`).
- **Tình huống gây thiệt hại:** Bất kỳ ai có ví MetaMask trên mạng Sepolia đều có thể gọi hàm `revokeCertificate` để hủy bỏ vĩnh viễn chứng chỉ tốt nghiệp hoặc chứng nhận khóa học của sinh viên khác mà không cần sự đồng ý của Nhà trường/Giảng viên.
- **Khuyến nghị:** Thêm modifier kiểm tra quyền hạn rõ ràng:
  ```solidity
  modifier onlyAdmin() {
      require(msg.sender == admin, "NotAdmin");
      _;
  }
  function revokeCertificate(bytes32 certHash) external onlyAdmin { ... }
  ```
- **Ai phát hiện:** Thành viên nhóm (Phan Thành Đạt phát hiện).

---

### Phát hiện 2 — Duyệt toàn bộ mảng động không giới hạn độ dài trong hàm đọc (Hạng mục 7: Vòng lặp)
- **Mức độ:** Trung bình (Medium)
- **Vị trí:** Dòng 52-67, hàm `getAllActiveCertificates()`
- **Mô tả:** Hàm duyệt qua toàn bộ mảng `allCertHashes` bằng 2 vòng lặp liên tiếp để đếm và cấp phát mảng trả về. Khi số lượng chứng chỉ vượt quá 500 - 1.000 bản ghi, việc đọc dữ liệu có thể vượt ngưỡng giới hạn gas thực thi của node RPC hoặc tốn rất nhiều thời gian phản hồi.
- **Tình huống gây thiệt hại:** Khi số lượng sinh viên cấp bằng tăng dần theo các kỳ học, DApp gọi hàm này sẽ bị timeout hoặc Out-of-Gas, khiến trang tra cứu danh sách chứng chỉ bị tê liệt.
- **Khuyến nghị:** Áp dụng phân trang (Pagination) bằng cách nhận vào `uint256 offset, uint256 limit`, hoặc tốt hơn là truy vấn qua sự kiện (Event Indexing) và GraphQL/The Graph ngoài chuỗi thay vì duyệt mảng on-chain.
- **Ai phát hiện:** Công cụ AI phát hiện & Sinh viên thẩm định.

---

### Phát hiện 3 — Sử dụng lệnh `.transfer()` lạc hậu thay vì `.call` (Hạng mục 5: Cách chuyển ETH)
- **Mức độ:** Nhẹ (Low)
- **Vị trí:** Dòng 74, hàm `withdraw(address payable recipient)`
- **Mô tả:** Hàm rút ngân quỹ sử dụng `recipient.transfer(...)`. Lệnh này có giới hạn cứng 2.300 gas.
- **Tình huống gây thiệt hại:** Nếu địa chỉ ví nhận tiền `recipient` là ví đa chữ ký (Gnosis Safe / Multi-sig) hoặc hợp đồng có logic xử lý trong `receive()`, giao dịch rút tiền sẽ luôn bị thất bại (Revert) do không đủ gas.
- **Khuyến nghị:** Tuân thủ Điều 4 trong `AGENTS.md`, chuyển sang cú pháp cấp thấp `.call`:
  ```solidity
  (bool success, ) = recipient.call{value: address(this).balance}("");
  require(success, "WithdrawFailed");
  ```
- **Ai phát hiện:** Thành viên nhóm (Nguyễn Hữu Bằng phát hiện).

---

### Phát hiện 4 — Không kiểm tra địa chỉ sinh viên rỗng (Hạng mục 10: Địa chỉ rỗng)
- **Mức độ:** Nhẹ (Low)
- **Vị trí:** Dòng 31, hàm `issueCertificate(bytes32 certHash, address student, ...)`
- **Mô tả:** Không kiểm tra tham số `student != address(0)`.
- **Tình huống gây thiệt hại:** Người cấp chứng chỉ có thể gõ nhầm hoặc giao diện frontend gửi tham số `0x000...`, dẫn đến chứng chỉ được gán cho "hố đen" mà không ai có thể sử dụng hay chứng minh quyền sở hữu.
- **Khuyến nghị:** Bổ sung kiểm tra ngay đầu hàm:
  ```solidity
  require(student != address(0), "InvalidStudentAddress");
  ```
- **Ai phát hiện:** Công cụ AI phát hiện.

---

## Bảng đối chiếu 10 hạng mục kiểm tra bắt buộc (Sổ tay Trang 32)

| STT | Hạng mục kiểm tra | Đạt / Chưa đạt | Đánh giá thực tế trên mã nguồn Nhóm 8 |
| :---: | :--- | :---: | :--- |
| **1** | **Phân quyền** | ❌ **CHƯA ĐẠT** | Hàm `revokeCertificate` quên kiểm tra quyền Admin (Phát hiện 1). |
| **2** | **Thứ tự thao tác (CEI)** | ⚠️ Cần lưu ý | Hàm `withdraw` cần xóa số dư trước khi chuyển tiền nếu dùng logic ghi nhận. |
| **3** | **Điều kiện thời gian** | ✅ ĐẠT | Dùng `block.timestamp` ghi nhận thời điểm cấp bằng hợp lệ. |
| **4** | **Phép chia** | ✅ ĐẠT | Chưa phát sinh phép chia làm tròn về 0. |
| **5** | **Cách chuyển ETH** | ❌ **CHƯA ĐẠT** | Dùng `.transfer()` thay vì `.call` kèm kiểm tra `success` (Phát hiện 3). |
| **6** | **Dữ liệu riêng tư** | ✅ ĐẠT | Đã lưu mã băm `certHash` thay vì đưa toàn bộ thông tin cá nhân lên chuỗi. |
| **7** | **Vòng lặp** | ❌ **CHƯA ĐẠT** | Vòng lặp duyệt mảng động `allCertHashes` có nguy cơ DoS (Phát hiện 2). |
| **8** | **Sự kiện** | ✅ ĐẠT | Có phát `CertificateIssued` và `CertificateRevoked` với `indexed`. |
| **9** | **Trường hợp số 0** | ⚠️ Cần lưu ý | Chưa xử lý tiền nạp dư (`msg.value > certFee`). |
| **10** | **Địa chỉ rỗng** | ❌ **CHƯA ĐẠT** | Thiếu kiểm tra `student != address(0)` (Phát hiện 4). |
