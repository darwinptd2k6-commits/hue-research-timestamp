# KẾ HOẠCH DỰ ÁN (PROJECT PLAN)
## Dự án: Hue Research Timestamp (HRT)
**Học phần**: ECO2432 - Web3 & Fintech  
**Giảng viên phụ trách**: TS. Hà Ngọc Long  
**Đơn vị**: Trường Đại học Kinh tế - Đại học Huế (HUE)  
**Phiên bản**: v1.1.0

---

## 1. Mục tiêu dự án

Xây dựng hệ thống phi tập trung **Hue Research Timestamp (HRT)** cho phép sinh viên, giảng viên và các nhóm nghiên cứu tại Trường Đại học Kinh tế - Đại học Huế thực hiện:
- Đóng dấu thời gian chứng thực sự tồn tại (Proof of Existence) và bản quyền tác giả (Proof of Authorship) cho các đề tài nghiên cứu khoa học, khóa luận tốt nghiệp, bài báo và bộ dữ liệu thô.
- Ngăn chặn triệt để hành vi chiếm đoạt ý tưởng nghiên cứu và chỉnh sửa kết quả thực nghiệm hồi tố.
- Cung cấp cổng tra cứu công khai, minh bạch tính toàn vẹn của tài liệu nghiên cứu trên mạng thử nghiệm Ethereum Sepolia.

---

## 2. Phân chia vai trò và thành viên nhóm (2 Thành viên)

| STT | Thành viên phụ trách | MSSV | Vai trò chính | Nhiệm vụ chi tiết |
| :---: | :--- | :---: | :--- | :--- |
| 1 | **Phan Thành Đạt** | **24K430002** | **Project Lead & Smart Contract Engineer** | Điều phối tiến độ chung, viết đặc tả nghiệp vụ `SPEC.md`, thiết kế và lập trình Smart Contract `ProjectCore.sol`, tối ưu hóa Gas, viết bộ kiểm thử `test/ProjectCore.test.js`, thẩm định bảo mật (CEI, Reentrancy) và quản lý triển khai Sepolia. |
| 2 | **Nguyễn Hữu Bằng** | **24K4070016** | **Frontend Web3 Dev & Tokenomics Lead** | Xây dựng giao diện DApp `web/index.html`, tích hợp Ethers.js v6, lập trình thuật toán băm tệp tại máy khách (Client-side Hashing), thiết kế mô hình kinh tế vi mô & phân bổ quỹ Basis Points (`ECONOMIC_RULES.md`), thu thập minh chứng `evidence/`. |

### Ma trận trách nhiệm (RACI Matrix)

| Hạng mục công việc | Phan Thành Đạt | Nguyễn Hữu Bằng |
| :--- | :---: | :---: |
| 1. Lập kế hoạch dự án & Đặc tả nghiệp vụ (`SPEC.md`) | **A / R** | C |
| 2. Thiết kế mô hình kinh tế & Quản trị quỹ (`ECONOMIC_RULES.md`) | C | **A / R** |
| 3. Phát triển Smart Contract `ProjectCore.sol` & Tối ưu Gas | **A / R** | C |
| 4. Xây dựng bộ kiểm thử tự động `test/ProjectCore.test.js` | **A / R** | I |
| 5. Phát triển giao diện Web3 DApp & Client Hashing (`web/index.html`) | C | **A / R** |
| 6. Triển khai Sepolia Testnet, Tích hợp & Thu thập Evidence | **A** | **R** |

*(Ghi chú: A = Accountable - Chịu trách nhiệm chính; R = Responsible - Người thực hiện; C = Consulted - Người tham vấn; I = Informed - Người nhận thông tin)*

---

## 3. Lộ trình công việc qua các bài thực hành (Milestones)

### Giai đoạn 1: Khởi động & Nền tảng (Lab 1 - Lab 4)
- **Lab 1 - 2**: Thiết lập môi trường làm việc cá nhân (Antigravity IDE, Git, ví thử nghiệm MetaMask, mạng Sepolia testnet).
- **Lab 3**: Khảo sát thực trạng bảo vệ bản quyền nghiên cứu học thuật tại Đại học Huế; xác định bài toán đóng dấu thời gian.
- **Lab 4**: Nghiên cứu token ERC-20 (`ClubTokens.sol`) và mô hình khuyến khích người dùng trong hệ sinh thái học tập.

### Giai đoạn 2: Thiết kế hệ thống & Quản trị nhóm (Lab 5 - Lab 8)
- **Lab 5 - 6**: Soạn thảo tài liệu đặc tả nghiệp vụ `docs/SPEC.md` và mô hình kinh tế `docs/ECONOMIC_RULES.md`.
- **Lab 7**: Thống nhất quy ước làm việc với AI qua `AGENTS.md` và thiết lập mẫu nhật ký `AI_JOURNAL.md`.
- **Lab 8**: Khởi tạo repository nhóm `hue-research-timestamp`, mời các thành viên làm cộng tác viên (Collaborators), phân nhánh phát triển (`main`, `dev`, `feature/*`).

### Giai đoạn 3: Phát triển Smart Contract & Thẩm định an toàn (Lab 9 - Lab 13)
- **Lab 9**: Hợp đồng đầu tiên: Két tiết kiệm có khóa thời gian (`TimeLockVault.sol`); khởi tạo hợp đồng chính `contracts/project/ProjectCore.sol`. *(Hoàn thành)*
- **Lab 10**: Rà soát mã nguồn do AI sinh ra: Phát hiện 4 lỗi bảo mật trong `VaultBuggy.sol` (phân quyền, đảo ngược thời gian, lộ slot `private`, giới hạn gas transfer); audit củng cố `ProjectCore.sol`. *(Hoàn thành)*
- **Lab 11**: Cài đặt quy tắc kinh tế vào sản phẩm: Tích hợp phí đăng ký `registrationFee = 0.001 ETH`, chống spam lưu trữ, rút quỹ an toàn theo Checks-Effects-Interactions (CEI). *(Hoàn thành)*
- **Lab 12**: **Cổng duyệt Gate Review 1**: Báo cáo tự kiểm tra sức khỏe codebase, demo 3 phút, nhận quyết định thông qua (**QUA / PASS**), thu hẹp phạm vi và cập nhật kế hoạch. *(Hoàn thành)*
- **Lab 13**: Thực nghiệm một vụ mất tiền và cách khắc phục: Khai thác lỗi Reentrancy trên `VulnerableBank.sol`, vá lỗi bằng CEI và ReentrancyGuard, đối chiếu bảo mật cho `ProjectCore.sol`. *(Hoàn thành)*

### Giai đoạn 4: Kiểm thử, Tích hợp DApp & Hoàn thiện (Lab 14 - Lab 15)
- **Lab 14**: *(Hoàn thành)*
  - Rà soát chéo mã nguồn giữa các nhóm (Cross-audit theo 10 hạng mục Sổ tay ECO2432).
  - Hoàn thiện báo cáo `docs/AUDIT_REPORT.md` và `evidence/lab-14/AUDIT_REPORT_FOR_PEER.md`.
  - Khắc phục triệt để 3 phát hiện: hoàn trả tiền thừa, trần mức phí DoS, và authority trong sự kiện rút quỹ.
  - Hoàn thiện bộ kiểm thử tự động toàn diện: 38/38 ca test pass 100% (`test/ProjectCore.test.js`, `test/Lab11_EconomicRules.test.js`, `test/Lab13_ReentrancyHardening.test.js`, `test/Lab14_CrossAudit.test.js`).
- **Lab 15**: *(Hoàn thành)*
  - Hoàn thiện giao diện Web DApp `web/index.html` với thiết kế Dark Glassmorphism chuẩn cao cấp, responsive di động, hiệu ứng nút loading/spinner, băm file SHA-256 qua Web Crypto API, bắt lỗi thân thiện bằng tiếng Việt.
  - Xây dựng Kế hoạch thuyết trình 5 phút (`docs/PRESENTATION_PLAN.md`) phân công chi tiết Phan Thành Đạt & Nguyễn Hữu Bằng, phân bổ 6 mốc thời gian, demo checklist và bộ câu hỏi vấn đáp 3 vòng.
  - Cập nhật Bảng ánh xạ hàm Smart Contract - Giao diện Web DApp trong `README.md`.
  - Hoàn thiện bộ kiểm thử tự động toàn diện: 46/46 ca test pass 100% (bổ sung `test/Lab15_DAppIntegration.test.js` với 8/8 tests).
  - Thu thập và lưu trữ đầy đủ hồ sơ minh chứng `evidence/lab-15/` và `evidence/LAB15/` (`SPEC.md`, `AI_JOURNAL.md`, `DAPP_GUIDE.md`, `test_run.log`). Tag phiên bản `v0.1-demo`.

---

## 4. Quyết định Thu hẹp Phạm vi sau Gate Review 1 (Scope Pruning)

Theo kết luận tại [`docs/GATE_REVIEW_1.md`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/docs/GATE_REVIEW_1.md):
1. **Phạm vi cắt giảm**:
   - Cắt giảm cơ chế bỏ phiếu biểu quyết phi tập trung DAO / Multi-sig phức tạp trên chuỗi trong phiên bản v0.1. Quyền thu hồi văn bằng vi phạm đạo văn giao cho Quản trị viên nhà trường (`onlyOwner`).
   - Cắt giảm việc lưu trữ file nhị phân trực tiếp trên chuỗi; chỉ lưu trữ mã băm `bytes32 documentHash` và URI tóm tắt.
2. **Luồng cốt lõi tập trung hoàn thiện**:
   - Client Hashing (SHA-256) $\rightarrow$ `registerDocument` (thu phí 0.001 ETH) $\rightarrow$ Mốc thời gian bất biến $\rightarrow$ `verifyDocument` miễn phí gas.
3. **Phân công trách nhiệm cho các Lab tiếp theo**:
   - **Lab 13**: **Phan Thành Đạt** phụ trách thực nghiệm Reentrancy trên `VulnerableBank.sol` và hardening `ProjectCore.sol`.
   - **Lab 14**: **Phan Thành Đạt & Nguyễn Hữu Bằng** phụ trách rà soát chéo và triển khai Sepolia Testnet.
   - **Lab 15**: **Nguyễn Hữu Bằng** phụ trách hoàn thiện Web DApp `web/index.html` và tích hợp Ethers.js v6.

---

## 5. Quản lý rủi ro dự án

| Rủi ro | Mức độ | Biện pháp phòng ngừa / Khắc phục |
| :--- | :---: | :--- |
| Hết Sepolia ETH thử nghiệm | Trung bình | Tích hợp vòi nhận Sepolia ETH định kỳ; tối ưu hóa gas limit của các hàm trong smart contract. |
| Người dùng tải file nhạy cảm lên mạng | Cao | Bắt buộc băm file trực tiếp tại máy người dùng (Client-side), không truyền nội dung tệp lên chuỗi hay server. |
| Xung đột mã nguồn khi làm việc nhóm | Thấp | Phân chia nhiệm vụ theo module rõ ràng, mỗi tính năng tạo nhánh riêng và tạo Pull Request có review trước khi merge vào `main`. |
| Phát sinh lỗ hổng bảo mật khi rút quỹ | Cao | Áp dụng `ReentrancyGuard`, kiểm tra quyền `onlyOwner`, tuân thủ Checks-Effects-Interactions. |
