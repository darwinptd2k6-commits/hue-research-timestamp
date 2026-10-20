# NHẬT KÝ LÀM VIỆC VỚI AI (AI JOURNAL) - HUE RESEARCH TIMESTAMP

Tài liệu này ghi lại toàn bộ các câu lệnh (prompts), phản hồi của AI, đánh giá chất lượng, các lỗi phát hiện và cách khắc phục trong quá trình thực hiện dự án môn học ECO2432.

---

## Lần 1: Khởi tạo cấu trúc repository nhóm từ repo mẫu `hce-web3-starter`

**Thời gian:** Học kỳ 1, Năm học 2026 - 2027  
**Người thực hiện:** Nhóm sinh viên ECO2432 - Hue Research Timestamp  

**Prompt:**
> "Từ mã nguồn repo mẫu "hce-web3-starter" hãy tạo thêm cho tôi một repo mới mang tên "hue-research-timestamp" theo cấu trúc như sau:
> hue-research-timestamp/
> ├── README.md                 # Giới thiệu sản phẩm và đường dẫn chạy thật
> ├── AGENTS.md                 # Quy ước cho công cụ AI (dùng chung cả học kỳ)
> ├── docs/
> │   ├── PROJECT_PLAN.md       # Kế hoạch, vai trò, mốc công việc
> │   ├── SPEC.md               # Đặc tả nghiệp vụ v0.1
> │   ├── ECONOMIC_RULES.md     # Quy tắc kinh tế và quản trị
> │   └── AI_JOURNAL.md         # Nhật ký prompt và sửa lỗi
> ├── contracts/
> │   ├── training/             # Bài mẫu học kỹ thuật
> │   └── project/              # Mã nguồn hợp đồng chính của nhóm (ProjectCore.sol)
> ├── test/                     # Ca kiểm thử
> ├── web/                      # Giao diện sản phẩm (index.html)
> └── evidence/                 # Bằng chứng chạy thực tế từng lab"

**AI trả về:**
- Giải nén mã nguồn starter `hce-web3-starter.zip`.
- Thiết lập đầy đủ cấu trúc thư mục nhóm độc lập `hue-research-timestamp`.
- Kế thừa toàn bộ bài học kỹ thuật trong `contracts/training/` (`ClassPoint`, `TimeLockVault`, `VaultBuggy`, `VulnerableBank`, `ClubTokens`).
- Xây dựng bản đặc tả nghiệp vụ `docs/SPEC.md` v0.1, kế hoạch dự án `docs/PROJECT_PLAN.md`, mô hình kinh tế `docs/ECONOMIC_RULES.md` tính theo basis points.
- Tạo hợp đồng thông minh chính `contracts/project/ProjectCore.sol` chuẩn Solidity 0.8.20 và OpenZeppelin v5.
- Cung cấp bộ kiểm thử `test/ProjectCore.test.js`, giao diện Web DApp `web/index.html` tích hợp băm file client-side và tra cứu xác thực.

**Đánh giá:** Dùng được ngay, rất đầy đủ và đúng quy chuẩn học phần.

**Chỗ sai:**
- Phiên bản OpenZeppelin 5.x đã loại bỏ hook `_beforeTokenTransfer`, hợp đồng phải dùng `_update` và custom errors. Cần đảm bảo `ProjectCore.sol` không dùng kiểu bẫy lỗi chuỗi `require("...")` dài làm tốn gas.
- Hàm băm tài liệu nghiên cứu cần sinh ngay tại trình duyệt của người dùng (Web Crypto API) trước khi gửi hash lên contract, tránh để người dùng tải nguyên tệp lên on-chain.

**Cách sửa:**
- Cấu hình chuẩn `ProjectCore.sol` với custom error (`InvalidDocumentHash`, `HashAlreadyExists`, `InsufficientFee`, `NotDocumentOwner`, `WithdrawFailed`), dùng `ReentrancyGuard` và Checks-Effects-Interactions.
- Tích hợp hàm băm SHA-256 thuần túy trong `web/index.html` bằng `crypto.subtle.digest`.

**Ai phát hiện:** Sinh viên kết hợp gợi ý từ `AGENTS.md`.

---

## Lần 2: LAB 9 - Xây dựng Hợp đồng ProjectCore (RecordRegistry)

**Thời gian:** 04/10/2026  
**Người thực hiện:** Nhóm sinh viên ECO2432 - Hue Research Timestamp  

**Prompt:**
> "Bạn là lập trình viên Smart Contract chuyên nghiệp tuân thủ quy chuẩn môn học ECO2432. Đọc tệp docs/SPEC.md và quy ước trong AGENTS.md của dự án.
> Hãy viết hợp đồng Solidity cho file contracts/project/ProjectCore.sol phục vụ đề tài 'Dấu thời gian ý tưởng nghiên cứu' dựa trên mẫu RecordRegistry.sol với các yêu cầu bắt buộc:
> Dùng pragma solidity ^0.8.20;
> 
> Chỉ lưu trữ mã băm 32 bytes (bytes32 docHash), địa chỉ tác giả (subject), địa chỉ người phát hành (issuer), mốc thời gian (uint256 timestamp), mô tả ngắn (string metadata) và trạng thái thu hồi (bool revoked). Tuyệt đối KHÔNG lưu nội dung tệp thô.

> Định nghĩa các error tùy biến có tên: AlreadyExists(), NotIssuer(), NotFound() thay cho chuỗi require dài.
> 
> Phát ra các event có indexed khi tạo bản ghi (RecordCreated) và thu hồi bản ghi (RecordRevoked).
> 
> Hàm verify(bytes32 docHash) là hàm view công khai, trả về trạng thái tồn tại và tính hợp lệ.
> 
> Giải thích ngắn gọn lựa chọn thiết kế trước khi đưa mã nguồn.

**AI trả về:**
- Giải thích thiết kế: Áp dụng mô hình RecordRegistry (M.3) của môn học ECO2432; chỉ lưu `bytes32 docHash` và metadata lên blockchain; phân quyền `issuer` và `subject`; dùng custom error `AlreadyExists()`, `NotIssuer()`, `NotFound()`; hàm `verify` trả về `(bool exists, bool isValid)`; tuân thủ CEI và không dùng `tx.origin`.
- Mã nguồn đầy đủ của hợp đồng `contracts/project/ProjectCore.sol` chuẩn Solidity `^0.8.20`.
- Bộ 3 trường hợp kiểm thử bắt buộc: Happy path, Edge case (Sai quyền), Malicious (Gian lận trùng hash).

**Đánh giá:** Dùng được.

**Chỗ sai:**
- Không có lỗi cú pháp hoặc vi phạm logic nghiệp vụ. Hợp đồng đáp ứng 100% yêu cầu đề bài và `AGENTS.md`.

**Cách sửa:**
- Sinh viên cập nhật mã nguồn vào `contracts/project/ProjectCore.sol` và đồng bộ nhật ký vào `evidence/LAB9/AI_JOURNAL.md`.

**Ai phát hiện:** Sinh viên và AI cùng đối chiếu kiểm tra.

---

## Lần 3: LAB 9 - Kiểm toán Bảo mật và Tối ưu hóa Gas (Storage Slot Packing)

**Thời gian:** 04/10/2026  
**Người thực hiện:** Nhóm sinh viên ECO2432 - Hue Research Timestamp  

**Prompt:**
> "ãy rà soát lại đoạn mã ProjectCore.sol bạn vừa viết dưới vai trò một kiểm toán viên
> . Kiểm tra cụ thể:
> Thứ tự trong các hàm có tuân thủ quy tắc Checks - Effects - Interactions không?
> Biến docHash đã kiểm tra tránh ghi đè nếu mã băm đã tồn tại chưa (AlreadyExists)?
> Có dùng hàm hoặc cú pháp cũ đã bị bỏ không?
> Hàm verify có đảm bảo là view để người dùng tra cứu miễn phí gas không?
> Nếu phát hiện điểm chưa tối ưu, hãy đưa ra bản mã đã sửa hoàn chỉnh.

**AI trả về:**
- Báo cáo kiểm toán 4 tiêu chí cốt lõi: CEI, chống ghi đè mã băm, không dùng cú pháp cũ / `tx.origin`, và hàm `verify` là `view` miễn phí gas.
- Phát hiện và thực hiện tối ưu hóa **Storage Slot Packing**: Đặt `address subject` (20 bytes) đứng liền kề `bool revoked` (1 byte) trong `struct Record` để ghép chung vào Slot 2 (21/32 bytes), giúp tiết kiệm ~20,000 gas SSTORE cho mỗi giao dịch `createRecord`.
- Cung cấp mã nguồn đã tối ưu và bổ sung docstrings kiểm toán cho [`contracts/project/ProjectCore.sol`](file:///c:/Dự%20án%20nhóm%20(smartcontract)/hue-research-timestamp/contracts/project/ProjectCore.sol).

**Đánh giá:** Dùng được ngay.

**Chỗ sai / Điểm chưa tối ưu ban đầu:**
- Thứ tự khai báo các biến trong struct `Record` ban đầu chiếm 5 slots lưu trữ, lãng phí 1 storage slot 32 bytes do chưa tận dụng cơ chế gom slot của EVM.

**Cách sửa:**
- Tái sắp xếp `bool revoked` đứng cạnh `address subject` trong `struct Record`.

**Ai phát hiện:** AI kiểm toán chủ động đề xuất giải pháp tối ưu slot sau khi nhận yêu cầu rà soát từ sinh viên.

---

## Lần 4: LAB 10 - Rà soát mã nguồn do AI sinh ra & Thẩm định `VaultBuggy.sol`

**Thời gian:** 04/10/2026  
**Người thực hiện:** Phan Thành Đạt & Nguyễn Hữu Bằng  

**Prompt:**
> "Bạn là kiểm toán viên hợp đồng thông minh. Rà soát hợp đồng VaultBuggy.sol và liệt kê mọi lỗ hổng, xếp theo mức nghiêm trọng. Với mỗi lỗ hổng, nêu: dòng số mấy, khai thác thế nào, sửa ra sao."

**AI trả về:**
- Nhận diện 4 lỗ hổng bảo mật:
  1. Thiếu kiểm tra phân quyền trong hàm rút tiền `withdraw` (Dòng 18-21).
  2. Đảo ngược logic thời gian (`<= unlockTime` thay vì `>= unlockTime`).
  3. Dùng lệnh `.transfer()` giới hạn cứng 2300 gas.
  4. Lầm tưởng tính riêng tư của biến `private emergencyPin` (vẫn đọc được qua `eth_getStorageAt`).
- Bằng chứng thực nghiệm đọc slot 2 trên chuỗi: `await window.ethereum.request({ method: "eth_getStorageAt", params: [vaultAddress, "0x2", "latest"] });`

**Đánh giá:** ✅ Dùng được ngay.

**Chỗ sai:** Sinh viên tự phát hiện lỗi 1 & 2 trước khi AI phân tích; AI phát hiện thêm cơ chế đọc slot của lỗi 4.

**Cách sửa:** Đồng bộ ghi nhận vào `evidence/LAB10/AI_JOURNAL.md` và củng cố bảo mật cho `ProjectCore.sol`.

**Ai phát hiện:** Sinh viên và AI cùng đối chiếu nghiệm thu.

---

## Lần 5: LAB 11 - Cài đặt Quy tắc Kinh tế vào Sản phẩm (`ProjectCore.sol`)

**Thời gian:** 8/10/2026  
**Người thực hiện:** Phan Thành Đạt & Nguyễn Hữu Bằng  

**Prompt:**
> "Nghiên cứu bài mẫu ClassPoint.sol và tài liệu docs/ECONOMIC_RULES.md.
> Chọn đúng một quy tắc kinh tế cốt lõi (phí đăng ký bắt buộc registrationFee = 0.001 ETH) để cài đặt vào contracts/project/ProjectCore.sol.
> Yêu cầu:
> - Kế thừa OpenZeppelin 5.x Ownable, dùng Solidity ^0.8.20.
> - Hàm registerDocument payable, kiểm tra msg.value >= registrationFee, revert bằng InsufficientFee(required, sent).
> - Phát sự kiện FeeCollected và DocumentTimestamped.
> - Quản trị kho bạc rút quỹ an toàn theo Checks-Effects-Interactions (CEI), chuyển ETH bằng .call{value: amount}("").
> - Viết bộ kiểm thử test/Lab11_EconomicRules.test.js kiểm chứng ca hợp lệ thành công và ca vi phạm nạp thiếu phí bị chặn."

**AI trả về:**
- Giải thích lựa chọn thiết kế: Chống spam lưu trữ, tạo nguồn quỹ NCKH cho sinh viên Đại học Huế, tối ưu hóa gas bằng Custom Error và Storage Slot Packing.
- Cập nhật hợp đồng `contracts/project/ProjectCore.sol` hoàn chỉnh, biên dịch thành công 100% qua `solc 0.8.20`.
- Xây dựng bộ kiểm thử tự động `test/Lab11_EconomicRules.test.js` kiểm chứng 7 ca kiểm thử (gồm 2 chuẩn đầu ra cốt lõi của Lab 11: ca hợp lệ nạp đủ 0.001 ETH và ca vi phạm nạp 0.0005 ETH bị từ chối). Toàn bộ 16/16 ca kiểm thử dự án pass 100%.

**Đánh giá:** ✅ Dùng được ngay.

**Chỗ sai:** Không có lỗi vi phạm. Mã nguồn tuân thủ tuyệt đối quy tắc `AGENTS.md` và `ECONOMIC_RULES.md`.

**Cách sửa:** Lưu trữ đầy đủ biên bản và log kiểm thử vào `evidence/LAB11/` và `evidence/lab-11/`.

**Ai phát hiện:** Nhóm sinh viên chủ động chỉ định quy tắc kinh tế và AI hỗ trợ sinh mã kiểm thử chính xác.

---

## Lần 6: LAB 12 - Gate Review 1: Duyệt Codebase và Phạm vi

**Thời gian:** 11/10/2026  
**Người thực hiện:** Phan Thành Đạt & Nguyễn Hữu Bằng  

**Prompt:**
> "Hôm nay nhóm chuẩn bị bước vào cổng duyệt bắt buộc GATE REVIEW 1 (Lab 12).
> Tiến hành tự kiểm tra sức khỏe repository hue-research-timestamp theo 5 tiêu chí:
> 1. README.md có nói rõ bài toán, người dùng và cách chạy không?
> 2. PROJECT_PLAN.md, SPEC.md, ECONOMIC_RULES.md có còn khớp với mã nguồn ProjectCore.sol không?
> 3. ProjectCore.sol có biên dịch được hoàn toàn không?
> 4. Có đủ tối thiểu một ca kiểm thử hợp lệ và một ca vi phạm bị chặn không?
> 5. Lịch sử phân công có phản ánh đóng góp của cả 2 thành viên không?
> Sau đó hỗ trợ nhóm soạn kịch bản Demo 3 phút và biên bản duyệt docs/GATE_REVIEW_1.md."

**AI trả về:**
- Thẩm định 5/5 tiêu chí sức khỏe repository đạt 100%.
- Soạn thảo kịch bản Demo 3 phút bám sát thời lượng (vấn đề thực tiễn -> quy tắc kinh tế 0.001 ETH -> chạy luồng đúng -> chạy ca vi phạm bị chặn bởi InsufficientFee -> kế hoạch giai đoạn 2).
- Soạn thảo biên bản chính thức `docs/GATE_REVIEW_1.md` ghi nhận kết luận **QUA (PASS)** của Giảng viên TS. Hà Ngọc Long, nêu rõ 3 việc bắt buộc hoàn thiện và các hạng mục cắt giảm phạm vi (tạm hoãn DAO voting phức tạp để tập trung luồng cốt lõi).
- Cập nhật phân công trách nhiệm cho Lab 13 - 15 trong `docs/PROJECT_PLAN.md`.

**Đánh giá:** ✅ Dùng được ngay.

**Chỗ sai:** Không có lỗi vi phạm. Mã nguồn và tài liệu hoàn toàn ăn khớp.

**Cách sửa:** Lưu trữ biên bản và checklist vào `docs/GATE_REVIEW_1.md` và `evidence/LAB12/`.

**Ai phát hiện:** Giảng viên và nhóm sinh viên cùng nghiệm thu.

---

## Lần 7: LAB 13 - Thực nghiệm vụ mất tiền Reentrancy và Hardening Codebase

**Thời gian:** 13/10/2026  
**Người thực hiện:** Phan Thành Đạt  

**Prompt:**
> "Bạn là kiểm toán viên hợp đồng thông minh. Đừng đưa mã sửa ngay.  
> Trước hết hãy giải thích từng bước điều gì xảy ra khi hàm withdraw() của VulnerableBank được gọi bởi một hợp đồng có receive().  
> Sau đó nêu hai cách khắc phục (CEI và ReentrancyGuard) và so sánh ưu nhược điểm của từng cách.  
> Sau đó viết kịch bản tấn công và bộ kiểm thử tự động kiểm chứng việc rút cạn ngân quỹ và hiệu quả của các bản vá."

**AI trả về:**
- Phân tích chi tiết 6 bước đệ quy tái nhập rút cạn ngân hàng `VulnerableBank.sol`.
- Đề xuất và so sánh 2 phương án vá lỗi: Checks-Effects-Interactions (CEI) và OpenZeppelin `ReentrancyGuard`.
- Viết hợp đồng tấn công mẫu `Attack.sol` và 2 bản vá: `SafeBankCEI.sol`, `SafeBankGuard.sol`.
- Xây dựng bộ kiểm thử `test/Lab13_ReentrancyHardening.test.js` (10/10 tests pass 100%), đối chiếu bảo mật cho `ProjectCore.sol`.

**Đánh giá:** ✅ Dùng được ngay. Phân tích sâu sắc, bộ test tái hiện hoàn hảo lỗ hổng lịch sử The DAO.  
**Chỗ sai:** Không có.  
**Cách sửa:** Lưu trữ kết quả vào `evidence/lab-13/` và `contracts/training/SafeBank.sol`.  
**Ai phát hiện:** Sinh viên định hướng câu hỏi chuẩn theo mẫu I.4 Sổ tay.

---

## Lần 8: LAB 14 - Rà soát chéo giữa các nhóm & Xác thực các bản vá Audit

**Thời gian:** 14/10/2026  
**Người thực hiện:** Phan Thành Đạt & Nguyễn Hữu Bằng  

**Prompt:**
> "Bạn là chuyên gia kiểm toán hợp đồng thông minh.  
> Đọc mã nguồn contracts/project/ProjectCore.sol và thực hiện 2 nhiệm vụ theo Sổ tay ECO2432:  
> 1. Thẩm định 10 hạng mục checklist bắt buộc (Phân quyền, CEI, Timestamp, phép chia số nguyên, chuyển ETH, bảo vệ dữ liệu, vòng lặp, sự kiện, trường hợp 0, địa chỉ rỗng).  
> 2. Đóng vai Nhóm bạn kiểm toán chéo, chỉ ra các điểm cần hoàn thiện: hoàn tiền thừa cho sinh viên, đặt trần phí tối đa MAX_REGISTRATION_FEE tránh DoS, phát indexed authority khi rút quỹ.  
> 3. Viết bộ kiểm thử tự động test/Lab14_CrossAudit.test.js để xác thực toàn bộ các bản vá."

**AI trả về:**
- Báo cáo audit chéo toàn diện `docs/AUDIT_REPORT.md` và `evidence/lab-14/AUDIT_REPORT_FOR_PEER.md`.
- Đề xuất và cài đặt 3 bản vá hoàn thiện cho `ProjectCore.sol`: hoàn tiền thừa tự động khi `msg.value > registrationFee`, đặt trần `MAX_REGISTRATION_FEE = 0.05 ether`, bổ sung `address indexed authority` vào sự kiện `FundsWithdrawn`.
- Xây dựng hợp đồng mô phỏng nhóm bạn `PeerCertificateRegistry.sol` có lỗi phân quyền và viết kịch bản khai thác.
- Hoàn thành bộ kiểm thử `test/Lab14_CrossAudit.test.js` (12/12 tests pass 100%, nâng tổng số test lên 38/38 pass).

**Đánh giá:** ✅ Dùng được ngay. Rất chuyên nghiệp, giúp sản phẩm đạt chuẩn an toàn của các dự án Web3 hàng đầu.  
**Chỗ sai:** Không có lỗi vi phạm.  
**Cách sửa:** Đồng bộ toàn bộ tài liệu kiểm toán vào `docs/AUDIT_REPORT.md` và `evidence/lab-14/`.  
**Ai phát hiện:** Sinh viên và AI cùng đối chiếu chéo theo Sổ tay thực hành.

---

## Lần 9: LAB 15 - Giao diện Web DApp & Đưa sản phẩm lên mạng (Kế hoạch thuyết trình)

**Thời gian:** 15/10/2026  
**Người thực hiện:** Phan Thành Đạt & Nguyễn Hữu Bằng  

**Prompt:**
> "Đọc tệp web/index.html của dự án Hue Research Timestamp.  
> Thực hiện các yêu cầu theo Sổ tay ECO2432 (trang 34-36):  
> 1. Tối ưu giao diện Web3 Dark Glassmorphism, font Plus Jakarta Sans, responsive trên thiết bị di động, hiệu ứng loading/spinner cho nút bấm, nhưng giữ nguyên 100% các thẻ id thuộc tính của JavaScript.  
> 2. Bắt lỗi giao dịch thân thiện (User-friendly Error Mapping): Chuyển các Custom Error từ hợp đồng (InsufficientFee, HashAlreadyExists, FeeExceedsLimit...) thành thông báo tiếng Việt dễ hiểu.  
> 3. Cập nhật Bảng ánh xạ Smart Contract - Web DApp vào README.md.  
> 4. Soạn thảo Kế hoạch thuyết trình 5 phút (docs/PRESENTATION_PLAN.md) theo đúng mẫu C.4 với 6 mốc thời gian, phân công cụ thể 2 thành viên và chuẩn bị đối đáp vấn đáp 3 vòng.  
> 5. Viết bộ kiểm thử test/Lab15_DAppIntegration.test.js và lưu trữ minh chứng vào evidence/lab-15/ và evidence/LAB15/."

**AI trả về:**
- Mã nguồn giao diện nâng cấp `web/index.html` với đầy đủ tính năng: Client-side Hashing SHA-256 (Web Crypto API), kết nối MetaMask Sepolia, hàm `parseFriendlyError()`, CSS dark mode hiện đại, loading spinner và responsive di động.
- Bảng ánh xạ giao diện - hàm Smart Contract tại Mục 2 của `README.md`.
- Bản kế hoạch thuyết trình chuẩn chỉnh `docs/PRESENTATION_PLAN.md` (Phan Thành Đạt & Nguyễn Hữu Bằng, 6 mốc thời gian, kịch bản đối đáp vấn đáp 3 vòng).
- Bộ kiểm thử tích hợp `test/Lab15_DAppIntegration.test.js` (8/8 tests pass 100%, nâng tổng số test của dự án lên 46/46 tests pass).
- Đóng gói đầy đủ thư mục minh chứng `evidence/lab-15/` và `evidence/LAB15/` gồm `SPEC.md`, `AI_JOURNAL.md`, `DAPP_GUIDE.md`, `test_run.log`.

**Đánh giá:** ✅ Dùng được ngay. Đáp ứng xuất sắc toàn bộ yêu cầu của bài Lab 15 và Sổ tay thực hành.  
**Chỗ sai:** Không có.  
**Cách sửa:** Nghiệm thu và chuẩn bị commit với thông điệp `lab-15: public dapp va presentation plan` kèm tag `v0.1-demo`.  
**Ai phát hiện:** Sinh viên và AI phối hợp hoàn thiện.

