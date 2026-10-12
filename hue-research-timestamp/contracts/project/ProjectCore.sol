// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title ProjectCore - Hop dong chinh cua nhom co tich hop quy tac kinh te
contract ProjectCore is ERC20, Ownable {
    address public classFund;
    uint256 public feeBps = 100; // 100 điểm cơ bản = 1%
    uint256 public maxHolding;  // Trần nắm giữ của mỗi ví

    event FeeCollected(address indexed from, uint256 amount);
    error ExceedsMaxHolding(uint256 attempted, uint256 limit);

    constructor(address _classFund) 
        ERC20("Project Core Token", "PCT") 
        Ownable(msg.sender) 
    {
        require(_classFund != address(0), "Vi quy khong hop le");
        classFund = _classFund;
        
        // Phát hành 1 triệu token ban đầu cho chủ sở hữu
        _mint(msg.sender, 1_000_000 * 10 ** decimals());
        maxHolding = totalSupply() * 2 / 100; // Trần nắm giữ là 2% tổng cung
    }

    /// @dev Ghi đè hàm _update theo chuẩn OpenZeppelin v5 để thu phí và chặn trần nắm giữ
    function _update(address from, address to, uint256 value) internal override {
        bool isNormalTransfer = from != address(0) && to != address(0) && from != owner();

        // Thu phí 1% nếu là giao dịch thông thường chuyển cho ví quỹ
        if (isNormalTransfer && feeBps > 0) {
            uint256 fee = (value * feeBps) / 10_000;
            if (fee > 0) {
                super._update(from, classFund, fee);
                emit FeeCollected(from, fee);
                value -= fee; // Trừ đi phần phí trước khi chuyển phần còn lại cho người nhận
            }
        }

        super._update(from, to, value);

        // Kiểm tra trần nắm giữ sau khi giao dịch hoàn tất
        if (to != address(0) && to != classFund && to != owner()) {
            if (balanceOf(to) > maxHolding) {
                revert ExceedsMaxHolding(balanceOf(to), maxHolding);
            }
        }
    }
}
