# SPEC - Đặc tả nghiệp vụ v0.1: Hue Research Timestamp

## 1. Mục đích

Hệ thống cung cấp giải pháp đóng dấu thời gian (Timestamping) và bảo vệ bản quyền công trình khoa học trên nền tảng Blockchain Ethereum cho sinh viên, giảng viên và các nhà nghiên cứu tại Đại học Huế (Hue University), nhằm chứng minh tính nguyên bản và thời điểm công bố của tài liệu học thuật một cách minh bạch, bất biến mà không cần tiết lộ nội dung nhạy cảm của đề tài.

---

## 2. Đầu vào

1. **`documentHash`** (`bytes32`):
   - Mã băm 256-bit (Keccak-256 hoặc SHA-256) được sinh trực tiếp từ nội dung tệp nghiên cứu (PDF, DOCX, ZIP) tại trình duyệt của người dùng.
   - Do người dùng (tác giả hoặc đại diện nhóm tác giả) cung cấp qua giao diện web.
2. **`title`** (`string`):
   - Tên đề tài, bài báo hoặc công trình nghiên cứu khoa học (ví dụ: "Ứng dụng DeFi trong tài chính vi mô tại Thừa Thiên Huế").
3. **`authors`** (`string`):
   - Danh sách họ tên tác giả, mã sinh viên, email học thuật hoặc khoa/bộ môn trực thuộc.
4. **`metadataURI`** (`string`):
   - Đường dẫn liên kết đến bản tóm tắt (Abstract), tài liệu bổ trợ hoặc mã lưu trữ phân tán IPFS/Arweave (ví dụ: `ipfs://bafy...` hoặc `https://hue.edu.vn/research/...`).
5. **`msg.value`** (`uint256`):
   - Lượng tiền tệ thử nghiệm (ETH) gửi kèm giao dịch để chi trả phí dịch vụ đóng dấu (`registrationFee`).

---

## 3. Quy tắc nghiệp vụ

- **R1 (Tính duy nhất của bản ghi)**: Mỗi mã băm `documentHash` chỉ được đăng ký đóng dấu thành công duy nhất một lần trên toàn hệ thống. Nếu mã băm đã tồn tại trước đó, giao dịch phải bị hủy bỏ ngay lập tức.
- **R2 (Quyền sở hữu tác giả)**: Địa chỉ ví gọi hàm đăng ký (`msg.sender`) được hệ thống ghi nhận là chủ sở hữu bản quyền ban đầu (`owner`) của tài liệu tương ứng.
- **R3 (Thời gian bất biến)**: Thời gian đóng dấu được lấy chính xác từ dấu thời gian của khối (`block.timestamp`) và số thứ tự khối (`block.number`) tại thời điểm giao dịch được thợ đào xác nhận trên chuỗi. Dữ liệu này không ai có quyền can thiệp sửa đổi.
- **R4 (Mức phí đăng ký)**: Người đăng ký phải gửi kèm số ETH tối thiểu bằng `registrationFee` do hợp đồng quy định. Nếu gửi không đủ, giao dịch sẽ bị từ chối.
- **R5 (Phát sinh sự kiện)**: Mọi thao tác đăng ký thành công bắt buộc phải phát sự kiện `DocumentTimestamped` với đầy đủ các tham số định danh có đánh chỉ mục (`indexed`).
- **R6 (Cập nhật siêu dữ liệu)**: Chỉ có địa chỉ ví chủ sở hữu tài liệu (`owner`) mới có quyền gọi hàm cập nhật `metadataURI` (nhằm bổ sung mã định danh xuất bản DOI hoặc link bài báo sau khi nghiệm thu). Tuyệt đối không được phép chỉnh sửa `documentHash`, `timestamp` hay `owner`.
- **R7 (Quản trị và Rút quỹ an toàn)**: Quản trị viên hợp đồng (Chủ sở hữu trường/dự án) có quyền điều chỉnh phí dịch vụ và rút doanh thu tích lũy về ví kho bạc nghiên cứu, bắt buộc tuân theo nguyên tắc Checks-Effects-Interactions và chống tấn công Reentrancy.
- **R8 (Xử lý gian lận học thuật)**: Trong trường hợp Hội đồng kỷ luật/học thuật kết luận đề tài vi phạm đạo văn nghiêm trọng, Quản trị viên có thẩm quyền đánh dấu thu hồi (`isRevoked = true`) kèm lý do thu hồi minh bạch trên chuỗi qua sự kiện `DocumentRevoked`.

---

## 4. Đầu ra

1. **Chứng thư xác thực thời gian kỹ thuật số (Digital Timestamp Certificate)** hiển thị trên DApp bao gồm:
   - Mã băm tài liệu (`documentHash`).
   - Tên đề tài (`title`) và tác giả (`authors`).
   - Thời điểm đóng dấu (`timestamp` được định dạng giờ Việt Nam UTC+7).
   - Số hiệu khối (`blockNumber`).
   - Địa chỉ ví tác giả đăng ký (`owner`).
   - Trạng thái hiệu lực (`isActive / isRevoked`).
   - Đường dẫn liên kết tra cứu giao dịch trên Etherscan Sepolia (`https://sepolia.etherscan.io/tx/<txHash>`).
2. **Kết quả tra cứu đối chiếu (Verification Result)**:
   - Trạng thái: "HỢP LỆ VÀ NGUYÊN BẢN" (Mã băm khớp chính xác 100%).
   - Hoặc: "CHƯA TỒN TẠI TRÊN HỆ THỐNG" (Tài liệu chưa được đăng ký hoặc nội dung file đã bị thay đổi dù chỉ một ký tự).

---

## 5. Trường hợp ngoại lệ

- **E1 (Mã băm rỗng)**: Người dùng gửi `documentHash == bytes32(0)` -> Hệ thống kích hoạt lỗi tùy biến `InvalidDocumentHash()`.
- **E2 (Mã băm đã được đăng ký trước)**: Người dùng (hoặc kẻ mạo danh) cố gắng đăng ký một mã băm tài liệu đã tồn tại trong hợp đồng -> Hệ thống kích hoạt lỗi tùy biến `HashAlreadyExists(documentHash, existingTimestamp)`.
- **E3 (Không đủ phí dịch vụ)**: Người dùng gửi giá trị ETH trong `msg.value` nhỏ hơn `registrationFee` hiện hành -> Hệ thống kích hoạt lỗi tùy biến `InsufficientFee(requiredFee, sentFee)`.
- **E4 (Sửa đổi trái phép)**: Tài khoản không phải chủ sở hữu tài liệu cố gắng gọi hàm `updateMetadata` -> Hệ thống kích hoạt lỗi tùy biến `NotDocumentOwner()`.
- **E5 (Rút quỹ thất bại)**: Hàm chuyển tiền ra ngoài thất bại (ví nhận từ chối nhận ETH hoặc lỗi mạng) -> Hệ thống hoàn tác trạng thái và kích hoạt lỗi `WithdrawFailed()`.
- **E6 (Tài khoản không có quyền quản trị)**: Người dùng thông thường cố gắng thay đổi phí hoặc thu hồi văn bằng -> Hệ thống kích hoạt lỗi từ OpenZeppelin `OwnableUnauthorizedAccount(account)`.

---

## 6. Ngoài phạm vi (Out of Scope v0.1)

- Không lưu trữ toàn bộ file nhị phân (PDF, Word, video, tệp dữ liệu dung lượng lớn) trực tiếp trong storage của Smart Contract nhằm tránh phí gas đắt đỏ và nghẽn mạng blockchain.
- Không tự động giải quyết các tranh chấp pháp lý ngoài đời thực giữa các bên (hệ thống chỉ đóng vai trò cung cấp bằng chứng kỹ thuật mật mã bất khả chối cãi về mặt thời gian và tính toàn vẹn tài liệu).
- Chưa tích hợp cơ chế bình chọn phi tập trung DAO của Hội đồng khoa học (sẽ được nghiên cứu bổ sung trong phiên bản v0.2).
