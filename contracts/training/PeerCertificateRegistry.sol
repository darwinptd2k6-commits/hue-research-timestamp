// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title PeerCertificateRegistry (Hợp đồng của Nhóm bạn - Nhóm 8: Xác thực chứng nhận khóa học)
 * @notice Mã nguồn do Nhóm 8 bàn giao cho Nhóm 9 (Hue Research Timestamp) thực hiện Cross-Audit tại Lab 14.
 * @dev Hợp đồng này chứa một số lỗi bảo mật và vi phạm checklist kiểm toán 10 hạng mục của Sổ tay ECO2432.
 */
contract PeerCertificateRegistry {

    struct Certificate {
        bytes32 certHash;
        address student;
        uint256 issueDate;
        string courseName;
        bool isRevoked;
    }

    address public admin;
    uint256 public certFee = 0.002 ether;
    mapping(bytes32 => Certificate) public certificates;
    bytes32[] public allCertHashes;

    event CertificateIssued(bytes32 indexed certHash, address indexed student);
    event CertificateRevoked(bytes32 indexed certHash);

    constructor() {
        admin = msg.sender;
    }

    // [LỖI 1 - Hạng mục 10]: Thiếu kiểm tra student != address(0)
    // [LỖI 2 - Hạng mục 9]: Cho phép thu thừa tiền mà không hoàn trả
    function issueCertificate(bytes32 certHash, address student, string memory courseName) external payable {
        require(msg.value >= certFee, "Thieu phi");
        require(certificates[certHash].issueDate == 0, "Da ton tai");

        certificates[certHash] = Certificate({
            certHash: certHash,
            student: student,
            issueDate: block.timestamp,
            courseName: courseName,
            isRevoked: false
        });

        allCertHashes.push(certHash);
        emit CertificateIssued(certHash, student);
    }

    // [LỖI 3 - Hạng mục 1]: HÀM NHẠY CẢM QUÊN KIỂM TRA QUYỀN ADMIN! Bất kỳ ai cũng thu hồi được chứng chỉ của người khác
    function revokeCertificate(bytes32 certHash) external {
        require(certificates[certHash].issueDate != 0, "Khong tim thay");
        certificates[certHash].isRevoked = true;
        emit CertificateRevoked(certHash);
    }

    // [LỖI 4 - Hạng mục 7]: Vòng lặp duyệt mảng động không giới hạn độ dài -> Nguy cơ Out-of-Gas DoS
    function getAllActiveCertificates() external view returns (bytes32[] memory) {
        uint256 activeCount = 0;
        for (uint256 i = 0; i < allCertHashes.length; i++) {
            if (!certificates[allCertHashes[i]].isRevoked) {
                activeCount++;
            }
        }
        bytes32[] memory activeList = new bytes32[](activeCount);
        uint256 index = 0;
        for (uint256 i = 0; i < allCertHashes.length; i++) {
            if (!certificates[allCertHashes[i]].isRevoked) {
                activeList[index++] = allCertHashes[i];
            }
        }
        return activeList;
    }

    // [LỖI 5 - Hạng mục 5 & 2]: Rút quỹ dùng .transfer() (giới hạn 2300 gas) và không dùng Custom Error
    function withdraw(address payable recipient) external {
        require(msg.sender == admin, "Khong phai admin");
        require(address(this).balance > 0, "So du rong");
        // Vi phạm AGENTS.md Điều 4: Dùng transfer thay vì call
        recipient.transfer(address(this).balance);
    }
}
