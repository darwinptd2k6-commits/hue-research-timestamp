# NHẬT KÝ LÀM VIỆC VỚI AI - LAB 10: RÀ SOÁT MÃ NGUỒN DO AI SINH RA

## Lần 1: Rà soát và thẩm định bảo mật hợp đồng huấn luyện `VaultBuggy.sol`

**Thời gian:** 04/10/2026  
**Người thực hiện:** Nhóm sinh viên ECO2432 - Hue Research Timestamp  

**Prompt:**
> "Bạn là kiểm toán viên hợp đồng thông minh.
> Rà soát hợp đồng dưới đây và liệt kê mọi lỗ hổng, xếp theo mức nghiêm trọng.
> Với mỗi lỗ hổng, nêu: dòng số mấy, khai thác thế nào, sửa ra sao.
> 
> ```solidity
> // SPDX-License-Identifier: MIT
> pragma solidity ^0.8.20;
> 
> // CANH BAO: Tep nay co loi co y. Khong dung lai trong bai lam.
> contract VaultBuggy {
>     address public owner;
>     uint256 public unlockTime;
>     uint256 private emergencyPin;
> 
>     constructor(uint256 lockSeconds, uint256 pin) {
>         owner = msg.sender;
>         unlockTime = block.timestamp + lockSeconds;
>         emergencyPin = pin;
>     }
> 
>     function deposit() external payable {}
> 
>     function withdraw() external {
>         require(block.timestamp <= unlockTime, "Chua den han rut tien");
>         payable(msg.sender).transfer(address(this).balance);
>     }
> }
> ```"

**AI trả về:**
- Báo cáo phân tích 4 lỗ hổng nghiêm trọng được cài cắm trong `VaultBuggy.sol`:
  1. **Lộ dữ liệu nhạy cảm qua ô nhớ on-chain (Dòng 8)**: Biến `emergencyPin` được khai báo `private` nhưng vẫn có thể bị đọc công khai bằng RPC `eth_getStorageAt`.
  2. **Đảo ngược điều kiện khóa thời gian (Dòng 19)**: Sử dụng `<= unlockTime` thay vì `>= unlockTime`, cho phép rút trước hạn nhưng khóa tiền vĩnh viễn khi đã quá hạn.
  3. **Thiếu kiểm soát phân quyền (Dòng 18)**: Hàm `withdraw()` không kiểm tra `msg.sender == owner`, dẫn đến bất kỳ ai cũng có thể rút cạn quỹ của két.
  4. **Sử dụng `.transfer()` lỗi thời & không có CEI (Dòng 20)**: Sử dụng `.transfer()` với giới hạn 2300 gas gây lỗi với smart contract wallet; không phát event sau khi rút.

**Đánh giá:** ✅ Dùng được ngay (Phân tích chi tiết, chính xác số dòng và cách sửa).

---

### Bảng tổng hợp rà soát 4 lỗi trong `VaultBuggy.sol` (Theo chuẩn Sổ tay SV)

| Lỗi | Mô tả chi tiết & Vị trí dòng | Ai phát hiện | Cách khắc phục |
| :---: | :--- | :---: | :--- |
| **1** | **Thiếu kiểm tra phân quyền (Dòng 18-21)**:<br>Hàm `withdraw()` là `external` công khai nhưng không kiểm tra `msg.sender == owner`, bất kỳ ai cũng có thể gọi để rút sạch số dư trong két. | **Nguyễn Hữu Bằng** | Thêm kiểm tra điều kiện:<br>`if (msg.sender != owner) revert NotOwner();` |
| **2** | **Đảo ngược logic khóa thời gian (Dòng 19)**:<br>Dùng toán tử `<= unlockTime` khiến người dùng rút được tiền TRƯỚC hạn, nhưng sau khi qua thời hạn khóa thì két bị KHÓA VĨNH VIỄN. | **Phan Thành Đạt** | Đổi điều kiện kiểm tra đúng chiều:<br>`if (block.timestamp < unlockTime) revert StillLocked(unlockTime, block.timestamp);` |
| **3** | **Sử dụng `.transfer()` giới hạn cứng gas (Dòng 20)**:<br>Dùng `payable(msg.sender).transfer(...)` chỉ cấp 2300 gas, giao dịch sẽ bị lỗi nếu người nhận là Contract Wallet hoặc Multisig ví Gnosis Safe. | **AI phát hiện** | Thay bằng lệnh gọi cấp thấp:<br>`(bool ok, ) = payable(owner).call{value: amount}("");`<br>`if (!ok) revert TransferFailed();` |
| **4** | **Lầm tưởng tính riêng tư của từ khóa `private` (Dòng 8)**:<br>`emergencyPin` mang từ khóa `private` chỉ ngăn truy cập giữa các hợp đồng, hoàn toàn không mã hóa dữ liệu trên blockchain. | **AI phát hiện & Thực nghiệm chứng minh** | Đọc thực nghiệm trực tiếp ô nhớ thứ 2 qua Web3 RPC Console:<br>`await window.ethereum.request({ method: "eth_getStorageAt", params: [vaultAddress, "0x2", "latest"] });`<br>-> Khắc phục: Không lưu trữ secret/mã PIN dạng rõ lên on-chain. |

---

## Lần 2: Rà soát và củng cố bảo mật hợp đồng chính `ProjectCore.sol`

**Thời gian:** 04/10/2026  
**Người thực hiện:** Nhóm sinh viên ECO2432 - Hue Research Timestamp  

**Prompt:**
> "Bạn là kiểm toán viên hợp đồng thông minh. Rà soát hợp đồng chính ProjectCore.sol của nhóm và đối chiếu với SPEC.md.
> Kiểm tra các lỗ hổng: phân quyền, đảo ngược thời gian, lộ dữ liệu, Checks-Effects-Interactions, và tối ưu hóa gas."

**AI trả về:**
- Hợp đồng `ProjectCore.sol` đã đạt chuẩn bảo mật tuyệt đối:
  - Phân quyền: Kiểm tra chặt chẽ quyền `issuer` trong `createRecord` và `revokeRecord`.
  - Không lộ dữ liệu: Chỉ lưu `bytes32 docHash` và metadata URI, không lưu trữ dữ liệu nhạy cảm trên chuỗi.
  - CEI & Reentrancy: Tuân thủ nghiêm ngặt Checks -> Effects -> Logs.
  - Tối ưu Gas: Cấu trúc `struct Record` đã áp dụng **Storage Slot Packing** (ghép `address subject` và `bool revoked` vào cùng 1 slot 32 bytes) giúp tiết kiệm 20,000 gas.

**Đánh giá:** ✅ Dùng được ngay.

**Chỗ sai:** Không phát hiện thêm lỗ hổng bảo mật.

**Cách sửa:** Nhóm chốt phiên bản mã nguồn đã tối ưu và vượt qua toàn bộ 9/9 ca kiểm thử tự động.

**Ai phát hiện:** Sinh viên và AI cùng đối chiếu nghiệm thu.
