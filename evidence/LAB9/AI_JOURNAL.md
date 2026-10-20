# NHẬT KÝ LÀM VIỆC VỚI AI - LAB 9: XÂY DỰNG HỢP ĐỒNG PROJECTCORE (RECORDREGISTRY)

## Lần 1: Viết Smart Contract ProjectCore.sol cho đề tài Dấu thời gian ý tưởng nghiên cứu

**Thời gian:** 04/10/2026  
**Người thực hiện:** Nhóm sinh viên ECO2432 - Hue Research Timestamp  

**Prompt:**
> "Bạn là lập trình viên Smart Contract chuyên nghiệp tuân thủ quy chuẩn môn học ECO2432. Đọc tệp docs/SPEC.md và quy ước trong AGENTS.md của dự án.
> Hãy viết hợp đồng Solidity cho file contracts/project/ProjectCore.sol phục vụ đề tài 'Dấu thời gian ý tưởng nghiên cứu' dựa trên mẫu RecordRegistry.sol với các yêu cầu bắt buộc:
> Dùng pragma solidity ^0.8.20;
> Chỉ lưu trữ mã băm 32 bytes (bytes32 docHash), địa chỉ tác giả (subject), địa chỉ người phát hành (issuer), mốc thời gian (uint256 timestamp), mô tả ngắn (string metadata) và trạng thái thu hồi (bool revoked). Tuyệt đối KHÔNG lưu nội dung tệp thô. 
> Định nghĩa các error tùy biến có tên: AlreadyExists(), NotIssuer(), NotFound() thay cho chuỗi require dài.
> Phát ra các event có indexed khi tạo bản ghi (RecordCreated) và thu hồi bản ghi (RecordRevoked).
> Hàm verify(bytes32 docHash) là hàm view công khai, trả về trạng thái tồn tại và tính hợp lệ.
> Giải thích ngắn gọn lựa chọn thiết kế trước khi đưa mã nguồn.

**AI trả về:**
- Giải thích lựa chọn thiết kế: Mô hình lưu trữ Proof of Existence (M.3) chỉ lưu `bytes32 docHash` và siêu dữ liệu, không lưu trữ tệp thô; phân quyền `issuer` và `subject`; tối ưu gas bằng custom errors; tuân thủ Checks-Effects-Interactions (CEI) và không dùng `tx.origin`.
- Mã nguồn đầy đủ của hợp đồng `contracts/project/ProjectCore.sol` chuẩn Solidity `^0.8.20`, struct `Record` gồm 6 trường, 3 custom errors `AlreadyExists()`, `NotIssuer()`, `NotFound()`, 2 events `RecordCreated` và `RecordRevoked`, cùng các hàm `createRecord`, `revokeRecord`, `verify`, `getRecord`.
- Cung cấp tối thiểu 3 trường hợp kiểm thử (Happy path, Edge case/Unauthorized, Malicious/Collision).

**Đánh giá:** Dùng được.

**Chỗ sai:**
- Không có lỗi cú pháp hoặc vi phạm logic nghiệp vụ. Hợp đồng tuân thủ tuyệt đối quy chuẩn `AGENTS.md` và `docs/SPEC.md`.

**Cách sửa:**
- Sinh viên lưu mã nguồn vào `contracts/project/ProjectCore.sol`, thực hiện rà soát các hàm `verify`, `createRecord`, `revokeRecord` và ghi nhận nhật ký vào `evidence/LAB9/AI_JOURNAL.md`.

**Ai phát hiện:** Sinh viên và AI cùng đối chiếu kiểm tra.

---

## Lần 2: Rà soát kiểm toán bảo mật và tối ưu hóa Gas (Storage Slot Packing)

**Thời gian:** 04/10/2026  
**Người thực hiện:** Nhóm sinh viên ECO2432 - Hue Research Timestamp  

**Prompt:**
> "ãy rà soát lại đoạn mã ProjectCore.sol bạn vừa viết dưới vai trò một kiểm toán viên
> . Kiểm tra cụ thể:
> Thứ tự trong các hàm có tuân thủ quy tắc Checks - Effects - Interactions không?
> Biến docHash đã kiểm tra tránh ghi đè nếu mã băm đã tồn tại chưa (AlreadyExists)?
> Có dùng hàm hoặc cú pháp cũ đã bị bỏ không?
> Hàm verify có đảm bảo là view để người dùng tra cứu miễn phí gas không?
> Nếu phát hiện điểm chưa tối ưu, hãy đưa ra bản mã đã sửa hoàn chỉnh.

**AI trả về:**
- Báo cáo kết quả kiểm toán 4 tiêu chí:
  1. CEI: Cả `createRecord` và `revokeRecord` đều tuân thủ nghiêm ngặt Checks -> Effects -> Interactions (Logs).
  2. Chống ghi đè: Kiểm tra `_records[docHash].timestamp != 0` với error `AlreadyExists()`.
  3. Cú pháp: Chuẩn Solidity `^0.8.20`, dùng `msg.sender`, `calldata` và Custom Errors, loại bỏ toàn bộ chuỗi require và `tx.origin`.
  4. Tra cứu miễn phí: `verify` và `getRecord` là hàm `view`, không tốn gas khi tra cứu off-chain qua RPC.
- Phát hiện và triển khai tối ưu hóa **Storage Slot Packing**: Đặt `address subject` (20 bytes) đứng liền kề `bool revoked` (1 byte) để gộp chung vào Slot số 2 (21/32 bytes), giúp tiết kiệm ~20,000 gas SSTORE cho mỗi giao dịch `createRecord`.
- Cập nhật mã nguồn hoàn chỉnh có chú thích kiểm toán cho [`contracts/project/ProjectCore.sol`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/contracts/project/ProjectCore.sol).

**Đánh giá:** Dùng được ngay, nâng cao hiệu quả tiết kiệm gas và độ an toàn của hợp đồng.

**Chỗ sai / Điểm chưa tối ưu ban đầu:**
- Thứ tự khai báo các biến trong struct `Record` ban đầu chưa tận dụng đóng gói slot của EVM, làm tiêu tốn thêm 1 slot bộ nhớ storage (32 bytes).

**Cách sửa:**
- Tái cấu trúc thứ tự trường trong `struct Record`: di chuyển `bool revoked` đứng cạnh `address subject` để EVM pack chung vào 1 slot.

**Ai phát hiện:** AI kiểm toán chủ động đề xuất giải pháp tối ưu slot sau khi nhận yêu cầu rà soát từ sinh viên.
