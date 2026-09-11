# 项目交接文档 — modern_tome_viewer

> **最新状态（本节是唯一的总账，下面各节的数字若是旧的会就地标注）**
>
> | 项 | 值 |
> | --- | --- |
> | 3750 个数值 | **3650 源码公式（97.3%）** / 71 反解估算 / 29 仅参考值 |
> | 技能维度 | 1591 全可调 / 9 部分可调 / 7 完全不可调（另有 219 个技能没有数值） |
> | 技能总数 | **1834**（上游导出 1826 + 从 Lua 补的 8 条怪物技能，见 §11） |
| 怪物描述 | 765 个有英文原文，其中 763 个有中文译文（缺译 2 条已在报告里列出） |
> | 手写覆盖层 | `data/lua-expressions.json` **1053 条**，构建时按三套渲染重校验 1053/1053 通过 |
> | 怪物图鉴 | **812 个可遇模板**（普通 447 / 精英 176 / 史诗 49 / 固定Boss 98 / 精英Boss 36 / 神级 6），另有 130 个抽象 BASE 模板不计入；`type` 20 个大类 / `subtype` 89 个亚类，侧栏可按大类→亚类两级中文筛选 |
> | 线上站点 | <https://ovideros.github.io/modern_tome_viewer/> · 仓库 <https://github.com/ovideros/modern_tome_viewer> · 发布提交 `cb27214` |
> | 测试基线 | typecheck 无错 · monsters **51/51** · scaling **45/45** · verify **90/90** · smoke **73/73** · e2e **247/247** |
> | 剩余失败原因 | `reference mismatch` 11 · `source unavailable` 70 · `unsupported input dimensions` 9 · `Multiple local assignment` 10 |
>
> 本轮的逐条进展见 §0「最近一轮变更」；数值覆盖的来龙去脉见
> [expression-overlay-report.md](expression-overlay-report.md)。
> 怪物图鉴的收录口径、数量统计与已知缺口见 [monster-pipeline.md](monster-pipeline.md)。
> 当前实现与边界以 [lua-scaling.md](lua-scaling.md) 为准。
>
> 交接时间：2026-09-10（初版）／后续多轮续修
> 本文档目标：让接手的新 agent 在不看历史对话的情况下，能独立继续开发。

---

## 0. 最近一轮变更：词缀页第三轮（数值修正 + 卡片直接给效果 + 材料等级）

用户反馈三条，全部改完并验证。详细口径见
[item-pipeline.md](item-pipeline.md) §5 与 §7.1。

### 1. 详情面板被顶部横幅挡住

两个页面的详情面板是 `fixed` 钉在视口上的，而 header 是 `sticky top-0 z-30`：
`inset-y-0` 让面板从 `top: 0` 开始、层级又低，于是**词缀名和「关闭」按钮整块被横幅盖住**。
改为 `fixed bottom-0 right-0 top-[calc(var(--header-h)+2px)]`。`--header-h` 由
`useHeaderHeight` 跟着真实高度同步（窄屏 header 折行），所以不能用硬编码的 57px。
e2e 里有两条几何断言（面板顶部、标题顶部都在 header 底边之下）。

### 2. 许多词缀要点开才看得到效果 → 卡片直接写效果

- 卡片原来打印原始属性码（`FIRE 10~15`），回调型则写「打开详情查看」。现在统一走
  `src/lib/ego-facts.ts` 产出最多 3 行效果：结构化属性（与详情面板共用 `fieldMeta`
  和 `formatPropValue`，所以卡片和面板不可能互相矛盾）在前，回调说明在后。
- **数值模型本身是错的，这轮一并修正。** `resolvers.mbonus_material(max, add)` 的区间是
  `add ~ add + max`（引擎实现是 `ceil(rng.mbonus(max, 等级, 90) × ml / 5) + add`），
  早期读成 `offset + 材料等级 × step`，于是 `balanced` 显示 `15~35`。
  交叉验算是决定性的：玩家词缀表同一行写的是 `5-15命中闪避/20-50缴械免疫`，
  改对后全库 506 行有数字区间的记录里 503 行与表一致（剩 3 行是表自身笔误）。
  这个比对已经做成常驻步骤：`docs/items-community-report.md` 有「数值区间交叉核对」一节。
- 两处乘数以前完全没算：**价格函数其实是数值变换**（`v=v/100`、`v=v/10`、取负、恒等，
  全库只有这四种，识别不出来就不给数字），以及**字段自身的标度**
  （`Moddable:compareFields` 打印 `raw * mod`，免疫/移速存小数、打印乘 100）。
  漏掉标度会把 `stun_immune` 打成 0、`movement_speed` 打成 `0~0`。
- 208 条没有属性表的词缀现在有文字说明：优先用**游戏自己的说明**（`charm_on_use` /
  `on_block` / `special_on_*` 的 `desc`，以及 `resolvers.charm(_t"...")` 第一个参数），
  58 条走这条；其余 31 条手写整理（每条都写了出处表达式）。构建产物有
  `effectCoverage` 计数，现在是「0 条没有任何可读效果」。
- 顺带修掉的：`wielder = { combat = {...} }`（33 条 egos 这么写）以前被当成一个叫
  `combat` 的属性行，成员键 `melee_project`/`burst_on_crit` 被当成值显示在错的区；
  现在会归到 `combat` 区。天赋/技能树/生物类型代码（`Talents.T_WARD`、
  `wild-gift/fungus`、`living`）现在经 `makeCodeLabeler` 翻成中文。

### 3. 材料等级选择器

词缀侧栏新增「材料等级 1–5」：**单选的显示参数，不是筛选条件**（不改变匹配结果），
写入 URL 的 `ml`，再点一次取消。选中后「随材料等级变化」的属性显示该等级自己的区间，
回调说明里的值也跟着变（例如 `evasive` 在 1 级是 10~16%、5 级是 10~40%）。
神器没有这一项：固定神器的属性全是字面量，全库 0 条 `mbonus_material`。

### 本轮踩到的坑

1. `mbonus_material` 的参数方向（见上）。任何「看起来像 offset + step」的 resolver
   都要回源码确认，不要凭形状猜。
2. **regex 的 `%%` 转义必须和格式符写在同一个 pattern 里**：单独匹配
   `%(?!%)[-+ #0-9.]*[dsf]` 会跳过 `%%` 的第一个 `%`，再把第二个 `%` 和 ` for` 的
   ` f` 一起吃掉，`reduce fatigue by %d%% for 2 turns` 变成 `... by {0}%?or 2 turns`。
3. **汉化表按带颜色代码的原文存 key**：`#VIOLET#%d#LAST#` 必须在剥颜色**之前**查表，
   否则这些说明一条都翻不出来（会静默退回英文）。
4. 函数体里的值变换要靠 `lua-entities.mjs` 新加的 `bodyText`（共享解析器只留第一个
   字符串 return）。`bodyText` 的边界按块嵌套算：`for`/`while` 的 `do` 不额外开块，
   否则 `end` 会数错。
5. `return 0, v` 这类恒等形态必须锚定到 `end`，否则 `return 0, v * e.material_level`
   会被误判成恒等。
6. 卡片和面板必须共用格式化函数。自己写一套 `toFixed` 会把 `0.1%` 打成 `0~0`。
7. `onSelectPool` 以前写的是 `{ ...current, slot: pool }`——`EgoFilters` 里没有 `slot`
   字段（是 `slots` 数组），对象展开让 TS 不做多余属性检查，于是这个点击**静默无效**。
   现在按池反查槽位分类。

### 已部署并线上验证（2026-09-11）

三个提交推到 `main`（`65560ce` 数据管线 / `e15ca1a` 两个页面 / `c23f018` 测试与文档），
Actions `Deploy to GitHub Pages` 的 build 与 deploy 两步都 success。
线上 <http://old.ovideros.site/modern_tome_viewer/> 实测：608 张词缀卡片全部有效果行、
`balanced` 显示 `+5~+15`、详情面板顶部（82px）在 header 底边（55px）之下、
`ml=1` 收敛到 `+20~+28`、416 件神器、**460 个图标全部 200**、
0 控制台报错 / 0 失败请求。线上 bundle 哈希与本地构建一致。

推之前还做了一次「只用提交内容」的构建验证：`git archive HEAD` 解到临时目录
（软链 node_modules，避免重复安装），`npm run build:pages` + `smoke` + `verify` +
`test:items` 全通过，产物哈希与本地一致——确认 CI 的干净 checkout 能构建。

### 验证

`typecheck` · `test:items` 63 · `test:monsters` 51 · `test:scaling` 45 · `verify` 90 ·
`smoke` 109 · `e2e` 292 — 全绿，零控制台错误。
新增断言：卡片都有非空效果行、没有「打开详情」、`balanced` 的区间是 `+5~+15`、
材料等级是单选且换级会改数值、点第二次取消、详情「游戏说明」区块、
以及详情面板顶部必须在 header 之下。

---

## 0. 上一轮变更：装备词缀与固定神器（新页面）

本轮新增两个页面与一条**独立、可复现**的物品提取管线。
完整的数据口径、属性映射来源、数值语义、ID 规则与更新方式见
[item-pipeline.md](item-pipeline.md)；社区表核对结果见
[items-community-report.md](items-community-report.md)。这里只记结论与踩到的坑。

### 交付

| 页面 | 路由 | 数据 | 规模 |
| --- | --- | --- | --- |
| 装备词缀 | `#/egos` | `public/data/egos.json` | 608 条（本体 603 / 兽人 5） |
| 固定神器 | `#/artifacts` | `public/data/artifacts.json` | 496 件（可装备 416 + 非装备 80） |

- 两条数据都**按页面懒加载**，不进入技能首页的启动路径。
- 神器图标 493/496 解析成功（全部 exact 命中），去重后复制 456 个 PNG；
  缺图 3 件进覆盖报告，页面用类别文字兜底。
- 社区补充层 594 行、命中 570（本池 505 / 共享池 65）、稀有度冲突 14（一律以源码为准）。

### 本轮踩到的坑（都能复发，改动相关代码前先看这里）

1. **`parseLuaFile` 读 `world-artifacts.lua` 返回 0 个实体且诊断也为 0。**
   文件开头的 `for ... do ... end` 被 `parseStatement` 交给宽松的
   `skipBlockStatement()`，它的深度计算把每个 `end` 都当块结束，于是吞掉后面 8500 行。
   同文件里其实有正确的 `skipBlock()`，但只有 `parseUnary` 会走到。
   → 物品侧不走语句解析，改为**单趟 token 扫描 + 字符串外配对花括号**，
   再把表区间重建成片段交给共享 `parseLuaFile` 解析。共享文件一行未改。
2. **token 重建必须给相邻词之间补空格。** 源码 `return _t"..."` 原样拼接会变成
   `return_t`，导致**所有**函数体文本抽取失败。这是个静默错误：
   100 条 `special_desc` 只读出 15 条时才发现。
3. **`compare_scaled` 的参数位置与 `compare_fields` 不同**，格式串/标签各往后一位；
   取错会把 `%+d #LAST#(%+d eff.)` 当标签。
4. **`desc_wielder` 是局部闭包**（`local desc_wielder = function(...)`），
   只匹配 `function _M:desc_wielder(` 会取到空，而 `descCombat` 的字段会顺势填满
   `wielder` 区——静默错位。两处都有测试钉住。
5. **`_t` 解包只能用于文本字段。** 把 `type`/`subtype` 也走 `literalOfTranslationCall`
   会把结构性标识变成 prose，继承解析直接崩（`no-type` 从 64 涨到 548）。
6. **同一 `define_as` 在多处定义要按内容比较，不能按名字。**
   `RUNE_RIFT` / `VOID_STAR` 是逐字节相同的重复定义（合并、列出全部位置）；
   兽人 DLC 的 kaltor-shop 两件是**同名不同内容**的真实变体（保留两行）。
   比较前必须剥掉 AST 里每行的 `line`，否则不同偏移量会误判为不同。
7. **`unique = true` ≠ 固定神器。** 药水/卷轴用它表示不可堆叠，Boss 定义也带它。
   必须解析继承链拿到真实的 `type` 再分类；否则 281 个 Boss 定义会被当成神器。
8. **charm 词缀有普通档与 `greater_ego` 高级档同名同 keywords。**
   按 keywords 做 ID 会把 12 条高级档静默丢掉。
9. **`#RESIST#` 不是随机变体**，而是物品名的占位符（`descAttribute` 运行时填数值）。
   伤害类型写死在各自的 `newEntity` 里。不要展开成组合枚举。
10. **搜索必须对含糊标点不敏感。** 震慑免疫的属性标签是「震慑/冰冻免疫」，
    直接 `includes('震慑免疫')` 命中 0 条。haystack 与查询词都过
    `normalizeSearchText`，并给分组行补别名（`抗性` → `resists`）。
11. **e2e 会在同一 page 上跨 section 复用视口。** 新增的页面段必须先
    `setViewportSize` 回桌面宽度并显式展开筛选栏，否则 `#ego-query` 不可见。

### 界面约定（用户已明确的偏好）

- 高级词缀（`greater_ego`）用**琥珀色**标记；亮色 `text-amber-800`、暗色 `text-amber-300`，
  实测对比度 6.32:1 / 9.34:1。不要退回普通 chip。
- 词缀列表排序：**普通档在前、高级档在后**；同档内**社区推荐度降序**，缺失的排末尾。
  推荐度也直接显示在卡片上（`推荐 4`）和详情里（`社区推荐 4 / 5`）。
- 两个侧栏一律用**标签切换**而不是下拉框；同维度多选是「或」，跨维度是「且」；
  空列表 = 不限制。`适用部位` 与 `收录范围` 默认展开。
- 神器侧「可装备 / 非装备」是**两个独立标签**（默认只勾可装备），不是互斥单选。
- 部位分类用 `src/lib/items.ts` 的 `EGO_SLOT_GROUPS`：按玩家表的 20 类组织，合并共享池，
  不列 NPC 专用池 / 消耗品池。**标签名来自这张表，不能从物品亚类推**——
  早期从亚类推，`charms` 池被标成「项圈」（它同时服务项圈/图腾/魔杖），
  `armor` 被标成「重甲」，`shield` 被标成「双手斧」。

### 本轮的界面改动后新增/更新的测试

`smoke` 88→95，`e2e` 269→283：新增了「侧栏无下拉框」「部位默认展开」
「普通档先于高级档」「同档按推荐度降序」「高级标记颜色不同于普通 chip」
「多选 facet 写 URL 且刷新可恢复」「可装备/非装备两个独立标签的三种组合」等断言。

### 体积

路径字典（`file` 是 `items-report.json.files` 的下标）与字段表
（`fieldMeta[key]` 存 `area`/`label`/`labelZh`/`format`/`unit`/`scale`）两项归一化把
神器数据从 3.2 MB 降到 2.3 MB、词缀从 1.9 MB 降到 1.6 MB。改数据格式时两处都要同步。

第三轮又加了 `materialRanges`（每个值 5 个区间）与 `notes`（回调说明），
`egos.json` 1.65 MB → 2.19 MB；同时**刻意不把 `formula` 写进 JSON**
（只有测试和报告用得到，写进去要多 ~150 KB 重复键名），
`materialRanges` 已经足够驱动材料等级选择器。

### 验证

`typecheck` · `test:items` 46 · `test:monsters` 51 · `test:scaling` 45 ·
`verify` 90 · `smoke` 88 · `e2e` 269 — 全绿，零控制台错误。（下一轮把 `test:items`
扩到 63、`smoke` 扩到 109。）
e2e 与 smoke 都新增了物品页面断言（列表、筛选、搜索、深链接恢复、属性分区、
多抗性归组、命运之轮无模拟控件、手机端无横向滚动）。

---

## 0. 最近一轮变更：怪物图鉴（上一轮）

本轮新增中文「怪物」页面与一条**独立、可复现**的 NPC 提取管线。逐条依据见
[monster-pipeline.md](monster-pipeline.md)，这里只记结论与踩到的坑。

| 项 | 结果 |
| --- | --- |
| 新页面 | `#/monsters`：分类侧栏 + 可搜索列表 + 怪物详情面板；技能在页面内面板打开（≥1800px 为第三列，1280–1799px 为底部抽屉，更窄回退到搜索页），不再需要"点进去再返回" |
| 收录 | 942 个 `newEntity` 模板 → 130 个抽象 BASE 不计入 → **812 个**可遇模板 |
| 分类 | 普通 447 / 精英 176 / 史诗 49 / 固定Boss 98 / 精英Boss 36 / 神级 6（依据 `Actor:textRank`） |
| 技能 | 固定 729 个模板有配置；218 个带互斥随机技能组/池；引用技能 **0 个未收录** |
| 技能查看 | 技能在**页内面板**打开，任何宽度都不离开怪物：≥1800px 为第三列（怪物与技能同时可见、当前技能高亮），其余宽度为底部抽屉；<1280px（含手机）技能抽屉替代怪物抽屉并提供「← 返回怪物」 |
| 中文 | 名称 812/812（游戏汉化表，`zh_hans.lua` ×4） |
| 图片 | 787/812（96.9%），按引用复制 681 张；缺图 25 个逐条记在报告里 |
| 补充技能 | 从 Lua 补 8 条上游缺的技能，技能总数 1826 → **1834** |

五条踩坑记录（都写进了 `scripts/monsters/*.test.mjs`）：

0. **`desc = _t[[...]]` 是调用不是字面量**。描述被汉化宏包了一层，按字面量
   读会得到"所有怪物都没有描述"。同一处 `_t` 解析也用在名称上，漏掉它中文
   覆盖率会直接掉到 0。
1. **`do` 不能当成块起始**。`for k, v in pairs(t) do` 里 `for` 和 `do` 各加一次
   深度，会让块跳过多吃一个 `end`，把 `newEntity{...}` 的 `}` 一起吞掉。正确做法是
   记住"循环头已开"，让它的 `do` 不再计数。
2. **`define_as` 不是全局唯一**。游戏会在多个区域文件里重复声明同一个
   `define_as`（`ELANDAR`、`GLADIATOR`、`BASE_NPC_NAGA`…），它们必须各自成行。
   但首版曾直接拿它当 React key，重复 key 让列表切换时残留旧卡片——界面显示
   101 个固定 Boss，数据其实只有 98 个。现在 id 统一做全局唯一化，重复项加
   `#2` 后缀并记录 `variantOf`。
3. **搜索 haystack 漏了随机组技能**。详情页正确显示了 4 套互斥组，但搜索
   `T_CALL_OF_THE_CRYPT` 找不到兽人死灵法师，因为 haystack 只拼了固定技能。
   同时 `T_HIEMAL_SHIELD` 被按 `_` 切成三个词，任何含 `shield` 的怪都会命中；
   现在查询解析器把带下划线的词当整体。
4. **`archive` 字段名不一致**。图片索引里写 `archive: 'gfx'`，归档注册用的是
   `id: 'tome'`，导致 `copyImages` 一张都读不出来（当时被"索引里本来就没这些
   文件"掩盖了）。修好后 682 张一次复制成功。

### 0.0.1 技能面板（同轮追加）

怪物页最初把技能链到搜索页，读一个技能要来回跳。改成复用职业页的
`TalentDetail`，在页面自己的面板里打开：

- ≥1280px（`xl`）：作为第三列放在怪物面板右侧，怪物技能列表保持可见，当前技能行
  高亮 `aria-pressed`。三列在 1280px 就成立，靠的是**列表让出一列**：技能面板打开
  时列表的卡片列数改用容器查询按列表自身宽度决定（<560px 一列，≥560px 两列），
  两块面板同时从 360px 收窄到 340px。**此前这一段要 1800px 才会变成第三列**
  （当时的 `xxl` 变体已因此删除），细节见 §0.5。
- <1280px（含手机）：同样是底部抽屉，但替代怪物抽屉（同一时刻只有一个抽屉，
  叠两层只会互相遮挡）；抽屉顶部是「← 返回怪物」按钮，关闭即回到怪物。
  e2e 在 1200 / 900 / 420 / 360px 四档逐一验证开、关与返回。

面板使用 `embedded` 模式：保留完整技能说明与数值模拟，去掉"跳到大系"面包屑与
收藏/对比按钮（怪物页没有大系上下文）。布局全部由 Tailwind 变体决定（<1280px
是否需要"技能抽屉替代怪物抽屉"这一个布尔量来自 JS 媒体查询），避免缩窗时 JS 与
CSS 判断不一致。

顺带修掉第 6 个真实缺陷：**技能点击之后的深链失效**。原来的 URL 同步用一个
"本地状态领先"布尔标记决定是否采纳新 hash，而那个标记会被错误的 render 消费掉：
先在本页打开技能、再用地址栏跳到 `#/monsters?cat=boss&m=WALROG`，新 hash 被当成
自己写的而丢弃（实测显示 812 个而不是 98 个，选中的也是上一只怪）。现在发布与
采纳各自记住"上次同步过的字符串"，只有既不是自己发布、也不是自己采纳过的 hash
才当成外部输入。e2e 里"深链 → 刷新 → 回到上一个怪物视图"这一段覆盖它。

---

## 0.1 上一轮变更（2026 续修，按 jj 提交顺序）

六次**功能**提交（文档更新另计），全部从"用户看到的现象"倒推到根因。
**每条都先复现、再改、再实测**，下面写的是可复核的证据，不是结论。
用 `jj log` 可以按 change-id 逐条查证。

| jj | 提交 | 现象 | 根因 | 结果 |
| --- | --- | --- | --- | --- |
| `yyxvzmqv` | 审计并修复覆盖层的「丢失滑条」 | 有些技能数字对，但滑条拖了不动 | 导出把非轴输入钉死时，15 点复现**证明不了**依赖存在 | 扫出 101 条「声明了却没读到」，回源码修好 24 条（22 条漏 `pmod`、2 条写死常数） |
| `ovoylqpx` | 详情卡片：数值模拟移到技能说明下方 | 一进卡片先看到滑条、后看到技能描述 | 顺序问题 | 现在是 技能说明 → 数值模拟 |
| `rorurnmm` | 强度滑条上限 200 → 150 | 滑条最右端拖不到、也没意义 | 有效 100 需原始 300，有效 150 已需原始 640；导出钉住的强度从来是 100 | 四种强度统一 1–150 |
| `llzqznvx` | 多轴阶梯：同阶梯参数随轴一起推进 | 无尽追踪等 34 个值**连滑条都不显示** | 三层都堵：公式在兄弟方法里、反解缺 driver、`ladderAxis` 拒绝多条阶梯 | 34 条解决 33 条；源码 3618→3650 |
| `sqpvuups` | 固定冷却 | 超越永恒显示 `50`，看不出它不吃减 CD | 导出**本来就有** `fixed_cooldown`，构建时被丢掉 | 27 条带上标记 + 角标 |
| `syntqmpz` | 筛选器：只看固定 / 只看非固定 | —— | —— | 三态互斥开关（全部 1826 / 固定 27 / 非固定 1799） |

### 0.1 这几轮真正修对的三处**判分器缺陷**

覆盖率从 3618 涨到 3650 不是"公式写不出来"，是**工具把正确的公式判成了错**：

1. **`ladderAxis` 拒绝多条阶梯**（`llzqznvx`）。导出会把**整个 `info` 函数**碰到的参数并集
   抄进每一个 acronym，所以标题常带 2–6 条阶梯。渲染语义是**引擎一列一列同时推进所有带阶梯的参数**，
   不是"变一个、其余钉在首值"——本轮 14 条自动新解的公式直接证明了这一点
   （匕首格挡是 `120 + 灵巧 + 敏捷`，只变一个的话第 2 点会是 155 而不是导出的 170）。
   实现：`axisSiblings()` + `simAtAxis()` 让**逐元素完全相同**的阶梯随轴一起走；
   真的不同的第二条阶梯（`魔力 10..100` 配 `角色等级 1..50`）仍然拒绝，剩 9 条。
2. **`isDeclaredInput` 不认 `kind:"other"`**。`physical save` / `精准` / `shield block 200`
   这些解析器认不出类别的标签**恰恰是公式真读的输入**。
3. **一条阶梯可以「这点截断、那点四舍五入」**（`llzqznvx`）。`matchesDisplayed()` 是逐点判的，
   而一次 `tformat` 调用用**同一个格式符**打印整条阶梯。新增 `readingIsConsistent()` 要求整条阶梯
   能被同一个约定读完（6 种：`trunc`/`round` × 不前置/`%0.1f`/`%0.2f`）。
   这个洞是**抓假阳性时发现的**：子代理提交的心灵震爆公式靠混用读数拿到了 PASS。
   收紧后全库 3481 条整数阶梯只有 2 条会掉。

> **重要方法论**：数值复现（三套 15 点）与"滑条正确"是**两件事**。
> 导出把非轴输入钉死时，前者无法证明后者；15 点也分辨不出"三行读同一个值还是各读各的"
> （无尽追踪三行都读豁免，读哪个只能由句子决定，已写进 `note`）。
> 这类条目必须回源码确认，或至少被显式计数以便复核。

### 0.2 仍未解决

| 类别 | 数量 | 说明 |
| --- | --- | --- |
| `unsupported input dimensions` | 9 | 标题里两条**真的不同**的阶梯（联合轴，如 `魔力 10..100` + `角色等级 1..50`）。要支持得让 `simAtAxis` 按索引同时推两条不同阶梯 |
| `source unavailable` | 70 | 信息主要在 addon 里（`data-possessors` 本地没有源码）；或 getter 读别的技能/武器/随机数 |
| `Multiple local assignment` | 10 | `info` 里多值局部赋值，无法确定哪个参数对应哪个 `%d` |
| `reference mismatch` | 11 | 有候选但算不对；多数是抽到了同技能另一个 getter 的表达式 |
| 判定为导出不自洽 | 1 | 心灵震爆 `T_MIND_BLAST#2`：1.00/1.30 沿技能等级渲染、1.50 沿属性渲染，两者互斥，公式写不出来（见报告 §2.5） |

### 0.3 数字与命令的对应关系

上面每个数字都能自己跑出来，不要凭文档相信：

```bash
cd modern_tome_viewer
npm run data          # 打印 manifest.scaling（源码/估算/参考 + 失败原因分布）与 overlay 重校验行
npm run check         # typecheck + scaling + verify + build + smoke
node scripts/try-formula.mjs --overlay data/lua-expressions.json   # 覆盖层逐条验收
```

---

## 0.2 部署（已完成并线上验证）

站点已发布到 GitHub Pages：

| 项 | 值 |
| --- | --- |
| 仓库 | <https://github.com/ovideros/modern_tome_viewer>（public） |
| 默认分支 | `main`，发布提交 `c23f018`（上一版 `cb27214`） |
| 线上地址 | <https://ovideros.github.io/modern_tome_viewer/> |
| 自定义域名 | <http://old.ovideros.site/modern_tome_viewer/>（见下方「账号级自定义域名」） |
| 工作流 | `.github/workflows/deploy-pages.yml`（push `main` 触发；`build` + `deploy` 均成功） |

- 工作流用 Node 22 + `npm ci`（有 lockfile 时）+ `npm run build:pages`，再用官方
  `configure-pages` / `upload-pages-artifact` / `deploy-pages` 发布
  `modern_tome_viewer/dist`；Pages 的 `build_type` 已设为 `workflow`。
- `vite.config.ts` 的 `base: './'` 让产物同时适配子路径与本地 `file://`，页面是
  hash 路由，子路径下的深链与刷新都正常（已在 `/modern_tome_viewer/` 前缀下实测）。
- **`public/data` 与 `public/img` 改为提交**：CI 的干净 checkout 没有 gfx 图集与
  语言表，生成不了这些文件，而站点运行时要 `fetch` 它们。`.gitignore` 里加了
  `!public/data/`、`!public/img/` 例外并写明原因。
- `t-engine4-src-1.7.6/`（638 MB 引擎解压树）已明确忽略，不再可能被 `git add -A`
  误收。**这是本轮踩到的坑**：根 `.gitignore` 是白名单式（`dlc-src/**/*.*` 这种
  规则不覆盖新目录），第一次在原始工作目录 `git add -A` 一次性暂存了 666 MB，
  后来改成「只导出该提交需要的路径」再提交，并把引擎树补进 `.gitignore`。

### 线上验证（真实浏览器，2026-09-10）

在 <https://ovideros.github.io/modern_tome_viewer/> 上实测：

- `#/monsters` 列出 812 个怪物；深链 `?cat=boss&m=WALROG` 得到 98 个结果，
  刷新后仍是 98；点技能在页内打开技能面板且 URL 仍停在 `#/monsters`。
- 怪物页 93 张 `<img>` 全部加载成功（`naturalWidth > 0`），0 张破损。
- 搜索 / 职业 / 种族 / 收藏各路由均正常渲染，**0 个控制台报错、0 个失败请求**。

### 账号级自定义域名（不是本仓库的配置）

`ovideros.github.io` 这个仓库在 Settings → Pages 设置了自定义域名
`old.ovideros.site`，GitHub 会把它套用到该账号下**所有** `*.github.io/<repo>/`
站点，所以本项目也多了一个 `old.ovideros.site/modern_tome_viewer/` 地址（两个地址
返回同一份页面）。仓库里没有 `CNAME` 文件，要改得去 `ovideros.github.io` 仓库改。

### 干净克隆的测试基线

| 环境 | 结果 |
| --- | --- |
| 完整源码机器（最新，含 §0.4–§0.8） | typecheck 无错 · monsters 51/51 · scaling 45/45 · verify 90/90 · smoke 73/73 · e2e 247/247 |
| 干净克隆（无 gfx 图集 / 语言表 / DLC 源码） | 上一轮实测：`build:pages` ✅ · smoke 61/61 · verify 87/87 · e2e 222/222 · monsters **40 通过 + 3 skip**；§0.4 新增的用例不依赖游戏源码，推算为 **48 通过 + 3 skip**（本轮未在干净克隆上重跑） |

那 3 项 skip 是需要图集或语言表的用例，测试里用 `skipArt` / `hasLocaleTables` /
`hasDlcSources` 三个信号显式声明原因，**不再是失败**。

详见 [deployment.md](deployment.md)。

## 0.3 本轮进展记录（本地简要）

> 上面 §0 / §0.1 / §0.2 是本轮做完并验证过的内容。这里是给下一轮接手用的一页速览，
> 细节都在对应文档里，不重复。§0.4（种类中文化 + 大类/亚类筛选）、§0.5（技能面板
> 放宽到 1280px）、§0.6（底部抽屉滚动修复）**均已提交并部署**，见 §0.7。

### 做完并验证过的事

| 阶段 | 结果 | 细节 |
| --- | --- | --- |
| 怪物图鉴 | `#/monsters`，812 个可遇模板（普通 447 / 精英 176 / 史诗 49 / 固定Boss 98 / 精英Boss 36 / 神级 6），130 个抽象 BASE 不计入 | [monster-pipeline.md](monster-pipeline.md) |
| 提取管线 | `scripts/monsters/`：Lua 读取器 → 继承合并 → 技能 resolver（固定/随机组）→ 汉化 → 图片 → 产物与报告 | §0 与 monster-pipeline.md |
| 技能补缺 | 从 Lua 补 8 条上游缺失技能（含 `T_HEAT`），技能总数 1826 → 1834，怪物引用技能 0 未收录 | monster-pipeline.md §8 |
| 页内技能面板 | 点技能不离开怪物页：≥1800px 第三列，更窄为底部抽屉，<1280px 抽屉替代怪物抽屉并提供「← 返回怪物」 | §0.0.1 |
| 部署 | GitHub Pages 已上线并线上验证（812 怪物 / 深链 98 / 图片 0 破损 / 0 报错） | [deployment.md](deployment.md) |

### 本轮修掉的 7 个真实缺陷（都有测试兜底）

1. `for … do` 的 `do` 被当成第二个块起始，吞掉实体表的 `}`（845 → 942 模板）
2. `desc = _t[[...]]` 被当成字面量，导致全部怪物描述为空
3. `define_as` 在多个区域文件重复，重复 React key 让列表残留旧卡片
4. 搜索 haystack 漏了随机组技能，且技能 id 被按 `_` 切词
5. 图片索引的 archive 名与归档注册 id 不一致，一张图都复制不出来
6. URL 同步状态机在「本页点技能后再深链」时丢弃新 hash
7. 窄屏用 `hidden` 类切换面板时输给 `xl:hidden`，关闭技能后怪物面板永久消失

### 下一轮可以接着做的

- [ ] 9 个缺图模板（`human`、`dwarf`、`Ureslak the Prismatic` 等）：多为 `moddable_tile`
      合成模型或画风里确实没有 PNG，已逐条列在 `monsters-report.json` 的 `imageGaps`
- [ ] `monsters-report.json` 里 39 条诊断（32 条是跨区域重复 `define_as`，属正常）
- [ ] 毒池/教程等内部技能在技能列表里的呈现（当前只标注 `supplemental: true`）
- [ ] 干净克隆下 3 项需要图集/语言表的测试用例：若要全绿，需把 gfx 图集纳入 CI 输入
- [ ] 技能补缺管线目前是「按 id 集合补」，若要覆盖更多上游缺口需扩展 `data:supplement`

### 常用命令

```bash
cd modern_tome_viewer
npm run data          # 技能 + 怪物数据 + 图片（需本机游戏源码包）
npm run check         # typecheck + monsters + scaling + verify + build + smoke
npm run e2e -- http://127.0.0.1:4173/     # 需先 npm run serve
npm run build:pages   # 部署构建（校验已提交产物）
```

---

## 0.4 追加：怪物种类中文化与「大类 / 亚类」选择器

需求：把页面上的 `horror / eldritch` 这类英文种类换成中文，并在左侧搜索栏下方
加一个按 `type`（大类）与 `subtype`（亚类）两级选择的筛选器，交互参考职业页。
**代码已完成并通过全部本地测试，尚未提交、未推送**（等本地网页验收）。

### 数据层

| 改动 | 位置 |
| --- | --- |
| 语言解析保留 `_t(text, tag)` 的上下文分表 `byContext` | `scripts/monsters/locale.mjs` |
| 新增 `translateEntityWord(locale, tag, value)`：按 `entity type` / `entity subtype` 取词，缺失才回退扁平映射 | 同上 |
| 快照升到 `version: 2`，多出 `contexts` 段（只存这两个表：65 + 232 条） | `scripts/monsters/locale-snapshot.mjs` |
| 每个模板写入 `typeZh` / `subtypeZh`；`census` 增加 `distinctTypes` / `distinctSubtypes` / `withChineseType` / `withChineseSubtype` / `withSubtype`；报告增加 `missingTypeLabels` | `scripts/monsters/build-monsters.mjs` |
| 重新生成 `public/data/monsters.json` 与 `data/raw/locales/zh_hans.json`（图片零变化，报告只多两个字段） | 运行 `npm run data:monsters` |

覆盖：**812/812 大类、811/811 亚类**有中文，`missingTypeLabels` 为空。

### 界面层

- `TypeChip` / 详情面板 / 缺图占位符都改成中文（如 `恐魔 / 艾尔德里奇`），
  tooltip 保留源码英文；详情面板「数据来源与继承」新增一行中文 + 源码对照。
- 侧栏搜索框下方新增 `MonsterTypeTree`：`全部类别` → 20 个大类行（中文 + 英文 +
  计数），选中的大类展开它的亚类（缩进），再点一次逐级回退；点大类切换时自动清空
  亚类。手机端（<1024px）用两个 `<select>` 暴露同样两级。
- 筛选与 URL：`?type=horror&sub=eldritch`（亚类只在有 `type` 时生效）；结果行显示
  「类别“恐魔” / “艾尔德里奇”」。搜索 haystack 增加 `typeZh` / `subtypeZh`，
  所以搜「害虫」「大恶魔」也能命中。
- 亚类值归一化：`subtypeKey()` 把 `Sher'Tul` / `sher'tul` / `shertul` 折成一行
  （否则侧栏会出现三行「夏·图尔」），全库仅此一处冲突。

### 顺带修掉的一个真实缺陷

怪物页的 URL 同步是**单向**的：只有 `onParamsChange`（只改 App 状态），不像
搜索/职业/种族页那样调用 `writeHash`，所以页面内选完筛选器后地址栏不变、刷新即丢。
补上 `writeHash('monsters', …)` 后又暴露第二个坑：`publishedHash` / `adoptedHash`
用 `''` 当"还没同步过"的哨兵，而"无筛选"本身就是一个合法空串，
于是**清空筛选时 publish effect 直接早退**，地址栏留着旧参数。
两处一起修：哨兵改成 `undefined`，publish effect 不再拿 `adoptedHash` 比较。
回归测试：smoke「the active type/subtype is written to the URL」、
e2e「type/subtype filter is written to the URL」+ 深链还原 + 清除后恢复 812。

### 验证（本机，全部通过）

```bash
npm run typecheck      # 无错
npm run test:monsters  # 51/51
npm run test:scaling   # 45/45
npm run verify         # 87/87
npm run build:pages    # 通过（校验已提交产物）
npm run smoke          # 70/70
npm run e2e            # 当时 239/239；§0.5 追加 4 项后为 243/243（需 node scripts/serve.mjs dist 4173）
```

### 已知取舍

- `light` 亚类（1 个怪：`crystal.lua:61` 的 wisp）按游戏的
  `entity subtype` 表显示为「轻甲」——与游戏内 tooltip 一致；这是上游汉化表
  自身的上下文冲突，页面不做修正，tooltip 给出源码 `elemental / light`。
- 类型树的计数是全集总数（与稀有度行一致），不随关键词变化。

---

## 0.5 追加：技能面板的宽度门槛从 1800px 放宽到 1280px

需求：在怪物页显示技能面板要求太宽；希望技能面板打开时左侧怪物列表从两列
变成一列来腾空间。**已完成并通过全部本地测试，未提交、未推送。**

### 改法

| 位置 | 之前 | 现在 |
| --- | --- | --- |
| 技能面板作为第三列 | `xxl:block`（≥1800px） | `xl:block`（≥1280px，`data-testid="monster-talent-column"`） |
| 技能底部抽屉 | `xxl:hidden` | `xl:hidden`（<1280px，与怪物抽屉同一档） |
| 怪物面板宽度 | 固定 360px | 技能面板打开时 340px，否则 360px |
| 技能面板宽度 | 固定 360px | 340px |
| 卡片列表列数 | 恒定 `sm:grid-cols-2` | 技能面板打开时改为容器查询：`main` 加 `@container`，网格用 `@min-[560px]:grid-cols-2`（按列表自身宽度决定）；未打开时仍是 `sm:grid-cols-2` |
| `xxl` 变体 | `src/styles.css` 自定义 | 已无引用，删除 |

实测（本机 Chromium，`?m=WALROG` + 点开一个技能）：

| 视口 | 侧栏 | 列表 | 卡片列数 | 怪物面板 | 技能面板 |
| --- | --- | --- | --- | --- | --- |
| 1280 | 236 | 296 | 1 | 340 | 340（列） |
| 1500 | 236 | 516 | 1 | 340 | 340（列） |
| 1600 | 236 | 616 | 2 | 340 | 340（列） |
| ≥1600 | 236 | ≤616 | 2 | 340 | 340（列；页面外层 `max-w-[1600px]` 封顶） |
| <1280 | 236 | — | 1–2 | 抽屉 | 抽屉（替代怪物抽屉） |

各档均无横向滚动、无卡片内容溢出；`cardColumns` 用
`getComputedStyle(grid).gridTemplateColumns` 实测，不是看类名。

### 为什么用容器查询

列数要跟着**列表自己的宽度**变，而不是视口：同一视口下开着技能面板时列表会少
700px，用 `sm:`/`xl:` 这类视口断点只能写成"技能打开时 → 一列；≥某宽度 → 两列"的
特例，还得再引入一个魔数断点。容器查询直接表达"列表够宽就两列"，
1600px 起自动恢复两列，以后改侧栏或面板宽度也不用重算断点。
未打开技能面板时不使用该分支，保持原有 `sm:grid-cols-2` 行为不变。

### 测试

- e2e 新增/改写 4 项：1500px 是**列**而不是抽屉、1500px 列表一列、1280px 三栏仍然
  成立且列表 ≥240px、1600px 列表恢复两列；<1280px 的 1200/900/420/360 四档抽屉
  行为不变。
- smoke 的「技能面板在当前视口有呈现方式」原本就接受列或抽屉，未改。

### 验证

```bash
npm run typecheck      # 无错
npm run test:monsters  # 51/51
npm run smoke          # 70/70
npm run e2e            # 当时 243/243；§0.6 追加 4 项后为 247/247
```

---

## 0.6 追加：底部抽屉滚不动（滚动跑到背后的怪物列表）

现象：窄屏（<1280px）打开怪物抽屉或技能抽屉后，**抽屉里的内容无法上下滑动**；
手指/滚轮一划，动的是抽屉背后的怪物列表。

### 根因

抽屉的 DOM 是"外壳 + 面板"两层，但两层的高度约束是错的：

```html
<!-- 旧写法 -->
<div class="fixed inset-x-0 bottom-0 max-h-[75vh]">          <!-- 只有 max-height -->
  <div class="mx-2 mb-2 max-h-[75vh] overflow-hidden">       <!-- 只有 max-height -->
    <section class="panel flex h-full flex-col overflow-hidden">  <!-- h-full -->
      <header>…</header>
      <div class="min-h-0 flex-1 overflow-y-auto">…</div>         <!-- 本该滚动 -->
```

`h-full`＝`height:100%`，而父元素的高度是 `auto`（只有 `max-height`），
百分比高度按 `auto` 处理 → 面板长到内容高度（实测 881px），内层滚动区随之被撑开
（`scrollHeight == clientHeight`，永远不会滚动）；外层 `max-h` + `overflow-hidden`
只是把超出 75vh（675px）的部分**裁掉**，内容既看不到也够不到。
滚轮的"最近可滚动祖先"因此落到了 `<body>`，于是背后的列表在滚。

浏览器实测（420×900，`#/monsters?m=WALROG`）：修前内层滚动区 752/752、
页面 `scrollTop` 0 → 400；修后面板被压到 667，内层 538/752，滚轮把内层滚到
214 且页面 `scrollTop` 保持 0；继续滚到末尾也不再带动页面。

### 修法

1. 抽屉外壳与内层都改成**有界的 flex 列**：
   `fixed … flex max-h-[75vh] flex-col` + `flex max-h-[75vh] min-h-0 flex-col overflow-hidden`。
   这样 `max-height` 会真的把面板"压小"，而不是让它长出去再裁掉。
2. 面板根节点加 `min-h-0`（`MonsterDetail` 的 `<section>`、`TalentDetail` 的
   `<aside>`）。flex 子项默认 `min-height:auto` 不允许缩到内容以下，加 `min-h-0`
   才能被压缩，内层 `min-h-0 flex-1 overflow-y-auto` 才会得到有限高度而可滚动。
   桌面两栏场景父元素本来就有确定高度（`h-[calc(100vh…)]`），`min-h-0` 对它是空操作。
3. 面板正文加 `overscroll-contain`（`overscroll-behavior: contain`）：
   抽屉滚到底后不再把滚动"接力"给背后的页面。

同一套结构在 4 个页面共 5 处（怪物页 2 处、职业页、种族页、搜索页），
**全部一起修**（它们是同一份复制粘贴的写法，只修一处等于留着 4 个同样的坑）。

### 回归测试

e2e 新增 4 项（`420px … sheet scrolls itself` / `does not scroll the list behind it`
× 怪物抽屉、技能抽屉）：读内层滚动区的 `scrollHeight/clientHeight` 判断是否可滚，
在正文里真实滚一次滚轮，断言"内层 `scrollTop` > 0 且页面 `scrollTop` 不变"。
这两点正好覆盖本次的失败模式；happy-dom 没有布局，所以这只能由 e2e 兜住。

### 验证

```bash
npm run typecheck      # 无错
npm run test:monsters  # 51/51
npm run smoke          # 70/70
npm run e2e            # 247/247
```

---

## 0.7 已推送并部署（2026-09-11）

| 项 | 值 |
| --- | --- |
| 提交 | `cb27214`（§0.4 / §0.5 / §0.6 一个提交，24 个文件；其前是本地文档记录 `4fac3e0`） |
| 推送 | `042542a..cb27214  main -> main`（`git push -u origin main`） |
| Actions | run `34559164635` → **success**（`build` + `deploy`，约 1 分钟） |
| 线上验证 | 真实浏览器 12 项全过：812 个模板 · `?type=horror&sub=eldritch` = 61 · 卡片与侧栏中文种类 · 1500px 技能为第三列且列表一列 · 420px 两个抽屉自身可滚且不带动背后列表 · 0 控制台报错 · 0 失败请求（图标 404 除外） |

线上站点：<https://ovideros.github.io/modern_tome_viewer/>（`#/monsters`）。

> 注意：本文件的"发布提交"指向最后一次**功能**发布；之后若只有文档提交，
> 站点内容不会变。要确认线上到底是哪一版，看 Actions 最近一次成功 run 的
> `head_sha`，或直接看 `index.html` 里的 JS 文件名。

---

## 0.8 追加：技能说明的数值被放到了错误的句子上（法术亲和）

**现象**（用户报告）：法术亲和（`T_SPELLCRAFT`）默认状态显示
"你学会巧妙控制和调谐你的法术，降低 49, 66, 79, 90, 100 法术冷却时间。"
——既没有百分号，数值也大得不像话（游戏里这个减冷却上限只有 30%）。

**结论：确实是显示错误，而且是两层问题叠出来的。**

### 根因

1. `src/lib/data.ts` 的 `expandAcronym` 用 `if (!wire.f) return null` 把
   **没拟合出公式族（family）** 的词条整个丢掉。但 `family` 只服务于
   "用 base/max 反推" 的兜底路径；**有 Lua 表达式**的词条根本不需要它，
   而 Lua 表达式是最强的来源。实测全库 3750 条里有 **295 条**属于这种
   （分布在 **219 个技能**），全部被丢掉，数组因此变短。
2. `src/components/VariableText.tsx` 的 `buildNodes` 把描述里的 `<acronym>`
   占位符与这个数组**按位置**配对，于是丢掉一条，后面所有数值整体前移一句：
   法术亲和的减冷却句拿到了下一句的"额外法术强度"阶梯（49…100，本来就没有
   `%`），而后面的句子退化成导出原文（没有 tooltip、不参与模拟）。
   顺带解释用户看到的"没有百分比"：**不是百分号丢了**，是那一格换成了别的值。
3. 另有 2 个技能（护甲掌握 `T_GOLEM_ARMOUR`、鲁莽冲撞 `T_RECKLESS_CHARGE`）
   的占位符是**词阶梯**（"降低护甲/增加护甲"、"Small/Medium-sized/Big"），
   构建侧本来就不为它生成数值条目，位置同样错位。

### 修法

| 位置 | 改动 |
| --- | --- |
| `expandAcronym` | 只有词条"既无 Lua、又无 family、又无导出阶梯"时才丢；`family` 类型改为允许 `null`（`scaling.ts` 与 `scaling-core.d.ts` 同步） |
| `buildNodes` | 改为**按占位符自己显示的数字**配对（相同阶梯优先取第一个未用的）；没有数字的占位符保留导出原文且**不消耗**数值；匹配不上时退回"下一个未用"（＝原来的位置配对） |
| 不变 | 数值本身没错，`public/data/talents.json` 不需要重新生成 |

按内容配对是严格改进：数据对齐时它与位置配对**完全等价**（同一阶梯序列
一一对应），只有在位置已经漂移时才纠正。

### 结果（真实浏览器实测）

| 技能 | 修前 | 修后 |
| --- | --- | --- |
| 法术亲和 | 降低 **49, 66, 79, 90, 100** 法术冷却时间（无 %） | 降低 **6%, 13%, 20%, 26%, 30%** 法术冷却时间；下一句"获得 49, 66, 79, 90, 100 额外法术强度加成" |
| 护甲掌握 | 词阶梯后三个数值整体前移 | "降低护甲, …, 增加护甲 **-2, -1, 0, 1, 2** 点，护甲强度 **-10%…**，减少 **-3%…** 被暴击率" |
| 鲁莽冲撞 | 体型词换成攻击次数 | "Small, …, Big 体型…" 保留，攻击次数 **2, 3, 4, 5, 6** 归位 |
| 意志之力 | 整句退化为导出原文（无模拟） | "增加武器伤害 **29%, 42%, 51%, 59%, 66%**"，可模拟 |

> 法术强度那条在**搜索页**默认是 49,66,79,90,100，导出原文（系数 1.5）是
> 58,79,95,109,122：搜索页没有职业上下文，滑条默认系数 1.0；职业页按该职业
> 掌握度取值，tooltip 里「当前条件 / 导出条件」并列可对照。这是既有设计，
> 本次未改。

### 回归测试

- `scripts/verify.mjs` 新增 3 项不变量（对全库 1834 个技能）：
  ① 每个导出值都活过 reader；② 每个**含数字**的占位符都有自己的值
  （词阶梯豁免）；③ 法术亲和三条值的顺序与后缀。
  这两条不变量正是本次失败模式：修改前 ① 报 219 个技能、② 报 2 个技能。
- `scripts/smoke.mjs` 新增 3 项渲染断言（真实产物 + 真实数据）：
  法术亲和的减冷却句含 `6%, 13%, …%`、强度阶梯不在减冷却句里、
  护甲掌握的词阶梯不吃掉后面的数值。

### 验证

```bash
npm run typecheck      # 无错
npm run test:monsters  # 51/51
npm run test:scaling   # 45/45
npm run verify         # 90/90（新增 3 项）
npm run smoke          # 73/73（新增 3 项）
npm run e2e            # 247/247
```

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
| 结构化筛选（模式/冷却/固定冷却/速度/射程/资源/需求/职业/标记 + 分面计数） | 完成 |
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
npm run test:monsters → 51/51
npm run test:scaling → 45/45
npm run verify      → 90/90
npm run smoke       → 73/73
npm run e2e         → 247/247  （需 PLAYWRIGHT_BROWSERS_PATH=<仓库>/.pw-browsers）
npm run data        → 覆盖层 1053/1053 accepted；manifest.scaling.source = 3650/3750
```

构建产物：JS 286 KB（gzip 88 KB）、CSS 27 KB、`talents.json` 4.1 MB。

**顺序很重要**：`npm run data` → `vite build` → 再跑 smoke/e2e。跳过重建会让测试跑在旧 `dist/` 上
（曾经因此把"全绿"报错，实际测的是旧产物）。`scripts/serve.mjs` 从磁盘流式读，换产物不用重启。


## 3. 目录结构

```
modern_tome_viewer/
├── data/raw/master/             # 上游 tometips 导出的原始 JSON（已提交，构建输入）
├── public/                      # 由 npm run data 生成（未提交）
│   ├── data/talents.json        #   规范化技能数据（含反解出的系数）
│   ├── data/meta.json           #   分类/职业/种族/词表/边界
│   ├── data/talents.json        #   规范化技能数据（含补充技能）
│   ├── data/monsters.json       #   怪物图鉴数据（本轮的产物）
│   ├── data/monsters-report.json#   怪物覆盖率/诊断/缺图报告
│   ├── data/manifest.json       #   构建元信息
│   └── img/{talents/48,class-icons,player,npc,object,terrain}/
├── data/talent-supplement.json  # 从 Lua 补的上游缺失技能（已提交，构建输入）
├── data/raw/locales/zh_hans.json# 规范化的游戏汉化表（已提交；上游 16MB 语言表不入库）
├── scripts/
│   ├── build-data.mjs           # 技能数据管线（清洗/富化/反解/拷贝图标）+ 合并补充技能
│   ├── monsters/                # 怪物数据管线（见下）
│   │   ├── lua-table.mjs        #   实体定义用的 Lua 读取器（不执行 Lua）
│   │   ├── extract.mjs          #   模板/继承/技能 resolver/等级/图片解析
│   │   ├── images.mjs           #   内置 ZIP 读取器 + Shockbolt 图片索引与复制
│   │   ├── locale.mjs           #   游戏汉化表解析（英文 → 中文）
│   │   ├── locale-snapshot.mjs  #   生成已提交的汉化表快照 + 干净环境兜底
│   │   ├── talent-supplement.mjs#   从 newTalent{} 提取上游缺失技能
│   │   ├── build-monsters.mjs   #   入口：产出 monsters.json / 报告 / 图片
│   │   └── *.test.mjs           #   43 项怪物管线与前端检索测试
│   ├── verify.mjs               # 87 项引擎断言
│   ├── build-pages.mjs          # 部署构建（校验已提交产物后 vite build）
│   ├── smoke.mjs                # 61 项渲染冒烟（happy-dom）
│   ├── e2e.mjs                  # 222 项真实浏览器端到端
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
│   ├── lib/monsters.ts          #   怪物数据加载、倒排索引（固定/随机技能）、检索
│   ├── hooks/                   #   主题、数据加载、hash 路由、收藏/对比、表头高度
│   ├── components/              #   搜索栏、筛选面板、结果列表、详情面板、对比栏、
│   │                            #   VariableText（实时数值+tooltip）、ClassBits
│   └── pages/                   #   SearchPage / ClassesPage / RacesPage /
│                                #   MonstersPage / FavoritesPage / ComparePage
├── docs/feasibility.md          # 可行性分析 + 反解原理 + 常见疑问（第 10 节）
├── docs/monster-pipeline.md     # 怪物图鉴：收录口径、数量、继承、图片、已知边界
├── docs/deployment.md           # GitHub Pages 部署（产物提交策略、启用步骤）
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
   >
   > **筛选器**：`FilterState.cooldownKind: 'any' | 'fixed' | 'normal'`（默认 `any`），
   > 在「冷却时间」分区里是一个 `role="radiogroup"` 的三态开关（全部 / 只看固定 27 / 只看非固定 1799），
   > 计数由 `cooldownKindCounts()` 给出——它和别的分面一样先把开关本身放开再计数，所以数字回答的是
   > "选这项会剩几个"。两个半区**互斥且穷尽**（合成全集，verify 有断言），
   > 但和数值窗口是**正交**的：`只看固定 + 冷却≤5` 会得到 2 条（时空之箭、无影手）。

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

### 5.1 现状（**本轮**＝最初那次源码提取扩展；最新总量见 §0）

> 下面这组数字是**那一轮**的快照，保留是为了说明"每次跳变靠什么"。
> 当前是 **3650 源码 / 71 反解 / 29 参考**。

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

> 数字是 §0 的总账；下表按"投入产出比"排，不是按条目数。

### 6.1 继续提高源码覆盖率

1. **联合轴支持（9 条，收益中等但能收口一类）**——`simAtAxis()` 目前只能推"逐元素相同"的
   那组阶梯。真正的联合轴（`魔力 10..100` 配 `角色等级 1..50`，两条按索引一起走）
   需要一个 `axes: [{label, ladder}]` 的多轴形式，并让 `ladderAxis()` 在
   "两条阶梯长度相同"时返回全部；判分逻辑本身不用动。
2. **`source unavailable` 70 条**——逐个看是"读别的技能 getter"还是"读运行时数据"。
   前者可在提取器里做一次跨技能内联（`self:callTalent(T_X, "getY")`）；
   后者（武器伤害、随机数、别的角色状态）应明确记为不可建模，不要再花时间。
3. **`Multiple local assignment` 10 条**——放宽局部变量解析（多值返回、表构造）。
   注意 `T_RELENTLESS_PURSUIT` 那类"公式在兄弟方法里"的形态：提取器不内联
   `t.getXxx(self, t)`，这是本轮手写覆盖层里最大的一类来源。
4. **Possessor 源码**——用户未提供 `data-possessors/`，需要时向其索取。

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
