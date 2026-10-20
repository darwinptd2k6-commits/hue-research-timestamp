# NHẬT KÝ LÀM VIỆC VỚI AI — LAB 14: RÀ SOÁT CHÉO GIỮA CÁC NHÓM

## Dự án: Hue Research Timestamp (HRT)
**Học phần:** Tiền điện tử & Hợp đồng thông minh (ECO2432) — Trường Đại học Kinh tế, Đại học Huế  
**Nhóm sinh viên thực hiện:**
- Phan Thành Đạt (MSSV: 24K430002) — Project Lead & Smart Contract Engineer
- Nguyễn Hữu Bằng (MSSV: 24K4070016) — Web3 Frontend Dev & Tokenomics Lead  

---

## Lần 1: Sử dụng AI thẩm định rủi ro phân quyền trên `ProjectCore.sol` (Theo mẫu Prompt I.1 của Sổ tay)

**Thời gian:** 14/10/2026  
**Người thực hiện:** Nguyễn Hữu Bằng  

**Prompt:**
> "Bạn là chuyên viên thẩm định rủi ro tài sản số.  
> Dưới đây là mã nguồn hợp đồng contracts/project/ProjectCore.sol.  
> Hãy liệt kê mọi quyền đặc biệt mà chủ sở hữu hợp đồng (Quản trị viên) có thể thực hiện.  
> Với mỗi quyền, nêu: tên hàm, số dòng, và rủi ro cụ thể cho người dùng (sinh viên, nhà nghiên cứu).  
> Trình bày dưới dạng bảng.  
> Chỉ dựa trên mã nguồn tôi cung cấp. Nếu không tìm thấy quyền nào, hãy nói rõ là không tìm thấy, không suy đoán.  
> 
> [Đính kèm mã nguồn ProjectCore.sol]"

**AI trả về:**
Bảng phân tích quyền hạn đặc biệt của Owner trong `ProjectCore.sol`:
| Tên hàm | Vị trí dòng | Quyền hạn đặc biệt của Owner | Rủi ro cho người dùng / Tác giả | Đánh giá an toàn |
| :--- | :---: | :--- | :--- | :--- |
| `revokeDocument` | Dòng 210 | Thu hồi hiệu lực dấu thời gian của một công trình nghiên cứu kèm lý do vi phạm học thuật | Nếu tài khoản Admin bị đánh cắp, kẻ gian có thể thu hồi oan chứng nhận của tác giả | Có căn cứ: Cần thiết để xử lý đạo văn; đã phát event `DocumentRevoked` minh bạch on-chain |
| `setRegistrationFee` | Dòng 248 | Thay đổi mức phí dịch vụ đăng ký tài liệu | **CÓ RỦI RO**: Không có trần tối đa `MAX_FEE`. Admin có thể vô ý nhập nhầm phí 100 ETH làm tê liệt người dùng | **LỖI PHÁT HIỆN**: Cần bổ sung mức trần tối đa |
| `withdrawFees` | Dòng 260 | Rút toàn bộ số dư doanh thu tích lũy về ví chỉ định | Rút quỹ về ví không đúng mục đích nếu không có giám sát | Đã an toàn: Chỉ rút phần phí dịch vụ, không ảnh hưởng đến dữ liệu dấu thời gian đã đăng ký |

**Đánh giá:** ✅ Dùng được ngay. Bảng phân tích chi tiết, chỉ ra đúng số dòng và phát hiện được lỗ hổng thiếu mức trần phí dịch vụ trong hàm `setRegistrationFee`.  
**Chỗ sai:** Không có.  
**Cách sửa:** Sử dụng phát hiện này để bổ sung hằng số `MAX_REGISTRATION_FEE = 0.05 ether` vào bản vá của nhóm.  
**Ai phát hiện:** **Sinh viên và AI đồng thuận phát hiện**.

---

## Lần 2: Sinh ca kiểm thử cho toàn bộ 10 hạng mục checklist (Theo mẫu Prompt I.5 của Sổ tay)

**Thời gian:** 14/10/2026  
**Người thực hiện:** Phan Thành Đạt  

**Prompt:**
> "Dưới đây là hợp đồng ProjectCore.sol sau khi đã tiếp thu các phát hiện kiểm toán từ Nhóm 8.  
> Hãy liệt kê các ca kiểm thử cần có, chia làm ba nhóm theo đúng mẫu I.5 của Sổ tay thực hành ECO2432:  
> - Nhóm 1: Luồng bình thường (Happy path)  
> - Nhóm 2: Trường hợp biên (số 0, nạp thừa tiền, đúng bằng mốc thời gian, trần mức phí)  
> - Nhóm 3: Trường hợp có người cố tình gian lận hoặc tấn công phá hoại  
> Với nhóm 3, mô tả rõ kẻ tấn công làm gì và mong đợi hệ thống phản ứng ra sao."

**AI trả về:**
- **Nhóm 1 (Luồng bình thường)**:
  - TC1: Đăng ký tài liệu thành công với đúng phí `0.001 ETH`.
  - TC2: Tra cứu tính hợp lệ của tài liệu trả về đầy đủ thông tin tác giả, mốc thời gian và trạng thái.
  - TC3: Quản trị viên rút quỹ an toàn về ví Quỹ NCKH Đại học Huế.
- **Nhóm 2 (Trường hợp biên)**:
  - TC4: Sinh viên nạp thừa tiền (gửi `0.005 ETH`), hệ thống thu đúng `0.001 ETH` và hoàn trả tức thì `0.004 ETH` về ví sinh viên.
  - TC5: Thử rút quỹ khi số dư hợp đồng bằng 0 (`ZeroBalance`).
  - TC6: Thử rút quỹ về địa chỉ rỗng `address(0)` (`InvalidRecipient`).
  - TC7: Đặt mức phí mới bằng đúng mức trần `0.05 ether` (thành công).
- **Nhóm 3 (Trường hợp gian lận / Tấn công)**:
  - TC8: Kẻ lạ mạo danh gọi hàm rút quỹ `withdrawFees` $\rightarrow$ Kỳ vọng: Bị chặn với lỗi `OwnableUnauthorizedAccount`.
  - TC9: Kẻ xấu cố tình đặt mức phí trên trời `0.1 ETH` ($> 0.05$ ETH) $\rightarrow$ Kỳ vọng: Bị chặn với lỗi `FeeExceedsLimit`.
  - TC10: Kẻ lạ cố tình sửa metadata bài báo của người khác $\rightarrow$ Kỳ vọng: Bị chặn với lỗi `NotDocumentOwner`.
  - TC11: Kẻ nhận tiền độc hại cố tình gọi đệ quy tái nhập trong `withdrawFees` $\rightarrow$ Kỳ vọng: Bị chặn bởi `ReentrancyGuardReentrantCall`.

**Đánh giá:** ✅ Dùng được ngay. Phân loại 3 nhóm test cases rất chuẩn mực, bao phủ 100% các hạng mục kiểm toán của Sổ tay.  
**Chỗ sai:** Ban đầu AI quên viết assertion kiểm tra xem phần tiền thừa `0.004 ETH` có thực sự được hoàn trả cho người gửi hay không.  
**Cách sửa:** Sinh viên đã bổ sung kiểm tra `assert.strictEqual(result.excessRefunded, 4000000000000000n)` vào ca kiểm thử `TC-LAB14-10`.  
**Ai phát hiện:** **Sinh viên phát hiện** (Phan Thành Đạt).

---

## Lần 3: Phân tích và xây dựng bản vá cho Hợp đồng Nhóm bạn (`PeerCertificateRegistry.sol`)

**Thời gian:** 17/10/2026  
**Người thực hiện:** Phan Thành Đạt & Nguyễn Hữu Bằng  

**Prompt:**
> "Hãy rà soát hợp đồng PeerCertificateRegistry.sol của Nhóm 8.  
> Tập trung vào 2 lỗ hổng nghiêm trọng nhất:  
> 1. Hàm revokeCertificate không kiểm tra admin.  
> 2. Hàm withdraw dùng .transfer(balance).  
> Hãy viết đoạn mã khắc phục chuẩn theo cú pháp Solidity 0.8.20 và quy ước AGENTS.md để gửi cho Nhóm bạn."

**AI trả về:**
- Mã nguồn bản vá đề xuất cho Nhóm bạn:
  ```solidity
  error NotAdmin();
  error WithdrawFailed();

  modifier onlyAdmin() {
      if (msg.sender != admin) revert NotAdmin();
      _;
  }

  function revokeCertificate(bytes32 certHash) external onlyAdmin {
      require(certificates[certHash].issueDate != 0, "Khong tim thay");
      certificates[certHash].isRevoked = true;
      emit CertificateRevoked(certHash);
  }

  function withdraw(address payable recipient) external onlyAdmin {
      require(recipient != address(0), "Dia chi rong");
      uint256 amount = address(this).balance;
      require(amount > 0, "So du rong");
      (bool success, ) = recipient.call{value: amount}("");
      if (!success) revert WithdrawFailed();
  }
  ```

**Đánh giá:** ✅ Dùng được ngay. Giải pháp ngắn gọn, thay thế `.transfer()` bằng `.call` an toàn, dùng Custom Errors tối ưu gas.  
**Chỗ sai:** Không có.  
**Cách sửa:** Ghi trực tiếp khuyến nghị này vào báo cáo `evidence/lab-14/AUDIT_REPORT_FOR_PEER.md`.  
**Ai phát hiện:** Sinh viên và AI đồng thuận.
