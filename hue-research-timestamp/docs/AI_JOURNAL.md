# NHẬT KÝ LÀM VIỆC VỚI AI (AI JOURNAL) - HUE RESEARCH TIMESTAMP

Tài liệu này ghi lại toàn bộ các câu lệnh (prompts), phản hồi của AI, đánh giá chất lượng, các lỗi phát hiện và cách khắc phục trong quá trình thực hiện dự án môn học ECO2432.

---

## Lần 1: Khởi tạo cấu trúc repository nhóm từ repo mẫu `hce-web3-starter`

**Thời gian:** Học kỳ 1, Năm học 2026 - 2027  
**Người thực hiện:** Nhóm sinh viên ECO2432 - Hue Research Timestamp  

**Prompt:**
> "Từ mã nguồn repo mẫu "hce-web3-starter" hãy tạo thêm cho tôi một repo mới mang tên "hue-research-timestamp" theo cấu trúc như sau:
> hue-research-timestamp/
> ├── README.md                 # Giới thiệu sản phẩm và đường dẫn chạy thật
> ├── AGENTS.md                 # Quy ước cho công cụ AI (dùng chung cả học kỳ)
> ├── docs/
> │   ├── PROJECT_PLAN.md       # Kế hoạch, vai trò, mốc công việc
> │   ├── SPEC.md               # Đặc tả nghiệp vụ v0.1
> │   ├── ECONOMIC_RULES.md     # Quy tắc kinh tế và quản trị
> │   └── AI_JOURNAL.md         # Nhật ký prompt và sửa lỗi
> ├── contracts/
> │   ├── training/             # Bài mẫu học kỹ thuật
> │   └── project/              # Mã nguồn hợp đồng chính của nhóm (ProjectCore.sol)
> ├── test/                     # Ca kiểm thử
> ├── web/                      # Giao diện sản phẩm (index.html)
> └── evidence/                 # Bằng chứng chạy thực tế từng lab"

**AI trả về:**
- Giải nén mã nguồn starter `hce-web3-starter.zip`.
- Thiết lập đầy đủ cấu trúc thư mục nhóm độc lập `hue-research-timestamp`.
- Kế thừa toàn bộ bài học kỹ thuật trong `contracts/training/` (`ClassPoint`, `TimeLockVault`, `VaultBuggy`, `VulnerableBank`, `ClubTokens`).
- Xây dựng bản đặc tả nghiệp vụ `docs/SPEC.md` v0.1, kế hoạch dự án `docs/PROJECT_PLAN.md`, mô hình kinh tế `docs/ECONOMIC_RULES.md` tính theo basis points.
- Tạo hợp đồng thông minh chính `contracts/project/ProjectCore.sol` chuẩn Solidity 0.8.20 và OpenZeppelin v5.
- Cung cấp bộ kiểm thử `test/ProjectCore.test.js`, giao diện Web DApp `web/index.html` tích hợp băm file client-side và tra cứu xác thực.

**Đánh giá:** Dùng được ngay, rất đầy đủ và đúng quy chuẩn học phần.

**Chỗ sai:**
- Phiên bản OpenZeppelin 5.x đã loại bỏ hook `_beforeTokenTransfer`, hợp đồng phải dùng `_update` và custom errors. Cần đảm bảo `ProjectCore.sol` không dùng kiểu bẫy lỗi chuỗi `require("...")` dài làm tốn gas.
- Hàm băm tài liệu nghiên cứu cần sinh ngay tại trình duyệt của người dùng (Web Crypto API) trước khi gửi hash lên contract, tránh để người dùng tải nguyên tệp lên on-chain.

**Cách sửa:**
- Cấu hình chuẩn `ProjectCore.sol` với custom error (`InvalidDocumentHash`, `HashAlreadyExists`, `InsufficientFee`, `NotDocumentOwner`, `WithdrawFailed`), dùng `ReentrancyGuard` và Checks-Effects-Interactions.
- Tích hợp hàm băm SHA-256 thuần túy trong `web/index.html` bằng `crypto.subtle.digest`.

**Ai phát hiện:** Sinh viên kết hợp gợi ý từ `AGENTS.md`.

---

## Lần 2: LAB 9 - Xây dựng Hợp đồng ProjectCore (RecordRegistry)

**Thời gian:** 04/10/2026  
**Người thực hiện:** Nhóm sinh viên ECO2432 - Hue Research Timestamp  

**Prompt:**
> "Bạn là lập trình viên Smart Contract chuyên nghiệp tuân thủ quy chuẩn môn học ECO2432. Đọc tệp docs/SPEC.md và quy ước trong AGENTS.md của dự án.
> Hãy viết hợp đồng Solidity cho file contracts/project/ProjectCore.sol phục vụ đề tài 'Dấu thời gian ý tưởng nghiên cứu' dựa trên mẫu RecordRegistry.sol với các yêu cầu bắt buộc:
> Dùng pragma solidity ^0.8.20;
> 
> Chỉ lưu trữ mã băm 32 bytes (bytes32 docHash), địa chỉ tác giả (subject), địa chỉ người phát hành (issuer), mốc thời gian (uint256 timestamp), mô tả ngắn (string metadata) và trạng thái thu hồi (bool revoked). Tuyệt đối KHÔNG lưu nội dung tệp thô.

> Định nghĩa các error tùy biến có tên: AlreadyExists(), NotIssuer(), NotFound() thay cho chuỗi require dài.
> 
> Phát ra các event có indexed khi tạo bản ghi (RecordCreated) và thu hồi bản ghi (RecordRevoked).
> 
> Hàm verify(bytes32 docHash) là hàm view công khai, trả về trạng thái tồn tại và tính hợp lệ.
> 
> Giải thích ngắn gọn lựa chọn thiết kế trước khi đưa mã nguồn.

**AI trả về:**
- Giải thích thiết kế: Áp dụng mô hình RecordRegistry (M.3) của môn học ECO2432; chỉ lưu `bytes32 docHash` và metadata lên blockchain; phân quyền `issuer` và `subject`; dùng custom error `AlreadyExists()`, `NotIssuer()`, `NotFound()`; hàm `verify` trả về `(bool exists, bool isValid)`; tuân thủ CEI và không dùng `tx.origin`.
- Mã nguồn đầy đủ của hợp đồng `contracts/project/ProjectCore.sol` chuẩn Solidity `^0.8.20`.
- Bộ 3 trường hợp kiểm thử bắt buộc: Happy path, Edge case (Sai quyền), Malicious (Gian lận trùng hash).

**Đánh giá:** Dùng được.

**Chỗ sai:**
- Không có lỗi cú pháp hoặc vi phạm logic nghiệp vụ. Hợp đồng đáp ứng 100% yêu cầu đề bài và `AGENTS.md`.

**Cách sửa:**
- Sinh viên cập nhật mã nguồn vào `contracts/project/ProjectCore.sol` và đồng bộ nhật ký vào `evidence/LAB9/AI_JOURNAL.md`.

**Ai phát hiện:** Sinh viên và AI cùng đối chiếu kiểm tra.

---

## Lần 3: LAB 9 - Kiểm toán Bảo mật và Tối ưu hóa Gas (Storage Slot Packing)

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
- Báo cáo kiểm toán 4 tiêu chí cốt lõi: CEI, chống ghi đè mã băm, không dùng cú pháp cũ / `tx.origin`, và hàm `verify` là `view` miễn phí gas.
- Phát hiện và thực hiện tối ưu hóa **Storage Slot Packing**: Đặt `address subject` (20 bytes) đứng liền kề `bool revoked` (1 byte) trong `struct Record` để ghép chung vào Slot 2 (21/32 bytes), giúp tiết kiệm ~20,000 gas SSTORE cho mỗi giao dịch `createRecord`.
- Cung cấp mã nguồn đã tối ưu và bổ sung docstrings kiểm toán cho [`contracts/project/ProjectCore.sol`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/contracts/project/ProjectCore.sol).

**Đánh giá:** Dùng được ngay.

**Chỗ sai / Điểm chưa tối ưu ban đầu:**
- Thứ tự khai báo các biến trong struct `Record` ban đầu chiếm 5 slots lưu trữ, lãng phí 1 storage slot 32 bytes do chưa tận dụng cơ chế gom slot của EVM.

**Cách sửa:**
- Tái sắp xếp `bool revoked` đứng cạnh `address subject` trong `struct Record`.

**Ai phát hiện:** AI kiểm toán chủ động đề xuất giải pháp tối ưu slot sau khi nhận yêu cầu rà soát từ sinh viên.

---

## Mẫu ghi chép cho các bài Lab tiếp theo (Lab 10 - Lab 15)

```markdown
## Lần [Số thứ tự]: [Tên bài lab hoặc nội dung công việc]

**Thời gian:** DD/MM/YYYY
**Người thực hiện:** [Tên sinh viên]

**Prompt:**
> [Dán nguyên văn câu lệnh đã gửi cho AI]

**AI trả về:**
[Tóm tắt ngắn gọn nội dung phản hồi của AI]

**Đánh giá:** Dùng được / Phải sửa / Sai, bỏ

**Chỗ sai:**
[Mô tả cụ thể lỗi logic, lỗi bảo mật, không tuân thủ AGENTS.md, hoặc sai quy tắc kinh tế]

**Cách sửa:**
[Sinh viên đã chỉnh sửa mã nguồn hoặc tinh chỉnh prompt như thế nào]

**Ai phát hiện:** Sinh viên phát hiện / AI tự nhận diện sau khi được chất vấn.
```
