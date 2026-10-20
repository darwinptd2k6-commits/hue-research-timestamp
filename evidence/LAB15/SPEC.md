# SPEC — LAB 15: GIAO DIỆN WEB DAPP VÀ ĐƯA SẢN PHẨM LÊN MẠNG

## Dự án: Hue Research Timestamp (HRT)
**Học phần:** Tiền điện tử & Hợp đồng thông minh (ECO2432) — Trường Đại học Kinh tế, Đại học Huế  
**Nhóm sinh viên thực hiện:**
- Phan Thành Đạt (MSSV: 24K430002) — Project Lead & Smart Contract Engineer
- Nguyễn Hữu Bằng (MSSV: 24K4070016) — Web3 Frontend Dev & Tokenomics Lead  

---

## 1. Mục đích
Xây dựng và hoàn thiện giao diện ứng dụng phi tập trung (Web3 DApp) cho hệ thống **Hue Research Timestamp (HRT)** tại [`web/index.html`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/web/index.html), cho phép người dùng băm tệp nghiên cứu trực tiếp tại trình duyệt (Client-side Hashing), ký gửi giao dịch đóng dấu thời gian lên mạng Sepolia qua ví MetaMask, tra cứu chứng thư số miễn phí gas, bắt lỗi giao dịch thân thiện bằng tiếng Việt và hỗ trợ hiển thị tối ưu trên màn hình điện thoại di động (Mobile Responsive).

---

## 2. Đầu vào
- **Tệp nghiên cứu khoa học**: Định dạng PDF, DOCX, ZIP hoặc CSV do tác giả lựa chọn từ thiết bị cá nhân.
- **Thông tin công trình**:
  - Tên đề tài nghiên cứu (`string title`).
  - Danh sách tác giả / MSSV / Khoa viện (`string authors`).
  - Đường dẫn tóm tắt / IPFS URI / DOI xuất bản (`string metadataURI`).
- **Phí giao dịch**: Mặc định `0.001 ETH` nạp kèm theo `msg.value` (hỗ trợ hoàn trả tiền thừa nếu nạp thừa).
- **Mã băm tra cứu**: Chuỗi hex 32 bytes (`bytes32 documentHash`, dài đúng 66 ký tự bắt đầu bằng `0x`).
- **Ví Web3**: Tiện ích mở rộng MetaMask (hoặc trình duyệt di động tích hợp Web3 như MetaMask Mobile, Brave).

---

## 3. Quy tắc nghiệp vụ

- **R1 (Băm tệp tại máy khách - Client-side Hashing)**: Việc sinh mã băm SHA-256 từ tệp nghiên cứu phải được thực hiện 100% trong môi trường trình duyệt thông qua Web Crypto API (`crypto.subtle.digest("SHA-256", buffer)`). Tuyệt đối không gửi nội dung tệp thô qua bất kỳ API trung gian nào.
- **R2 (Kết nối và chuyển mạng tự động)**: DApp phải phát hiện trình cắm MetaMask (`window.ethereum`), yêu cầu mở quyền truy cập tài khoản và hiển thị địa chỉ ví thu gọn (`0x1234...5678`), số dư ETH hiện có và tên mạng (Sepolia Testnet).
- **R3 (Ký số và gửi giao dịch on-chain)**: Hàm `registerDocument` chỉ được kích hoạt khi:
  - Đã kết nối ví MetaMask.
  - Tệp nghiên cứu đã được chọn và mã băm SHA-256 đã được tính toán.
  - Tên đề tài và tác giả không được để trống.
  - Phí gửi `msg.value >= 0.001 ETH`.
- **R4 (Tra cứu chứng thư số miễn phí gas)**: Hàm `verifyDocument` thực thi theo chế độ `view` không tiêu tốn gas; cho phép tra cứu ngay cả khi người dùng chưa kết nối ví MetaMask bằng cách sử dụng Public RPC Provider fallback (`https://rpc.sepolia.org`).
- **R5 (Phản hồi trạng thái và nút bấm xử lý)**: Trong suốt quá trình người dùng gửi giao dịch, nút bấm phải chuyển sang trạng thái chờ xử lý (Loading Spinner), khóa vô hiệu hóa (`disabled = true`) để chống click đúp, và hiển thị thông báo tiến độ (đang yêu cầu ký $\rightarrow$ đang đóng khối $\rightarrow$ thành công).
- **R6 (Bắt lỗi giao dịch thân thiện - User-Friendly Error Mapping)**: Mọi lỗi revert từ Smart Contract (như `InsufficientFee`, `HashAlreadyExists`, `FeeExceedsLimit`, `ACTION_REJECTED`) phải được thông dịch sang tiếng Việt rõ ràng, dễ hiểu thay vì chuỗi kỹ thuật EVM thô.
- **R7 (Tương thích thiết bị di động - Mobile Friendly)**: Giao diện phải co giãn linh hoạt (responsive), hiển thị trực quan và thao tác mượt mà trên màn hình điện thoại thông minh.

---

## 4. Đầu ra
- Giao diện DApp hoạt động ổn định tại [`web/index.html`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/web/index.html).
- Đường dẫn web công khai trên GitHub Pages: `https://hue-research-timestamp.github.io/web/`.
- Thông báo xác nhận giao dịch thành công kèm liên kết kiểm tra mã băm khối trực tiếp trên [Sepolia Etherscan](https://sepolia.etherscan.io/).
- Khung Chứng thư Dấu thời gian số (Digital Certificate) hiển thị đầy đủ: Trạng thái (Hợp lệ / Đã thu hồi), Tiêu đề, Tác giả, Mốc thời gian định dạng giờ Việt Nam, Số khối, Ví chủ sở hữu và Metadata URI.

---

## 5. Trường hợp ngoại lệ (Edge Cases & Error Handling)
- **TH1 (Người dùng chưa cài ví MetaMask)**: Hiển thị hộp thoại cảnh báo: *"Vui lòng cài đặt tiện ích mở rộng MetaMask trên trình duyệt!"*.
- **TH2 (Người dùng từ chối ký giao dịch)**: Bắt lỗi `ACTION_REJECTED` / `user rejected` và thông báo: *"Bạn đã từ chối ký xác nhận giao dịch trên ví MetaMask."*.
- **TH3 (Tài liệu đã từng đăng ký trước đó)**: Bắt lỗi `HashAlreadyExists` và thông báo: *"Tài liệu này đã tồn tại trên Blockchain! Mã băm SHA-256 đã được một tác giả khác đăng ký trước đó."*.
- **TH4 (Số dư ví không đủ trả phí)**: Bắt lỗi `insufficient funds` và thông báo: *"Số dư ví Sepolia ETH của bạn không đủ để trả phí đăng ký và gas!"*.
- **TH5 (Mã băm tra cứu sai định dạng)**: Nếu chuỗi không đủ 66 ký tự hoặc không bắt đầu bằng `0x`, hiển thị cảnh báo: *"Mã băm không hợp lệ! Bắt buộc là chuỗi hex 32 bytes"*.

---

## 6. Ngoài phạm vi
- Không xây dựng backend tập trung bằng NodeJS/Python/MySQL để lưu trữ cơ sở dữ liệu (DApp thuần Serverless Web3, giao tiếp trực tiếp giữa trình duyệt và mạng Ethereum Sepolia).
- Không hỗ trợ tải trực tiếp toàn bộ tài liệu dung lượng lớn lên blockchain (chỉ lưu mã băm 32 bytes).
