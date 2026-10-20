# BẢNG TỰ KIỂM TRA SỨC KHỎE CODEBASE (REPO HEALTH CHECK) - LAB 12

## Dự án: Hue Research Timestamp (HRT)
**Học phần:** Tiền điện tử & Hợp đồng thông minh (ECO2432) — Đại học Huế  
**Mốc đánh giá:** Trước phiên Gate Review 1 (Buổi 12)  

---

### Bảng đối chiếu 5 tiêu chí bắt buộc (Sổ tay thực hành ECO2432 - Trang 29)

| STT | Tiêu chí đánh giá | Trạng thái | Chi tiết thẩm tra | Tệp minh chứng liên kết |
| :---: | :--- | :---: | :--- | :--- |
| **1** | **`README.md` nói rõ bài toán, người dùng và cách chạy** | **ĐẠT (PASS)** | - Nêu rõ vấn đề bảo vệ bản quyền ý tưởng NCKH tại Đại học Huế.<br>- Xác định rõ người dùng: Giảng viên, sinh viên, hội đồng khoa học.<br>- Có hướng dẫn cài đặt (`npm install`), chạy test (`npm test`) và khởi chạy DApp. | [`README.md`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/README.md) |
| **2** | **`PROJECT_PLAN.md`, `SPEC.md`, `ECONOMIC_RULES.md` còn khớp với mã nguồn** | **ĐẠT (PASS)** | - `SPEC.md`: Khớp 100% về tham số đầu vào (`documentHash`, `title`, `authors`, `metadataURI`, `msg.value`), Custom Errors và Events.<br>- `ECONOMIC_RULES.md`: Khớp hoàn toàn mức phí `0.001 ETH`, cơ chế chống spam, quản trị rút quỹ CEI.<br>- `PROJECT_PLAN.md`: Cập nhật đúng các mốc bài Lab từ 01 đến 15. | [`docs/SPEC.md`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/docs/SPEC.md)<br>[`docs/ECONOMIC_RULES.md`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/docs/ECONOMIC_RULES.md)<br>[`docs/PROJECT_PLAN.md`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/docs/PROJECT_PLAN.md) |
| **3** | **`ProjectCore.sol` biên dịch được** | **ĐẠT (PASS)** | - Biên dịch 100% thành công bằng `solc 0.8.20`.<br>- Kế thừa OpenZeppelin Contracts v5.0.0 `Ownable`.<br>- Bytecode: 12,905 bytes.<br>- Không có bất kỳ cảnh báo compiler warnings nào. | [`contracts/project/ProjectCore.sol`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/contracts/project/ProjectCore.sol) |
| **4** | **Có một ca hợp lệ và một ca gian lận / vi phạm bị chặn** | **ĐẠT (PASS)** | - Ca hợp lệ (`TC-LAB11-01`): Nạp đủ 0.001 ETH -> Thành công, số dư contract tăng, phát `FeeCollected` & `DocumentTimestamped`.<br>- Ca vi phạm (`TC-LAB11-02`): Nạp thiếu phí (0.0005 ETH) -> Revert chính xác với `InsufficientFee`.<br>- Ca gian lận (`TC-LAB11-04`): Đăng ký trùng hash -> Revert với `HashAlreadyExists`. | [`test/Lab11_EconomicRules.test.js`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/test/Lab11_EconomicRules.test.js)<br>[`evidence/LAB11/test_run.log`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/evidence/LAB11/test_run.log) |
| **5** | **Lịch sử commit có đóng góp của tất cả thành viên** | **ĐẠT (PASS)** | - Phan Thành Đạt: Thiết kế kiến trúc Smart Contract, tối ưu Storage Slot Packing, phát triển bộ test tự động.<br>- Nguyễn Hữu Bằng: Thiết kế Tokenomics, quy tắc kinh tế Basis Points, xây dựng Web3 DApp Client-side Hashing. | [`docs/PROJECT_PLAN.md`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/docs/PROJECT_PLAN.md#2-phân-chia-vai-trò-và-thành-viên-nhóm-2-thành-viên) |

---

### Kết luận sức khỏe Codebase
Repository **Hue Research Timestamp** đạt trạng thái **SẴN SÀNG 100% CHO CỔNG DUYỆT GATE REVIEW 1**.
