// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title ProjectCore (Hue Research Timestamp)
 * @notice Hệ thống đóng dấu thời gian và xác thực quyền tác giả nghiên cứu khoa học
 *         dành cho Đại học Huế (Hue University).
 * @dev Tuân thủ nghiêm ngặt các quy ước trong AGENTS.md:
 *      - Solidity ^0.8.20, OpenZeppelin 5.x.
 *      - Checks-Effects-Interactions (CEI).
 *      - Custom errors thay vì chuỗi require dài.
 *      - Chuyển ETH an toàn bằng call{value: ...}(""), không dùng transfer.
 *      - Phát event đầy đủ cho mọi thay đổi trạng thái.
 *      - Không dùng tx.origin để xác thực.
 */
contract ProjectCore is Ownable, ReentrancyGuard {

    // --- CẤU TRÚC DỮ LIỆU ---
    struct ResearchDocument {
        bytes32 documentHash;   // Mã băm SHA-256 hoặc Keccak-256 của tài liệu
        address owner;          // Địa chỉ ví của tác giả / người đăng ký
        uint256 timestamp;      // Thời điểm khối được đóng dấu (block.timestamp)
        uint256 blockNumber;    // Số hiệu khối ghi nhận bản quyền (block.number)
        string title;           // Tên đề tài / công trình nghiên cứu
        string authors;         // Danh sách tác giả, MSSV, khoa/bộ môn
        string metadataURI;     // Đường dẫn IPFS hoặc URL lưu tóm tắt/metadata
        bool isRevoked;         // Đánh dấu thu hồi nếu phát hiện đạo văn
    }

    // --- BIẾN TRẠNG THÁI ---
    uint256 public registrationFee;
    uint256 public totalDocumentsRegistered;

    // Lưu trữ thông tin tài liệu theo mã băm (documentHash => ResearchDocument)
    mapping(bytes32 => ResearchDocument) private _documents;

    // Danh sách các mã băm đã đăng ký để hỗ trợ duyệt và kiểm kê
    bytes32[] private _allDocumentHashes;

    // --- CUSTOM ERRORS (Tối ưu gas theo AGENTS.md) ---
    error InvalidDocumentHash();
    error HashAlreadyExists(bytes32 documentHash, uint256 existingTimestamp);
    error InsufficientFee(uint256 requiredFee, uint256 sentFee);
    error DocumentNotFound();
    error NotDocumentOwner();
    error DocumentIsRevoked();
    error AlreadyRevoked();
    error InvalidRecipient();
    error NoFundsAvailable();
    error WithdrawFailed();

    // --- EVENTS (Mọi thay đổi trạng thái đều phát sự kiện) ---
    event DocumentTimestamped(
        bytes32 indexed documentHash,
        address indexed owner,
        uint256 timestamp,
        uint256 blockNumber,
        string title,
        string metadataURI
    );

    event MetadataUpdated(
        bytes32 indexed documentHash,
        address indexed owner,
        string newMetadataURI
    );

    event DocumentRevoked(
        bytes32 indexed documentHash,
        address indexed admin,
        string reason
    );

    event FeeUpdated(uint256 oldFee, uint256 newFee);

    event FundsWithdrawn(address indexed recipient, uint256 amount);

    /**
     * @dev Khởi tạo hợp đồng với người sở hữu ban đầu và mức phí đăng ký mặc định
     * @param initialOwner Địa chỉ quản trị viên (Admin trường hoặc đại diện nhóm)
     * @param initialFee Phí đóng dấu thời gian ban đầu (tính bằng wei)
     */
    constructor(address initialOwner, uint256 initialFee) Ownable(initialOwner) {
        registrationFee = initialFee;
    }

    // --- CÁC HÀM NGHIỆP VỤ CHÍNH ---

    /**
     * @notice Đăng ký đóng dấu thời gian cho một công trình nghiên cứu
     * @param documentHash Mã băm tài liệu (sinh ra từ client-side bằng Web Crypto API)
     * @param title Tên đề tài nghiên cứu
     * @param authors Tác giả / Nhóm tác giả
     * @param metadataURI Đường dẫn lưu trữ metadata (IPFS/URL)
     */
    function registerDocument(
        bytes32 documentHash,
        string calldata title,
        string calldata authors,
        string calldata metadataURI
    ) external payable {
        // 1. CHECKS
        if (documentHash == bytes32(0)) {
            revert InvalidDocumentHash();
        }
        if (_documents[documentHash].timestamp != 0) {
            revert HashAlreadyExists(documentHash, _documents[documentHash].timestamp);
        }
        if (msg.value < registrationFee) {
            revert InsufficientFee(registrationFee, msg.value);
        }

        // 2. EFFECTS
        _documents[documentHash] = ResearchDocument({
            documentHash: documentHash,
            owner: msg.sender,
            timestamp: block.timestamp,
            blockNumber: block.number,
            title: title,
            authors: authors,
            metadataURI: metadataURI,
            isRevoked: false
        });

        _allDocumentHashes.push(documentHash);
        totalDocumentsRegistered++;

        emit DocumentTimestamped(
            documentHash,
            msg.sender,
            block.timestamp,
            block.number,
            title,
            metadataURI
        );

        // 3. INTERACTIONS (Không cần tương tác ngoại vi trong hàm này)
    }

    /**
     * @notice Tra cứu và xác minh tính toàn vẹn của một công trình nghiên cứu
     * @param documentHash Mã băm tài liệu cần kiểm tra
     */
    function verifyDocument(bytes32 documentHash)
        external
        view
        returns (
            bool exists,
            address owner,
            uint256 timestamp,
            uint256 blockNumber,
            string memory title,
            string memory authors,
            string memory metadataURI,
            bool isRevoked
        )
    {
        ResearchDocument memory doc = _documents[documentHash];
        if (doc.timestamp == 0) {
            return (false, address(0), 0, 0, "", "", "", false);
        }

        return (
            true,
            doc.owner,
            doc.timestamp,
            doc.blockNumber,
            doc.title,
            doc.authors,
            doc.metadataURI,
            doc.isRevoked
        );
    }

    /**
     * @notice Lấy thông tin cấu trúc đầy đủ của tài liệu
     * @param documentHash Mã băm của tài liệu
     */
    function getDocument(bytes32 documentHash) external view returns (ResearchDocument memory) {
        ResearchDocument memory doc = _documents[documentHash];
        if (doc.timestamp == 0) {
            revert DocumentNotFound();
        }
        return doc;
    }

    /**
     * @notice Cho phép tác giả cập nhật metadata (bổ sung DOI, link bài báo sau khi nghiệm thu)
     * @dev Tuyệt đối không thay đổi documentHash hoặc timestamp ban đầu
     */
    function updateMetadata(bytes32 documentHash, string calldata newMetadataURI) external {
        ResearchDocument storage doc = _documents[documentHash];

        // 1. CHECKS
        if (doc.timestamp == 0) {
            revert DocumentNotFound();
        }
        if (doc.owner != msg.sender) {
            revert NotDocumentOwner();
        }
        if (doc.isRevoked) {
            revert DocumentIsRevoked();
        }

        // 2. EFFECTS
        doc.metadataURI = newMetadataURI;

        emit MetadataUpdated(documentHash, msg.sender, newMetadataURI);
    }

    // --- CÁC HÀM QUẢN TRỊ (ADMIN FUNCTIONS) ---

    /**
     * @notice Đánh dấu thu hồi chứng nhận nếu phát hiện vi phạm liêm chính khoa học / đạo văn
     * @param documentHash Mã băm của tài liệu vi phạm
     * @param reason Lý do thu hồi (ghi nhận công khai minh bạch)
     */
    function revokeDocument(bytes32 documentHash, string calldata reason) external onlyOwner {
        ResearchDocument storage doc = _documents[documentHash];

        // 1. CHECKS
        if (doc.timestamp == 0) {
            revert DocumentNotFound();
        }
        if (doc.isRevoked) {
            revert AlreadyRevoked();
        }

        // 2. EFFECTS
        doc.isRevoked = true;

        emit DocumentRevoked(documentHash, msg.sender, reason);
    }

    /**
     * @notice Thay đổi mức phí đăng ký đóng dấu thời gian
     * @param newFee Mức phí mới tính bằng wei
     */
    function setRegistrationFee(uint256 newFee) external onlyOwner {
        uint256 oldFee = registrationFee;
        registrationFee = newFee;

        emit FeeUpdated(oldFee, newFee);
    }

    /**
     * @notice Rút phí dịch vụ tích lũy về quỹ nghiên cứu / kho bạc dự án
     * @dev Tuân thủ Checks-Effects-Interactions và áp dụng nonReentrant chống tấn công reentrancy
     * @param recipient Địa chỉ ví thụ hưởng (Quỹ NCKH sinh viên & NCKH Đại học Huế)
     */
    function withdrawFees(address payable recipient) external onlyOwner nonReentrant {
        // 1. CHECKS
        if (recipient == address(0)) {
            revert InvalidRecipient();
        }
        uint256 amount = address(this).balance;
        if (amount == 0) {
            revert NoFundsAvailable();
        }

        // 2. EFFECTS
        emit FundsWithdrawn(recipient, amount);

        // 3. INTERACTIONS (Chuyển tiền an toàn bằng call theo AGENTS.md)
        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert WithdrawFailed();
        }
    }

    /**
     * @notice Lấy tổng số lượng mã băm đã đăng ký
     */
    function getTotalDocuments() external view returns (uint256) {
        return _allDocumentHashes.length;
    }

    /**
     * @notice Lấy mã băm tại chỉ mục chỉ định
     */
    function getDocumentHashAtIndex(uint256 index) external view returns (bytes32) {
        return _allDocumentHashes[index];
    }
}
