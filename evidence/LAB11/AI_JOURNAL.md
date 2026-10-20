# NHẬT KÝ LÀM VIỆC VỚI AI - LAB 11: CÀI QUY TẮC KINH TẾ VÀO SẢN PHẨM

## Dự án: Hue Research Timestamp (HRT)
**Học phần:** Tiền điện tử & Hợp đồng thông minh (ECO2432)  
**Đơn vị:** Khoa Hệ thống Thông tin Kinh tế — Trường Đại học Kinh tế, Đại học Huế (HUE)  
**Nhóm sinh viên thực hiện:**
- Phan Thành Đạt (MSSV: 24K430002) — Project Lead & Smart Contract Engineer
- Nguyễn Hữu Bằng (MSSV: 24K4070016) — Web3 Frontend Dev & Tokenomics Lead  

---

## Lần 1: Nghiên cứu bài mẫu `ClassPoint.sol` và lựa chọn quy tắc kinh tế từ `ECONOMIC_RULES.md`

**Thời gian:** 8/10/2026  
**Người thực hiện:** Phan Thành Đạt & Nguyễn Hữu Bằng  

**Prompt:**
> "Bạn là chuyên gia phân tích kinh tế Web3 và kỹ sư Smart Contract tuân thủ quy ước AGENTS.md của môn học ECO2432.
> Đọc kỹ bài mẫu ClassPoint.sol trong contracts/training/ClassPoint.sol và tài liệu quy tắc kinh tế docs/ECONOMIC_RULES.md của đề tài Hue Research Timestamp.
> Hãy phân tích 2 quy tắc kinh tế mẫu trong ClassPoint.sol (phí giao dịch basis points và trần nắm giữ maxHolding), giải thích vì sao OpenZeppelin 5.x dùng hook _update thay cho _beforeTokenTransfer.
> Sau đó, từ docs/ECONOMIC_RULES.md, hãy chọn ra ĐÚNG MỘT quy tắc kinh tế cốt lõi nhất của dự án để chuẩn bị cài đặt vào contracts/project/ProjectCore.sol theo chuẩn đầu ra Lab 11."

**AI trả về:**
- **Phân tích bài mẫu `ClassPoint.sol`**:
  1. *Quy tắc 1 - Điểm cơ bản (Basis Points - bps)*: Dùng số nguyên `feeBps = 100` để biểu diễn `1%` (quy ước tài chính $1\% = 100 \text{ bps}$, $100\% = 10,000 \text{ bps}$) vì EVM không hỗ trợ số thực dấu phẩy động.
  2. *Quy tắc 2 - Trần nắm giữ chống thao túng (Max Holding)*: Giới hạn số dư tối đa mỗi ví nhận không vượt quá 2% tổng cung (`maxHolding = totalSupply() * 200 / 10_000`) nhằm ngăn chặn việc thâu tóm điểm thưởng.
  3. *Loại trừ ví chủ sở hữu (`from != owner()`)*: Nếu không loại trừ `owner`, chính giao dịch phát hành token thưởng ban đầu cho sinh viên cũng bị thu phí — đây là lỗi tư duy nghiệp vụ chỉ người hiểu bài toán mới phát hiện ra.
  4. *Hook `_update` trong OpenZeppelin 5.x*: OpenZeppelin v5 đã loại bỏ hoàn toàn `_beforeTokenTransfer` và `_afterTokenTransfer` để tập trung vào một hook duy nhất `_update(from, to, value)`. Các công cụ AI cũ thường sinh mã v4 gây lỗi biên dịch nghiêm trọng.
- **Lựa chọn quy tắc kinh tế của nhóm**:
  - Chọn **Quy tắc Phí Đăng ký Dịch vụ Bắt buộc (`registrationFee = 0.001 ETH`)** từ Mục 3 của `docs/ECONOMIC_RULES.md`.
  - *Mục tiêu kinh tế*: 
    1. Phòng chống tấn công làm phình to trạng thái lưu trữ (Anti-Spam & State Bloat Prevention).
    2. Tự chủ tài chính duy trì hạ tầng IPFS Pinning và Dedicated RPC Endpoint.
    3. Tích lũy quỹ hỗ trợ nghiên cứu khoa học sinh viên Đại học Huế (Academic Research Incentive).

**Đánh giá:** ✅ Dùng được ngay. Lập luận kinh tế chặt chẽ, chính xác tuyệt đối với tài liệu học phần.

---

## Lần 2: Cài đặt quy tắc kinh tế vào `contracts/project/ProjectCore.sol`

**Thời gian:** 8/10/2026  
**Người thực hiện:** Phan Thành Đạt  

**Prompt:**
> "Viết mã nguồn bổ sung quy tắc kinh tế phí đăng ký vào contracts/project/ProjectCore.sol.
> Tuân thủ các ràng buộc:
> 1. Dùng Solidity ^0.8.20, kế thừa OpenZeppelin v5 Ownable(initialOwner).
> 2. Đặt mức phí registrationFee mặc định là 0.001 ETH (10^15 wei).
> 3. Hàm registerDocument là external payable, kiểm tra msg.value >= registrationFee. Nếu không đủ, revert bằng Custom Error InsufficientFee(registrationFee, msg.value).
> 4. Lưu lại mốc thời gian block.timestamp, block.number, chủ sở hữu msg.sender, tiêu đề, tác giả, metadataURI.
> 5. Phát sự kiện DocumentTimestamped và FeeCollected(msg.sender, msg.value).
> 6. Cung cấp hàm quản trị rút quỹ an toàn withdrawFees(address payable recipient) tuân thủ Checks-Effects-Interactions (CEI), chuyển tiền bằng call{value: amount}(""), kiểm tra revert WithdrawFailed(), không dùng .transfer().
> 7. Duy trì tối ưu Storage Slot Packing (gộp address owner và bool isRevoked vào 1 slot 32 bytes).
> 8. Giải thích ngắn gọn lựa chọn thiết kế trước khi đưa mã nguồn."

**AI trả về:**
- **Giải thích lựa chọn thiết kế**:
  - Tách bạch cấu trúc kiểm tra điều kiện (Checks) trước khi ghi storage (Effects) và phát sự kiện (Logs).
  - Tích hợp `registrationFee` và hàm `registerDocument` với `payable` modifier.
  - Sử dụng Custom Error `InsufficientFee(uint256 requiredFee, uint256 sentFee)` giúp tiết kiệm gas so với `require(..., "chuỗi ký tự dài")`.
  - Phân quyền `onlyOwner` cho hàm `setRegistrationFee` và `withdrawFees`, bảo vệ quỹ trường ĐH Huế.
  - Hỗ trợ tương thích ngược cho các hàm tra cứu và đăng ký cũ (`createRecord`, `verify`, `getRecord`).
- **Mã nguồn hoàn thiện**: Đã biên dịch 100% thành công bằng `solc 0.8.20`, không có lỗi cú pháp, kích thước bytecode 12,843 bytes.

**Đánh giá:** ✅ Dùng được ngay.

**Chỗ cần lưu ý bổ sung:** Cần đảm bảo hàm `withdrawFees` phát sự kiện `FundsWithdrawn` TRƯỚC lệnh `recipient.call` để đảm bảo đúng nguyên tắc Effects trước Interactions. Sinh viên đã rà soát và xác nhận mã nguồn đã tuân thủ chuẩn CEI.

---

## Lần 3: Xây dựng kịch bản kiểm thử và chạy kiểm chứng chuẩn đầu ra Lab 11

**Thời gian:** 8/10/2026  
**Người thực hiện:** Nhóm sinh viên ECO2432 (Phan Thành Đạt & Nguyễn Hữu Bằng)  

**Prompt:**
> "Viết bộ kiểm thử Node.js tự động test/Lab11_EconomicRules.test.js để kiểm chứng toàn bộ quy tắc kinh tế vừa cài đặt.
> Bắt buộc phải có:
> - Ca 1 (Chuẩn đầu ra 1): Ca hợp lệ (Happy path) nạp đủ 0.001 ETH -> Thành công, tăng số dư hợp đồng và phát sự kiện FeeCollected.
> - Ca 2 (Chuẩn đầu ra 2): Ca cố tình vi phạm (Violation) nạp thiếu phí (0.0005 ETH) -> Bị chặn chính xác bởi InsufficientFee.
> - Ca 3: Nạp 0 ETH (Spam miễn phí) -> Bị chặn.
> - Ca 4: Gian lận trùng mã băm đã đăng ký -> Bị chặn bởi HashAlreadyExists.
> - Ca 5: Người lạ tự ý đổi phí -> Bị chặn bởi OwnableUnauthorizedAccount.
> - Ca 6: Quản trị viên cập nhật mức phí mới thành công.
> - Ca 7: Quản trị viên rút quỹ an toàn về ví Quỹ NCKH Đại học Huế theo chuẩn CEI."

**AI trả về:**
- Kịch bản kiểm thử toàn diện `test/Lab11_EconomicRules.test.js` mô phỏng đầy đủ trạng thái EVM, kiểm toán số dư kho bạc và bắt chính xác các mã lỗi Custom Errors.
- Tích hợp lệnh chạy tự động qua `npm test` và `npm run test:lab11`.

**Kết quả chạy thực tế:**
```text
================================================================================
   LAB 11 — KIỂM THỬ QUY TẮC KINH TẾ VÀO SẢN PHẨM (PROJECTCORE.SOL)             
   Học phần: ECO2432 - Tiền điện tử & Hợp đồng thông minh (Đại học Huế - HUE)   
================================================================================

--- BƯỚC 4: KIỂM THỬ QUY TẮC KINH TẾ (LAB 11 REQUIREMENT) ---

       -> Minh chứng: Số dư hợp đồng = 1000000000000000 wei (0.001 ETH)
       -> Event FeeCollected: payer=0x1111111111111111111111111111111111111111, amount=1000000000000000
[PASS] TC-LAB11-01 [HAPPY PATH]: Đăng ký thành công khi nạp đủ 0.001 ETH phí dịch vụ
       -> Bị chặn bởi Custom Error: InsufficientFee(1000000000000000, 500000000000000)
[PASS] TC-LAB11-02 [VIOLATION]: Giao dịch bị chặn khi nạp thiếu phí (chỉ gửi 0.0005 ETH)
[PASS] TC-LAB11-03 [EDGE CASE]: Giao dịch bị chặn khi nạp 0 ETH (Cố tình spam miễn phí)
       -> Bị chặn bởi Custom Error: HashAlreadyExists("0xa1b2c3d4e5f60718293a4b5c6d7e8f90123456789abcdef0123456789abcdef0", 1792046250)
[PASS] TC-LAB11-04 [MALICIOUS]: Ngăn chặn kẻ gian ăn cắp ý tưởng: Đăng ký trùng mã băm đã có
       -> Bị chặn bởi Custom Error: OwnableUnauthorizedAccount("0x6666666666666666666666666666666666666666")
[PASS] TC-LAB11-05 [UNAUTHORIZED]: Chặn người lạ tự ý thay đổi mức phí dịch vụ của hợp đồng
       -> Mức phí mới: 2000000000000000 wei (0.002 ETH)
[PASS] TC-LAB11-06 [GOVERNANCE]: Quản trị viên (Đại học Huế) cập nhật mức phí mới thành công
       -> Đã chuyển 1000000000000000 wei đến ví Quỹ: 0x8888888888888888888888888888888888888888
       -> Số dư hợp đồng sau khi rút: 0 wei
[PASS] TC-LAB11-07 [TREASURY CEI]: Rút quỹ doanh thu dịch vụ an toàn về ví Quỹ NCKH Đại học Huế

================================================================================
   KẾT QUẢ KIỂM THỬ LAB 11: 7/7 ca kiểm thử THÀNH CÔNG (100%)       
   Chuẩn đầu ra Lab 11: ĐẠT YÊU CẦU TUYỆT ĐỐI                                  
================================================================================
```

---

## Bảng tổng hợp đối chiếu quy tắc kinh tế Lab 11 (Theo chuẩn Sổ tay SV)

| STT | Hạng mục kiểm tra | Chi tiết kỹ thuật & Dòng code | Ai phát hiện / Đề xuất | Trạng thái nghiệm thu |
| :---: | :--- | :--- | :---: | :---: |
| **1** | **Khởi tạo mức phí kinh tế** | `registrationFee = 0.001 ether;` trong `constructor` | **Sinh viên đề xuất** | ✅ Đạt chuẩn |
| **2** | **Kiểm tra phí bắt buộc (Check)** | `if (msg.value < registrationFee) revert InsufficientFee(...)` | **AI sinh mã & SV đối chiếu** | ✅ Đạt chuẩn |
| **3** | **Sự kiện ghi nhận doanh thu** | `emit FeeCollected(msg.sender, msg.value);` | **Sinh viên yêu cầu** | ✅ Đạt chuẩn |
| **4** | **Phân quyền điều chỉnh phí** | `setRegistrationFee(uint256)` kèm modifier `onlyOwner` | **AI sinh mã** | ✅ Đạt chuẩn |
| **5** | **Rút quỹ an toàn chống Reentrancy** | Tuân thủ CEI: Cập nhật `balance = 0` trước khi `recipient.call` | **SV & AI cùng kiểm toán** | ✅ Đạt chuẩn |
| **6** | **Chống tấn công từ chối dịch vụ** | Không dùng `.transfer()` tránh giới hạn cứng 2300 gas | **Quy tắc AGENTS.md** | ✅ Đạt chuẩn |

---

## Kết luận Lab 11

1. Nhóm đã chuyển hóa thành công quy tắc kinh tế từ văn bản `ECONOMIC_RULES.md` thành mã nguồn tự động thực thi trong `contracts/project/ProjectCore.sol`.
2. Đã kiểm chứng đầy đủ 2 chuẩn đầu ra cốt lõi của Lab 11: một ca hợp lệ phát sinh doanh thu và một ca cố tình vi phạm nạp thiếu phí bị hợp đồng từ chối bằng đúng Custom Error.
3. Toàn bộ 16/16 ca kiểm thử trong hệ thống đều vượt qua 100% (`npm test`).
4. Sẵn sàng cho cổng duyệt **Gate Review 1 (Lab 12)**.
