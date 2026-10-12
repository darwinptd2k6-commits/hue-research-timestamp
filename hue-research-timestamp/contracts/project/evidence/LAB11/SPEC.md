# Đặc tả Kỹ thuật & Quy tắc Kinh tế (Lab 11)

## 1. Thông tin Hợp đồng
- **Tên Token:** Project Core Token (PCT)
- **Chuẩn:** ERC20 (OpenZeppelin v5)
- **Mạng:** Sepolia Testnet

## 2. Các Quy tắc Kinh tế (Tokenomics Rules)
- **Phí giao dịch (Fee):** 1% (`feeBps = 100`) trên các giao dịch chuyển thông thường, được tự động trích chuyển về ví quỹ lớp (`classFund`).
- **Trần nắm giữ (Max Holding):** Giới hạn tối đa mỗi ví người dùng chỉ được nắm giữ 2% tổng cung (`maxHolding = totalSupply() * 2 / 100`) để tránh tình trạng cá voi thâu tóm token.
- **Quyền quản trị (Ownership):** Kế thừa từ `Ownable`, cho phép chủ sở hữu khởi tạo và kiểm soát các tham số cơ bản.
