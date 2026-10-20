// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title SafeBankCEI
 * @notice Khắc phục lỗ hổng Reentrancy bằng Cách 1: Checks-Effects-Interactions (CEI).
 * @dev Không cần thư viện bên ngoài, không tốn thêm gas cho biến khóa (reentrancy status flag).
 *      Mấu chốt bảo mật: Cập nhật sổ sách `balances[msg.sender] = 0;` TRƯỚC KHI thực hiện lệnh chuyển ETH ra ngoài.
 */
contract SafeBankCEI {
    mapping(address => uint256) public balances;

    event Deposited(address indexed account, uint256 amount);
    event Withdrawn(address indexed account, uint256 amount);

    function deposit() external payable {
        require(msg.value > 0, "So tien nap phai lon hon 0");
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function withdraw() external {
        // 1. CHECKS: Kiểm tra số dư người gọi
        uint256 bal = balances[msg.sender];
        require(bal > 0, "Khong co so du");

        // 2. EFFECTS: Cập nhật sổ sách TRƯỚC KHI chuyển tiền ra ngoài
        balances[msg.sender] = 0;
        emit Withdrawn(msg.sender, bal);

        // 3. INTERACTIONS: Chuyển ETH ra ngoài sau cùng
        (bool ok, ) = msg.sender.call{value: bal}("");
        require(ok, "Chuyen that bai");
    }

    function bankBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

/**
 * @title SafeBankGuard
 * @notice Khắc phục lỗ hổng Reentrancy bằng Cách 2: OpenZeppelin ReentrancyGuard (nonReentrant).
 * @dev Sử dụng khóa mutex trạng thái của OpenZeppelin Contracts v5.
 *      Mọi nỗ lực gọi lại hàm (re-entering) trong cùng một transaction sẽ bị revert với ReentrancyGuardReentrantCall().
 */
contract SafeBankGuard is ReentrancyGuard {
    mapping(address => uint256) public balances;

    event Deposited(address indexed account, uint256 amount);
    event Withdrawn(address indexed account, uint256 amount);

    function deposit() external payable {
        require(msg.value > 0, "So tien nap phai lon hon 0");
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function withdraw() external nonReentrant {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "Khong co so du");

        // Dù chuyển tiền trước hay sau, modifier nonReentrant đã khóa hàm withdraw
        (bool ok, ) = msg.sender.call{value: balance}("");
        require(ok, "Chuyen that bai");

        balances[msg.sender] = 0;
        emit Withdrawn(msg.sender, balance);
    }

    function bankBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
