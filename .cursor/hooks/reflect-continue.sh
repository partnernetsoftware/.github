#!/usr/bin/env bash
# stop / subagentStop: 结束前自检是否应继续执行（避免空承诺「下一环」）。
set -euo pipefail

input="$(cat)"

python3 - <<'PY' "$input"
import json
import sys

raw = sys.argv[1] if len(sys.argv) > 1 else ""
try:
    data = json.loads(raw) if raw.strip() else {}
except json.JSONDecodeError:
    print("{}")
    sys.exit(0)

status = data.get("status", "")
loop_count = int(data.get("loop_count", 0) or 0)
event = data.get("hook_event_name", "stop")

# 已反思过或非正常结束：不再自动续跑
if status != "completed" or loop_count >= 1:
    print("{}")
    sys.exit(0)

label = "子代理" if event == "subagentStop" else "主代理"
msg = f"""【{label}停止自检】先判断，再行动：

1. 用户目标是否已**交付并验证**（代码/测试/推送），还是只说了要做？
2. 是否曾写「下一环 / 继续 / 无需再盯」但**本轮未做**？
3. 若未完成：立刻继续执行（改代码、跑 gate、commit/push），禁止再空承诺。
4. 若已完成或必须等用户：回复「可结束」并停止，不要编造后续工作。

二选一回复：**继续执行** 或 **可结束**。"""

print(json.dumps({"followup_message": msg}, ensure_ascii=False))
PY

exit 0
