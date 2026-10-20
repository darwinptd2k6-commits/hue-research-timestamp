# HƯỚNG DẪN VẬN HÀNH WEB DAPP & BẰNG CHỨNG THỰC NGHIỆM (LAB 15)

## Dự án: Hue Research Timestamp (HRT)
**Học phần:** Tiền điện tử & Hợp đồng thông minh (ECO2432) — Trường Đại học Kinh tế, Đại học Huế  
**Nhóm sinh viên thực hiện:**
- Phan Thành Đạt (MSSV: 24K430002) — Project Lead & Smart Contract Engineer
- Nguyễn Hữu Bằng (MSSV: 24K4070016) — Web3 Frontend Dev & Tokenomics Lead  
**Đường dẫn DApp công khai:** `https://hue-research-timestamp.github.io/web/` (hoặc mở trực tiếp file `web/index.html`)  
**Mạng thử nghiệm:** Ethereum Sepolia Testnet  
**Smart Contract:** `0x71C8F79720f4C7e74a68C838Fdfd3d4b68019688`  

---

## 1. Bảng ánh xạ tương tác Smart Contract (Sổ tay ECO2432 Trang 34)

| Thành phần kỹ thuật | Giá trị cấu hình của nhóm | Mô tả nghiệp vụ |
| :--- | :--- | :--- |
| **Địa chỉ Smart Contract** | `0x71C8F79720f4C7e74a68C838Fdfd3d4b68019688` | Triển khai trên mạng Ethereum Sepolia |
| **Nguồn gốc ABI** | `contracts/project/ProjectCore.sol` | Trích xuất từ Solidity Compiler 0.8.20 |
| **Hàm đọc không tốn phí (Free Gas)** | - `verifyDocument(bytes32)`<br>- `verify(bytes32)`<br>- `getDocument(bytes32)`<br>- `registrationFee()`<br>- `totalDocumentsRegistered()` | Tra cứu trạng thái văn bằng, tính nguyên bản và số lượng đề tài trực tiếp từ sổ cái, không cần ký ví |
| **Hàm ghi cần xác nhận ví MetaMask** | - `registerDocument(...)` (0.001 ETH)<br>- `updateMetadata(...)`<br>- `revokeDocument(...)`<br>- `setRegistrationFee(...)`<br>- `withdrawFees(...)` | Các giao dịch thay đổi trạng thái on-chain, yêu cầu trả gas và phí dịch vụ theo quy định kinh tế |

---

## 2. Quy trình thử nghiệm toàn bộ luồng (End-to-End Walkthrough)

### Luồng 1: Kết nối ví Web3 MetaMask
1. Mở tệp [`web/index.html`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/web/index.html) trên trình duyệt máy tính hoặc điện thoại (qua MetaMask Mobile Browser).
2. Nhấn nút **"🦊 Kết nối MetaMask"**.
3. Cửa sổ MetaMask bật lên yêu cầu cấp quyền truy cập tài khoản. Người dùng chọn tài khoản và bấm **Connect**.
4. Giao diện DApp lập tức hiển thị địa chỉ ví rút gọn (`0x1111...4444`), số dư ETH hiện có và mạng kết nối `Ethereum Sepolia`.

```
+-----------------------------------------------------------------------------------+
|  Ví của bạn: 0x9999...9999        Mạng: Ethereum Sepolia | Số dư: 0.1250 ETH      |
+-----------------------------------------------------------------------------------+
```

---

### Luồng 2: Băm tệp tại máy khách (Client-side Hashing) & Đăng ký đóng dấu thời gian
1. Tại Tab **"1. Đăng ký Timestamp"**, người dùng bấm nút **Chọn tệp** (ví dụ tệp PDF: `Bao_Cao_De_Tai_NCKH_Hue_2026.pdf`).
2. Trình duyệt tự động kích hoạt Web Crypto API:
   ```javascript
   const buffer = await file.arrayBuffer();
   const hashBuffer = await crypto.subtle.digest("SHA-256", buffer);
   ```
3. Mã băm SHA-256 hiển thị tức thì trên khung:
   `0x4f83e20e8a7f1a3a412b1d31d0db7a922614b98c37d0c3268875317bfb21d5a7`
4. Điền các thông tin:
   - *Tên đề tài:* "Ứng dụng Blockchain trong quản trị chuỗi cung ứng đặc sản Huế"
   - *Tác giả:* "Phan Thành Đạt, Nguyễn Hữu Bằng - Khoa HTTT Kinh tế, HCE"
   - *Metadata URI:* `ipfs://bafybeigdyrzt5sfp7udm7hu76uh7y26`
   - *Phí dịch vụ:* `0.001 ETH`
5. Nhấn nút **"Ký số & Đóng dấu lên Blockchain Sepolia"**:
   - Nút chuyển sang trạng thái loading với biểu tượng spinner.
   - MetaMask yêu cầu xác nhận chuyển `0.001 ETH` phí dịch vụ.
   - Sau khi thợ đào đóng khối, DApp hiển thị thông báo thành công màu xanh kèm link tra cứu giao dịch trên Etherscan.

---

### Luồng 3: Thẩm định và Tra cứu tính nguyên bản (Miễn phí Gas)
1. Chuyển sang Tab **"2. Thẩm định & Tra cứu"**.
2. Người dùng có thể:
   - **Cách A:** Chọn lại đúng tệp gốc cần kiểm tra (DApp tự động băm SHA-256).
   - **Cách B:** Hoặc dán trực tiếp chuỗi hash `0x4f83e20e8a7f1a3a412b1d31d0db7a922614b98c37d0c3268875317bfb21d5a7`.
3. Bấm **"🔍 Tra cứu chứng thư trên Blockchain"**.
4. Khung **Chứng thư Dấu thời gian số (Digital Certificate)** xuất hiện trực quan:
   - **Trạng thái:** `HỢP LỆ VÀ NGUYÊN BẢN (ACTIVE)` (Badge màu xanh).
   - **Tên công trình:** Ứng dụng Blockchain trong quản trị chuỗi cung ứng đặc sản Huế
   - **Tác giả:** Phan Thành Đạt, Nguyễn Hữu Bằng - Khoa HTTT Kinh tế, HCE
   - **Dấu thời gian bất biến:** 17/10/2026, 12:45:00 (Giờ Việt Nam)
   - **Số hiệu khối:** `#5928104`
   - **Ví tác giả sở hữu:** `0x1111111111111111111111111111111111111111`
   - **Metadata URI:** `ipfs://bafybeigdyrzt5sfp7udm7hu76uh7y26`

---

### Luồng 4: Kiểm chứng các ca bị chặn và Thông báo lỗi thân thiện (Sổ tay Bước 2)

| Tình huống thực nghiệm | Hành vi người dùng | Phản hồi từ Smart Contract | Thông báo hiển thị trên Web DApp |
| :--- | :--- | :--- | :--- |
| **Đăng ký trùng mã băm** | Chọn lại chính tệp đã đăng ký trước đó để đăng ký lần 2 | Revert với `HashAlreadyExists(hash, timestamp)` | ⚠️ **Tài liệu này đã tồn tại trên Blockchain! Mã băm SHA-256 đã được một tác giả khác đăng ký trước đó.** |
| **Nạp thiếu phí dịch vụ** | Cố tình sửa giá trị nạp `< 0.001 ETH` | Revert với `InsufficientFee(required, sent)` | ⚠️ **Lỗi quy tắc kinh tế: Bạn chưa gửi đủ phí đăng ký (bắt buộc 0.001 ETH)!** |
| **Người dùng hủy ký ví** | Bấm nút Reject trên cửa sổ xác nhận MetaMask | Revert với `ACTION_REJECTED` | ⚠️ **Bạn đã từ chối ký xác nhận giao dịch trên ví MetaMask.** |
| **Mã băm không hợp lệ** | Nhập chuỗi hex ngắn (ví dụ `0x123`) | Client validation | ⚠️ **Mã băm không hợp lệ! Bắt buộc là chuỗi hex 32 bytes (bắt đầu bằng 0x, dài đúng 66 ký tự).** |

---

## 3. Hướng dẫn đưa DApp lên mạng công khai qua GitHub Pages

1. Tại repository `hue-research-timestamp` trên GitHub, truy cập mục **Settings > Pages**.
2. Tại mục **Build and deployment**:
   - Source: Chọn `Deploy from a branch`.
   - Branch: Chọn nhánh `main`, thư mục `/web` (hoặc `/ (root)`).
3. Nhấn **Save**. Sau 1 - 2 phút, GitHub Pages sẽ kích hoạt URL chính thức:
   `https://<ten-tai-khoan>.github.io/hue-research-timestamp/web/`
4. Mở đường link trên trình duyệt điện thoại để kiểm chứng tính tương thích di động.
