# NHẬT KÝ LÀM VIỆC VỚI AI — LAB 13: THỰC NGHIỆM MỘT VỤ MẤT TIỀN VÀ CÁCH KHẮC PHỤC

## Dự án: Hue Research Timestamp (HRT)
**Học phần:** Tiền điện tử & Hợp đồng thông minh (ECO2432) — Đại học Huế  
**Nhóm sinh viên thực hiện:**
- Phan Thành Đạt (MSSV: 24K430002) — Project Lead & Smart Contract Engineer
- Nguyễn Hữu Bằng (MSSV: 24K4070016) — Web3 Frontend Dev & Tokenomics Lead  

---

## Lần 1: Rà soát an toàn theo lối đặt câu hỏi dẫn dắt (Theo mẫu I.4 của Sổ tay)

**Thời gian:** 13/10/2026  
**Người thực hiện:** Phan Thành Đạt  

**Prompt:**
> "Bạn là kiểm toán viên hợp đồng thông minh.  
> Đừng đưa mã sửa ngay.  
> Trước hết hãy giải thích từng bước điều gì xảy ra khi hàm withdraw() dưới đây được gọi bởi một hợp đồng có hàm receive().  
> Sau đó nêu hai cách khắc phục và so sánh ưu nhược điểm của từng cách.  
> 
> ```solidity
> contract VulnerableBank {
>     mapping(address => uint256) public balances;
> 
>     function deposit() external payable {
>         balances[msg.sender] += msg.value;
>     }
> 
>     function withdraw() external {
>         uint256 balance = balances[msg.sender];
>         require(balance > 0, "Khong co so du");
>         (bool ok, ) = msg.sender.call{value: balance}("");
>         require(ok, "Chuyen that bai");
>         balances[msg.sender] = 0;
>     }
> 
>     function bankBalance() external view returns (uint256) {
>         return address(this).balance;
>     }
> }
> ```"

**AI trả về:**
- **Giải thích từng bước luồng khai thác Reentrancy**:
  1. *Bước 1 (Khởi tạo vốn mồi)*: Hợp đồng tấn công nạp `1 ETH` vào `VulnerableBank` qua `deposit()`. Lúc này `balances[attacker] = 1 ETH`.
  2. *Bước 2 (Gọi rút tiền lần 1)*: Hợp đồng tấn công gọi `withdraw()`. Ngân hàng kiểm tra `balance > 0` (hợp lệ).
  3. *Bước 3 (Chuyển giao quyền kiểm soát)*: Ngân hàng thực thi lệnh cấp thấp `msg.sender.call{value: balance}("")`. Vì địa chỉ nhận là hợp đồng, EVM tự động chuyển luồng thực thi sang hàm `receive()` của hợp đồng tấn công.
  4. *Bước 4 (Tái nhập đệ quy)*: Tại thời điểm này, biến lưu trữ `balances[attacker]` trong ngân hàng **vẫn chưa bị trừ** (vẫn là 1 ETH). Trong hàm `receive()`, kẻ tấn công tiếp tục gọi lại `withdraw()`.
  5. *Bước 5 (Vòng lặp rút cạn)*: Ngân hàng lại kiểm tra `balances[attacker]` (vẫn thấy bằng 1 ETH) và lại tiếp tục gửi thêm 1 ETH nữa. Vòng lặp đệ quy này tái diễn cho đến khi ngân hàng cạn sạch số dư (hoặc chạm giới hạn gas).
  6. *Bước 6 (Cập nhật muộn màng)*: Chỉ khi toàn bộ các hàm gọi đệ quy kết thúc, dòng `balances[msg.sender] = 0;` mới được thực thi, nhưng lúc này toàn bộ ngân quỹ đã biến mất.
- **Hai cách khắc phục và so sánh**:
  - *Cách 1: Quy tắc Checks - Effects - Interactions (CEI)*: Đổi thứ tự, gán `balances[msg.sender] = 0;` TRƯỚC KHI thực hiện `call{value}`. Ưu điểm: Không tốn thêm gas cho biến trạng thái mutex, không phụ thuộc thư viện ngoài. Nhược điểm: Cần kỷ luật lập trình viên cao.
  - *Cách 2: OpenZeppelin ReentrancyGuard*: Sử dụng modifier `nonReentrant` để khóa mutex hàm. Ưu điểm: Chắc chắn, an toàn kể cả khi logic phức tạp gọi chéo nhiều hàm. Nhược điểm: Tốn thêm một thao tác ghi SSTORE/SLOAD cho biến trạng thái khóa.

**Đánh giá:** ✅ Dùng được ngay. Phân tích chi tiết từng bước đúng yêu cầu sư phạm, giải thích sâu bản chất kế toán "chi tiền trước khi ghi sổ".  
**Chỗ sai:** Không có.  
**Cách sửa:** Giữ nguyên phân tích, sử dụng làm cơ sở dựng sơ đồ bảng vẽ cho báo cáo thực nghiệm.  
**Ai phát hiện:** Sinh viên định hướng câu hỏi chuẩn theo mẫu I.4.

---

## Lần 2: Sinh mã hai bản vá lỗi `SafeBankCEI` và `SafeBankGuard`

**Thời gian:** 13/10/2026  
**Người thực hiện:** Phan Thành Đạt  

**Prompt:**
> "Hãy viết mã nguồn hai hợp đồng vá lỗi SafeBankCEI và SafeBankGuard theo đúng chuẩn Solidity ^0.8.20 và OpenZeppelin v5.
> Yêu cầu:
> 1. SafeBankCEI: Khắc phục lỗi bằng thứ tự dòng lệnh (Checks - Effects - Interactions), không dùng thư viện ngoài.
> 2. SafeBankGuard: Kế thừa ReentrancyGuard của OpenZeppelin v5, áp dụng nonReentrant.
> 3. Trả lời rõ câu hỏi phỏng vấn: Thứ chặn được cuộc tấn công ở Cách 1 là gì? Có phải là từ khóa nonReentrant không?"

**AI trả về:**
- Mã nguồn `SafeBankCEI` và `SafeBankGuard`.
- Câu trả lời phỏng vấn:
  > *"Thứ chặn được cuộc tấn công ở Cách 1 chính là **thứ tự các dòng lệnh**, tuyệt đối không liên quan đến từ khóa hay thư viện nào. Khi dòng `balances[msg.sender] = 0;` được đẩy lên trước lệnh `call`, thì ngay tại lần gọi đệ quy thứ hai, điều kiện `require(balances[msg.sender] > 0)` đã thất bại và giao dịch bị chặn đứng ngay lập tức."*

**Đánh giá:** ⚠️ Phải sửa nhỏ.  
**Chỗ sai:** Trong mã nguồn ban đầu của `SafeBankCEI`, AI dùng `msg.sender.transfer(bal);` thay vì `msg.sender.call{value: bal}("")`. Đây là vi phạm Điều 4 trong `AGENTS.md` ("Tuyệt đối không dùng .transfer() hoặc .send() vì giới hạn cứng 2.300 gas").  
**Cách sửa:** Sinh viên phát hiện và sửa lại thành `(bool ok, ) = msg.sender.call{value: bal}(""); require(ok, "Chuyen that bai");` để đúng quy ước học phần.  
**Ai phát hiện:** **Sinh viên phát hiện** (Phan Thành Đạt).

---

## Lần 3: Soi lại `ProjectCore.sol`, Hardening và thiết kế Negative Tests

**Thời gian:** 13/10/2026  
**Người thực hiện:** Phan Thành Đạt & Nguyễn Hữu Bằng  

**Prompt:**
> "Rà soát toàn bộ hợp đồng contracts/project/ProjectCore.sol:
> 1. Tìm mọi vị trí có chuyển tiền ETH ra ngoài.
> 2. Phân tích xem hàm withdrawFees(address payable recipient) hiện tại đã an toàn trước Reentrancy chưa?
> 3. Đề xuất phương án phòng thủ chuyên sâu (defense-in-depth): Kết hợp cả CEI và ReentrancyGuard của OpenZeppelin v5.
> 4. Liệt kê các ca kiểm thử thất bại (negative tests) cần viết cho ProjectCore: sai người gọi, sai địa chỉ nhận, số dư bằng 0, nạp thiếu phí, sửa trái phép metadata, thu hồi không quyền."

**AI trả về:**
- **Kết quả rà soát điểm chuyển tiền**:
  - Hợp đồng `ProjectCore.sol` chỉ có DUY NHẤT một hàm chuyển tiền ETH ra ngoài là `withdrawFees(address payable recipient)`.
  - Hàm `registerDocument` và `createRecord` chỉ nhận tiền (`msg.value >= registrationFee`), không chuyển tiền ra ngoài.
  - Các hàm khác (`updateMetadata`, `revokeDocument`, `verifyDocument`) không luân chuyển ETH.
- **Đánh giá mức độ an toàn của `withdrawFees`**:
  - Hiện tại hàm đã có CEI: `emit FundsWithdrawn` và tính toán số dư trước lệnh `call`.
  - Tuy nhiên, nếu địa chỉ ví nhận `recipient` là một hợp đồng thông minh độc hại, khi nó nhận ETH, hàm `receive()` của nó có thể cố tình gọi lại các hàm trạng thái khác của `ProjectCore` (Cross-function Reentrancy).
  - Do đó, việc kế thừa thêm `ReentrancyGuard` và bổ sung modifier `nonReentrant` cho `withdrawFees` là giải pháp tăng cường an ninh cấp độ tổ chức (Defense-in-Depth).
- **Danh sách Negative Test Cases đề xuất**:
  1. Kẻ lạ gọi `withdrawFees` -> Revert `OwnableUnauthorizedAccount`.
  2. Rút tiền về `address(0)` -> Revert `InvalidRecipient`.
  3. Rút tiền khi số dư `balance == 0` -> Revert `ZeroBalance`.
  4. Hợp đồng nhận tiền cố tình re-enter `withdrawFees` -> Revert `ReentrancyGuardReentrantCall`.
  5. Đăng ký tài liệu nạp thiếu phí -> Revert `InsufficientFee`.
  6. Sửa metadata khi không phải tác giả -> Revert `NotDocumentOwner`.
  7. Thu hồi tài liệu khi không phải Admin -> Revert `OwnableUnauthorizedAccount`.

**Đánh giá:** ✅ Dùng được ngay. Rất sát với yêu cầu Bước 5 của Sổ tay thực hành.  
**Chỗ sai:** Không có.  
**Cách sửa:** Nhóm tiến hành cập nhật mã nguồn `contracts/project/ProjectCore.sol` và hiện thực hóa toàn bộ 10 ca kiểm thử trong `test/Lab13_ReentrancyHardening.test.js`.  
**Ai phát hiện:** Sinh viên và AI đồng thuận thẩm định.

---

## Bảng tổng hợp các phát hiện rà soát theo quy chuẩn chấm điểm Lab 13

| STT | Vấn đề an toàn / Nghiệp vụ | Ai phát hiện | Cách khắc phục |
| :---: | :--- | :---: | :--- |
| **1** | Lỗ hổng Reentrancy rút cạn ngân quỹ trên `VulnerableBank.sol` do chuyển tiền trước khi cập nhật sổ sách | **AI & Sinh viên** | Đảo thứ tự dòng lệnh (CEI) trong `SafeBankCEI` và dùng `ReentrancyGuard` trong `SafeBankGuard`. |
| **2** | AI sinh mã dùng lệnh lỗi thời `.transfer()` trong bản vá `SafeBankCEI` vi phạm quy ước `AGENTS.md` | **Sinh viên phát hiện** | Sửa thành `msg.sender.call{value: bal}("")` kèm `require(ok)`. |
| **3** | Hàm `withdrawFees` trong `ProjectCore.sol` chưa có khóa chống gọi lại cấp hợp đồng | **Sinh viên phát hiện** | Kế thừa OpenZeppelin `ReentrancyGuard` và bổ sung modifier `nonReentrant` cho `withdrawFees`. |
| **4** | Cần kiểm tra giá trị biên: Quản trị viên vô ý rút quỹ về `address(0)` làm mất ETH | **Sinh viên phát hiện** | Thêm điều kiện `if (recipient == address(0)) revert InvalidRecipient();`. |
| **5** | Rút quỹ khi số dư trống rỗng (`address(this).balance == 0`) gây lãng phí gas | **Sinh viên phát hiện** | Thêm điều kiện `if (amount == 0) revert ZeroBalance();`. |
