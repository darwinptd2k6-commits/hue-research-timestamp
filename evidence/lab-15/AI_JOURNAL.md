# NHẬT KÝ LÀM VIỆC VỚI AI — LAB 15: GIAO DIỆN WEB VÀ ĐƯA SẢN PHẨM LÊN MẠNG

## Dự án: Hue Research Timestamp (HRT)
**Học phần:** Tiền điện tử & Hợp đồng thông minh (ECO2432) — Trường Đại học Kinh tế, Đại học Huế  
**Nhóm sinh viên thực hiện:**
- Phan Thành Đạt (MSSV: 24K430002) — Project Lead & Smart Contract Engineer
- Nguyễn Hữu Bằng (MSSV: 24K4070016) — Web3 Frontend Dev & Tokenomics Lead  

---

## Lần 1: Chỉnh sửa giao diện Web3 DApp theo mẫu Prompt I.7 của Sổ tay

**Thời gian:** 17/10/2026  
**Người thực hiện:** Nguyễn Hữu Bằng  

**Prompt:**
> "Bạn là chuyên gia thiết kế giao diện Web3 Frontend.  
> Hãy đọc tệp web/index.html của dự án Hue Research Timestamp.  
> Áp dụng đúng chỉ dẫn I.7 trong Sổ tay thực hành ECO2432:  
> 1. Giữ nguyên toàn bộ logic kết nối và các thẻ thuộc tính id (walletAddress, walletBalance, btnConnect, btnRegister, regStatus, verifyHashInput, btnVerify, verifyStatus, verifyResult, contractAddressInput...) vì JavaScript đang dùng chúng.  
> 2. Đổi tiêu đề và nhãn nhận diện thành: 'Hue Research Timestamp (HRT)'.  
> 3. Tối ưu hóa CSS theo phong cách hiện đại (Modern Web3 Aesthetics): Theme tối sang trọng, kính mờ Glassmorphism, card nổi, bo tròn viền, font chữ Google Fonts Plus Jakarta Sans / JetBrains Mono.  
> 4. Đảm bảo giao diện hiển thị gọn gàng, co giãn mượt mà trên màn hình điện thoại di động (Mobile Responsive).  
> 5. Nút bấm phải có trạng thái đang xử lý (Loading Spinner) và vô hiệu hóa khi đang gửi giao dịch."

**AI trả về:**
- Cấu trúc giao diện hoàn chỉnh cho `web/index.html`:
  - Thêm thẻ Meta viewport và Google Fonts (`Plus Jakarta Sans` và `JetBrains Mono`).
  - Thiết kế CSS hệ màu hiện đại (`#090d16`, `#1e293b`, `#2563eb`, `#10b981`), hiệu ứng kính mờ `backdrop-filter: blur(16px)` và bóng đổ sâu.
  - Xây dựng lớp CSS `.spinner` và trạng thái `btn.disabled = true` khi giao dịch đang được xử lý.
  - Media query `@media (max-width: 640px)` giúp giao diện tự động xếp cột dọc trên điện thoại.
  - Giữ nguyên 100% các thẻ `id` phục vụ cho tương tác Ethers.js.

**Đánh giá:** ✅ Dùng được ngay. Thiết kế giao diện rất đẹp mắt, đậm chất Web3 Fintech, chuẩn bị sẵn sàng cho buổi demo trước lớp.  
**Chỗ sai:** Không có lỗi thẻ id.  
**Cách sửa:** Giữ nguyên toàn bộ mã HTML/CSS và tích hợp vào `web/index.html`.  
**Ai phát hiện:** Sinh viên kiểm tra kỹ bảng danh mục `id` đối chiếu.

---

## Lần 2: Nâng cấp cơ chế bắt lỗi thân thiện (User-Friendly Error Handling) theo Sổ tay Bước 2

**Thời gian:** 17/10/2026  
**Người thực hiện:** Phan Thành Đạt  

**Prompt:**
> "Theo lưu ý tại Bước 2 Lab 15 Sổ tay thực hành:  
> 'Phần bắt lỗi trong khối try/catch là chi tiết phân biệt sản phẩm dùng được và bài tập. Trường e.shortMessage chứa tên lỗi tùy biến đã định nghĩa trong hợp đồng — đây là lý do Lab 9 bắt dùng error tùy biến thay cho chuỗi require. Giao diện phải hiện thông báo bằng ngôn ngữ người dùng, không phải chuỗi lỗi kỹ thuật.'  
> Hãy viết hàm JavaScript parseFriendlyError(err) để bắt và chuyển đổi toàn bộ các Custom Errors từ hợp đồng ProjectCore.sol (InsufficientFee, HashAlreadyExists, InvalidDocumentHash, NotDocumentOwner, OwnableUnauthorizedAccount, FeeExceedsLimit) cũng như các lỗi ví MetaMask (ACTION_REJECTED, insufficient funds) sang câu thông báo tiếng Việt lịch sự, dễ hiểu."

**AI trả về:**
- Đoạn mã hàm `parseFriendlyError(err)`:
  ```javascript
  function parseFriendlyError(err) {
    const raw = (err.shortMessage || err.reason || err.message || "").toString();
    if (raw.includes("InsufficientFee")) {
      return "Lỗi quy tắc kinh tế: Bạn chưa gửi đủ phí đăng ký (bắt buộc 0.001 ETH)!";
    }
    if (raw.includes("HashAlreadyExists")) {
      return "Tài liệu này đã tồn tại trên Blockchain! Mã băm SHA-256 đã được một tác giả khác đăng ký trước đó.";
    }
    if (raw.includes("InvalidDocumentHash")) {
      return "Mã băm tài liệu không hợp lệ hoặc rỗng!";
    }
    if (raw.includes("OwnableUnauthorizedAccount") || raw.includes("NotOwner")) {
      return "Lỗi phân quyền: Bạn không phải Quản trị viên của hợp đồng!";
    }
    if (raw.includes("NotDocumentOwner")) {
      return "Chỉ chính tác giả đăng ký công trình mới có quyền cập nhật siêu dữ liệu!";
    }
    if (raw.includes("FeeExceedsLimit")) {
      return "Mức phí điều chỉnh vượt quá giới hạn trần an toàn (0.05 ETH)!";
    }
    if (raw.includes("user rejected") || raw.includes("ACTION_REJECTED")) {
      return "Bạn đã từ chối ký xác nhận giao dịch trên ví MetaMask.";
    }
    if (raw.includes("insufficient funds")) {
      return "Số dư ví Sepolia ETH của bạn không đủ để trả phí đăng ký và gas!";
    }
    return raw;
  }
  ```

**Đánh giá:** ⚠️ Phải sửa nhỏ.  
**Chỗ sai:** Ban đầu AI chỉ kiểm tra `err.message`, nhưng trong Ethers.js v6, tên Custom Error từ EVM thường nằm ở trường `err.shortMessage` hoặc `err.revert.name`. Nếu chỉ kiểm tra `err.message` thì một số lỗi Revert phức tạp sẽ bị lọt thành chuỗi kỹ thuật dài.  
**Cách sửa:** Sinh viên phát hiện và bổ sung gộp chuỗi `(err.shortMessage || err.reason || err.message)` để bắt chính xác mọi trường hợp.  
**Ai phát hiện:** **Sinh viên phát hiện** (Phan Thành Đạt).

---

## Lần 3: Xây dựng kịch bản demo và phân vai trình bày 5 phút (Theo Phần C.4 Sổ tay)

**Thời gian:** 17/10/2026  
**Người thực hiện:** Phan Thành Đạt & Nguyễn Hữu Bằng  

**Prompt:**
> "Dựa trên Phần C.4 của Sổ tay thực hành ECO2432 (Trang 36) và kết quả triển khai toàn bộ từ Lab 8 đến Lab 15, hãy soạn thảo tệp docs/PRESENTATION_PLAN.md cho nhóm 2 người:  
> - Thành viên 1: Phan Thành Đạt (Smart Contract Lead)  
> - Thành viên 2: Nguyễn Hữu Bằng (Frontend & Tokenomics Lead)  
> Phân chia chính xác 6 mốc thời gian: 0:00–0:30, 0:30–1:15, 1:15–2:45, 2:45–3:30, 3:30–4:15, 4:15–5:00.  
> Mỗi mốc nêu rõ người nói, nội dung trọng tâm và artifact bắt buộc phải mở trên màn hình máy chiếu."

**AI trả về:**
- Bản kế hoạch trình bày `docs/PRESENTATION_PLAN.md` chi tiết từng giây, kèm checklist demo và bộ câu hỏi vấn đáp 3 tầng (Tầng 1 - Hiểu mã, Tầng 2 - Quyết định thiết kế, Tầng 3 - Phản biện rủi ro).

**Đánh giá:** ✅ Dùng được ngay. Rất chỉn chu, đúng tinh thần bảo vệ đề tài NCKH Web3.  
**Chỗ sai:** Không có.  
**Cách sửa:** Lưu trực tiếp vào `docs/PRESENTATION_PLAN.md`.  
**Ai phát hiện:** Sinh viên và AI đồng thuận.
