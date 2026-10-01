# Hue Research Timestamp (HRT)

> **Hệ thống Đóng dấu Thời gian & Xác thực Quyền Tác giả Nghiên cứu Khoa học trên Blockchain**  
> Dự án nhóm học phần: **ECO2432 - Web3 & Fintech**  
> Đơn vị thực hiện: **Trường Đại học Kinh tế - Đại học Huế (HUE)**

---

## 1. Giới thiệu sản phẩm

Trong môi trường nghiên cứu học thuật, việc bảo vệ ý tưởng ban đầu, chứng minh quyền sở hữu đề tài và thời điểm công bố là thách thức lớn đối với sinh viên và giảng viên. Các phương pháp truyền thống (gửi email, nộp bản in) dễ bị tranh chấp, khó xác minh độc lập và thiếu cơ chế chống sửa đổi hồi tố.

**Hue Research Timestamp (HRT)** là ứng dụng phi tập trung (DApp) chạy trên mạng thử nghiệm Ethereum Sepolia, cung cấp cơ chế:
- **Băm tài liệu tại trình duyệt (Client-side Hashing)**: File nghiên cứu (PDF/Word/Data) được sinh mã băm SHA-256 an toàn ngay trên máy của người dùng bằng Web Crypto API; file gốc không bao giờ bị tải lên máy chủ ngoài, bảo vệ 100% tính riêng tư đề tài trước khi công bố.
- **Đóng dấu thời gian bất biến (Proof of Existence & Authorship)**: Mã băm, thông tin tác giả và dấu thời gian khối (`block.timestamp`) được lưu trữ vĩnh viễn trên Smart Contract `ProjectCore.sol`.
- **Cổng tra cứu công khai (Verification Portal)**: Bất kỳ ai (hội đồng chấm luận văn, tạp chí, độc giả) cũng có thể tải file hoặc nhập mã băm để kiểm chứng tính nguyên bản và thời điểm đăng ký ban đầu.

---

## 2. Đường dẫn chạy thật & Triển khai

- **Giao diện DApp**: [Mở trực tiếp tệp `web/index.html`](file:///C:/Users/LENOVO/.gemini/antigravity/scratch/hue-research-timestamp/web/index.html) (hoặc chạy qua Live Server/GitHub Pages: `https://<ten-nhom>.github.io/hue-research-timestamp/web/`)
- **Mạng thử nghiệm**: Ethereum Sepolia Testnet
- **Địa chỉ hợp đồng `ProjectCore.sol`**: `0x71C8F79720f4C7e74a68C838Fdfd3d4b68019688` (Cập nhật sau khi nhóm hoàn tất deploy tại Lab 14)
- **Trình khám phá khối**: [Sepolia Etherscan Explorer](https://sepolia.etherscan.io/)
- **Mở nhanh trên Remix IDE**: [Remix Ethereum IDE](https://remix.ethereum.org)

---

## 3. Cấu trúc kho lưu trữ (Repository Structure)

```text
hue-research-timestamp/                 <-- Thư mục gốc của repo nhóm
├── README.md                 # Giới thiệu sản phẩm và đường dẫn chạy thật
├── AGENTS.md                 # Quy ước cho công cụ AI (dùng chung cả học kỳ)
├── docs/
│   ├── PROJECT_PLAN.md       # Kế hoạch, vai trò, mốc công việc (Lab 1 -> Lab 15)
│   ├── SPEC.md               # Đặc tả nghiệp vụ v0.1
│   ├── ECONOMIC_RULES.md     # Quy tắc kinh tế và quản trị (Basis points, phí)
│   └── AI_JOURNAL.md         # Nhật ký prompt và sửa lỗi
├── contracts/
│   ├── training/             # Bài mẫu học kỹ thuật (TimeLock, Bank, ClassPoint...)
│   └── project/              # Mã nguồn hợp đồng chính của nhóm (ProjectCore.sol)
├── test/                     # Ca kiểm thử tự động và kế hoạch kiểm thử
│   ├── TEST_PLAN.md          # Kịch bản 12 ca kiểm thử (happy path, fraud, admin)
│   └── ProjectCore.test.js   # Script kiểm thử chạy bằng Node.js (100% pass)
├── web/                      # Giao diện sản phẩm
│   └── index.html            # DApp Web3 kết nối MetaMask, băm file SHA-256
└── evidence/                 # Bằng chứng chạy thực tế từng lab (tx hash, screenshots)
    └── README.md             # Bảng theo dõi minh chứng 15 bài thực hành
```

---

## 4. Hướng dẫn cài đặt và Chạy thử nghiệm

### 4.1. Chạy DApp Frontend
1. Mở thư mục `hue-research-timestamp` bằng Antigravity IDE hoặc VS Code.
2. Mở trực tiếp tệp `web/index.html` trên trình duyệt Chrome/Edge (đã cài tiện ích mở rộng ví **MetaMask**).
3. Đảm bảo ví MetaMask đã chuyển sang mạng **Sepolia Testnet**.
4. Trải nghiệm 2 tính năng chính:
   - **Đăng ký Timestamp**: Chọn file nghiên cứu -> Điền tên đề tài, tác giả -> Nhấn "Ký số & Đăng ký".
   - **Thẩm định & Tra cứu**: Nhập mã băm SHA-256 hoặc chọn file -> Nhấn "Tra cứu trên Blockchain".

### 4.2. Chạy bộ kiểm thử tự động (Unit Tests)
Trong thư mục gốc của repo:
```bash
# Cài đặt thư viện phụ thuộc (nếu cần biên dịch cục bộ)
npm install

# Thực thi kiểm thử 9 kịch bản tự động
npm test
```

### 4.3. Biên dịch và Triển khai Smart Contract trên Remix IDE
1. Truy cập [Remix IDE](https://remix.ethereum.org).
2. Tạo tệp `ProjectCore.sol` trong Remix và dán nội dung từ `contracts/project/ProjectCore.sol`.
3. Tại tab **Solidity Compiler**, chọn phiên bản `0.8.20` và nhấn **Compile ProjectCore.sol**.
4. Tại tab **Deploy & Run Transactions**:
   - Chọn Environment: `Injected Provider - MetaMask` (kết nối ví Sepolia có ETH).
   - Điền tham số Constructor:
     - `initialOwner`: Địa chỉ ví của bạn (hoặc admin nhóm).
     - `initialFee`: `1000000000000000` (tương đương 0.001 ETH).
   - Nhấn **Deploy** và xác nhận giao dịch trên MetaMask.
   - Sao chép Contract Address đã triển khai dán vào ô cấu hình tại Tab 3 của giao diện Web.

---

## 5. Đưa mã nguồn lên GitHub (Dành cho Lab 8)

Thành viên đại diện nhóm khởi tạo repository trống mới trên GitHub với tên `hue-research-timestamp` và thực hiện các lệnh sau:

```bash
git init -b main
git add .
git commit -m "feat: khoi tao repo nhom hue-research-timestamp theo chuan ECO2432"
git remote add origin https://github.com/<tai-khoan-nhom>/hue-research-timestamp.git
git push -u origin main
```
Sau đó, vào mục **Settings > Collaborators** trên GitHub để mời các thành viên còn lại trong nhóm vào cùng phát triển.

---

## 6. Thành viên nhóm & Phân công (2 Thành viên)

- **Học phần**: ECO2432 - Web3 & Fintech
- **Giảng viên phụ trách**: **TS. Hà Ngọc Long**
- **Đơn vị**: Trường Đại học Kinh tế - Đại học Huế (HUE)
- **Danh sách thành viên & Phân công nhiệm vụ**:

| STT | Họ và tên | MSSV | Vai trò chính | Nhiệm vụ chi tiết |
| :---: | :--- | :---: | :--- | :--- |
| 1 | **Phan Thành Đạt** | **24K430002** | **Project Lead & Smart Contract Engineer** | Điều phối tiến độ chung, viết đặc tả nghiệp vụ `SPEC.md`, thiết kế và lập trình Smart Contract `ProjectCore.sol`, tối ưu hóa Gas, viết bộ kiểm thử `test/ProjectCore.test.js`, thẩm định bảo mật (CEI, Reentrancy) và quản lý triển khai Sepolia. |
| 2 | **Nguyễn Hữu Bằng** | **24K4070016** | **Frontend Web3 Dev & Tokenomics Lead** | Xây dựng giao diện DApp `web/index.html`, tích hợp Ethers.js v6, lập trình thuật toán băm tệp tại máy khách (Client-side Hashing), thiết kế mô hình kinh tế vi mô & phân bổ quỹ Basis Points (`ECONOMIC_RULES.md`), thu thập minh chứng `evidence/`. |
