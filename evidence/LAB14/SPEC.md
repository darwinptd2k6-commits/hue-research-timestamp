# SPEC — LAB 14: RÀ SOÁT CHÉO GIỮA CÁC NHÓM (CROSS-AUDIT SPECIFICATION)

## Dự án: Hue Research Timestamp (HRT)
**Học phần:** Tiền điện tử & Hợp đồng thông minh (ECO2432) — Trường Đại học Kinh tế, Đại học Huế  
**Nhóm sinh viên thực hiện:**
- Phan Thành Đạt (MSSV: 24K430002) — Project Lead & Smart Contract Engineer
- Nguyễn Hữu Bằng (MSSV: 24K4070016) — Web3 Frontend Dev & Tokenomics Lead  

---

## 1. Mục đích
Thiết lập quy trình và tiêu chí thẩm định chất lượng an toàn mã nguồn Smart Contract thông qua cơ chế rà soát chéo vòng tròn giữa các nhóm sinh viên (Peer Review / Cross-Audit), áp dụng đầy đủ danh mục kiểm tra 10 hạng mục bắt buộc của Sổ tay thực hành ECO2432 nhằm phát hiện, báo cáo và khắc phục triệt để các lỗ hổng trước khi triển khai chính thức lên mạng thử nghiệm Sepolia.

---

## 2. Đầu vào
- **Mã nguồn và tài liệu của Nhóm 8 bàn giao**:
  - Hợp đồng `contracts/training/PeerCertificateRegistry.sol` (Hệ thống xác thực chứng nhận khóa học theo mẫu M.3).
  - Bản đặc tả yêu cầu và quy tắc kinh tế của Nhóm 8.
- **Mã nguồn và tài liệu của Nhóm 9 (HRT) đưa ra thẩm định**:
  - Hợp đồng chính [`contracts/project/ProjectCore.sol`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/contracts/project/ProjectCore.sol) (425 dòng, Solidity ^0.8.20, OpenZeppelin v5).
  - Bản đặc tả [`docs/SPEC.md`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/docs/SPEC.md) và mô hình kinh tế [`docs/ECONOMIC_RULES.md`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/docs/ECONOMIC_RULES.md).
- **Danh mục 10 hạng mục kiểm tra bắt buộc** (Trang 32 Sổ tay thực hành).

---

## 3. Quy tắc nghiệp vụ (Audit Checklist Rules)

- **R1 (Kiểm soát phân quyền - Access Control)**: Mọi hàm thay đổi trạng thái có tính chất nhạy cảm hoặc quản trị tài sản (`revokeDocument`, `setRegistrationFee`, `withdrawFees`) bắt buộc phải có modifier kiểm tra quyền hạn (`onlyOwner`). Hàm cập nhật siêu dữ liệu `updateMetadata` bắt buộc chỉ cho phép chính tác giả sở hữu (`doc.owner == msg.sender`) thực hiện.
- **R2 (Mô hình CEI & Chống Reentrancy)**: Mọi hàm rút hoặc luân chuyển ETH ra khỏi hợp đồng phải tuân thủ nghiêm ngặt mô hình Checks-Effects-Interactions (kiểm tra điều kiện $\rightarrow$ cập nhật trạng thái/phát event $\rightarrow$ chuyển tiền sau cùng), kết hợp khóa `nonReentrant` của OpenZeppelin.
- **R3 (Tính bất biến của Dấu thời gian)**: Mốc thời gian ghi nhận bản ghi `block.timestamp` được thiết lập duy nhất một lần tại thời điểm đăng ký hợp lệ, tuyệt đối không có hàm nào được phép chỉnh sửa hoặc ghi đè mốc thời gian này.
- **R4 (Cách chuyển ETH an toàn)**: Tuyệt đối không dùng `.transfer()` hoặc `.send()` (giới hạn cứng 2.300 gas); bắt buộc sử dụng cú pháp cấp thấp `.call{value: amount}("")` kết hợp kiểm tra `success` và custom error `WithdrawFailed()`.
- **R5 (Bảo vệ tính riêng tư dữ liệu)**: Chỉ lưu trữ mã băm SHA-256 (32 bytes) và liên kết metadata URI trên chuỗi; tuyệt đối không lưu nội dung tệp thô hoặc thông tin định danh cá nhân nhạy cảm lên blockchain.
- **R6 (Kiểm soát tài nguyên vòng lặp)**: Không sử dụng vòng lặp `for`/`while` duyệt trên mảng động không có giới hạn phần tử để triệt tiêu nguy cơ nghẽn mạng do vượt trần Gas Limit (Out-of-Gas DoS).
- **R7 (Minh bạch sự kiện - Event Auditability)**: Mọi thay đổi trạng thái đều phải phát `event` tương ứng có chỉ mục `indexed` cho các trường tìm kiếm chính (`documentHash`, `owner`, `authority`, `recipient`).
- **R8 (Xử lý tiền nạp thừa - Excess ETH Refund)**: Khi người dùng gửi số tiền `msg.value > registrationFee`, hợp đồng chỉ thu đúng mức phí quy định và phải tự động hoàn trả phần tiền dư an toàn cho người gửi.
- **R9 (Giới hạn trần mức phí dịch vụ - Fee Ceiling)**: Mức phí đăng ký không được vượt quá trần quy định `MAX_REGISTRATION_FEE = 0.05 ether` nhằm ngăn chặn rủi ro DoS kinh tế khi tài khoản quản trị viên gặp sự cố.
- **R10 (Kiểm tra địa chỉ rỗng)**: Mọi tham số địa chỉ ví nhận tiền hoặc người thụ hưởng bắt buộc phải khác `address(0)`.

---

## 4. Đầu ra
- Báo cáo kiểm toán chéo [`docs/AUDIT_REPORT.md`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/docs/AUDIT_REPORT.md) ghi nhận đầy đủ các phát hiện, mức độ rủi ro, số dòng mã vi phạm và phản hồi khắc phục của Nhóm 9.
- Báo cáo kiểm toán của Nhóm 9 dành cho Nhóm bạn [`evidence/lab-14/AUDIT_REPORT_FOR_PEER.md`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/evidence/lab-14/AUDIT_REPORT_FOR_PEER.md).
- Mã nguồn hợp đồng chính [`contracts/project/ProjectCore.sol`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/contracts/project/ProjectCore.sol) được vá và kiểm chứng thành công.
- Bộ kiểm thử tự động [`test/Lab14_CrossAudit.test.js`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/test/Lab14_CrossAudit.test.js) đạt tỷ lệ vượt qua `12/12 PASS (100%)`.

---

## 5. Trường hợp ngoại lệ (Negative Cases & Boundary Checks)
- **TH1 (Kẻ xấu cố tình đổi mức phí quá cao)**: Nếu Quản trị viên (hoặc kẻ tấn công chiếm quyền) gọi `setRegistrationFee` với mức phí lớn hơn `0.05 ether`, giao dịch phải bị từ chối với lỗi `FeeExceedsLimit(newFee, MAX_REGISTRATION_FEE)`.
- **TH2 (Người dùng chuyển thừa tiền phí)**: Nếu người đăng ký gửi `msg.value = 0.005 ETH` trong khi phí chỉ là `0.001 ETH`, hệ thống phải thu đúng `0.001 ETH` và hoàn trả tức thì `0.004 ETH` về ví người dùng mà không làm hỏng giao dịch.
- **TH3 (Rút tiền về ví hố đen `address(0)`)**: Nếu gọi `withdrawFees(address(0))`, hệ thống phải từ chối ngay với lỗi `InvalidRecipient()`.
- **TH4 (Người lạ thu hồi chứng nhận nghiên cứu)**: Nếu tài khoản không phải `owner()` gọi `revokeDocument`, giao dịch phải revert với `OwnableUnauthorizedAccount`.

---

## 6. Ngoài phạm vi
- Không thực hiện kiểm toán formal verification toán học chuyên sâu bằng công toán học hình thức (Certora/Halmos) trong phạm vi môn học sinh viên Kinh tế.
- Không can thiệp vào các hợp đồng bên thứ ba ngoài phạm vi hai nhóm được phân công rà soát.
