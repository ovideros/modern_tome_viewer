# 交接提示词（复制到新对话）

> 2026-09-10 更新：下方 B 是已执行的历史任务说明。新 agent 请先读 `docs/lua-scaling.md`，
> 当前已接入 1225 条源码公式，保留 2110 条估算；继续工作应优先处理匹配缺口，勿重复实现提取器。
> 当前基线：scaling 26 / verify 77 / smoke 42 / e2e 112。

下面分三块：

- **A. 通用交接提示词** —— 想继续做任何事都可以用；
- **B. 专项任务提示词** —— 针对当前最高优先级（用 Lua 源码提取系数）；
- **C. 简短版** —— 如果只想快速接上下文。

建议直接把 **A + B** 一起粘贴给新 agent。

---

## A. 通用交接提示词

```
你是接手 modern_tome_viewer 项目的开发 agent。请先完整阅读交接文档，再动手。

【项目位置】
工作区：/Users/ovideros/Codes/senior1/modern_tome
项目代码：./modern_tome_viewer
交接文档：./modern_tome_viewer/docs/HANDOVER.md   ← 必读
补充文档：./modern_tome_viewer/README.md（用法）
          ./modern_tome_viewer/docs/feasibility.md（可行性分析、数值反解原理、常见疑问第 10 节）

【项目是什么】
Tales of Maj'Eyal (ToME4) 技能查看器的纯静态网页版，替代原站点
https://starsapphirex.github.io/tome-viewer/viewers/classes/。
技术栈：Vite 7 + React 19 + TypeScript + Tailwind 4，无后端，构建产物部署到任意静态服务器。
已实现：高级搜索（多字段 + 检索语法）、结构化筛选（分面计数）、技能详情、
职业/种族浏览页、收藏、技能对比、技能数值模拟（滑条实时重算）、亮暗双主题。

【必读的既有实现】
1. src/lib/scaling-core.js —— 数值公式与"反解"算法（纯 JS，浏览器和构建脚本共用）。
   读它之前先读 HANDOVER.md 第 5 节和 docs/feasibility.md 第 10 节，理解为什么需要反解。
2. scripts/build-data.mjs —— 数据管线，含多处踩坑记录（冷却取数、unlocked 语义、
   HTML 补平衡等），改任何一步前先看文档。
3. scripts/verify.mjs / smoke.mjs / e2e.mjs —— 三层测试，改动后必须全绿。

【环境约束（很重要）】
- Node v25.2.1；npm 缓存必须指定：npm --cache ../.npm-cache install
- e2e 需要 Chromium，运行前带环境变量：
  PLAYWRIGHT_BROWSERS_PATH=/Users/ovideros/Codes/senior1/modern_tome/.pw-browsers
- 根目录还有只读参考：starsapphirex.github.io/（原站点 + tometips 数据导出）、
  tome-src-full/（游戏本体 Lua 源码）、dlc-src/（三个 DLC 源码）。

【命令】
cd modern_tome_viewer
npm run data        # 重新生成 public/data（约 90s）
npm run check       # typecheck + verify + build + smoke
npm run serve       # 静态服务器 http://127.0.0.1:4173/
npm run e2e -- http://127.0.0.1:4173/   # 真实浏览器 e2e

【当前测试基线，改动后必须保持】
verify 73/73、smoke 42/42、e2e 108/108、typecheck 无错误。

【工作方式要求】
- 动手前先复述你对任务的理解和计划，再执行。
- 优先复用已有组件与工具函数，不要另起一套。
- 任何行为改动都要补/改测试；测试选择器优先用 data-testid。
- 改动数据管线后，务必确认 verify 里的真实数据断言（如火焰冲击 181/246/297/340/378）仍成立。
- 完成时报告：改了什么、验证结果（贴测试数字）、遗留问题。

【当前最高优先级任务】
见下一条消息（专项任务提示词）。如果你收到的任务不是这个，以用户当前指令为准。
```

---

## B. 专项任务提示词（继续提高源码覆盖率）

```
【任务】继续把"技能数值"从反解估算换成真实 Lua 公式，提高覆盖率。

【当前状态】3750 个数值里 2237（59.7%）已由源码公式还原并通过逐点校验，
1141 是反解估算、372 只能显示参考值。先读 docs/HANDOVER.md 第 5、6 节，
特别是 5.3 节：**阶梯的"轴"由标题决定，不一定是技能等级**。

【必读】
- scripts/extract-lua-coefficients.mjs  源码提取器（含诊断开关 TOME_EXTRACT_DEBUG=1）
- src/lib/lua-formula.js                封闭表达式语言 + 求值器
- scripts/lua-scaling.mjs               阶梯比对（注意 matchesDisplayed 的显示语义）
- scripts/audit/match-rate.mjs          按原因分类剩余数值，先跑它决定做什么

【硬约束】
- 只接受能通过"逐点校验 + 候选唯一"的公式；不确定就退回参考值，不要猜。
- 不要把放宽误差阈值当作提高覆盖率的手段。
- 任何改动后跑：node --test scripts/scaling.test.mjs、npm run check、npm run e2e。
- `npm run e2e` 需要 PLAYWRIGHT_BROWSERS_PATH=/Users/ovideros/Codes/senior1/modern_tome/.pw-browsers。

【建议顺序（按收益）】
1. reference mismatch 651 条：逐个看失败候选，补公式家族/语义
   （weaponDamage 需实际武器伤害、getTalentTypeMastery、getOffHandMult 等）。
2. source unavailable 682 条里，`info` 依赖未在标题出现、又无法给出基准的角色状态时，
   可考虑"固定为基准值 + 明示假设"的做法（参考 PASS_THROUGH 的写法），前提是仍能逐点复现。
3. Multiple local assignment 66 条：放宽局部变量解析。
4. Info control flow / Dynamic format 31 条：分支互斥时逐分支解析。
5. 需要 Possessor 源码（约 68 条）时向用户索取 data-possessors/。

【验收】报告新的覆盖率（source/estimated/reference 三个数字）、构建耗时、
以及至少 5 个抽样技能"源码公式算出的值 == 导出文本显示值"的证据；
所有测试保持全绿（verify 77、smoke 42、e2e 112、scaling 26）。
```

## C. 简短版（快速接上下文）

```
接手 /Users/ovideros/Codes/senior1/modern_tome/modern_tome_viewer 项目。
先读 docs/HANDOVER.md（交接文档）、README.md、docs/feasibility.md 第 10 节。
项目是 ToME4 技能查看器的纯静态网页版（Vite + React 19 + TS + Tailwind）。
当前测试基线：npm run check 全绿 + npm run e2e 108/108。
环境：npm 需加 --cache ../.npm-cache；e2e 需带
PLAYWRIGHT_BROWSERS_PATH=/Users/ovideros/Codes/senior1/modern_tome/.pw-browsers。
最高优先级：继续用根目录的 tome-src-full/ 与 dlc-src/ 里的 Lua 源码提高技能数值覆盖率
（当前 59.7% 源码公式 / 30.4% 反解估算 / 9.9% 仅参考值），细节见 HANDOVER.md 第 5、6 节。
先用 node scripts/audit/match-rate.mjs 看剩余失败原因，再决定做什么。
先复述计划再动手，改完必须跑测试并报告结果。
```
