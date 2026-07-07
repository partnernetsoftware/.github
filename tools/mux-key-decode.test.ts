// PART:test — pullKeySequences 跨 stdin chunk 的 UTF-8 多字节解码回归
// 根因: keyInputBuf += data.toString() 逐 chunk 独立解码，多字节字符(如中文)被
// 拆在两个 Buffer chunk 边界时会各自产出乱码/替换字符。修复用 StringDecoder 流式
// 解码保留跨 chunk 未完成尾字节。见 skills/mux/mux.ts pullKeySequences。
import { test, expect } from "bun:test";
import { pullKeySequences } from "./mux.ts";

test("pullKeySequences: 中文名一次性到达 → 正确解码", () => {
  const buf = Buffer.from("太阳花", "utf8");
  const out = pullKeySequences(buf);
  expect(out.join("")).toBe("太阳花");
});

test("pullKeySequences: 中文多字节字符被 stdin 拆成两个 chunk → 仍正确解码(不产生替换字符/乱码)", () => {
  const full = Buffer.from("1:太阳花agent", "utf8");
  // 在 "太" 字(3字节 UTF-8: E5 A4 AA)中间切断，模拟 tty 分片到达
  const cut = 3; // "1:" 后第 1 个字节(太 的首字节)
  const chunk1 = full.subarray(0, cut + 1); // 含 "太" 的第 1 字节
  const chunk2 = full.subarray(cut + 1);    // 含 "太" 剩余 2 字节 + 后续
  const out1 = pullKeySequences(chunk1);
  const out2 = pullKeySequences(chunk2);
  const joined = out1.join("") + out2.join("");
  expect(joined).toBe("1:太阳花agent");
  expect(joined).not.toContain("\ufffd"); // 无 U+FFFD 替换字符
});

test("pullKeySequences: 每字节独立到达(极端分片) → 累计正确", () => {
  const full = Buffer.from("中文测试", "utf8");
  let joined = "";
  for (const b of full) {
    joined += pullKeySequences(Buffer.from([b])).join("");
  }
  expect(joined).toBe("中文测试");
});
