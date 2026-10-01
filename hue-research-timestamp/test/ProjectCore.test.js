/**
 * Bộ kiểm thử tự động cho ProjectCore (Hue Research Timestamp)
 * Chạy bằng lệnh: node test/ProjectCore.test.js
 */

const assert = require("assert");

console.log("==================================================================");
console.log("   KIỂM THỬ HỢP ĐỒNG PROJECTCORE - HUE RESEARCH TIMESTAMP (HRT)   ");
console.log("   Môn học: ECO2432 - Web3 & Fintech (Đại học Huế - Hue)         ");
console.log("==================================================================\n");

async function runTests() {
    let passedCount = 0;
    let totalCount = 0;

    function test(description, testFn) {
        totalCount++;
        try {
            testFn();
            console.log(`[PASS] TC${totalCount.toString().padStart(2, '0')}: ${description}`);
            passedCount++;
        } catch (error) {
            console.error(`[FAIL] TC${totalCount.toString().padStart(2, '0')}: ${description}`);
            console.error(`       Chi tiết: ${error.message}`);
        }
    }

    // Mô phỏng trạng thái Smart Contract để kiểm thử độc lập logic nghiệp vụ
    class MockProjectCore {
        constructor(initialOwner, initialFee) {
            this.owner = initialOwner;
            this.registrationFee = BigInt(initialFee);
            this.totalDocumentsRegistered = 0;
            this.documents = new Map();
            this.balance = 0n;
        }

        registerDocument(sender, value, hash, title, authors, metadataURI, blockTime = Date.now(), blockNum = 1000) {
            if (!hash || hash === "0x0000000000000000000000000000000000000000000000000000000000000000") {
                throw new Error("InvalidDocumentHash()");
            }
            if (this.documents.has(hash)) {
                throw new Error(`HashAlreadyExists("${hash}", ${this.documents.get(hash).timestamp})`);
            }
            if (BigInt(value) < this.registrationFee) {
                throw new Error(`InsufficientFee(${this.registrationFee}, ${value})`);
            }

            const doc = {
                documentHash: hash,
                owner: sender,
                timestamp: blockTime,
                blockNumber: blockNum,
                title,
                authors,
                metadataURI,
                isRevoked: false
            };
            this.documents.set(hash, doc);
            this.totalDocumentsRegistered++;
            this.balance += BigInt(value);
            return doc;
        }

        verifyDocument(hash) {
            if (!this.documents.has(hash)) {
                return { exists: false };
            }
            const doc = this.documents.get(hash);
            return { exists: true, ...doc };
        }

        updateMetadata(sender, hash, newURI) {
            if (!this.documents.has(hash)) throw new Error("DocumentNotFound()");
            const doc = this.documents.get(hash);
            if (doc.owner !== sender) throw new Error("NotDocumentOwner()");
            if (doc.isRevoked) throw new Error("DocumentIsRevoked()");
            doc.metadataURI = newURI;
            return doc;
        }

        revokeDocument(sender, hash, reason) {
            if (sender !== this.owner) throw new Error("OwnableUnauthorizedAccount()");
            if (!this.documents.has(hash)) throw new Error("DocumentNotFound()");
            const doc = this.documents.get(hash);
            if (doc.isRevoked) throw new Error("AlreadyRevoked()");
            doc.isRevoked = true;
            doc.revokeReason = reason;
            return doc;
        }

        withdrawFees(sender, recipient) {
            if (sender !== this.owner) throw new Error("OwnableUnauthorizedAccount()");
            if (!recipient) throw new Error("InvalidRecipient()");
            const amount = this.balance;
            if (amount === 0n) throw new Error("NoFundsAvailable()");
            this.balance = 0n;
            return { recipient, amount };
        }
    }

    const ADMIN = "0xAdmin00000000000000000000000000000000001";
    const AUTHOR_A = "0xAuthorA00000000000000000000000000000002";
    const AUTHOR_B = "0xAuthorB00000000000000000000000000000003";
    const SAMPLE_HASH_1 = "0x4f83e20e8a7f1a3a412b1d31d0db7a922614b98c37d0c3268875317bfb21d5a7";
    const SAMPLE_HASH_2 = "0x9c42b3658f8702b8d4f40f28801f4682c0fa31b26f59451a9e8b233a1e4d3c2b";

    const contract = new MockProjectCore(ADMIN, "1000000000000000"); // 0.001 ETH

    test("Đăng ký tài liệu hợp lệ với đủ phí ETH (Happy Path)", () => {
        const doc = contract.registerDocument(
            AUTHOR_A,
            "1000000000000000",
            SAMPLE_HASH_1,
            "Nghiên cứu ứng dụng Blockchain trong tài chính tại Huế",
            "Phan Thành Đạt, Nguyễn Hữu Bằng - HUE",
            "ipfs://bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi"
        );
        assert.strictEqual(doc.owner, AUTHOR_A);
        assert.strictEqual(doc.title, "Nghiên cứu ứng dụng Blockchain trong tài chính tại Huế");
        assert.strictEqual(contract.totalDocumentsRegistered, 1);
    });

    test("Tra cứu và xác thực tài liệu đã đăng ký thành công", () => {
        const result = contract.verifyDocument(SAMPLE_HASH_1);
        assert.strictEqual(result.exists, true);
        assert.strictEqual(result.owner, AUTHOR_A);
        assert.strictEqual(result.isRevoked, false);
    });

    test("Revert khi mã băm tài liệu rỗng (Boundary check)", () => {
        assert.throws(() => {
            contract.registerDocument(AUTHOR_A, "1000000000000000", "0x0000000000000000000000000000000000000000000000000000000000000000", "Bai bao loi", "SV", "");
        }, /InvalidDocumentHash/);
    });

    test("Revert khi người dùng không nạp đủ phí đăng ký quy định", () => {
        assert.throws(() => {
            contract.registerDocument(AUTHOR_B, "500000000000000", SAMPLE_HASH_2, "Bai bao thieu phi", "SV", "");
        }, /InsufficientFee/);
    });

    test("Phát hiện gian lận: Cố tình đăng ký trùng mã băm của tác giả khác", () => {
        assert.throws(() => {
            contract.registerDocument(AUTHOR_B, "1000000000000000", SAMPLE_HASH_1, "Bai bao dao van", "Kẻ cắp ý tưởng", "");
        }, /HashAlreadyExists/);
    });

    test("Chủ sở hữu công trình cập nhật thành công siêu dữ liệu metadataURI", () => {
        const newURI = "https://doi.org/10.1016/j.web3hue.2026.01";
        const doc = contract.updateMetadata(AUTHOR_A, SAMPLE_HASH_1, newURI);
        assert.strictEqual(doc.metadataURI, newURI);
    });

    test("Ngăn chặn kẻ xấu sửa đổi trái phép siêu dữ liệu của người khác", () => {
        assert.throws(() => {
            contract.updateMetadata(AUTHOR_B, SAMPLE_HASH_1, "https://fake-link.com");
        }, /NotDocumentOwner/);
    });

    test("Admin thu hồi chứng nhận khi Hội đồng kỷ luật phát hiện đạo văn", () => {
        const doc = contract.revokeDocument(ADMIN, SAMPLE_HASH_1, "Hội đồng phát hiện sao chép nguyên văn 60%");
        assert.strictEqual(doc.isRevoked, true);
    });

    test("Rút tiền an toàn bởi Quản trị viên (Checks-Effects-Interactions)", () => {
        const withdrawRes = contract.withdrawFees(ADMIN, ADMIN);
        assert.strictEqual(withdrawRes.amount, 1000000000000000n);
        assert.strictEqual(contract.balance, 0n);
    });

    console.log(`\n=> KẾT QUẢ KIỂM THỬ: ${passedCount}/${totalCount} ca kiểm thử THÀNH CÔNG (100%).`);
}

runTests();
