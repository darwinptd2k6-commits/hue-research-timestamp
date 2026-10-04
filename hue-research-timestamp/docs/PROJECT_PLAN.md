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
- **Lab 9 - 10**: Thực hành các bài mẫu bảo mật kỹ thuật (`TimeLockVault`, `VaultBuggy`, `VulnerableBank`).
- **Lab 11**: Rà soát các bẫy lỗi phổ biến: Reentrancy, Overflow/Underflow, xác thực bằng `tx.origin`.
- **Lab 12**: Viết bản nháp hợp đồng chính `contracts/project/ProjectCore.sol`.
- **Lab 13**: Refactor mã nguồn theo OpenZeppelin 5.x, triển khai cơ chế Checks-Effects-Interactions, custom errors và cấu trúc điểm cơ bản (basis points).

### Giai đoạn 4: Kiểm thử, Tích hợp DApp & Hoàn thiện (Lab 14 - Lab 15)
- **Lab 14**:
  - Viết bộ kiểm thử toàn diện trong `test/ProjectCore.test.js`.
  - Thực hiện kiểm thử luồng đúng, luồng sai quyền, tấn công tái kích hoạt (reentrancy) và gian lận trùng mã băm.
  - Triển khai hợp đồng chính lên mạng Ethereum Sepolia; lưu trữ địa chỉ hợp đồng và transaction hash vào `evidence/`.
- **Lab 15**:
  - Hoàn thiện giao diện Web DApp `web/index.html` cho phép băm file SHA-256 ngay trên trình duyệt và xác thực trực tiếp với Sepolia testnet.
  - Kiểm thử toàn trình End-to-End từ giao diện người dùng.
  - Đóng gói tài liệu, hoàn thiện `README.md`, video demo và bằng chứng chạy thực tế trong `evidence/`.

---

## 4. Quản lý rủi ro dự án

| Rủi ro | Mức độ | Biện pháp phòng ngừa / Khắc phục |
| :--- | :---: | :--- |
| Hết Sepolia ETH thử nghiệm | Trung bình | Tích hợp vòi nhận Sepolia ETH định kỳ; tối ưu hóa gas limit của các hàm trong smart contract. |
| Người dùng tải file nhạy cảm lên mạng | Cao | Bắt buộc băm file trực tiếp tại máy người dùng (Client-side), không truyền nội dung tệp lên chuỗi hay server. |
| Xung đột mã nguồn khi làm việc nhóm | Thấp | Phân chia nhiệm vụ theo module rõ ràng, mỗi tính năng tạo nhánh riêng và tạo Pull Request có review trước khi merge vào `main`. |
| Phát sinh lỗ hổng bảo mật khi rút quỹ | Cao | Áp dụng `ReentrancyGuard`, kiểm tra quyền `onlyOwner`, tuân thủ Checks-Effects-Interactions. |
