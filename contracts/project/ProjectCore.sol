// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title ProjectCore
 * @notice Hợp đồng quản lý dấu thời gian ý tưởng nghiên cứu khoa học (Hue Research Timestamp)
 *         theo mô hình RecordRegistry (M.3) của môn học ECO2432 (Trường ĐH Kinh tế - ĐH Huế).
 * @dev Tuân thủ nghiêm ngặt quy chuẩn an toàn bảo mật, quy tắc kinh tế và tối ưu gas:
 *      1. Quy tắc kinh tế Lab 11: Yêu cầu phí nạp bắt buộc (registrationFee = 0.001 ETH mặc định)
 *         nhằm chống spam lưu trữ (Anti-Spam), tự chủ hạ tầng IPFS/RPC và tài trợ NCKH sinh viên.
 *      2. Checks-Effects-Interactions (CEI): Kiểm tra điều kiện -> Cập nhật trạng thái -> Tương tác / Logs.
 *      3. Phòng chống tấn công tái nhập (Reentrancy Hardening - Lab 13):
 *         Bảo vệ hàm rút quỹ `withdrawFees` bằng cả hai lớp phòng thủ chuyên sâu:
 *         - Lớp 1 (CEI): Phát sự kiện và kiểm tra số dư trước khi chuyển ETH.
 *         - Lớp 2 (ReentrancyGuard): Khóa modifier `nonReentrant` của OpenZeppelin ngăn chặn mọi cuộc gọi lại.
 *      4. Chống ghi đè (Anti-collision): Kiểm tra mã băm tài liệu đã tồn tại với HashAlreadyExists().
 *      5. Tối ưu hóa lưu trữ (Storage Slot Packing): Đóng gói `address owner` (20 bytes) và `bool isRevoked` (1 byte)
 *         vào cùng Slot 3 (21/32 bytes) giúp tiết kiệm 20,000 gas SSTORE khi tạo bản ghi mới.
 *      6. Tra cứu miễn phí gas: Các hàm `verifyDocument`, `verify`, `getDocument`, `getRecord` là `view`.
 *      7. Chuyển ETH an toàn: Rút quỹ dùng lệnh cấp thấp `.call{value: amount}("")` kết hợp revert WithdrawFailed(),
 *         tuyệt đối không dùng `.transfer()` hoặc `.send()`.
 *      8. Bảo mật danh tính: Dùng `msg.sender`, tuyệt đối không dùng `tx.origin`.
 */
contract ProjectCore is Ownable, ReentrancyGuard {

    // --- CẤU TRÚC DỮ LIỆU BẢN GHI (TỐI ƯU HÓA STORAGE SLOT) ---
    struct Record {
        bytes32 documentHash;   // Slot 0: 32 bytes (Mã băm SHA-256 / Keccak-256)
        uint256 timestamp;      // Slot 1: 32 bytes (Mốc thời gian đóng dấu block.timestamp)
        uint256 blockNumber;    // Slot 2: 32 bytes (Số hiệu khối ghi nhận trên mạng)
        address owner;          // Slot 3: 20 bytes (Địa chỉ ví tác giả / người đăng ký)
        bool isRevoked;         // Slot 3: 1 byte  (Trạng thái thu hồi - Pack cùng Slot 3 = 21/32 bytes)
        string title;           // Slot 4: Tiêu đề công trình nghiên cứu
        string authors;         // Slot 5: Tác giả / Bộ môn nghiên cứu
        string metadataURI;     // Slot 6: URI tóm tắt / IPFS Hash
        string revokeReason;    // Slot 7: Lý do thu hồi (nếu bị kỷ luật học thuật)
    }

    // --- LƯU TRỮ TRẠNG THÁI ---
    mapping(bytes32 => Record) private _documents;
    uint256 public registrationFee;
    uint256 public totalDocuments;

    /// @notice Mức trần phí tối đa bảo vệ người dùng tránh lỗi cấu hình DoS (Lab 14 Audit Remediation)
    uint256 public constant MAX_REGISTRATION_FEE = 0.05 ether;

    // --- CUSTOM ERRORS (Tối ưu gas theo chuẩn Solidity 0.8.20) ---
    error InsufficientFee(uint256 requiredFee, uint256 sentFee);
    error InvalidDocumentHash();
    error HashAlreadyExists(bytes32 documentHash, uint256 existingTimestamp);
    error DocumentNotFound();
    error NotDocumentOwner();
    error DocumentIsRevoked();
    error AlreadyRevoked();
    error InvalidRecipient();
    error ZeroBalance();
    error WithdrawFailed();
    error FeeExceedsLimit(uint256 attemptedFee, uint256 maxLimit);
    error RefundFailed();

    // Các lỗi kế thừa tương thích ngược với Lab 9 & Lab 10
    error AlreadyExists();
    error NotIssuer();
    error NotFound();

    // --- SỰ KIỆN (EVENTS) ---
    event DocumentTimestamped(
        bytes32 indexed documentHash,
        address indexed owner,
        uint256 timestamp,
        uint256 blockNumber,
        string title
    );

    event FeeCollected(
        address indexed payer,
        uint256 amount
    );

    event MetadataUpdated(
        bytes32 indexed documentHash,
        address indexed owner,
        string newMetadataURI
    );

    event DocumentRevoked(
        bytes32 indexed documentHash,
        address indexed authority,
        string reason
    );

    event FeeUpdated(
        uint256 oldFee,
        uint256 newFee
    );

    event FundsWithdrawn(
        address indexed authority,
        address indexed recipient,
        uint256 amount
    );

    // Sự kiện tương thích ngược với Lab 9
    event RecordCreated(
        bytes32 indexed docHash,
        address indexed subject,
        address indexed issuer,
        uint256 timestamp,
        string metadata
    );

    event RecordRevoked(
        bytes32 indexed docHash,
        address indexed issuer
    );

    /**
     * @notice Khởi tạo hợp đồng ProjectCore với quyền sở hữu và mức phí ban đầu
     * @param initialOwner Địa chỉ ví của Quản trị viên / Nhà trường
     * @param initialFee Mức phí dịch vụ đăng ký ban đầu (ví dụ: 0.001 ETH = 1000000000000000 wei)
     */
    constructor(address initialOwner, uint256 initialFee)
        Ownable(initialOwner != address(0) ? initialOwner : msg.sender)
    {
        registrationFee = initialFee > 0 ? initialFee : 0.001 ether;
    }

    // --- CÁC HÀM NGHIỆP VỤ CỐT LÕI (LAB 11 - QUY TẮC KINH TẾ) ---

    /**
     * @notice Đăng ký đóng dấu thời gian cho tài liệu nghiên cứu (có thu phí dịch vụ kinh tế)
     * @dev Tuân thủ Checks-Effects-Interactions và kiểm tra phí msg.value >= registrationFee
     * @param documentHash Mã băm SHA-256 của tài liệu nghiên cứu (32 bytes)
     * @param title Tiêu đề công trình / đề tài khoa học
     * @param authors Danh sách tác giả, MSSV, khoa viện
     * @param metadataURI Đường dẫn lưu trữ IPFS hoặc link xuất bản
     */
    function registerDocument(
        bytes32 documentHash,
        string calldata title,
        string calldata authors,
        string calldata metadataURI
    ) external payable {
        // 1. CHECKS (Kiểm tra quy tắc kinh tế & tính toàn vẹn dữ liệu)
        if (msg.value < registrationFee) {
            revert InsufficientFee(registrationFee, msg.value);
        }
        if (documentHash == bytes32(0)) {
            revert InvalidDocumentHash();
        }
        if (_documents[documentHash].timestamp != 0) {
            revert HashAlreadyExists(documentHash, _documents[documentHash].timestamp);
        }

        // 2. EFFECTS (Cập nhật trạng thái bộ nhớ storage)
        _documents[documentHash] = Record({
            documentHash: documentHash,
            timestamp: block.timestamp,
            blockNumber: block.number,
            owner: msg.sender,
            isRevoked: false,
            title: title,
            authors: authors,
            metadataURI: metadataURI,
            revokeReason: ""
        });
        totalDocuments++;

        // 3. INTERACTIONS / LOGS (Phát sự kiện định danh on-chain)
        emit DocumentTimestamped(
            documentHash,
            msg.sender,
            block.timestamp,
            block.number,
            title
        );
        emit FeeCollected(msg.sender, registrationFee);

        // [Lab 14 Audit Remediation]: Hoàn trả phần ETH nạp thừa an toàn theo chuẩn CEI
        uint256 excess = msg.value - registrationFee;
        if (excess > 0) {
            (bool refundSuccess, ) = msg.sender.call{value: excess}("");
            if (!refundSuccess) {
                revert RefundFailed();
            }
        }
    }

    /**
     * @notice Cập nhật liên kết siêu dữ liệu (DOI, IPFS link) cho công trình nghiên cứu
     * @dev Chỉ chủ sở hữu ban đầu (owner) của tài liệu mới có quyền cập nhật
     * @param documentHash Mã băm tài liệu cần cập nhật
     * @param newMetadataURI Đường dẫn metadata mới
     */
    function updateMetadata(
        bytes32 documentHash,
        string calldata newMetadataURI
    ) external {
        Record storage doc = _documents[documentHash];

        if (doc.timestamp == 0) {
            revert DocumentNotFound();
        }
        if (doc.owner != msg.sender) {
            revert NotDocumentOwner();
        }
        if (doc.isRevoked) {
            revert DocumentIsRevoked();
        }

        doc.metadataURI = newMetadataURI;
        emit MetadataUpdated(documentHash, msg.sender, newMetadataURI);
    }

    /**
     * @notice Thu hồi chứng nhận dấu thời gian khi phát hiện hành vi đạo văn hoặc vi phạm học thuật
     * @dev Chỉ Quản trị viên (Chủ sở hữu / Hội đồng thẩm định) mới có quyền thu hồi
     * @param documentHash Mã băm tài liệu vi phạm
     * @param reason Lý do kỷ luật học thuật được ghi minh bạch lên chuỗi
     */
    function revokeDocument(
        bytes32 documentHash,
        string calldata reason
    ) external onlyOwner {
        Record storage doc = _documents[documentHash];

        if (doc.timestamp == 0) {
            revert DocumentNotFound();
        }
        if (doc.isRevoked) {
            revert AlreadyRevoked();
        }

        doc.isRevoked = true;
        doc.revokeReason = reason;
        emit DocumentRevoked(documentHash, msg.sender, reason);
    }

    // --- QUẢN TRỊ KHO BẠC & RÚT QUỸ (TREASURY GOVERNANCE) ---

    /**
     * @notice Điều chỉnh mức phí dịch vụ đăng ký tài liệu
     * @dev Chỉ Quản trị viên (onlyOwner) mới có quyền thay đổi
     * @param newFee Mức phí mới tính theo đơn vị wei
     */
    function setRegistrationFee(uint256 newFee) external onlyOwner {
        if (newFee > MAX_REGISTRATION_FEE) {
            revert FeeExceedsLimit(newFee, MAX_REGISTRATION_FEE);
        }
        uint256 oldFee = registrationFee;
        registrationFee = newFee;
        emit FeeUpdated(oldFee, newFee);
    }

    /**
     * @notice Rút doanh thu tích lũy về ví kho bạc nghiên cứu khoa học
     * @dev Tuân thủ Checks-Effects-Interactions (CEI), kết hợp modifier nonReentrant (Lab 13 Hardening)
     *      và chuyển ETH an toàn bằng lệnh .call
     * @param recipient Địa chỉ ví nhận tiền của Quỹ NCKH Đại học Huế
     */
    function withdrawFees(address payable recipient) external onlyOwner nonReentrant {
        if (recipient == address(0)) {
            revert InvalidRecipient();
        }
        uint256 amount = address(this).balance;
        if (amount == 0) {
            revert ZeroBalance();
        }

        // 1. Effects: Phát sự kiện trước khi chuyển tiền ra ngoài (Chống Reentrancy)
        emit FundsWithdrawn(msg.sender, recipient, amount);

        // 2. Interactions: Chuyển ETH an toàn bằng call cấp thấp
        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert WithdrawFailed();
        }
    }

    // --- CÁC HÀM TRA CỨU KHÔNG TỐN GAS (FREE GAS VIEW FUNCTIONS) ---

    /**
     * @notice Tra cứu và xác thực tính hợp lệ của tài liệu nghiên cứu
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
        Record memory doc = _documents[documentHash];
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
     * @notice Lấy toàn bộ thông tin bản ghi của một tài liệu nghiên cứu
     * @param documentHash Mã băm tài liệu
     */
    function getDocument(bytes32 documentHash)
        external
        view
        returns (Record memory)
    {
        Record memory doc = _documents[documentHash];
        if (doc.timestamp == 0) {
            revert DocumentNotFound();
        }
        return doc;
    }

    /**
     * @notice Lấy tổng số lượng tài liệu đã đăng ký trên hệ thống
     */
    function totalDocumentsRegistered() external view returns (uint256) {
        return totalDocuments;
    }

    // --- HÀM TƯƠNG THÍCH NGƯỢC (BACKWARDS COMPATIBILITY CHO LAB 9 & 10) ---

    /**
     * @notice Tạo bản ghi theo chuẩn RecordRegistry ban đầu (áp dụng kiểm tra phí kinh tế)
     */
    function createRecord(
        bytes32 docHash,
        address subject,
        string calldata metadata
    ) external payable {
        if (msg.value < registrationFee) {
            revert InsufficientFee(registrationFee, msg.value);
        }
        if (docHash == bytes32(0)) {
            revert InvalidDocumentHash();
        }
        if (_documents[docHash].timestamp != 0) {
            revert AlreadyExists();
        }

        address docOwner = subject != address(0) ? subject : msg.sender;
        _documents[docHash] = Record({
            documentHash: docHash,
            timestamp: block.timestamp,
            blockNumber: block.number,
            owner: docOwner,
            isRevoked: false,
            title: "Research Record",
            authors: "",
            metadataURI: metadata,
            revokeReason: ""
        });
        totalDocuments++;

        emit RecordCreated(docHash, docOwner, msg.sender, block.timestamp, metadata);
        emit DocumentTimestamped(docHash, docOwner, block.timestamp, block.number, "Research Record");
        emit FeeCollected(msg.sender, msg.value);
    }

    /**
     * @notice Tra cứu nhanh trạng thái tồn tại và hiệu lực của bản ghi
     */
    function verify(bytes32 docHash)
        external
        view
        returns (bool exists, bool isValid)
    {
        Record memory doc = _documents[docHash];
        if (doc.timestamp == 0) {
            return (false, false);
        }
        return (true, !doc.isRevoked);
    }

    /**
     * @notice Lấy thông tin bản ghi cho các bộ kiểm tra cũ
     */
    function getRecord(bytes32 docHash) external view returns (Record memory) {
        Record memory doc = _documents[docHash];
        if (doc.timestamp == 0) {
            revert NotFound();
        }
        return doc;
    }

    /**
     * @notice Thu hồi bản ghi tương thích ngược
     */
    function revokeRecord(bytes32 docHash) external {
        Record storage doc = _documents[docHash];
        if (doc.timestamp == 0) {
            revert NotFound();
        }
        if (doc.owner != msg.sender && owner() != msg.sender) {
            revert NotIssuer();
        }
        doc.isRevoked = true;
        emit RecordRevoked(docHash, msg.sender);
        emit DocumentRevoked(docHash, msg.sender, "Revoked by issuer or owner");
    }
}

