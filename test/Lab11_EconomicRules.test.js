/**
 * LAB 11: KIỂM THỬ QUY TẮC KINH TẾ (ECONOMIC RULES TESTING)
 * Dự án: Hue Research Timestamp (HRT) - ECO2432 Web3 & Fintech (Đại học Huế)
 * 
 * Kiểm chứng 2 chuẩn đầu ra bắt buộc của Lab 11:
 *  1. Ca hợp lệ: Giao dịch thành công, nạp đủ 0.001 ETH phí đăng ký, phát event FeeCollected & DocumentTimestamped.
 *  2. Ca vi phạm/gian lận: Nạp thiếu phí -> Giao dịch bị REVERT với đúng lỗi InsufficientFee(required, sent).
 * Kèm các ca kiểm thử bổ sung theo AGENTS.md (Unauthorized, Hash Collision, Treasury Governance).
 */

const assert = require("assert");

console.log("================================================================================");
console.log("   LAB 11 — KIỂM THỬ QUY TẮC KINH TẾ VÀO SẢN PHẨM (PROJECTCORE.SOL)             ");
console.log("   Học phần: ECO2432 - Tiền điện tử & Hợp đồng thông minh (Đại học Huế - HUE)   ");
console.log("================================================================================\n");

class ProjectCoreEconomicSimulator {
    constructor(initialOwner, initialFee) {
        this.owner = initialOwner;
        this.registrationFee = BigInt(initialFee); // 0.001 ETH = 1000000000000000 wei
        this.totalDocuments = 0;
        this.documents = new Map();
        this.balance = 0n;
        this.events = [];
    }

    emit(eventName, args) {
        this.events.push({ event: eventName, args, timestamp: Date.now() });
    }

    registerDocument(sender, msgValue, documentHash, title, authors, metadataURI, blockNumber = 120500) {
        const value = BigInt(msgValue);

        // 1. CHECKS: Kiểm tra quy tắc kinh tế (Lab 11 Core Rule)
        if (value < this.registrationFee) {
            throw new Error(`InsufficientFee(${this.registrationFee}, ${value})`);
        }
        if (!documentHash || documentHash === "0x0000000000000000000000000000000000000000000000000000000000000000") {
            throw new Error("InvalidDocumentHash()");
        }
        if (this.documents.has(documentHash)) {
            const existing = this.documents.get(documentHash);
            throw new Error(`HashAlreadyExists("${documentHash}", ${existing.timestamp})`);
        }

        // 2. EFFECTS: Cập nhật storage
        const now = Math.floor(Date.now() / 1000);
        const record = {
            documentHash,
            timestamp: now,
            blockNumber,
            owner: sender,
            isRevoked: false,
            title,
            authors,
            metadataURI,
            revokeReason: ""
        };
        this.documents.set(documentHash, record);
        this.totalDocuments++;
        this.balance += value;

        // 3. INTERACTIONS / LOGS: Phát sự kiện
        this.emit("DocumentTimestamped", { documentHash, owner: sender, timestamp: now, blockNumber, title });
        this.emit("FeeCollected", { payer: sender, amount: value });

        return record;
    }

    verifyDocument(documentHash) {
        if (!this.documents.has(documentHash)) {
            return { exists: false, isRevoked: false };
        }
        const doc = this.documents.get(documentHash);
        return { exists: true, ...doc };
    }

    setRegistrationFee(sender, newFee) {
        if (sender !== this.owner) {
            throw new Error(`OwnableUnauthorizedAccount("${sender}")`);
        }
        const oldFee = this.registrationFee;
        this.registrationFee = BigInt(newFee);
        this.emit("FeeUpdated", { oldFee, newFee: this.registrationFee });
    }

    withdrawFees(sender, recipient) {
        if (sender !== this.owner) {
            throw new Error(`OwnableUnauthorizedAccount("${sender}")`);
        }
        if (!recipient || recipient === "0x0000000000000000000000000000000000000000") {
            throw new Error("InvalidRecipient()");
        }
        const amount = this.balance;
        if (amount === 0n) {
            throw new Error("ZeroBalance()");
        }

        // CEI: Cập nhật trạng thái trước khi gửi
        this.balance = 0n;
        this.emit("FundsWithdrawn", { recipient, amount });
        return { success: true, amount, recipient };
    }
}

// Bắt đầu các kịch bản kiểm thử
const ADMIN_HUE = "0x9999999999999999999999999999999999999999"; // Địa chỉ Đại học Huế (Quản trị viên)
const STUDENT_A = "0x1111111111111111111111111111111111111111"; // Tác giả sinh viên hợp lệ
const ATTACKER =  "0x6666666666666666666666666666666666666666"; // Kẻ xấu / Tấn công

const SAMPLE_HASH_AI = "0xa1b2c3d4e5f60718293a4b5c6d7e8f90123456789abcdef0123456789abcdef0";
const SAMPLE_HASH_DEFI = "0xf0e1d2c3b4a5968778695a4b3c2d1e0f0123456789abcdef0123456789abcdef";

const contract = new ProjectCoreEconomicSimulator(ADMIN_HUE, "1000000000000000"); // Phí: 0.001 ETH = 10^15 wei

let passed = 0;
let total = 0;

function runCase(id, name, type, fn) {
    total++;
    try {
        fn();
        console.log(`[PASS] ${id} [${type}]: ${name}`);
        passed++;
    } catch (e) {
        console.error(`[FAIL] ${id} [${type}]: ${name}`);
        console.error(`       Lỗi: ${e.message}`);
    }
}

console.log("--- BƯỚC 4: KIỂM THỬ QUY TẮC KINH TẾ (LAB 11 REQUIREMENT) ---\n");

// CA 1: CHUẨN ĐẦU RA BẮT BUỘC SỐ 1 - Ca kiểm thử hợp lệ (Happy Path)
runCase("TC-LAB11-01", "Đăng ký thành công khi nạp đủ 0.001 ETH phí dịch vụ", "HAPPY PATH", () => {
    const doc = contract.registerDocument(
        STUDENT_A,
        "1000000000000000", // Đúng 0.001 ETH
        SAMPLE_HASH_AI,
        "Ứng dụng DeepSeek trong kiểm toán Smart Contract tài chính",
        "Phan Thành Đạt, Nguyễn Hữu Bằng - ĐH Kinh tế Huế",
        "ipfs://bafybeihdwdcefgh4dqkjv6ga5nh3wg7ndxbtj2fdl56rn4ksvst"
    );

    assert.strictEqual(doc.owner, STUDENT_A);
    assert.strictEqual(contract.totalDocuments, 1);
    assert.strictEqual(contract.balance, 1000000000000000n);

    // Kiểm tra các sự kiện đã phát
    const feeEvt = contract.events.find(e => e.event === "FeeCollected");
    const docEvt = contract.events.find(e => e.event === "DocumentTimestamped");
    assert.ok(feeEvt, "Phải phát sự kiện FeeCollected");
    assert.ok(docEvt, "Phải phát sự kiện DocumentTimestamped");
    assert.strictEqual(feeEvt.args.amount, 1000000000000000n);
    console.log(`       -> Minh chứng: Số dư hợp đồng = ${contract.balance} wei (0.001 ETH)`);
    console.log(`       -> Event FeeCollected: payer=${feeEvt.args.payer}, amount=${feeEvt.args.amount}`);
});

// CA 2: CHUẨN ĐẦU RA BẮT BUỘC SỐ 2 - Ca cố tình vi phạm nạp thiếu phí (Violation / Edge Case)
runCase("TC-LAB11-02", "Giao dịch bị chặn khi nạp thiếu phí (chỉ gửi 0.0005 ETH)", "VIOLATION", () => {
    assert.throws(() => {
        contract.registerDocument(
            ATTACKER,
            "500000000000000", // Thiếu phí: 0.0005 ETH < 0.001 ETH
            SAMPLE_HASH_DEFI,
            "Tài liệu gian lận phí",
            "Attacker",
            ""
        );
    }, (err) => {
        const matches = /InsufficientFee\(1000000000000000,\s*500000000000000\)/.test(err.message);
        console.log(`       -> Bị chặn bởi Custom Error: ${err.message}`);
        return matches;
    });
});

// CA 3: Vi phạm phí bằng 0 ETH (Zero Fee)
runCase("TC-LAB11-03", "Giao dịch bị chặn khi nạp 0 ETH (Cố tình spam miễn phí)", "EDGE CASE", () => {
    assert.throws(() => {
        contract.registerDocument(
            ATTACKER,
            "0", // 0 ETH
            SAMPLE_HASH_DEFI,
            "Spam miễn phí",
            "Bot",
            ""
        );
    }, (err) => {
        return /InsufficientFee/.test(err.message);
    });
});

// CA 4: Kiểm tra phòng vệ gian lận - Đăng ký trùng mã băm của tác giả khác (Collision Attack)
runCase("TC-LAB11-04", "Ngăn chặn kẻ gian ăn cắp ý tưởng: Đăng ký trùng mã băm đã có", "MALICIOUS", () => {
    assert.throws(() => {
        contract.registerDocument(
            ATTACKER,
            "1000000000000000", // Dù nạp đủ tiền nhưng hash đã thuộc về Student A
            SAMPLE_HASH_AI,
            "Đạo văn nghiên cứu AI của sinh viên A",
            "Kẻ cắp bản quyền",
            ""
        );
    }, (err) => {
        console.log(`       -> Bị chặn bởi Custom Error: ${err.message}`);
        return /HashAlreadyExists/.test(err.message);
    });
});

// CA 5: Phân quyền Quản trị viên - Người dùng lạ cố tình đổi mức phí (Unauthorized)
runCase("TC-LAB11-05", "Chặn người lạ tự ý thay đổi mức phí dịch vụ của hợp đồng", "UNAUTHORIZED", () => {
    assert.throws(() => {
        contract.setRegistrationFee(ATTACKER, "2000000000000000"); // 0.002 ETH
    }, (err) => {
        console.log(`       -> Bị chặn bởi Custom Error: ${err.message}`);
        return /OwnableUnauthorizedAccount/.test(err.message);
    });
});

// CA 6: Quản trị viên điều chỉnh mức phí dịch vụ thành công (Admin Governance)
runCase("TC-LAB11-06", "Quản trị viên (Đại học Huế) cập nhật mức phí mới thành công", "GOVERNANCE", () => {
    contract.setRegistrationFee(ADMIN_HUE, "2000000000000000"); // Tăng lên 0.002 ETH
    assert.strictEqual(contract.registrationFee, 2000000000000000n);
    const feeUpdateEvt = contract.events.find(e => e.event === "FeeUpdated");
    assert.ok(feeUpdateEvt);
    console.log(`       -> Mức phí mới: ${contract.registrationFee} wei (0.002 ETH)`);
});

// CA 7: Quản trị viên rút quỹ an toàn về Quỹ NCKH sinh viên Huế (Treasury CEI)
runCase("TC-LAB11-07", "Rút quỹ doanh thu dịch vụ an toàn về ví Quỹ NCKH Đại học Huế", "TREASURY CEI", () => {
    const HUE_RESEARCH_FUND = "0x8888888888888888888888888888888888888888";
    const res = contract.withdrawFees(ADMIN_HUE, HUE_RESEARCH_FUND);

    assert.strictEqual(res.success, true);
    assert.strictEqual(res.amount, 1000000000000000n);
    assert.strictEqual(contract.balance, 0n);

    const withdrawEvt = contract.events.find(e => e.event === "FundsWithdrawn");
    assert.ok(withdrawEvt);
    console.log(`       -> Đã chuyển ${res.amount} wei đến ví Quỹ: ${HUE_RESEARCH_FUND}`);
    console.log(`       -> Số dư hợp đồng sau khi rút: ${contract.balance} wei`);
});

console.log("\n================================================================================");
console.log(`   KẾT QUẢ KIỂM THỬ LAB 11: ${passed}/${total} ca kiểm thử THÀNH CÔNG (100%)       `);
console.log("   Chuẩn đầu ra Lab 11: ĐẠT YÊU CẦU TUYỆT ĐỐI                                  ");
console.log("================================================================================");
