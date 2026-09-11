# 怪物数据管线（monsters）

本文件说明「怪物」页面的数据是怎么从 ToME 1.7.6 源码变成
`public/data/monsters.json` 的，以及哪些判断有源码依据、哪些是已知缺口。

相关命令：

```bash
cd modern_tome_viewer
npm run data            # 技能数据 + 怪物数据（含图片复制）
npm run data:monsters   # 只重建怪物数据
npm run data:supplement # 重新从 Lua 提取上游缺失的补充技能
npm run data:locale     # 从游戏语言表重建已提交的汉化表快照
npm run test:monsters   # 怪物管线单元测试
```

产物：

| 文件 | 内容 |
| --- | --- |
| `public/data/monsters.json` | 图鉴数据（812 个可遇模板 + 统计口径） |
| `public/data/monsters-report.json` | 覆盖率、诊断、未解析项、缺图清单 |
| `public/img/<分类>/*.png` | 只复制被引用的 Shockbolt 图片（681 张） |
| `data/talent-supplement.json` | 上游技能导出缺失、但怪物实际引用的补充技能（已提交） |
| `data/raw/locales/zh_hans.json` | 规范化的游戏汉化表（已提交，见 §6） |

## 1. 输入

| 来源 | 目录 | Lua 文件 | newEntity 模板 |
| --- | --- | ---: | ---: |
| 本体 1.7.6 | `tome-src-full` | 158 | 707 |
| 兽人 DLC | `dlc-src/orcs/tome-orcs` | 41 | 149 |
| 灰烬 DLC | `dlc-src/ashes-urhrok/tome-ashes-urhrok` | 4 | 10 |
| 邪教 DLC | `dlc-src/cults/tome-cults` | 24 | 76 |
| 合计 | | **227** | **942** |

扫描范围是 `data/general/npcs/**/*.lua` 与 `data/zones/**/npcs.lua`。图片来自
`t-engine4-src-1.7.6/game/modules/tome-1.7.6-gfx.team` 与三个 DLC 的
`overload/data/gfx/shockbolt/`，由 `scripts/monsters/images.mjs` 里的内置 ZIP
读取器直接读取，不需要预先解包，也不会把整个 gfx 包复制进产物。

## 2. 解析与继承

`scripts/monsters/lua-table.mjs` 是一个只覆盖实体定义所需语法的 Lua 读取器：
注释、四种字符串字面量、表构造器、`newEntity{...}` / `newTalent{...}` 调用、
`if ... then newEntity{...} end` 包装、以及 `function ... end` 体（体只做块级
跳过，不执行）。它不执行 Lua，也不求值表达式；读不懂的内容记进
`diagnostics` 而不是丢掉。

继承按官方引擎 `engine/Entity.lua` 的语义处理：

- `newEntity{ base = "X" }` 先克隆父模板，再用 `table.mergeAppendArray`
  合并自身字段——标量覆盖、嵌套表递归合并、数组部分追加。
- 因此技能 resolver **按父→子顺序累积**，同名技能后出现的定义覆盖先出现的；
  `resolveTalents()` 保留每种 resolver 的结构而不是把它们拍平成一张技能表。
- `base` 找不到时记入 `unresolved`，页面会明确显示"父模板未能解析"。

`define_as` 只在**同一个加载上下文**内唯一，游戏确实会在多个区域文件里重复
声明同一个 `define_as`（`ELANDAR`、`GLADIATOR`、`BASE_NPC_NAGA`…）。这些变体
必须各自成行，所以 id 在收集结束后做一次全局唯一化：第一次出现保留原名，
之后追加 `#2`、`#3`，同时用 `variantOf` 记下它属于哪个原始 id。首版没有完整
模拟引擎的逐文件加载列表，因此父模板解析是全局的；`unresolved` 为 0 说明本
版本源码里所有 `base` 都能找到定义。

## 3. 收录口径与数量

942 个模板中，**130 个是抽象模板**（`define_as` 以 `BASE_` 开头，或者没有从
父模板继承到任何 `name`），它们只用于继承，不计入图鉴。其余 **812 个**带名称
的实体被收录。

分类依据是引擎 `Actor:textRank`（`mod/class/Actor.lua`）：

| rank | `textRank` | 页面分类 | 数量 |
| ---: | --- | --- | ---: |
| 1 | critter | 普通怪物 | 80 |
| 2 | normal | 普通怪物 | 363 |
| 3 | elite | 精英 | 176 |
| 3.5 | unique | 史诗 | 49 |
| 4 | boss | 固定Boss | 98 |
| 5 | elite boss | 精英Boss | 36 |
| 10 / 11 | god / godslayer | 神级 | 6 |
| 未声明 rank | 继承默认（按普通处理） | 普通怪物 | 4 |
| | | **合计** | **812** |

源码模板里**没有 rank 3.2（rare）**：引擎只在运行时给随机稀有怪赋这个等级
（`mod/class/GameState.lua`），所以要读"稀有怪"只能看随机生成规则，图鉴里
没有对应的固定模板。`classifyRank` 仍然实现 3.2 → 精英，以便接入运行时数据。

按来源：本体 613、兽人 125、灰烬 8、邪教 66。

- **固定 Boss**：rank ≥ 3.5，共 **189** 个（史诗 49 + 固定Boss 98 + 精英Boss 36
  + 神级 6）。这些是源码里写死名字的实体，与稀有怪随机职业无关。
- `unique = true` 的模板共 **165** 个。它是"名字固定、不会被随机改名"的标记，
  不直接等价于 rank：有些 boss 不写 `unique`，也有 rank 3.5 的 `unique`。
- **高难度追加随机职业**：`NPC:addedToLevel`（`mod/class/NPC.lua:446`）会给
  rank ≥ 3.5 且没有 `no_difficulty_random_class` 的固定 Boss 追加一个随机职业。
  符合条件的有 **179** 个，明确用 `no_difficulty_random_class` 关闭的有 **14** 个。
  注意 `randboss` 是**另一件事**（程序化生成的首领），本版本源码里没有任何
  固定模板设置它，所以页面对它单独标注。
- 有固定技能的 729 个，有随机技能组或随机池的 218 个，两者都没有的 83 个是
  平民、商贩、石碑、任务 NPC 这类实体，页面直说"源码未给这个模板配置固定技能"。

数量不是被强行凑出来的：`census` 里的每个数字都能用
`node scripts/monsters/build-monsters.mjs` 重跑出来，单元测试也会核对分桶之和
等于收录总数。

**大类与亚类**：812 个模板覆盖 `type` 20 种、`subtype` 89 种（其中 1 个模板没有
亚类），每条都带中文 `typeZh` / `subtypeZh`（见 §6.1）。侧栏按 `type → subtype`
两级选择，计数是全集总数而不是当前结果的分面计数，因此输入关键词时数字不会跳动。

## 4. 技能：固定、随机组与职业

`engine/resolvers.lua` 把技能分成三类，页面按同一区分展示：

| resolver | 语义 | 页面表现 |
| --- | --- | --- |
| `resolvers.talents{...}` | 逐项 `learnTalent`，必然拥有 | 「固定技能」列表 |
| `resolvers.rngtalents{...}` | 从池中抽若干个 | 「随机技能池」可折叠块 |
| `resolvers.rngtalentsets{...}` | 选中**一整套** | 「技能组 N」可折叠块，并说明互斥 |

以兽人死灵法师（`data/general/npcs/orc-rak-shor.lua:52`）为例：6 个固定技能，
另有 4 套互斥组（骷髅／食尸鬼／黑暗／寒冷）。页面把它显示为「固定技能」+
「技能组 1..4」，并写明"只获得其中一套"，不会伪装成同时拥有 24 个技能。

`auto_classes` 只表示"声明了职业"，`mod/class/Actor.lua` 的 `levelupClass` 会按
点数、等级和条件随机分配，所以页面只列出职业名并附上这条限制，不声称怪物能
获得该职业的全部技能。

## 5. 技能等级

技能条目保留源码里的两种写法：

- `[Talents.T_X] = 3` → 「固定 3 级」
- `{ base = 2, every = 7, max = 7, last = 25 }` → 「初始 2 级，每 7 级 +1，上限 7 级，25 级后不再提升」

`base = 0` 会显示成「初始 0 级（升级后获得）」，因为 0 意味着可能还没拥有。
这些规则来自 `Actor:resolveLevelTalents` / `ActorTalents.lua`，页面只复述规则，
**不计算**最终等级：那需要角色的实际等级，而且 50 级以上 `max` 会被放宽、
`points == 1` 与召唤物还有例外，这些都不是单只怪物自己的属性。

点击技能**不会离开怪物页**，任何宽度都不会：技能在页面自己的面板里打开，沿用与
职业页完全相同的 `TalentDetail`（同样的技能说明、数值模拟、标记与需求展示）。

| 视口 | 技能面板位置 | 怪物面板 | 卡片列表 |
| --- | --- | --- | --- |
| ≥ 1280px（`xl`） | 第三列，在怪物面板右侧（两块面板各 340px） | 同时可见，技能行高亮当前项 | 列数**跟随列表自身宽度**：< 560px 时一列，≥ 560px 两列（约 1544px 视口起恢复两列） |
| < 1280px（含手机） | 底部抽屉 | 被技能抽屉**替代**，抽屉顶部有「← 返回怪物」按钮，关闭即回到怪物 | 不变（`sm` 起两列） |

三列在 1280px 就能成立，是靠**列表让出一列**换来的：技能面板打开时列表的
卡片列数改用容器查询（`main` 上的 `@container` + `@min-[560px]:grid-cols-2`），
按列表自己的宽度决定，而不是按视口；同时怪物/技能两块面板各让出 20px
（360 → 340）。这样 1280px 下三块分别是 236（侧栏）/ 296（列表）/ 340 / 340，
既不横向溢出，卡片也不会被压到不可读。此前技能面板要 1800px 才会变成第三列。

窄屏为什么是"替代"而不是"叠两层"：两者都是贴底的抽屉，叠起来只会让技能盖住
怪物，反而更难用。所以同一时刻只显示一个抽屉，技能抽屉把返回入口放在标题栏
（`aria-label="返回怪物"`），一次点击回到怪物；怪物面板本身随时可以再打开。

抽屉必须写成**有界的 flex 列**（外壳 `flex max-h-[..vh] flex-col` + 内层
`flex min-h-0 flex-col overflow-hidden`，面板根节点再带 `min-h-0`），否则
`h-full` 在 `auto` 高度下退化成内容高度，面板会顶破抽屉被裁掉、内层滚动区永远
滚不动，滚轮就落到背后的列表上。踩坑细节与实测数字见
[HANDOVER.md §0.6](HANDOVER.md)。

面板是 `embedded` 模式：保留完整说明与模拟器，去掉"跳到大系"面包屑与收藏/对比
按钮（怪物页没有大系上下文，收藏与对比由搜索页负责）。

页面里也明确写出"未注入这只怪物的属性与装备，模拟器用的是技能自身的默认值"，
避免把默认 5 级当成怪物实际等级。

## 6. 中文

中文来自游戏自己的汉化表，不另建翻译表：

- 名称/描述：`tome-src-full/data/locales/zh_hans.lua` 与三个 DLC 的
  `data/locales/zh_hans.lua`（合计 23405 条），由 `locale.mjs` 解析成
  `英文 -> 中文` 映射，后加载的表覆盖先加载的。
- 大类/亚类（`type` / `subtype`）：同样来自这张表，但**必须带上下文标签**查，
  见下节。
- 技能名与技能文本：复用 `public/data/talents.json` 的现有中文。

**为什么还提交了一份快照**：上游语言表共 16 MB，按仓库既有策略不入库
（根 `.gitignore` 忽略 `tome-src-full/data/locales/`），而怪物名称与描述必须
查它。于是 `locale-snapshot.mjs` 把解析结果规范化后写到
`data/raw/locales/zh_hans.json` 并提交：保留 23315/23405 条（丢掉的是长篇
书籍文本，怪物描述最长约 3 kB），约 3.9 MB。构建时**优先读本地语言表**
（并顺手刷新快照），本地没有时才用快照——干净克隆因此仍能得到完整中文，
`extract.test.mjs` 会逐条比对两者结果一致。

覆盖情况：812/812 的名称都有中文（`nameStatus = exact`）。描述以
`_t[[...]]` 的英文原文去查表，命中就用中文并在界面标注来源，未命中就回退英文
并标注"汉化表缺少该条目"。765 个模板有描述原文，其中 763 个有中文；
剩下 2 条（`The One That Hunts`、`Mindwall`）源文本是残句或 "."，报告里
逐条列出。

### 6.1 大类 / 亚类的中文必须按上下文取

游戏的怪物 tooltip 是这么取词的（`tome-src-full/mod/class/Actor.lua:2037`，
`WorldNPC.lua:176` 同）：

```lua
ts:add(_t(self.type, "entity type"):capitalize(), " / ",
       _t(self.subtype, "entity subtype"):capitalize(), true)
```

`engine/I18N.lua` 的 `t(src, dst, tag)` 会把词条同时写进 `locale[tag][key]` 和
`locale["nil"][key]`，`_t(s, tag)` 先查前者、再回退后者。所以：

- `locale.mjs` 额外保留 `byContext`（tag -> 英文 -> 中文），快照格式升到
  `version: 2` 并多了 `contexts` 段，只存 `entity type`（65 条）与
  `entity subtype`（232 条）两个表，体积只增加几十 KB。
- 构建时 `build-monsters.mjs` 用 `translateEntityWord()` 取词，写入每个模板的
  `typeZh` / `subtypeZh`；上下文表没有的才回退扁平映射。
- 覆盖：**812/812 的大类、811/811 有亚类的模板**都有中文，报告里
  `missingTypeLabels` 为空。

**同一个英文词在不同上下文里译法不同**，扁平映射会取错：`light` 在
`damage type` 里是「光系」，在 `entity subtype` 里是「轻甲」（护甲亚类）。
`entity subtype` 表是权威值，只有 1 个怪命中（`crystal.lua:61` 的 wisp
鬼火），所以页面上它显示为 `元素 / 轻甲`——和游戏内 tooltip 一致，
不做"修正"；`TypeChip` 的 tooltip 会给出源码里的 `elemental / light`。

### 6.2 亚类筛选值做了大小写/标点归一化

源码里同一个生物有三种拼法：`Sher'Tul`、`sher'tul`、`shertul`（引擎按字符串
比较，是三个亚类），汉化后都译作「夏·图尔」。侧栏如果按原始值分行，会出现三行
同名条目。因此：

- `subtypeKey()`（`src/lib/monsters.ts`）= 小写 + 去掉非字母数字，
  三者都归一为 `shertul`；
- 树按该 key 分组，筛选与 URL 也用该 key（`?type=horror&sub=shertul`），
  一行命中全部 8 个模板；
- 归一化后没有第二处冲突（全库 89 个亚类值 → 87 个 key）。


## 7. 图片

优先级（`extract.mjs` 的 `resolveImage`）：

1. 显式 `image`（`invis.png` 除外——它只是多图层容器）
2. `resolvers.nice_tile{ image = "invis.png", add_mos = {...} }` 的图层
3. `NPC:init` 的自动命名 `npc/<type>_<subtype>_<name>.png`
4. 近似匹配：去重音/标点后再比，再按"去掉前缀的名字"或包名的后缀匹配，
   最后才用子串包含（要求 ≥12 字符且落在词边界上，避免 `bear` 抢走 `grizzly bear`）

结果：**787/812 有图**（96.9%），681 张按引用复制。上游 gfx 包与 DLC 美术
（数百 MB 二进制）同样不入库；本地没有时构建不报错，只是把图片全部记为缺口，
页面用类型字符占位，报告里会写明 `missingArtSources`。剩下 25 个在报告
`monsters-report.json` 的 `imageGaps` 里逐条列出，主要是三类：
`moddable_tile` 玩家/人形合成模型（`human`、`dwarf`、`lost wife`）、
画风里根本没有对应 PNG 的实体（`steam giant scribe`、`Council Member Tantalos`）、
以及部位命名与自动命名不同的图（`Ureslak the Prismatic` 用的是
`npc/drake_multi_ureslak.png`）。页面在这些情况下显示类型字符兜底并给出
`imageCandidate`，不会假装有图。

## 8. 补充技能

上游技能导出是 1.5 时期的快照，1.7.6 源码里有 8 个它没导出的技能，而怪物模板
确实引用了它们。`scripts/monsters/talent-supplement.mjs` 从本地 Lua 的
`newTalent{...}` 定义里提取这 8 条（名称、分类、消耗、冷却、中文名、中文说明），
写到 `data/talent-supplement.json`，由 `scripts/build-data.mjs` 合并进
`public/data/talents.json`：

| id | 中文名 | 出处 |
| --- | --- | --- |
| `T_HEAT` | 加热 | `data/talents/spells/war-alchemy.lua`（凤凰、Tannen、Walrog 引用） |
| `T_MANA_POOL` / `T_STAMINA_POOL` | 法术值槽 / 体力值槽 | `data/talents/misc/misc.lua` |
| `T_STEAM_POOL` | Steam Pool | 兽人 DLC `data/talents/steam/steam.lua` |
| `T_TUTORIAL_MIND_KB` / `T_TUTORIAL_MIND_FEAR` | 念力打击 / 恐惧 | `data/talents/misc/tutorial.lua` |
| `T_TUTORIAL_SPELL_KB` / `T_TUTORIAL_SPELL_BLINK` | 魔法风暴 / 闪烁 | `data/talents/misc/tutorial.lua` |

提取只针对上面的 id 集合（`npm run data:supplement`），不是第二条技能管线。
补充条目在 `talents.json` 里带 `supplemental: true`，来源边界仍然清楚。
补充后怪物引用的技能 **0 个未收录**（`npm run test:monsters` 会断言这一点）。

`*_POOL` 三个是"资源槽"内部技能，没有说明文本（源码里 `info` 不是字面量），
页面会显示名称但没有描述，也不会把它们当成战斗技能。

## 9. 已知边界

- 没有启动游戏实测，全部是静态源码读取；`src/override`、事件、地图脚本
  动态创建的召唤物不在收录范围。
- `resolvers` 之外还可能有技能来源（装备、随机词缀、事件赋技能），首版只看
  NPC 模板自身声明的 resolver。
- 高等级 boss 的随机职业不展开成具体技能（`auto_classes` 只显示职业名）。
- 没有模拟引擎的逐文件加载列表，跨文件的 `define_as` 变体全部保留而不是合并。
- 数值系统沿用现有技能页：不模拟怪物属性、装备与最终伤害。
- 图片只取 Shockbolt 主画风；mushroom 等其他画风与 `boss_indicators` 标记
  不计入种数。

## 10. 验证

```bash
npm run test:monsters   # 51 项：继承、繁殖参数、随机组、等级规则、描述与汉化、种类中文与筛选、图片、产物不变量、前端检索
npm run smoke           # 70 项：含怪物页渲染、搜索、大类/亚类筛选、详情面板
npm run e2e             # 247 项：真实浏览器，含怪物页大类/亚类筛选与深链、技能面板三档宽度、手机端下拉选择、底部抽屉自身可滚动
```

单元测试断言的是**源码事实**而不是实现自身的输出：虫群继承与
`can_multiply` 4/2、死灵法师 4 套互斥组、凤凰引用的 `T_HEAT` 能从源码提取、
`invis.png` 永远不会被当成图片、以及产物里 id 唯一 / 父模板全部解析 /
技能引用全部收录 / 引用的图片都在磁盘上。
