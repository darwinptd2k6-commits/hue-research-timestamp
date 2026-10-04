// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ProjectCore
 * @notice Hợp đồng quản lý dấu thời gian ý tưởng nghiên cứu khoa học (Hue Research Timestamp)
 *         theo mô hình RecordRegistry (M.3) của môn học ECO2432.
 * @dev Tuân thủ nghiêm ngặt quy chuẩn kiểm toán bảo mật và tối ưu gas:
 *      1. Checks-Effects-Interactions (CEI): Kiểm tra điều kiện -> Cập nhật trạng thái -> Phát sự kiện.
 *      2. Chống ghi đè (Anti-collision): Kiểm tra mốc thời gian != 0 với custom error AlreadyExists().
 *      3. Tối ưu hóa lưu trữ (Storage Slot Packing): Đóng gói `address subject` (20 bytes) và `bool revoked` (1 byte)
 *         chung 1 slot 32 bytes giúp tiết kiệm 20,000 gas SSTORE khi khởi tạo bản ghi.
 *      4. Tra cứu không tốn gas: Hàm `verify` và `getRecord` là `view` (thực thi qua eth_call ở client-side).
 *      5. Bảo mật xác thực: Dùng `msg.sender`, tuyệt đối không dùng `tx.origin`.
 */
contract ProjectCore {

    // --- CẤU TRÚC DỮ LIỆU (TỐI ƯU HÓA STORAGE SLOT) ---
    struct Record {
        bytes32 docHash;    // Slot 0: 32 bytes (Mã băm SHA-256 / Keccak-256)
        uint256 timestamp;  // Slot 1: 32 bytes (Mốc thời gian đóng dấu block.timestamp)
        address subject;    // Slot 2: 20 bytes (Địa chỉ tác giả / chủ thể công trình)
        bool revoked;       // Slot 2: 1 byte  (Trạng thái thu hồi - Pack cùng Slot 2 = 21/32 bytes)
        address issuer;     // Slot 3: 20 bytes (Địa chỉ người phát hành bản ghi)
        string metadata;    // Slot 4: Chuỗi mô tả / URI lưu trữ
    }

    // --- LƯU TRỮ TRẠNG THÁI ---
    mapping(bytes32 => Record) private _records;

    // --- CUSTOM ERRORS (Tối ưu gas theo Solidity 0.8.20) ---
    error AlreadyExists();
    error NotIssuer();
    error NotFound();

    // --- SỰ KIỆN (EVENTS) ---
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

    // --- HÀM NGHIỆP VỤ ---

    /**
     * @notice Tạo bản ghi dấu thời gian mới cho tài liệu nghiên cứu
     * @dev Áp dụng nghiêm ngặt CEI và kiểm tra chống ghi đè
     * @param docHash Mã băm 32 bytes của tài liệu nghiên cứu
     * @param subject Địa chỉ ví của tác giả / chủ sở hữu công trình
     * @param metadata Mô tả ngắn hoặc URI thông tin nghiên cứu
     */
    function createRecord(
        bytes32 docHash,
        address subject,
        string calldata metadata
    ) external {
        // 1. CHECKS: Kiểm tra mã băm đã tồn tại hay chưa
        if (_records[docHash].timestamp != 0) {
            revert AlreadyExists();
        }

        // 2. EFFECTS: Ghi bản ghi vào storage (tận dụng slot packing)
        _records[docHash] = Record({
            docHash: docHash,
            timestamp: block.timestamp,
            subject: subject,
            revoked: false,
            issuer: msg.sender,
            metadata: metadata
        });

        // 3. INTERACTIONS / LOGS: Phát event thông báo
        emit RecordCreated(
            docHash,
            subject,
            msg.sender,
            block.timestamp,
            metadata
        );
    }

    /**
     * @notice Thu hồi bản ghi dấu thời gian nếu phát hiện sai phạm hoặc đạo văn
     * @dev Chỉ người phát hành ban đầu (issuer) mới có thẩm quyền thu hồi
     * @param docHash Mã băm của tài liệu cần thu hồi
     */
    function revokeRecord(bytes32 docHash) external {
        Record storage record = _records[docHash];

        // 1. CHECKS: Kiểm tra tồn tại và quyền của người gọi
        if (record.timestamp == 0) {
            revert NotFound();
        }
        if (record.issuer != msg.sender) {
            revert NotIssuer();
        }

        // 2. EFFECTS: Cập nhật trạng thái thu hồi
        record.revoked = true;

        // 3. INTERACTIONS / LOGS: Phát event thu hồi
        emit RecordRevoked(docHash, msg.sender);
    }

    /**
     * @notice Thẩm định và tra cứu trạng thái tồn tại và tính hợp lệ của bản ghi (Miễn phí gas)
     * @param docHash Mã băm của tài liệu cần kiểm tra
     * @return exists Trạng thái tồn tại của bản ghi trên hệ thống
     * @return isValid Tính hợp lệ (đã tồn tại và chưa bị thu hồi)
     */
    function verify(bytes32 docHash)
        external
        view
        returns (bool exists, bool isValid)
    {
        Record memory record = _records[docHash];
        if (record.timestamp == 0) {
            return (false, false);
        }
        return (true, !record.revoked);
    }

    /**
     * @notice Lấy thông tin chi tiết đầy đủ của một bản ghi (Miễn phí gas)
     * @param docHash Mã băm tài liệu cần tra cứu
     * @return record Cấu trúc Record lưu trữ trên chuỗi
     */
    function getRecord(bytes32 docHash) external view returns (Record memory record) {
        record = _records[docHash];
        if (record.timestamp == 0) {
            revert NotFound();
        }
    }
}
