# KỊCH BẢN TRÌNH BÀY DỰ ÁN (PRESENTATION PLAN) — 5 PHÚT

## Dự án: Hue Research Timestamp (HRT)
**Học phần:** Tiền điện tử & Hợp đồng thông minh (ECO2432) — Trường Đại học Kinh tế, Đại học Huế  
**Giảng viên phụ trách:** TS. Hà Ngọc Long  
**Nhóm sinh viên thực hiện (2 thành viên):**
1. **Phan Thành Đạt** (MSSV: **24K430002**) — Project Lead & Smart Contract Engineer
2. **Nguyễn Hữu Bằng** (MSSV: **24K4070016**) — Web3 Frontend Dev & Tokenomics Lead  

---

## 1. Nguyên tắc trình bày (Theo Sổ tay thực hành ECO2432 - Phần C.4)
- **Thời lượng tối đa:** Đúng 5 phút (300 giây). Bấm giờ nghiêm ngặt.
- **Phân vai bình đẳng:** Cả 2 thành viên đều thuyết trình và đều chỉ trực tiếp vào một artifact do mình trực tiếp phụ trách.
- **Không dùng slide thay cho sản phẩm:** Mở trực tiếp các tệp trong repo GitHub, chạy giao dịch thật trên Web DApp và đối chiếu mã nguồn thực tế.

---

## 2. Bảng phân công kịch bản chi tiết theo từng giây

| Mốc thời gian | Thời lượng | Người trình bày | Nội dung trọng tâm | Artifact / Bằng chứng phải mở |
| :---: | :---: | :--- | :--- | :--- |
| **0:00 – 0:30** | 30 giây | **Phan Thành Đạt** | **Người dùng và vấn đề:**<br>- Thực trạng tranh chấp ý tưởng nghiên cứu và chỉnh sửa kết quả NCKH tại Đại học Huế.<br>- Giới thiệu giải pháp HRT: Đóng dấu thời gian số bất biến trên Blockchain Ethereum. | [`README.md`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/README.md) (Mục 1 & 2) |
| **0:30 – 1:15** | 45 giây | **Nguyễn Hữu Bằng** | **Quy tắc kinh tế & Mô hình phí:**<br>- Phí dịch vụ bắt buộc `0.001 ETH` (Anti-Spam & duy trì hạ tầng IPFS).<br>- Cơ chế hoàn tiền thừa an toàn (Excess ETH Refund).<br>- Phân bổ ngân quỹ hỗ trợ NCKH sinh viên. | [`docs/SPEC.md`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/docs/SPEC.md)<br>[`docs/ECONOMIC_RULES.md`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/docs/ECONOMIC_RULES.md) |
| **1:15 – 2:45** | 90 giây | **Nguyễn Hữu Bằng** | **Demo trực tiếp luồng cốt lõi (Live DApp):**<br>- Chọn file nghiên cứu $\rightarrow$ băm SHA-256 trực tiếp tại máy khách (Client-side Hashing bằng Web Crypto API).<br>- Kết nối MetaMask Sepolia $\rightarrow$ Gửi giao dịch nạp 0.001 ETH $\rightarrow$ Xem khối xác nhận.<br>- Sang tab Tra cứu $\rightarrow$ Hiển thị Chứng thư Dấu thời gian số (Digital Certificate) miễn phí gas. | [`web/index.html`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/web/index.html)<br>[Sepolia Etherscan](https://sepolia.etherscan.io/) |
| **2:45 – 3:30** | 45 giây | **Phan Thành Đạt** | **Demo ca gian lận / vi phạm bị chặn:**<br>- Ca 1: Cố tình đăng ký trùng mã băm của tác giả khác $\rightarrow$ Bị chặn bởi `HashAlreadyExists`.<br>- Ca 2: Nạp thiếu phí $\rightarrow$ Revert với `InsufficientFee`.<br>- Ca 3: Người lạ cố tình sửa metadata $\rightarrow$ Revert với `NotDocumentOwner`. | [`evidence/lab-11/test_run.log`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/evidence/lab-11/test_run.log)<br>[`test/Lab11_EconomicRules.test.js`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/test/Lab11_EconomicRules.test.js) |
| **3:30 – 4:15** | 45 giây | **Phan Thành Đạt** | **Audit & Quyết định an toàn:**<br>- Thực nghiệm tái nhập Reentrancy (Lab 13) và 3 câu giải thích vì sao thứ tự dòng lệnh CEI chặn được tấn công.<br>- Báo cáo Cross-audit (Lab 14): Khắc phục hoàn tiền thừa và đặt trần phí `MAX_REGISTRATION_FEE = 0.05 ether`. | [`docs/AUDIT_REPORT.md`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/docs/AUDIT_REPORT.md)<br>[`evidence/lab-13/REENTRANCY_REPORT.md`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/evidence/lab-13/REENTRANCY_REPORT.md) |
| **4:15 – 5:00** | 45 giây | **Nguyễn Hữu Bằng** | **Giới hạn, bài học & Hướng tiếp theo:**<br>- Thu hẹp phạm vi sau Gate Review 1 (cắt giảm DAO phức tạp, tập trung luồng đóng dấu cốt lõi).<br>- Bài học cốt lõi: AI sinh mã nhanh nhưng thường sai bảo mật và phiên bản cũ (v4 vs v5); sinh viên kinh tế phải là người nắm chắc logic sổ sách và thẩm định rủi ro. | [`docs/PROJECT_PLAN.md`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/docs/PROJECT_PLAN.md)<br>[`docs/PRESENTATION_PLAN.md`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/docs/PRESENTATION_PLAN.md) |

---

## 3. Checklist chuẩn bị trước giờ G (Demo Readiness)

- [x] Ví MetaMask có sẵn tối thiểu `0.05 Sepolia ETH` để ký giao dịch demo.
- [x] Tệp PDF nghiên cứu mẫu sẵn sàng trên máy tính để băm file tức thì (ví dụ: `Bao_Cao_NCKH_Blockchain_Hue_2026.pdf`).
- [x] Mã giao dịch mẫu thành công đã lưu vào nhật ký on-chain để tra cứu dự phòng nếu mạng Sepolia bị nghẽn gas:
  - Mã băm tài liệu mẫu: `0x4f83e20e8a7f1a3a412b1d31d0db7a922614b98c37d0c3268875317bfb21d5a7`
  - Địa chỉ Smart Contract: `0x71C8F79720f4C7e74a68C838Fdfd3d4b68019688`
- [x] Bộ kiểm thử tự động 38/38 tests pass 100% sẵn sàng chạy lệnh `npm test` trực tiếp trước hội đồng.
- [x] Mở sẵn 3 tab trình duyệt: (1) GitHub Repo, (2) Web DApp (`web/index.html`), (3) Sepolia Etherscan.

---

## 4. Chuẩn bị trả lời vấn đáp cá nhân 3 tầng (Sổ tay Phần K)

### Tầng 1 — Hiểu mã nguồn của mình:
- **Câu hỏi:** Hàm `registerDocument` làm gì? Ai được phép gọi?
  - *Trả lời:* Hàm nhận mã băm SHA-256 của bài báo khoa học, thu phí 0.001 ETH và lưu mốc thời gian vĩnh viễn trên blockchain. Bất kỳ sinh viên, giảng viên nào có ví Web3 đều được phép gọi (hàm `external payable`).
- **Câu hỏi:** Dòng `balances[msg.sender] = 0;` trong rút quỹ nếu xóa đi thì chuyện gì xảy ra?
  - *Trả lời:* Hợp đồng sẽ dính ngay lỗ hổng Reentrancy, kẻ tấn công có thể đệ quy rút cạn toàn bộ ngân quỹ như vụ The DAO 2016.

### Tầng 2 — Hiểu quyết định thiết kế:
- **Câu hỏi:** Vì sao nhóm chọn thu phí 0.001 ETH mà không miễn phí?
  - *Trả lời:* Nếu miễn phí, kẻ xấu có thể viết bot spam hàng triệu giao dịch làm phình to trạng thái lưu trữ (State Bloat). Phí 0.001 ETH vừa đủ để ngăn chặn spam, vừa tạo nguồn kinh phí duy trì hạ tầng IPFS và tài trợ giải thưởng NCKH sinh viên.

### Tầng 3 — Phản biện:
- **Câu hỏi:** Nếu có người đổi một ký tự trong file bài báo rồi đăng ký lại thì sao?
  - *Trả lời:* Thuật toán SHA-256 có hiệu ứng tuyết lở (Avalanche Effect), chỉ cần đổi 1 dấu chấm thì mã băm 32 bytes sẽ thay đổi hoàn toàn. Hệ thống sẽ nhận diện đó là 2 tài liệu độc lập; tác giả nào đăng ký trước có mốc thời gian khối sớm hơn sẽ là bằng chứng chứng minh quyền ưu tiên xuất bản (Priority of Invention).
