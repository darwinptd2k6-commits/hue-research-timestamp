# NHẬT KÝ LÀM VIỆC VỚI AI (AI JOURNAL) - HUE RESEARCH TIMESTAMP

Tài liệu này ghi lại toàn bộ các câu lệnh (prompts), phản hồi của AI, đánh giá chất lượng, các lỗi phát hiện và cách khắc phục trong quá trình thực hiện dự án môn học ECO2432.

---

## Lần 1: Khởi tạo cấu trúc repository nhóm từ repo mẫu `hce-web3-starter`

**Thời gian:** Học kỳ 1, Năm học 2026 - 2027

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

**Chỗ sai / Điểm cần lưu ý:**
- Phiên bản OpenZeppelin 5.x đã loại bỏ hook `_beforeTokenTransfer`, hợp đồng phải dùng `_update` và custom errors. Cần đảm bảo `ProjectCore.sol` không dùng kiểu bẫy lỗi chuỗi `require("...")` dài làm tốn gas.
- Hàm băm tài liệu nghiên cứu cần sinh ngay tại trình duyệt của người dùng (Web Crypto API) trước khi gửi hash lên contract, tránh để người dùng tải nguyên tệp lên on-chain.

**Cách sửa / Hoàn thiện:**
- Cấu hình chuẩn `ProjectCore.sol` với custom error (`InvalidDocumentHash`, `HashAlreadyExists`, `InsufficientFee`, `NotDocumentOwner`, `WithdrawFailed`), dùng `ReentrancyGuard` và Checks-Effects-Interactions.
- Tích hợp hàm băm SHA-256 thuần túy trong `web/index.html` bằng `crypto.subtle.digest`.

**Ai phát hiện:** Sinh viên kết hợp gợi ý từ `AGENTS.md`.

---

## Mẫu ghi chép cho các bài Lab tiếp theo (Lab 9 - Lab 15)

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
