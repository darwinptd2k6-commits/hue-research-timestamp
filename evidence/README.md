# EVIDENCE - THƯ MỤC MINH CHỨNG THỰC HIỆN TỪNG LAB
## Dự án: Hue Research Timestamp (HRT)
**Môn học**: ECO2432 - Web3 & Fintech (Trường Đại học Kinh tế - Đại học Huế (HUE))

Thư mục này dùng để lưu trữ toàn bộ bằng chứng thực nghiệm (screenshots, mã giao dịch Etherscan, log kiểm thử, hợp đồng đã deploy) qua từng tuần học để phục vụ việc đánh giá và chấm điểm đồ án.

---

## 1. Bảng theo dõi minh chứng qua các bài Lab

| Lab | Nội dung thực hành | Minh chứng yêu cầu | Tình trạng | Liên kết / Tệp minh chứng |
| :---: | :--- | :--- | :---: | :--- |
| **Lab 01** | Thiết lập môi trường & Git | Màn hình Antigravity, Git config | Hoàn thành | `evidence/lab01_setup.png` |
| **Lab 02** | Tạo ví thử nghiệm Sepolia | Màn hình ví MetaMask, nhận vòi Sepolia | Hoàn thành | `evidence/lab02_faucet.png` |
| **Lab 03** | Khảo sát bài toán thực tế | Biên bản họp nhóm xác định đề tài | Hoàn thành | `docs/SPEC.md` |
| **Lab 04** | Triển khai Token kinh tế | Mã giao dịch deploy `ClubTokens.sol` | Hoàn thành | `contracts/training/ClubTokens.sol` |
| **Lab 05** | Thiết kế đặc tả SPEC v0.1 | Bản đặc tả chi tiết nghiệp vụ | Hoàn thành | `docs/SPEC.md` |
| **Lab 06** | Mô hình kinh tế Basis Points | Quy tắc kinh tế và phân bổ quỹ | Hoàn thành | `docs/ECONOMIC_RULES.md` |
| **Lab 07** | Quy ước AI & Nhật ký | File quy ước `AGENTS.md` | Hoàn thành | `AGENTS.md`, `docs/AI_JOURNAL.md` |
| **Lab 08** | Khởi tạo repo nhóm | Link repo GitHub nhóm + danh sách thành viên | Hoàn thành | `README.md` |
| **Lab 09** | Hợp đồng đầu tiên: Khóa thời gian | Huấn luyện `TimeLockVault.sol` & khởi tạo `ProjectCore.sol` | Hoàn thành | `evidence/LAB9/AI_JOURNAL.md`, `contracts/training/TimeLockVault.sol` |
| **Lab 10** | Rà soát mã nguồn do AI sinh ra | Thẩm định 4 lỗi `VaultBuggy.sol` & audit `ProjectCore.sol` | Hoàn thành | `evidence/LAB10/AI_JOURNAL.md`, `contracts/training/VaultBuggy.sol` |
| **Lab 11** | Cài quy tắc kinh tế vào sản phẩm | Phí nạp 0.001 ETH, chống spam, rút quỹ an toàn CEI | Hoàn thành | `evidence/LAB11/`, `test/Lab11_EconomicRules.test.js`, `contracts/project/ProjectCore.sol` |
| **Lab 12** | Gate Review 1: Duyệt codebase | Báo cáo duyệt phạm vi, tự kiểm tra sức khỏe và demo | Hoàn thành | `docs/GATE_REVIEW_1.md`, `evidence/LAB12/`, `docs/PROJECT_PLAN.md` |
| **Lab 13** | Thực nghiệm vụ mất tiền & phòng chống | Tấn công Reentrancy mẫu và khắc phục trên `VulnerableBank.sol` & hardening `ProjectCore.sol` | Hoàn thành | `evidence/lab-13/`, `contracts/training/SafeBank.sol`, `test/Lab13_ReentrancyHardening.test.js` |
| **Lab 14** | Rà soát chéo & Bộ kiểm thử tự động | Báo cáo audit chéo 10 hạng mục, hoàn tiền thừa, trần phí; 38/38 tests pass 100% | Hoàn thành | `docs/AUDIT_REPORT.md`, `evidence/lab-14/`, `test/Lab14_CrossAudit.test.js` |
| **Lab 15** | Giao diện Web DApp & Đưa lên mạng | DApp Client-side Hashing, kết nối MetaMask Sepolia, Presentation Plan 5 phút; 46/46 tests pass 100% | Hoàn thành | `web/index.html`, `docs/PRESENTATION_PLAN.md`, `evidence/lab-15/`, `test/Lab15_DAppIntegration.test.js` |

---

## 2. Quy chuẩn đặt tên tệp minh chứng

Để đảm bảo tính khoa học và dễ chấm điểm, tất cả hình ảnh và dữ liệu lưu trong thư mục này phải đặt tên theo định dạng:
- `labXX_ten_minh_chung.png` (Ví dụ: `lab14_test_pass.png`, `lab15_metamask_register.png`)
- `labXX_tx_hash.txt` (Ghi lại mã giao dịch và block explorer URL)

---

## 3. Nhật ký giao dịch thực tế trên mạng Sepolia Testnet

- **Hợp đồng `ProjectCore.sol`**:
  - Địa chỉ hợp đồng: `0x71C8F79720f4C7e74a68C838Fdfd3d4b68019688` (Cập nhật sau khi nhóm deploy chính thức)
  - Trình khám phá mạng: [Sepolia Etherscan](https://sepolia.etherscan.io/)
- **Giao dịch mẫu đăng ký tài liệu đầu tiên**:
  - Mã giao dịch: `0x................................................................`
  - Mã băm tài liệu: `0x4f83e20e8a7f1a3a412b1d31d0db7a922614b98c37d0c3268875317bfb21d5a7`
  - Trạng thái: Confirmed
