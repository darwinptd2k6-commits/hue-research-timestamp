# AGENTS.md - Quy ước dự án ECO2432 (Hue Research Timestamp)

Tài liệu này là quy ước bắt buộc cho mọi công cụ AI (Gemini, Claude, ChatGPT, v.v.) và thành viên trong nhóm phát triển dự án **Hue Research Timestamp** xuyên suốt học kỳ.

---

## 1. Ngôn ngữ và Phiên bản công nghệ

- **Solidity**: `^0.8.20`.
- **OpenZeppelin Contracts**: phiên bản `5.x` (dùng cú pháp hook `_update`, tuyệt đối không dùng `_beforeTokenTransfer` vốn đã bị loại bỏ ở v5).
- **Web3 Frontend**: JavaScript ES6+, thư viện `ethers.js v6` (qua CDN hoặc bundler), Web Crypto API (`crypto.subtle.digest`) để băm tài liệu.
- **Python**: `3.10+` (cho các script kiểm thử, phân tích dữ liệu on-chain hoặc tương tác Web3.py).

---

## 2. Quy tắc bắt buộc khi viết Smart Contract

1. **Phát Event cho mọi thay đổi trạng thái**: Mọi hàm ghi dữ liệu vào blockchain (`registerDocument`, `updateMetadata`, `setRegistrationFee`, `withdrawFees`, `revokeDocument`) bắt buộc phải phát `event` tương ứng kèm `indexed` cho các trường định danh (`documentHash`, `owner`).
2. **Kiểm tra quyền rõ ràng**: Các hàm quản trị phải được bảo vệ bằng modifier kiểm tra quyền (như `onlyOwner` từ OpenZeppelin `Ownable`).
3. **Tuân thủ mô hình Checks - Effects - Interactions (CEI)**:
   - *Checks*: Kiểm tra điều kiện đầu vào, hash khác 0, hash chưa tồn tại, đủ phí ETH.
   - *Effects*: Cập nhật trạng thái hợp đồng (mapping, biến lưu trữ) trước.
   - *Interactions*: Tương tác bên ngoài (gửi ETH, gọi hợp đồng khác) sau cùng.
4. **Chuyển ETH an toàn**: Sử dụng cú pháp cấp thấp `(bool success, ) = recipient.call{value: amount}("")` và kiểm tra `if (!success) revert WithdrawFailed();`. Tuyệt đối không dùng `.transfer()` hoặc `.send()`.
5. **Ưu tiên Custom Error**: Sử dụng `error CustomErrorName(...)` thay cho chuỗi ký tự lỗi dài trong `require(...)` nhằm tối ưu chi phí gas triển khai và thực thi.
6. **Không dùng `tx.origin`**: Tuyệt đối sử dụng `msg.sender` để xác thực quyền, phòng tránh lỗ hổng bảo mật tấn công mạo danh (Phishing attack).
7. **Tính toán phần trăm**: Sử dụng đơn vị điểm cơ bản (**Basis Points - bps**), quy ước:
   - `1% = 100 bps`
   - `100% = 10,000 bps`
8. **Quy tắc bảo vệ dữ liệu nghiên cứu**:
   - Chỉ lưu trữ mã băm dữ liệu `bytes32 documentHash` và URI siêu dữ liệu (`metadataURI`) trên chuỗi.
   - Không được phép sửa đổi `documentHash` hoặc `timestamp` ban đầu của tài liệu sau khi đã đăng ký thành công (đảm bảo tính bất biến của bằng chứng thời gian).

---

## 3. Quy tắc khi viết Web DApp & Client-side Script

1. **Băm tài liệu tại máy người dùng (Client-side Hashing)**: Việc băm nội dung file nghiên cứu (SHA-256) phải thực hiện 100% tại trình duyệt của người dùng thông qua Web Crypto API, tuyệt đối không tải file nội dung thô lên bất kỳ máy chủ trung gian nào khi chưa được mã hóa.
2. **Không ghi khóa riêng tư (Private Key) hay API Secret vào mã nguồn**: Luôn dùng ví MetaMask / trình cắm Web3 của người dùng hoặc nạp khóa qua biến môi trường (`.env`).
3. **Xử lý đơn vị tiền tệ chuẩn xác**: Sử dụng `ethers.parseEther` khi gửi ETH và `ethers.formatEther` khi hiển thị số dư cho người dùng.
4. **Bắt lỗi giao dịch thân thiện**: Bắt các mã lỗi revert từ Smart Contract và thông báo rõ ràng cho người dùng (ví dụ: "Tài liệu này đã được đăng ký trước đó", "Số dư ví không đủ phí").

---

## 4. Quy tắc khi viết Python & Scripts bổ trợ

1. Không ghi khóa API hay khóa ví trong mã nguồn; đọc từ biến môi trường `os.getenv(...)`.
2. Kiểm tra trạng thái phản hồi HTTP (`response.raise_for_status()`) hoặc mã kết quả giao dịch Web3 trước khi xử lý dữ liệu.
3. Đổi đơn vị từ `wei` sang `ether` trước khi hiển thị hoặc lưu trữ báo cáo tài chính.

---

## 5. Quy tắc ứng xử khi AI được yêu cầu sinh mã

- **Giải thích ngắn gọn lựa chọn thiết kế** trước khi đưa ra mã nguồn.
- **Hỏi lại ngay khi yêu cầu nghiệp vụ chưa rõ ràng**; tuyệt đối không tự suy đoán các quy tắc kinh tế, phân chia tỷ lệ hay cơ chế bảo mật cốt lõi.
- **Luôn cung cấp tối thiểu ba trường hợp kiểm thử**, trong đó bắt buộc phải có ít nhất:
  - 1 trường hợp chạy đúng (Happy path).
  - 1 trường hợp giá trị biên hoặc sai quyền (Edge case / Unauthorized).
  - 1 trường hợp gian lận hoặc tấn công phá hoại (Malicious / Reentrancy / Hash Collision / Fake Timestamp).
