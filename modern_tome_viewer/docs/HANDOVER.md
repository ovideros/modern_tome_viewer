# 项目交接文档 — modern_tome_viewer

> 更新：2026-09-10，Lua 源码提取已接入。当前实现与边界以 [lua-scaling.md](lua-scaling.md) 为准。
> 当前覆盖：3335/3750（1225 源码 + 2110 估算），1323 全可调 / 184 部分 / 100 不可调。
> 新测试基线：scaling 26 / verify 77 / smoke 42 / e2e 112 / typecheck 无错。
> 以下保留原交接背景；旧基线和原计划属于历史记录。
>
> 交接时间：2026-09-10
> 交接人：上一轮 agent 会话
> 本文档目标：让接手的新 agent 在不看历史对话的情况下，能独立继续开发。

---

## 1. 项目是什么

一个 **Tales of Maj'Eyal (ToME4) 技能查看器的网页版**，替代原站点
<https://starsapphirex.github.io/tome-viewer/viewers/classes/>。

原站点的问题：搜索能力弱（只有名字 n-gram 匹配）、没有结构化筛选、没有数值模拟。
本项目从零重写，**纯静态站点**（Vite 构建 → `dist/`），无后端。

已实现能力：

| 能力 | 状态 |
| --- | --- |
| 多字段高级搜索（大系名 / 技能名 / 技能分类 / 技能文本） | 完成 |
| 检索语法 `name:` `tree:spell/fire` `"短语"` `-排除` | 完成 |
| 结构化筛选（模式/冷却/速度/射程/资源/需求/职业/标记 + 分面计数） | 完成 |
| 技能详情（完整文本、数值、需求、标记、来源） | 完成 |
| 职业浏览页（画像、子职业、掌握度、解锁状态、大系下展开技能） | 完成 |
| 种族浏览页（画像、亚种、种族技能） | 完成 |
| 收藏（localStorage） | 完成 |
| 技能对比（最多 6 个并列，自动高亮最优值） | 完成 |
| **技能数值模拟**（滑条调技能等级/系数/强度，数值实时重算） | 完成，覆盖 88% |
| 亮/暗双主题、URL 可分享、移动端布局 | 完成 |

---

## 2. 环境与命令

### 2.1 工作目录

```
/Users/ovideros/Codes/senior1/modern_tome/
├── modern_tome_viewer/          ← 本项目（所有代码在这里）
├── starsapphirex.github.io/     ← 原站点 + tometips 数据导出（只读参考）
├── tome-src-full/               ← 游戏本体 Lua 源码（37M，用户新加入）
└── dlc-src/                     ← 三个 DLC 的 Lua 源码（337M，用户新加入）
```

### 2.2 工具链

- Node **v25.2.1**，npm 11.6.2（无 pnpm）
- npm 缓存必须指定到工作区，否则报 `EPERM`：
  `npm --cache ../.npm-cache install`
- Chromium（Playwright headless shell）已下载到 `../.pw-browsers`，
  运行 e2e 时需带 `PLAYWRIGHT_BROWSERS_PATH=/Users/ovideros/Codes/senior1/modern_tome/.pw-browsers`

### 2.3 常用命令

```bash
cd modern_tome_viewer
npm install                                  # 依赖
npm run data                                 # 生成 public/data + public/img（约 90s）
npm run dev                                  # 开发服务器
npm run build                                # data + 构建到 dist/
npm run serve                                # 静态服务器 http://127.0.0.1:4173/
npm run check                                # typecheck + verify + build + smoke
npm run e2e -- http://127.0.0.1:4173/        # 真实浏览器 e2e（需先 npm run serve）
```

### 2.4 当前测试基线（改动后必须保持）

```
npm run typecheck   → 无错误
npm run verify      → 77/77
npm run smoke       → 42/42
npm run e2e         → 160/160
node --test scripts/scaling.test.mjs → 41/41
node scripts/audit/match-rate.mjs    → 源码覆盖 2469/3750 (65.8%)
```

构建产物：JS 271 KB（gzip 83 KB）、CSS 26 KB、`talents.json` 3.7 MB。


## 3. 目录结构

```
modern_tome_viewer/
├── data/raw/master/             # 上游 tometips 导出的原始 JSON（已提交，构建输入）
├── public/                      # 由 npm run data 生成（未提交）
│   ├── data/talents.json        #   规范化技能数据（含反解出的系数）
│   ├── data/meta.json           #   分类/职业/种族/词表/边界
│   ├── data/manifest.json       #   构建元信息
│   └── img/{talents/48,class-icons,player,npc}/
├── scripts/
│   ├── build-data.mjs           # 数据管线（清洗/富化/反解/拷贝图片）
│   ├── verify.mjs               # 73 项引擎断言
│   ├── smoke.mjs                # 42 项渲染冒烟（happy-dom）
│   ├── e2e.mjs                  # 108 项真实浏览器端到端
│   └── serve.mjs                # 零依赖静态服务器
├── src/
│   ├── lib/scaling-core.js      # ★ 数值公式 + 反解（纯 JS，浏览器与构建脚本共用）
│   ├── lib/scaling-core.d.ts    #   上面的类型声明
│   ├── lib/scaling.ts           #   类型化封装
│   ├── lib/search.ts            #   自研倒排索引（CJK 单字+双字，字段权重）
│   ├── lib/filters.ts           #   筛选谓词编译、分面计数、URL 序列化
│   ├── lib/data.ts              #   数据加载 + 紧凑格式展开 + 文案常量
│   ├── lib/compare.ts           #   对比最优值判定
│   ├── lib/types.ts             #   数据模型
│   ├── hooks/                   #   主题、数据加载、hash 路由、收藏/对比、表头高度
│   ├── components/              #   搜索栏、筛选面板、结果列表、详情面板、对比栏、
│   │                            #   VariableText（实时数值+tooltip）、ClassBits
│   └── pages/                   #   SearchPage / ClassesPage / RacesPage /
│                                #   FavoritesPage / ComparePage
├── docs/feasibility.md          # 可行性分析 + 反解原理 + 常见疑问（第 10 节）
└── README.md                    # 使用说明
```

---

## 4. 数据管线（scripts/build-data.mjs）

输入：`data/raw/master/*.json`（tometips 导出）+ `../starsapphirex.github.io/tometips/img/`
输出：`public/data/*.json` + `public/img/**`

管线做的事（**每一步都有踩坑记录，改动前务必读**）：

1. **只保留 1.5 变体**。上游导出的 `-1 / -1.3 / -1.5` 只差 tooltip 里的"技能系数"（1.00/1.30/1.50 = 难度），技能内容完全相同。原始数据只提交了 1.5 那一份。

2. **冷却/射程取数只取元素文本**。值形如
   `<acronym title="…技能等级 1-5…">49, 39, 34</acronym>`；
   若按整串抽数字会把 `1-5` 读成 `-5`，导致 96 个技能出现负冷却。
   正确做法：先 `<[^>]*>` 去标签再抽数字。

2b. **固定冷却（`fixed_cooldown`）要一起带上**。导出**本身就有**这个字段（27 个技能为 `true`），
   早先只是没往构建数据里抄。语义见 `Actor.lua:6872`——`getTalentCooldown()` 里
   `if t.fixed_cooldown or base then return cd end`，上面写着一行 `-- Can not touch this cooldown`：
   **任何效果都不能增减这个冷却**。游戏角色面板因此把它印成 `Fixed Cooldown: N`（`Actor.lua:6787`）。

   > 两个容易混淆的点：
   > - "固定" ≠ "数值是常数"。狂热/哨兵/定向跳跃的冷却都随技能等级变化（`44,35,30,26,24` 等），
   >   但它们同时是固定的；反过来，治愈之光冷却恒为 10，却**不是**固定，可以被减。
   > - 这个标记对玩家有直接用处：超越永恒自己就是"缩短其他技能剩余冷却"，
   >   而它会跳过固定冷却的技能（`races.lua:283` 的 `not t.fixed_cooldown`）。
   >
   > 线格式：`fixedCd: true`（只在为真时写，保持 JSON 小）；`expandCooldown(cd, fixedCd)` 把它
   > 放进 `Cooldown.fixed`，卡片与技能小卡片的冷却徽章据此加一个「固定」角标。

3. **色码转换**：`#GOLD#…#LAST#` → `<span style="color:…">`；同时产出纯文本供搜索。

4. **职业/种族记录**：
   - 大系元组是 `[unlocked, mastery, 名称]`，**第一项是 unlocked 不是 locked**
     （上游模板只在值为假时加 `locked` 类）。曾经读反过，导致盾战士的通用大系全被标成"锁定"。
   - `copy_add.life_rating` 对 10 个子职业缺失 → UI 显示「—」，不要编造。
   - 初始技能里的 `T_STAMINA_POOL` / `T_INSANITY_POOL` 是引擎资源池，不在技能导出中。
   - `ADVENTURER` 没有固定初始技能，测试已放行。

5. **描述 HTML 压缩**：职业/种族描述里大量
   `<span style="color:…"><span class="tstr-color-X">` 嵌套，压成单个 class span；
   上游 `POSSESSOR` 描述本身 span 不配对（14 开 16 闭），管线会补平衡。

6. **数值外围文字**：`parseAcronyms` 从数字两侧取 `prefix` / `suffix` / `tail`（见 5.11），
   只把非空部分写进 wire（`pre` / `tail`），避免把整句重复文本当成单位。

7. **数值反解**（见第 5 节）：对每个技能解析 `info_text` 里的 `<acronym>`，
   用游戏公式反推出隐藏系数，写进 `talents.json` 的 `acronyms` 字段。
   源码匹配上的条目额外写入 `l`（表达式 / 文件:行号 / 精度 / 轴 / `rounding`，见 5.10）。

8. **图片精确拷贝**：技能图标只复制被引用的 1704 个；职业/种族画像 99 张。
   上游缺 65 个技能图标（如 `nebula_spear.png`），UI 降级为首字母占位块，测试容忍。

---

## 5. 数值来源：优先 Lua 源码，兜底反解

### 5.1 现状（本轮扩展后）

```
3750 个数值
├── 2469 (65.8%)  源码公式（scripts/extract-lua-coefficients.mjs 从游戏 Lua 提取，逐点校验）
├──  995 (26.5%)  反解估算（网格搜索恢复 base/max，见 5.4）
└──  286 (7.6%)   仅参考值（无法参数化，UI 只显示原始数据）
技能维度：1422 全部可调 / 121 部分可调 / 64 完全不可调（另有 219 个技能没有数值可调）
数据构建：约 40 秒
```

本轮（解析器 + 语法扩展 + 悖论修正）把源码覆盖从 2237 提到 2469，仅参考值从 372 降到 286。
四次跳变：解析器关键字/索引修复 → 2268；语法扩展（幂/条件/他技能等级）→ 2308；
属性 actor 输入可用（`ACTOR_STAT_LABELS` 曾漏定义）+ 标题声明的输入集合统一 → 2409；
**悖论修正（PMod）与 `getParadoxSpellpower` 建模** → 2469。

UI 用 `data-testid` 区分三者：`source-value` / `estimated-value` / `reference-value`；
悬停 tooltip 对源码值显示文件名与行号，对估算值提示"其他输入下可能存在偏差"。

### 5.2 源码提取管线

| 文件 | 作用 |
| --- | --- |
| `scripts/extract-lua-coefficients.mjs` | 扫描 `tome-src-full` / `dlc-src`，解析 `newTalent{}`，产出 `data/lua-coefficients.json` |
| `src/lib/lua-formula.js` | 一套**封闭表达式语言**（绝不执行 Lua/JS 文本）+ 求值器 |
| `scripts/lua-scaling.mjs` | 把导出的数值阶梯与源码公式候选逐点比对 |
| `scripts/generate-lua-oracle.mjs` | 用真实 `Combat.lua` 生成 1200 组对照，考验 JS 求值器 |
| `scripts/scaling.test.mjs` | 45 项测试（含"全量源码匹配项在每个参考点都吻合"、轴推导、角色等级阶梯、本轮新增的构造器/索引/幂/条件/多强度/他技能等级） |
| `scripts/audit/match-rate.mjs` | 覆盖率审计：按失败原因分类剩余数值 |

**技能 id 推导**：`newTalent{ type = {"spell/fire", 2} }` → 大系第 2 个技能 = `T_FLAMESHOCK`
（与导出数据 `type` 一致；也可用 `source_code` 字段定位）。
优先级 `base < ashes-urhrok < cults < orcs`，DLC 覆盖本体。

**构造器与索引（本轮修）**：玩家可见技能由三个构造器定义，此前只认前一个：

| 构造器 | 块数 | 索引来源 |
| --- | --- | --- |
| `newTalent{ type = {tree, index} }` | 1757 | 声明值 |
| `uberTalent{ … }` | 62 | **无 type**：大系取自文件名（`uber/str.lua` → `uber/strength`），序号为文件内第几个 uber 块 |
| `newInscription{ type = {"inscriptions/runes", 1} }` | 34 | 声明值全是 1，序号按同大系出现顺序 |

另外 `type = {"spell/other", }` 这类**没有索引**的块，也按同大系出现顺序补位；
`short_name = WARDEN_S_FOCUS` 这种**不加引号的写法**此前会让 `literal()` 抛错、整块被静默丢弃，
现在 `literalOrNull()` 把它当字符串读。
兜底：`buildLuaIndex` 除按 `[tree,index]` 查，还会按导出的 `source_code`（文件+行号）直接定位，
所以索引合成错位也不会丢技能。

**DLC patch 判定（本轮修）**：此前"技能 id 出现在 `superload/overload/hooks` 任何位置"就整条排除，
实测 26 个被排除的技能**没有一个真被 DLC 重定义**（10 个牵连文件全是引擎侧补丁，
例如 `OrcCampaign.lua:286` 的 `if self:knowTalent(self.T_POLARIZATION)`）。
现在只有"文件里真的定义了该技能，或给它赋了字段（`T_X.getDamage = …`）"才算 patch，
真重定义时仍以 DLC 为准（addon 后加载覆盖本体）。

### 5.3 ★ 阶梯的"轴"不一定是技能等级（重要模型修正）

导出文本里的五个值，是**某一个参数取五个值时算出来的**，而这个参数由标题决定——
**标题里给出五个值的那个参数，就是这条阶梯的轴**：

| 标题 | 轴 | 含义 |
| --- | --- | --- |
| `技能等级 1-5` | 技能等级 | 大多数技能（3495 条） |
| `角色等级 1,10,25,40,50` | 角色等级 | 被捕猎 的察觉几率/半径 |
| `法术强度 10,25,50,75,100` | 法术强度 | 圣诗入门 等 |
| `灵巧 / 力量 / 体质 / 魔力 / 意志 10,25,50,75,100` | 该属性 | 心灵震爆、光明冲击 等 |
| `陷阱专精 技能等级 1-5` | 另一个技能的等级 | 刀锋陷阱 等 |

**早期实现把轴硬编码成"技能等级"**，于是凡是以其他参数为轴的数值
（角色等级、强度、属性、其他技能等级）都无法还原，被归到
`unsupported input dimensions`。修正后：

- 匹配器沿**该轴**逐点校验（`ladderAxis()` 从参数里推导轴）；
- `simAtAxis()` 把轴值代入对应的输入槽（技能等级 / 角色等级 / 强度 / 属性 / 子技能等级）；
- 提取器把 `self.level`、`self:getWil()` 这类**角色状态**改写为显式输入
  `['actor','角色等级']`、`['actor','意志']`，不再是"无法解析"；
- 表达式求值器认识 `actor` 输入，于是角色等级**变成可调滑块**；
- 提取器为公式用到的**任何**输入都提供一个滑块（技能等级、角色等级、技能系数、强度、属性），
  不再要求它必须是轴。

实测：被捕猎在角色等级 1 时复现导出基准 `半径 10,12,15,18,20`，
拉到 50 时按源码 `10 + self.level/5` 算出 `20` —— 数值真的随滑块变化。

> 结论：**"依赖角色等级所以算不了"是错的**。角色等级只是一个输入维度，
> 只要它是阶梯的轴、或能给出一个基准值，就可以做成滑块。

#### 5.3.1 标题里可以有好几条阶梯，逐元素相同的就是同一条（2026 续修）

标题常常带**不止一条**阶梯：导出会把**整个 `info` 函数**碰到的参数并集抄进**每一个** acronym。
无尽追踪的 `info` 用 `for e_type, fn in pairs(self.save_for_effects)` 把 `getReduction` 调了三次，
于是**每一行**的标题都背上 `physical save` / `spell save` / `mental save` 三条（每条都是 `10,25,50,75,100`）。

**渲染语义**：引擎一列一列地推进所有带阶梯的参数 —— 不是"变一个、其余钉在首值"。
本轮 14 条自动匹配上的公式**证明了这一点**，因为它们读的就是多个同阶梯参数：

| 技能 | 公式 | 判定依据 |
| --- | --- | --- |
| 匕首格挡 | `120 + 灵巧 + 敏捷` | 导出 `140,170,220,270,320`；"只变一个"在第 2 点会得 `155` |
| 战斗意志 | `statScale("wil") + statScale("cun")` | 两路同阶梯相加 |
| 咬一口 / 落星 / 虚幻形态 / 森林的恩赐 | `max(多个同阶梯属性)` | 同阶梯取 max 才等于阶梯值 |

实现：`axisSiblings()`（`scaling-core.js`）取**逐元素完全相同**的阶梯；
`simAtAxis()` 让它们随轴一起推进；`ladderAxis()` 只对**真的不一样**的第二条阶梯继续返回 null
（`魔力 10..100` 配 `角色等级 1..50` 是真正的联合轴，仍未支持，剩 9 条）。
线格式不存轴，`expandAcronym()` 在原处重新推导。

### 5.4 校验规则（为什么覆盖率不等于"差不多"）

一条源码公式只有**同时满足**以下条件才被采用：

1. 公式用到的输入维度与 acronym 声明的一致；
2. 代入数据自身的参数后，5 个点**逐点**吻合显示值；
3. 候选唯一——多条候选都能吻合则判为 `ambiguous formula`，宁可不用。

**关键细节：显示语义。** 导出数据没记录数值是用 `%d` 还是 `%.Nf` 渲染的，
而 Lua 的 `%d` **截断**、`%.Nf` **四舍五入**。整数显示因此有两种合法读法，两者都接受；
小数显示只有一种读法，精确比对。补齐这条真实显示规则后，
匹配数从 1225 涨到 2224——不是放宽阈值，而是修对了语义
（`matchesDisplayed()`，匹配器与测试共用同一实现）。

**但"逐点任选一种读法"是个空子**（2026 续修）：一次 `tformat` 调用用**同一个格式符**打印整条阶梯，
五点不可能混用两种约定。于是补了 `readingIsConsistent()` —— 要求整条阶梯的整数点能被**同一个**
约定读完（6 种：`trunc`/`round` × 不前置 / `%0.1f` / `%0.2f`，因为导出会在 talent 自己的格式符后
再取一次整数部分），`matchLuaFormula()` 与 `checkHandExpression()` 都接上。两个必需细节：

- **恰好落在整数上的点不参与判定**：`-8.9999999999999982` 与打印值 `-9` 只差 2e-15，
  该用哪种约定读它没有信息量，不能让浮点最后一位决定（否则混沌之球 `T_CHAOS_ORBS#1` 会被误杀）；
- 收紧后全库 3481 条整数阶梯里只有 **2 条**会掉，代价可忽略：一条是靠混用凑出来的拟合
  （驾驶机械蜘蛛 `T_MECHARACHNID_PILOTING#2`，已正确剔除），一条是源码公式本身复现不了
  （心灵震爆 `T_MIND_BLAST#2`，见 `docs/expression-overlay-report.md` §2.5）。

### 5.5 兜底反解

源码缺失或无法安全解析时，回退到用游戏公式
（`combatTalentScale`、`combatTalent{Spell,Mind,Physical,Steam}Damage`、`combatTalentStatDamage`）
从显示的阶梯反推 `base`/`max`：公式对 `(base, max)` 线性但单个驱动值下两者不可分离，
故用 `base∈[0,300] × max` 粗网格 + 逐步收缩精修，并枚举 mastery 候选（1.3 为主）。
这类值 UI 标为"反解估算"，tooltip 提示：**在数据自身输入下精确，其他输入下可能存在偏差**。
实现在 `src/lib/scaling-core.js`（纯 JS，浏览器与构建脚本共用）。

### 5.6 剩余 40% 为什么拿不到

> **本节各表的数字是首轮（覆盖率 65.8%）的分层记录，用来解释"为什么会失败"；
> 最新总量见下。** 经过后续几轮修判分器 + 1035→1053 条手写覆盖层，现在的分布是：
> **3650 源码（97.3%）/ 71 反解（1.9%）/ 29 只显示参考值（0.8%）**，
> 失败原因只剩 `reference mismatch: 11`、`source unavailable: 70`、
> `unsupported input dimensions: 9`、`Multiple local assignment: 10`；
> 明细与教训见 `docs/expression-overlay-report.md`。

3750 条数值：**2469 源码（65.8%）/ 995 反解（26.5%）/ 286 只显示参考值（7.6%）**。
1826 个技能里 219 个 `info` 根本没有 `<acronym>`（纯描述），余下 1607 个：
1422 全部可调 / 121 部分 / 64 完全不可调。

反解与"不能重算"是同一批失败原因的两个结局：**拿不到源码**就用反解兜底，
**形状也对不上任何已知公式族**就只剩参考值。原因分三层：

**第一层：完全没有可用的源码（834 条 = 1513 - 679）**

| 原因 | 数量 | 含义 |
| --- | --- | --- |
| 记录存在但候选为空 | ~470 | `info`/getter 不是"单个已知公式"：读别的技能的 getter（`callTalent`/`getTalentFromId`）、读武器/命中（`combatAttack`/`getAttackDamage`）、或 getter 里还有未建模的复合运算 |
| 技能不在 Lua 索引里 | 62 | 只剩 `data-possessors`（支配者，第四个 addon，本地没有源码）——**等用户提供** |
| `Multiple local assignment` | 77 | `info` 里有多值局部赋值（`local a,b = ...`），无法确定哪个参数对应哪个 `%d` |
| `Info control flow` | 18 | `info` 里有分支，显示文本随状态变化 |
| `Dynamic format` / 其余 | 23 | 格式串不是单一字面量、多个 info 表达式、源码路径不匹配、重复定义等 |

（`possible DLC patch` 从 52 条降到 **0**：全是误报，见 5.2。）

**第二层：有候选但被拒（679 条）**

| 原因 | 数量 | 含义 |
| --- | --- | --- |
| 输入对得上、算出的数对不上阶梯 | ~300 | 多数是**抽到的不是这条数值**（同一技能另一个 getter 的表达式）——阶梯校验正确地挡住了错公式；少数只差一个固定偏移/倍率，其中一部分是**导出本身少了一层 `ceil`**（照明），源码其实更接近游戏真值 |
| 没有候选读的输入与标题一致 | ~250 | 标题声明的输入（paradox/psi 资源、武器、别的技能）与表达式实际读取的不一致 |
| 轴无法确定 | 9 | 标题里同时有两个**不同**的阶梯（如 魔力 `10..100` + 角色等级 `1..50`）。逐元素相同的多条阶梯已按同一条处理，见 5.3.1 |
| 多个候选都能复现 | 9 | 两个不同表达式都能复现整条阶梯，拒绝猜 |

**第三层：连反解都做不到（372 条）**

| 原因 | 数量 | 含义 |
| --- | --- | --- |
| 拟合误差超容差 | ~150 | 阶梯形状不属于任何已知族 |
| 属性伤害但标题没给固定属性值 | ~100 | `combatTalentStatDamage` 的驱动量本身是未知的第二个自由变量 |
| 阶梯里有 0 或负值 | ~50 | 反解需要正值 |
| 强度伤害但标题给的是强度阶梯 | 15 | 驱动量随阶梯变化，退化 |

**反解的质量（重要）**：在导出自己的输入下重算，1141 条中
**415 条与导出逐点相同、224 条误差 ≤5%、315 条 5–20%、187 条 >20%**。
所以"覆盖率"不等于"准确率"：反解值在参考点之外只能算估计，
UI 必须继续标注「反解估算」并保留导出对照（见 5.9）。

**一个量过的可能性**：若把"候选读到的输入必须与标题声明完全一致"放宽为
"只要求阶梯能复现"，有 **98 条**能立刻变成源码值；但那意味着**忽略导出明确声明过的参数**，
在参考点之外可能是错的。要不要这么做属于产品决策，默认不做。

**全部 fail-closed**：判定不成立就不采用源码，退回参考值展示，
绝不输出"看起来合理但其实错"的数字。

### 5.6.1 表达式语言支持范围（本轮扩展后）

提取器只接受**封闭白名单**（`src/lib/lua-formula.js` 求值，绝不执行 Lua/JS 文本）。
本轮新增的能力，以及各自验证过的真实例子：

| 能力 | Lua 写法 | 结果 |
| --- | --- | --- |
| 有效强度 | `self:combatSpellpower(mod)`、`combatMindpower/Physicalpower/Steampower` | `['power','法术强度',mod]`；**四类强度分字段**（`sim.powers`），因为 `max(spellDamage, mindDamage)` 要按各自强度算 |
| 通用缩放 | `self:combatScale(x, y_low, x_low, y_high, x_high, power…)`、`self:combatLimit(x, limit, …)` | 与 `combatTalentScale/Limit` 同一凸包公式，锚点由参数给出，驱动量是任意表达式 |
| 别的技能等级 | `self:getTalentLevel(self.T_X)`、`…Raw` | `['talentRef','T_X',raw]`：标题若钉了这个输入就绑定（如 `陷阱专精 技能等级`），否则按导出基准 0（光能沁盾 48/64/76/86/95 ✅） |
| 属性 / 资源 | `self:getMag()` 等、`self:getParadox()`、`getPsi()`、`getHate()` | `['actor','魔力'|'paradox'…]`。注意 `ACTOR_STAT_LABELS` 此前**漏定义**，属性通道一直没通，修好后覆盖率一次 +101 |
| 数学函数 | `math.sqrt/abs/log/log10/exp/pow` | 与既有 floor/ceil/min/max 同一白名单（饥荒挽歌 `× math.sqrt(self.level)` ✅ 18/29/39/48/56） |
| 条件倍率 | `damage * (self:attr("x") and 2 or 1)`、`if <可选参数> then A else B end` | 解析为 `['cond', flag, A, B]`；匹配时枚举分支状态，取能复现导出阶梯的那组（并列时取"未开启"，因为导出是假角色渲染的）。灼烧 ✅ 23/32/38/44/49 |
| 武器倍率 | `self:combatTalentWeaponDamage(t, base, max, <他技能等级>)` | 第 4 个参数是表达式；这一族**不需要武器伤害数据**（返回的是倍率，info 印成百分比） |
| 伤害倍率的 power override | `self:combatTalent{Spell,Mind,Physical,Steam}Damage(t, base, max, <表达式>)` | 第 4 个参数改为表达式（时序系在这里传 `getParadoxSpellpower`）|
| 悖论修正（PMod） | `getParadoxModifier(self)`、`getParadoxSpellpower(self, t, mod, add)` | `['pmod',['actor','paradox']]` 与 `['power','法术强度', mod × pmod]`（chronomancer.lua:153/173），60 条时序系数值因此拿到源码 |

**输入集合的统一规则（重要）**：匹配时比较"标题声明的输入"与"公式消耗的输入
（power/stat 驱动 + 所有 `actor` 查询）"，两者必须完全相等（轴除外）。
标题声明的属性/资源/他技能等级都算已钉住的输入，因此
`角色等级 50`、`魔力 100`、`paradox` 这类标题参数第一次真正参与匹配。

### 5.7 数值随滑条呈现的规则

**一份状态，两处渲染。** `TalentDetail` 持有唯一的 `SimParams`（按 `talent.id:mastery` 作 key），
滑条与技能说明读同一个对象：**面板上滑条写什么，文字里就必须显示什么**。
曾经的写法是 `sim ?? defaultSimFor(...)`，并且只有动过滑条才把 `sim` 传给 `VariableText`，
于是"文字按导出值（系数 1.5）渲染、滑条却写着 1"，用户一动滑条数字才跳变——这是 bug，不是特性。
现在 `VariableText` 永远拿到具体的 sim，`sim` 只作为"是否偏离默认"的标记（决定要不要显示"恢复默认"）。

**显示几个值，取决于轴是不是"可购买的技能等级"：**

| 情形 | 显示 | 原因 |
| --- | --- | --- |
| `points > 1` 且轴是技能等级（或无轴） | **5 个值**，依次对应技能等级 1–5，当前等级高亮 | 五个值就是玩家能买的五级 |
| `points <= 1`（无论轴是什么） | **1 个值** | 只能投 1 点，导出的 1–5 级是"买不到的五个等级" |
| 轴是角色等级 / 强度 / 属性等连续输入 | **1 个值** | 导出的五点是采样值，滑条才是当前状态 |

**滑条落在导出没采样过的位置时必须真算。** 被捕猎的导出只有角色等级 1/10/25/40/50，
滑到 24 时显示的是 `min(100, 1 + 24/7)` 与 `10 + 24/5` 的实算结果（4% / 14），
**不允许**退回"1/10/25/40/50"的阶梯展示（`axisValueOf`/`indexOf` 的写法会让未命中阶梯时静默取第一格，
那样既显示错值、又让浮窗写错条件）。

**浮窗结构**（`ValueInputs` 驱动，见 5.9）：

```
数值说明
当前条件：技能等级 1，技能系数 1，法术强度 100     ← 全部当前输入，随滑条实时变化
源码公式 / 反解估算：…                            ← 源码值额外显示 文件:行号
五个数值依次对应技能等级 1–5。                      ← 仅在多值模式下出现
导出参考值：4, 46, 56, 64, 71                     ┐ 只有「反解估算 / 仅参考值」才显示：
导出条件：技能等级 1/2/3/4/5，技能系数 1.5，…        ┘ 源码值已在算同一条公式，重复导出只会更吵
```

实现要点：
- `acronymAxis()` 给出轴；多值模式用 `simAtAxis()` 沿轴重算整条阶梯，所以五个值同时反映"当前的其他参数"；
- 单值模式直接 `evaluateAcronym(acronym, sim)`，即当前滑条下的真实值；
- tooltip 正文第一行必须是纯文本的数值（`HoverTip` 把 children 包在一层纯文本 span 里），
  否则 `innerText` 会取到第一个块级标签的文字，测试与无障碍名称都会读错。

### 5.8 滑条的显示规则（避免噪音）

- **技能等级滑条**只在 `points > 1` 时出现。267 个技能只能投 1 点，
  其中 97 个的导出值虽然有 5 个（导出机制会按等级渲染），但玩家无法升级，
  给滑条只会误导。超过 1 点的技能一律显示。
- **技能系数滑条：0.9–1.5，步长 0.1**。它就是该大系的掌握度，数据里只有
  0.9(3) / 1.0(94) / 1.1(7) / 1.2(14) / 1.3(347) 五种取值，上限 1.5 留出余量。
  0.9 的三条是**工匠系（Embers of Rage）枪手/灵能射手/歼灭者的「灵巧 / 生存」**
  （源码 `dlc-src/orcs/tome-orcs/data/birth/classes/tinker.lua:151/218/305` 的 `{false,-0.1}`）。
  职业/种族页从树引用里拿 `mastery` 作为默认值，高级搜索页掌握度未知默认 **1**。
  这是刻意偏离导出标签（导出恒为 1.5）：游戏实际是"原始技能等级 × 掌握度"。
  `defaultSimFor()` 仍会把默认值夹进范围，防止"滑条停在边界而文字用另一个值"。
- **paradox 滑条：0–675**（`STAT_RANGES`）。悖论本身**没有上限**（引擎不给 cap，角色面板也只显示当前值），
  但决定费用与时空系法强的**悖论修正 PMod** 有：`bound(sqrt(paradox/300), 0.5, 1.5)`（`chronomancer.lua:153`），
  在 **paradox = 675** 时正好打到 +50% 上限（`sqrt(675/300)=1.5`），再往上提高没有任何效果——滑条到此为止；
  滑条行右侧实时显示 `悖论修正 ×1.50`。300 是源码注释里的"平衡点"，也正是导出钉住的值，所以默认 300。
- **强度滑条按类型分开：法术强度 / 精神强度 / physical power / steampower，1–150，是"有效值"**（`POWER_RANGE`）：
  - 游戏里伤害公式读的是 `self:combatSpellpower()`，即
    `rescaleCombatStats(原值)`（Combat.lua:1477 的凸包递减曲线），**不是**原始强度；
  - 角色面板写 `Spellpower: +N (M eff.)`——N 是原始、M 是有效，这就是用户记忆里的"两个不一样"；
  - 有效 100 需要原始 300，有效 150 需要原始 640——曲线已经非常平，再往上没有真实 build 够得着
    （导出钉住的强度从来都是 100），所以上限取 150 而不是 200；
  - `rawCombatStat()` 给出"达到该有效值所需的最小原始值"（曲线多对一且有 floor，只能给下界），
    滑条行右侧以 `原始值 ≥300` 的形式实时显示，把两者的关系摆在用户面前；
  - **每种强度一个滑条**，只显示该条数值真正读取的那几种：腐朽之地取
    `max(spellDamage, mindDamage)`，共用一条滑条时两个分支永远相等、永远算不出"更强的那一侧"，
    拆开后两个滑条任一方提高都会提高数值（e2e 有对称性断言）；
  - 导出标题里的强度恒为固定值 100、唯一的强度阶梯是 10/25/50/75/100，都在范围内。
- **轴上的属性**（灵巧/力量/…）给滑条，因为它的 5 个真实值决定了范围；
  **非轴的裸属性不给滑条**——导出只把它们固定在参考值（`力量 100`），
  那不是有意义的默认值，只会淹没真正有用的控件（但浮窗仍会如实列出这个固定值，因为公式确实用了它）。

### 5.9 数值 tooltip 的实现（易踩的坑）

**条件行由 `valueInputs()` 生成，不是抄标题。** `valueInputs(acronym)` 列出这条数值真正读取的
每个输入（`talentLevel` / `characterLevel` / `coefficient` / `power` / `stat:<标签>`）：
标题里声明的全部算上；验证过的 Lua 表达式再补上它自己调用的东西
（`self:getWil()` 会变成"意志"，即使标题没写）；反解兜底路径则读技能等级、系数和本族驱动量。
`inputValue(sim, key)` 取当前值，于是：

- 浮窗**不可能**写一个数字用不到的输入（被捕猎只依赖角色等级，它就没有"技能等级"那一行）；
- 也不可能漏掉一个会改变数字的输入（改系数/强度后描述不会消失）；
- 未被种下的属性按 `0` 显示——这正是求值器 `?? 0` 的兜底，浮窗不粉饰。

**源码值不再重复导出信息。** `acronym.lua` 存在（即这条数值真的是用游戏公式算的）时，
浮窗不再打印「导出参考值 / 导出条件」：公式已经定义了它，重复导出只是噪音。
「反解估算」和「仅参考值」仍然保留这两行——对它们而言导出就是唯一的数据，也是唯一的对照。

**公式里的隐含假设要写出来**（否则"源码公式"会显得比实际更确定）：

- `lua.conditions`（条件倍率）→ `按导出渲染时的状态：sun_paladin_avatar 关`；
- `lua.assumed`（他技能等级按 0 计）→ `另一技能等级按基准 0 计：SHIELD_EXPERTISE=0`。

工具本身仍是 `src/components/HoverTip.tsx`：**portal 到 `document.body` + `position: fixed`**，
位置由触发元素的 `getBoundingClientRect()` 算出，越界时上下翻转、左右夹取。

必须这样做，因为数值所在的容器是**双重裁剪**的：
`TalentDetail` 的 `<aside>` 是 `overflow-hidden`，内部滚动区是 `overflow-y-auto`，
而气泡最大宽 340px ≈ 面板宽 340px——绝对定位的气泡一定会被切掉。
后续新增任何"面板内浮层"都要走同一个组件，不要回到 `absolute` 定位。

### 5.10 整数显示读法的推断（`%d` 截断 vs `%.0f` 四舍五入）

导出**不记录格式化说明符**，而 Lua 里 `%d` 向零截断、`%.0f` 四舍五入。这直接影响"滑条滑到非采样点"
显示什么：被捕猎在角色等级 24 → 游戏显示 `%d(14.8) = 14`，四舍五入会写成 15。

**证据来自阶梯本身**：若某个阶梯点的预测值是小数且两种读法结果不同，该点就唯一确定了说明符
（被捕猎 4.571→4 只能是 `%d`；初现光芒 33.967→34 只能是 `%.0f`）。

- `scripts/lua-scaling.mjs`：
  - `integerRounding(acronym)` → `'trunc' | 'round' | null`（本值的证据，矛盾或无证据时为 null）；
  - `resolveIntegerRounding(acronyms)` → 按 `file:line` 分组（同一次 `tformat` 调用共用格式串），
    让**无证据的兄弟值继承**有证据的结论（被捕猎半径的五点全在整数/两种读法一致，故无从自证，
    但同一次调用的百分比给出了 `%d`），继承后必须能复现整条阶梯，否则放弃；
  - 结果写进 wire 的 `l.rounding`，浏览器端由 `formatAcronymValue()` 读取。
- 当前分布：2237 条源码值中 **1245 trunc / 550 round / 389 无证据（默认四舍五入）/ 53 小数**。
- 测试 `every source value re-renders its own ladder exactly as exported` 全量断言
  "渲染出的字符串 == 导出值"（>2200 条），比只断言"落在容差内"强得多。

### 5.11 数值外围文字（前后缀）与"重复模板"

导出常把**比数字列表更多的东西**包进同一个 `<acronym>`：正负号（`+16, +22`）、单位（`1%, 2%`）、
甚至整整一句重复五遍的话（`增加你的生命回复18。回复量受等级加成。, 增加你的生命回复29。…`）。

旧的写法 `suffix = inner.replace(NUM_RE,'')` 把"所有不是数字的文本"拼起来当单位，于是：

- 侦查圣诗渲染成 `16+++++, 22+++++`；
- 饥荒挽歌每个数字后面都挂上五遍整句（该条曾长达 552 字符）。

现在 `affixes(inner)` 只取**外侧文本**：第一个数字之前的 `prefix`、最后一个数字之后的 `suffix`，
并且当 `suffix` 全是句读（`.。,，;；!！?？:：、`）时改成列表末尾只输出一次的 `tail`
（`0.36, 0.66, 0.92, 1.16, 1.38.` 的句点属于句子，不属于每个数值）。
wire 仅在非空时下发 `pre` / `tail`；渲染时按 `prefix + 数值 + suffix` 逐值拼接、末尾补 `tail`，
所以饥荒挽歌恰好还原成导出的原句，时空调谐还原成 `时空法术强度：10, …`。

现状：81 条带前缀、5 条带句读尾；长度超过 12 的"垃圾后缀"已全部消失（构建后有断言）。

### 5.12 已声明的边界假设

`self:getShieldAmount` / `getShieldDuration` / `getHealAmount` 这类 Actor 包装函数只做一次
属性缩放。在"无相关加成"的基准下它们是恒等映射，管线据此解包，并在 tooltip 标注为基准读数；
若假设不成立，公式就复现不出显示值，匹配会失败，而不是给出错误结果。

## 6. 下一步任务（按性价比排序）

### 6.1 继续提高源码覆盖率

1. **`reference mismatch` 607 条**——逐个看失败候选，补缺失的公式家族/语义：
   `weaponDamage`（340 处调用，需实际武器伤害）、`getTalentTypeMastery` /
   `getTalentMastery` 等 Actor 查询、双持副手惩罚 `getOffHandMult`。
2. **`Multiple local assignment` 66 条**——继续放宽局部变量解析（多值返回、表构造）。
3. **`Info control flow` / `Dynamic format` 31 条**——`info` 里的条件分支，
   可在"分支互斥且各自安全"时逐分支解析。
4. **Possessor 源码（约 68 条）**——用户未提供 `data-possessors/`，需要时向其索取。

### 6.2 加固与工程化

- 用真实 `lua` 解释器跑差分测试，替代/补充 JS oracle；
- 把 `scripts/audit/match-rate.mjs` 接进 `npm run check`，覆盖率下降即报警；
- 65 个缺失技能图标可从游戏 `gfx/` 补齐。

## 7. 其他已知问题 / 待办（按优先级）

| # | 事项 | 说明 |
| --- | --- | --- |
| 1 | Lua 系数提取 | 见第 6 节，最高优先级 |
| 2 | 更多公式家族 | `combatTalentLimit` / `WeaponDamage` / `combatStatScale` 等 |
| 3 | 属性阶梯型数值 | `法术强度 10,25,50,75,100` 这类，需把阶梯维度也建模 |
| 4 | 英文界面 | 上游数据只有中文，收益有限，暂不做 |
| 5 | DLC 筛选 | 上游 `_dlc_name` 字段全空；如用 Lua 管线可从目录推断 |
| 6 | 数据自动更新 | 可加定时任务重新拉取导出并跑 `npm run data` |
| 7 | 65 个缺失技能图标 | 上游没导出；可从游戏源码的 `gfx/` 里补 |
| 8 | 收藏/对比的跨设备同步 | 目前仅 localStorage |

---

## 8. 开发时的关键约定

- **不要破坏既有测试**。任何改动后跑 `npm run check` + `npm run e2e`。
- **反解/公式改动后**，`verify.mjs` 里有针对真实数据的断言（火焰冲击 181/246/…），
  原文所称精确数值断言在接手时并不存在；本轮已补入 verify 和 e2e。
- **测试选择器**优先用 `data-testid`（已有：`result-row`、`tree-panel`、`talent-card`、
  `portrait`、`talent-detail`）。历史上因为用 CSS class 定位而误点过面包屑。
- **粘性布局**：表头高度 `--header-h`、搜索栏高度 `--searchbar-h` 都是运行时测量的 CSS 变量，
  新增粘性元素时要一起考虑，否则会互相遮挡。
- **happy-dom 限制**：不派发 React 的 checkbox/change 合成事件，交互测试放 e2e，
  smoke 只验证结构渲染。
- **截图验证**：e2e 支持 `--shot <dir>` 输出截图；当前会话的模型可能无法读图，
  可用 `ffmpeg -i x.png -f rawvideo -pix_fmt rgb24 -` + Python 做像素测量替代。

---

## 9. 参考资料

- 游戏公式文档：<https://te4.org/wiki/Scaling>
- 公式源码：`tome-src-full/mod/class/interface/Combat.lua`
  （`combatScale` / `combatTalentScale` / `combatTalentSpellDamage` / `rescaleDamage` …）
- 上游数据：`../starsapphirex.github.io/tometips/data/master/*.json`
- 本项目内部文档：`README.md`（用法）、`docs/feasibility.md`（可行性 + 反解原理 + 常见疑问）
