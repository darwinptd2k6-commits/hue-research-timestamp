# QUY TẮC KINH TẾ VÀ QUẢN TRỊ (ECONOMIC RULES & GOVERNANCE)
## Dự án: Hue Research Timestamp (HRT)
**Chủ đề**: Dấu Thời Gian Ý Tưởng Nghiên Cứu trên Blockchain  
**Môn học**: ECO2432 - Web3 & Fintech  
**Đơn vị áp dụng**: Trường Đại học Kinh tế - Đại học Huế (HUE)  
**Phiên bản**: v1.1.0  

---

## 1. Bối cảnh và Bài toán Nghiên cứu

### 1.1. Vấn đề thực tiễn (Problem Statement)
- **Rủi ro mất và nhái ý tưởng**: Sinh viên, học viên cao học và nghiên cứu sinh thường xuyên đối mặt với nguy cơ bị đánh cắp, sao chép hoặc tranh chấp quyền ưu tiên ý tưởng khoa học trước khi công trình được xuất bản chính thức.
- **Hạn chế của phương pháp truyền thống**: Các phương pháp xác nhận mốc thời gian truyền thống (như gửi email cho chính mình, đóng dấu bưu điện, nộp lưu chiểu tập trung) tiềm ẩn rủi ro can thiệp sửa đổi dữ liệu (tampering), chỉnh sửa lùi ngày giờ (backdating) hoặc phụ thuộc vào bên thứ ba trung gian thiếu tính minh bạch khách quan.

### 1.2. Giải pháp cốt lõi: RecordRegistry (M.3)
- **Ghi nhận mốc thời gian bất biến**: Áp dụng mô hình Smart Contract **RecordRegistry (M.3)** để ghi nhận mã băm `bytes32` (Keccak256 / SHA-256) của tệp tài liệu nghiên cứu lên Blockchain tại mốc thời gian chính xác của khối (`block.timestamp`) — tạo bằng chứng thời gian bất biến, chống chối bỏ hoàn toàn (Proof of Existence & Non-repudiation).
- **Nguyên tắc kỹ thuật - kinh tế cốt lõi**:
  - **Băm phía máy khách (Client-side Hashing)**: Việc tạo Hash thực hiện 100% trên giao diện người dùng (Web Crypto API) trước khi gửi giao dịch.
  - **Chỉ lưu `bytes32` lên chuỗi**: Không tải tệp thô lên blockchain giúp bảo mật 100% nội dung gốc chưa công bố.
  - **Tối ưu chi phí Gas**: Giảm dung lượng lưu trữ on-chain xuống mức tối thiểu, chi phí giao dịch ước tính chỉ khoảng **~$0.012/giao dịch** khi triển khai trên Layer 2 (Arbitrum/Optimism/Base/Polygon) hoặc mạng thử nghiệm.

---

## 2. Mục tiêu Kinh tế học Web3 (Micro-economy Objectives)

Dự án thiết kế mô hình kinh tế vi mô nhằm đạt được 3 mục tiêu cốt lõi:
1. **Phòng chống tấn công làm nghẽn dữ liệu (Anti-Spam & Storage Cost)**: Phí đăng ký danh nghĩa ngăn chặn bot hoặc kẻ xấu spam hàng loạt bản ghi rác gây phình to trạng thái lưu trữ (state bloat) của hợp đồng.
2. **Tự chủ tài chính bền vững (Self-Sustaining Infrastructure)**: Nguồn thu từ phí được tích lũy để chi trả chi phí duy trì cổng lưu trữ IPFS Pinning (Pinata/Web3.Storage), duy trì RPC node và tên miền dịch vụ cho sinh viên nghiên cứu tại Trường Đại học Kinh tế - Đại học Huế.
3. **Tái đầu tư hỗ trợ nghiên cứu khoa học (Academic Incentive)**: Tích lũy quỹ để trao học bổng, tài trợ đề tài và khen thưởng các công trình nghiên cứu khoa học xuất sắc của sinh viên Trường Đại học Kinh tế - Đại học Huế.

---

## 3. Cơ cấu Phí Dịch vụ (Fee Structure)

| Loại thao tác | Mức phí quy định | Người chịu phí | Mục đích kinh tế |
| :--- | :---: | :---: | :--- |
| **Đăng ký đóng dấu (`registerDocument`)** | `0.001 ETH` (mặc định) | Tác giả công trình | Chi phí tạo bản ghi thời gian bất biến, chống spam và đóng góp quỹ NCKH. |
| **Tra cứu & Đối chiếu (`verifyDocument`)** | `0 ETH` (Miễn phí) | Cộng đồng / Độc giả | Khuyến khích kiểm tra chéo, thẩm định nguồn gốc và tăng tính minh bạch học thuật. |
| **Cập nhật siêu dữ liệu (`updateMetadata`)** | `0 ETH` (+ gas mạng) | Chủ sở hữu tài liệu | Cho phép bổ sung DOI, link bài báo sau khi nghiệm thu/xuất bản. |
| **Thu hồi chứng nhận (`revokeDocument`)** | `0 ETH` (+ gas mạng) | Quản trị viên (Hội đồng) | Biện pháp kỷ luật học thuật khi phát hiện vi phạm đạo văn hoặc gian lận. |

---

## 4. Phân bổ Doanh thu theo Điểm Cơ Bản (Basis Points - bps)

Tuân thủ quy ước chuẩn kinh tế Web3 tại `AGENTS.md`, toàn bộ tỷ lệ phân bổ doanh thu được quy đổi sang **Basis Points (bps)**:
$$\text{100 bps} = 1\%, \quad \text{10,000 bps} = 100\%$$

Tổng doanh thu từ phí đăng ký tích lũy trong kho bạc Smart Contract được phân bổ tự động theo cơ cấu:

```
+------------------------------------------------------------------------+
|                   TỔNG DOANH THU ĐĂNG KÝ (10,000 bps = 100%)           |
+------------------------------------+-------------------+---------------+
|   Quỹ NCKH Sinh viên Huế           | Hạ tầng IPFS/RPC  | Quỹ Dự phòng  |
|             70%                    |        20%        |      10%      |
|         (7,000 bps)                |    (2,000 bps)    |  (1,000 bps)  |
+------------------------------------+-------------------+---------------+
```

1. **Quỹ Hỗ trợ Nghiên cứu Khoa học Sinh viên Huế (7,000 bps - 70%)**:
   - Chuyển định kỳ về ví quỹ Nghiên cứu Khoa học Sinh viên tại Trường Đại học Kinh tế - Đại học Huế.
   - Tài trợ kinh phí triển khai đề tài, hỗ trợ lệ phí công bố bài báo quốc tế (Scopus/WoS) và cấp học bổng nghiên cứu.
2. **Quỹ Vận hành Hạ tầng & Lưu trữ Phân tán (2,000 bps - 20%)**:
   - Thanh toán chi phí hạ tầng Web3: Lưu trữ phi tập trung IPFS/Filecoin/Arweave cho metadata tóm tắt, duy trì Dedicated RPC Endpoint và tên miền hệ thống.
3. **Quỹ Dự phòng & Bảo mật Hợp đồng (1,000 bps - 10%)**:
   - Khoản dự phòng bảo trì, kiểm toán hợp đồng thông minh (Smart Contract Audit) và thích ứng với biến động phí mạng trong tương lai.

---

## 5. Cơ chế Quản trị Kho bạc và Rút quỹ (Treasury Governance)

1. **Phòng chống tấn công Reentrancy**: Hàm `withdrawFees` bắt buộc áp dụng modifier `nonReentrant` của OpenZeppelin v5 để triệt tiêu hoàn toàn rủi ro tấn công đệ quy rút cạn số dư.
2. **Tuân thủ chặt chẽ mô hình Checks - Effects - Interactions (CEI)**:
   - **Check**: Xác thực người gọi có quyền quản trị (`onlyOwner`), số dư kho bạc $> 0$, địa chỉ nhận hợp lệ khác `address(0)`.
   - **Effect**: Đặt lại số dư và phát sự kiện `FundsWithdrawn` trước khi chuyển tiền.
   - **Interaction**: Chuyển ETH an toàn bằng lệnh cấp thấp `(bool success, ) = recipient.call{value: amount}("")` và kiểm tra lỗi tùy biến `if (!success) revert WithdrawFailed();`.
3. **Minh bạch On-chain**: Mọi giao dịch rút quỹ đều được ghi lại qua Event `FundsWithdrawn(address indexed recipient, uint256 amount)` cho phép toàn thể giảng viên, sinh viên giám sát trực tiếp qua Blockchain Explorer.

---

## 6. Chính sách Khuyến khích và Chế tài Học thuật

### 6.1. Cơ chế Khuyến khích (Incentives)
- **Tối ưu chi phí nghiên cứu**: Nghiên cứu sinh chỉ tốn chi phí cực nhỏ (~$0.012 trên L2) để sở hữu chứng thư ưu tiên ý tưởng độc quyền toàn cầu.
- **Khả năng liên kết điểm thưởng học thuật**: Dự kiến kết nối với hệ thống tích lũy tín nhiệm học thuật / token điểm rèn luyện sinh viên để miễn/giảm phí dịch vụ cho các tác giả có thành tích xuất sắc.

### 6.2. Cơ chế Răn đe và Chế tài (Penalties & Disincentives)
- **Phí không hoàn lại (Non-refundable)**: Phí đăng ký một khi đã nạp vào chuỗi sẽ không được hoàn trả dưới bất kỳ hình thức nào nhằm răn đe hành vi đăng ký cẩu thả hoặc spam.
- **Lưu vết vi phạm vĩnh viễn (On-chain Blacklist)**: Trường hợp công trình bị Hội đồng thẩm định kết luận vi phạm đạo văn hoặc đạo nhái số liệu, trạng thái `isRevoked = true` kèm nguyên nhân thu hồi sẽ được khắc vĩnh viễn trên blockchain, tạo rào cản ngăn ngừa triệt để các hành vi gian lận học thuật.
