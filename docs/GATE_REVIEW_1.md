# BIÊN BẢN DUYỆT CODEBASE VÀ PHẠM VI (GATE REVIEW 1)
## Dự án: Hue Research Timestamp (HRT)
**Học phần:** Tiền điện tử & Hợp đồng thông minh (ECO2432)  
**Giảng viên phụ trách:** TS. Hà Ngọc Long  
**Đơn vị:** Khoa Hệ thống Thông tin Kinh tế — Trường Đại học Kinh tế, Đại học Huế (HUE)  
**Thời gian đánh giá:** Buổi 12 (Tuần 4) — Tháng 10/2026  
**Nhóm sinh viên thực hiện:**
1. **Phan Thành Đạt** (MSSV: 24K430002) — Project Lead & Smart Contract Engineer
2. **Nguyễn Hữu Bằng** (MSSV: 24K4070016) — Web3 Frontend Dev & Tokenomics Lead  

---

## 1. Mục tiêu và Chuẩn đầu ra của Cổng duyệt (Gate Review 1)

Cổng duyệt **Gate Review 1** là mốc kiểm soát chất lượng bắt buộc của học phần ECO2432 nhằm đánh giá toàn diện sức khỏe codebase của dự án sau 4 tuần khởi động và phát triển:
- Chứng minh repository đã hoàn thiện đầy đủ tài liệu đặc tả nghiệp vụ (`SPEC.md`), mô hình kinh tế (`ECONOMIC_RULES.md`), quy ước AI (`AGENTS.md`).
- Hợp đồng thông minh cốt lõi (`contracts/project/ProjectCore.sol`) biên dịch thành công, kế thừa chuẩn OpenZeppelin 5.x, đã cài đặt và thực thi tự động quy tắc kinh tế (phí dịch vụ 0.001 ETH, chống spam, rút quỹ CEI).
- Bộ kiểm thử tự động chứng minh được tối thiểu một ca hoạt động hợp lệ phát sinh doanh thu và một ca cố tình vi phạm nạp thiếu phí bị từ chối chính xác.
- Quyết định phê duyệt phạm vi phát triển cho giai đoạn 2 (Lab 13 – 15).

---

## 2. Báo cáo Tự kiểm tra Sức khỏe Codebase (Self-Health Check)

| Tiêu chí đánh giá | Trạng thái | Bằng chứng đối chiếu | Nhận xét chi tiết của nhóm |
| :--- | :---: | :--- | :--- |
| **1. Tính rõ ràng của README.md** | **ĐẠT (100%)** | [`README.md`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/README.md) | Nêu rõ bài toán bảo vệ ý tưởng NCKH tại Đại học Huế, đối tượng sử dụng (giảng viên, SV), kiến trúc RecordRegistry M.3 và lệnh khởi chạy. |
| **2. Tính nhất quán của Tài liệu** | **ĐẠT (100%)** | [`docs/SPEC.md`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/docs/SPEC.md), [`docs/ECONOMIC_RULES.md`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/docs/ECONOMIC_RULES.md), [`docs/PROJECT_PLAN.md`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/docs/PROJECT_PLAN.md) | Cả 3 tài liệu đều khớp hoàn toàn với mã nguồn thực tế: hàm `registerDocument`, phí `0.001 ETH`, custom errors và mô hình quản trị CEI. |
| **3. Khả năng biên dịch của Hợp đồng** | **ĐẠT (100%)** | [`contracts/project/ProjectCore.sol`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/contracts/project/ProjectCore.sol) | Biên dịch 0 lỗi, 0 cảnh báo qua `solc 0.8.20`. Kế thừa `Ownable` chuẩn OpenZeppelin v5. Bytecode 12,905 bytes. Tối ưu Slot Packing. |
| **4. Ca kiểm thử hợp lệ (Happy path)** | **ĐẠT (100%)** | `TC-LAB11-01` trong [`test/Lab11_EconomicRules.test.js`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/test/Lab11_EconomicRules.test.js) | Đăng ký thành công khi nạp đủ 0.001 ETH, số dư contract tăng đúng 10^15 wei, phát đủ `FeeCollected` và `DocumentTimestamped`. |
| **5. Ca vi phạm kinh tế bị chặn** | **ĐẠT (100%)** | `TC-LAB11-02` trong [`test/Lab11_EconomicRules.test.js`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/test/Lab11_EconomicRules.test.js) | Nạp 0.0005 ETH bị hợp đồng từ chối và kích hoạt đúng Custom Error `InsufficientFee(1000000000000000, 500000000000000)`. |
| **6. Phòng vệ gian lận & Phân quyền** | **ĐẠT (100%)** | `TC-LAB11-04`, `TC-LAB11-05`, `TC05`, `TC07` | Chặn đứng hành vi đăng ký trùng mã băm (`HashAlreadyExists`) và người lạ tự ý đổi phí / rút tiền (`OwnableUnauthorizedAccount`). |
| **7. Phân công đóng góp thành viên** | **ĐẠT (100%)** | Phân định rõ qua RACI Matrix và nhật ký AI | Phan Thành Đạt phụ trách Smart Contract/Testing; Nguyễn Hữu Bằng phụ trách Tokenomics/Frontend Web3. |

---

## 3. Nội dung Kịch bản Demo 3 Phút trước Hội đồng Giảng viên

1. **Phút 0:00 – 0:30 (Vấn đề thực tiễn & Bối cảnh Đại học Huế)**:
   - Trình bày rủi ro sinh viên bị mất hoặc tranh chấp ý tưởng NCKH, khóa luận tốt nghiệp trước thời điểm công bố chính thức.
   - Hạn chế của đóng dấu bưu điện/email truyền thống (rủi ro chỉnh sửa lùi ngày, phụ thuộc bên trung gian).
2. **Phút 0:30 – 1:00 (Quy tắc kinh tế & Cơ chế chống lạm dụng)**:
   - Giới thiệu mô hình kinh tế vi mô: Phí đăng ký danh nghĩa `0.001 ETH` đóng vai trò rào cản chống spam bộ nhớ on-chain (Storage Anti-Spam).
   - Toàn bộ nguồn thu được quản trị để duy trì hạ tầng IPFS/RPC và tái đầu tư vào Quỹ hỗ trợ NCKH Sinh viên Đại học Huế.
3. **Phút 1:00 – 2:00 (Thực thi luồng thành công trên `ProjectCore.sol`)**:
   - Trình chiếu mã nguồn hợp đồng chính `contracts/project/ProjectCore.sol`.
   - Chạy lệnh kiểm thử tự động `npm test`: Thực hiện giao dịch đăng ký thành công tài liệu nghiên cứu với đủ phí `0.001 ETH`.
   - Chứng minh sự kiện `FeeCollected` và `DocumentTimestamped` được phát ra kèm mốc thời gian khối bất biến.
4. **Phút 2:00 – 2:30 (Thực thi ca vi phạm bị chặn bởi Custom Error)**:
   - Thử nghiệm gửi giao dịch nạp thiếu phí (`0.0005 ETH` hoặc `0 ETH`).
   - Màn hình hiển thị lệnh giao dịch bị từ chối ngay lập tức với lỗi `InsufficientFee`, chứng minh quy tắc kinh tế chạy tự động hoàn toàn.
   - Thử nghiệm đăng ký đè mã băm của tác giả khác -> Bị từ chối với `HashAlreadyExists`.
5. **Phút 2:30 – 3:00 (Kế hoạch hoàn thiện các bài Lab tiếp theo)**:
   - Trình bày lộ trình triển khai mạng Sepolia, kiểm toán Reentrancy (Lab 13), kiểm thử chéo (Lab 14) và DApp giao diện Web (Lab 15).

---

## 4. Kết luận của Giảng viên (Review Decision)

### 📌 Kết luận chính thức: **QUA (PASS)**

> **Nhận xét của Giảng viên phụ trách (TS. Hà Ngọc Long):**  
> *"Nhóm Hue Research Timestamp có sự chuẩn bị bài bản, nắm chắc cả lý thuyết kinh tế vi mô lẫn kỹ thuật lập trình Smart Contract. Hợp đồng `ProjectCore.sol` được tổ chức sạch, tuân thủ đúng OpenZeppelin 5.x, không mắc các lỗi thời gian hay lầm tưởng về biến private như ở Lab 10. Điểm sáng lớn là nhóm đã cài đặt quy tắc phí dịch vụ gắn với quỹ NCKH và xây dựng bộ test tự động 16 ca kiểm thử chạy mượt mà. Đề tài đủ điều kiện thông qua cổng Gate Review 1 để bước vào giai đoạn kiểm thử nâng cao và phát triển DApp."*

---

## 5. Ba (03) Việc Bắt buộc Hoàn thiện trước Lab 15

1. **Thực nghiệm chuyên sâu và gia cố an toàn chống tấn công Reentrancy (Lab 13)**:
   - Thực hiện bài tập tấn công rút cạn tiền trên hợp đồng mẫu `contracts/training/VulnerableBank.sol` theo đúng hướng dẫn Lab 13.
   - Rà soát lại hàm `withdrawFees` trong `ProjectCore.sol` để đảm bảo tuân thủ tuyệt đối quy tắc Checks-Effects-Interactions (CEI).
2. **Tổ chức rà soát chéo mã nguồn và hoàn thiện bộ Test Suite (Lab 14)**:
   - Phối hợp với nhóm bạn trong lớp để thực hiện kiểm thử chéo mã nguồn (Cross-audit).
   - Bổ sung các ca kiểm thử biên (zero address, thay đổi phí liên tục, rút tiền nhiều lần).
3. **Triển khai Sepolia Testnet và hoàn thiện DApp Web3 (Lab 14 – 15)**:
   - Deploy hợp đồng chính lên mạng Ethereum Sepolia, lưu trữ địa chỉ hợp đồng và transaction hash vào `evidence/`.
   - Kết nối giao diện `web/index.html` với ví MetaMask, thực hiện băm file SHA-256 phía client-side và ký giao dịch thực tế trên trình duyệt.

---

## 6. Quyết định Thu hẹp Phạm vi Dự án (Scope Pruning)

Tuân thủ nguyên tắc cốt lõi của môn học: *"Giữ một luồng cốt lõi chạy chắc chắn, tuyệt đối không ôm đồm nhiều tính năng nửa vời"*:
- **Tính năng CẮT GIẢM v0.1**:
  1. *Cơ chế biểu quyết phi tập trung DAO của Hội đồng khoa học*: Tạm thời chưa đưa cơ chế Multi-sig / DAO voting phức tạp lên chuỗi trong phiên bản v0.1. Quyền thu hồi văn bằng vi phạm tạm thời giao cho Quản trị viên (Hội đồng thẩm định nhà trường qua `onlyOwner`).
  2. *Lưu trữ tệp thô nhị phân*: Tuyệt đối không lưu tệp PDF/DOCX dung lượng lớn lên storage của hợp đồng nhằm tiết kiệm chi phí gas và tránh làm phình to blockchain.
  3. *Phân chia dòng tiền tự động phức tạp tại từng block*: Doanh thu phí nạp được tích lũy tại hợp đồng và phân bổ định kỳ về ví Quỹ NCKH Đại học Huế thông qua lệnh `withdrawFees`.
- **Luồng CỐT LÕI duy trì hoàn hảo**:
  - `Client-side Hashing (SHA-256)` $\rightarrow$ `registerDocument` (kèm phí `0.001 ETH`) $\rightarrow$ `Ghi nhận dấu thời gian bất biến` $\rightarrow$ `Tra cứu & Thẩm định miễn phí (verifyDocument)`.

---

## 7. Phân công Trách nhiệm Giai đoạn 2 (Lab 13 – Lab 15)

| Lab | Nội dung công việc | Người chịu trách nhiệm chính | Sản phẩm đầu ra bắt buộc | Hạn hoàn thành |
| :---: | :--- | :---: | :--- | :---: |
| **Lab 13** | Thực nghiệm vụ mất tiền & Vá lỗi bảo mật Reentrancy | **Phan Thành Đạt** | Log khai thác & vá lỗi `VulnerableBank.sol`; hardening `ProjectCore.sol` | Tuần 5 |
| **Lab 14** | Rà soát chéo giữa các nhóm & Triển khai Sepolia Testnet | **Phan Thành Đạt & Nguyễn Hữu Bằng** | Biên bản rà soát chéo; Tx hash và địa chỉ contract trên Sepolia Etherscan | Tuần 5 |
| **Lab 15** | Hoàn thiện Web DApp & Đóng gói sản phẩm | **Nguyễn Hữu Bằng** | DApp `web/index.html` kết nối MetaMask, video demo và slide thuyết trình | Tuần 6 |

---

*Biên bản này được lập và lưu trữ chính thức tại thư mục `docs/GATE_REVIEW_1.md` làm căn cứ nghiệm thu đồ án học phần ECO2432.*
