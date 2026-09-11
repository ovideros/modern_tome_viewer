# 物品数据管线：装备词缀与固定神器

本文档说明「装备词缀」（`#/egos`）与「固定神器」（`#/artifacts`）两个页面的数据来源、
收录口径、ID 规则、数值语义、社区补充层与更新方式。与 [`monster-pipeline.md`](monster-pipeline.md)
并列，是物品侧的唯一权威说明。

生成入口：

```bash
npm run data:items     # 生成 public/data/{egos,artifacts,items-report}.json 与物品图标
npm run test:items     # 物品侧解析/提取测试
```

`npm run data` 会依次跑技能、怪物、物品三条管线；`npm run build:pages` 会检查这些产物是否已提交。

---

## 1. 数据来源与优先级

| 优先级 | 来源 | 用途 |
| --- | --- | --- |
| 1 | 本地游戏源码（本体 1.7.6 + 三个 DLC） | 物品定义、词缀适用范围、属性数值、生成限制、特殊机制 |
| 2 | 本地游戏汉化 `data/locales/zh_hans.lua` 的规范化快照 | 中英文名称、术语、说明与特殊效果文本 |
| 3 | 用户提供的 Excel《物品词缀表（1.7.6版本适用）》 | 社区别名、推荐度、玩家备注（补充层，见 §7） |
| 4 | 英文 Wiki | 只用于发现漏项，不作为收录依据，不写入数据 |

四个源码根目录：

- 本体 `tome-src-full`
- 兽人 DLC（Embers of Rage）`dlc-src/orcs/tome-orcs`
- 灰烬 DLC（Ashes of Urh'Rok）`dlc-src/ashes-urhrok/tome-ashes-urhrok`
- 邪教 DLC（Forbidden Cults）`dlc-src/cults/tome-cults`

DLC 版本各自记录（`items-report.json` 与页面上的来源筛选都按包分开），不笼统改标成同一个版本。

### 展示参考：Modified Item Descriptions

固定神器详情的属性分区、同类归组与标签对齐，参考了用户提供的插件
`others/tome-mod-descriptions_9.teaa`（注意：该文件在磁盘上的**真实文件名是一个空格**，
不是文档里写的那个名字）。该插件是基于 Cleaner Item Descriptions 的中文版，
作者 yutiao888，声明适用本体 `{1,7,6}`、插件版本 `{0,1,1}`。

**只借鉴展示组织方式，不搬迁插件代码。** 插件里依赖 `game.player` 的部分一律不采用：

- 不显示「当前人物已满足的需求」（网站没有隐含的当前角色）；
- 不按「是否学会盾击/徒手技能」隐藏盾牌或手套的战斗属性；
- 不显示「有效强度」「装备后净提升」等依赖假设角色算出的数据；
- 不实现 Alt 切回原版、Ctrl 装备比较等运行时交互。

插件的作用是把「字段 → 中文标签 → 生效方式 → 展示分类」这套映射整理清楚，
本站把这套映射**从游戏源码里直接提取**（见 §4），而不是抄一份可能过期的表。

---

## 2. 为什么物品侧有独立的 Lua 读取入口

调用怪物管线的 `parseLuaFile` 读取 `data/general/objects/world-artifacts.lua`
会返回 **0 个实体**，而且 `diagnostics` 也是 0 —— 静默漏读。

原因：该文件开头有

```lua
for def, e in pairs(game.state:getWorldArtifacts()) do
	importEntity(e)
	print("Importing "..e.name.." into world artifacts")
end
```

`parseStatement` 把 `for` 交给宽松的 `skipBlockStatement()`，而它的深度计算把**每一个 `end`
都当作块结束**。于是这个 `for` 循环把文件剩下的 8500 多行全部吞掉。
同文件里其实有一个正确的 `skipBlock()`（`function`/`if`/`for`/`while` 各消耗一个 `end`，
`do` 不另开块，`repeat` 由 `until` 关闭），但它只有 `parseUnary` 会走到。

**处理方式**：物品侧不走语句解析，另建 `scripts/items/lua-entities.mjs`：

1. 复用共享的 `tokenize()`（纯函数，已有 `lua-table.test.mjs` 覆盖）；
2. **单趟扫描 token 流，在字符串之外配对 `{` 与 `}`**，记录每个 `newEntity{` 的表区间；
3. 再把该区间的 token 重建成 `local __frag = {...}` 交给共享的 `parseLuaFile`
   解析成 AST（复用经过测试的表/表达式读取器，不再造一份）。

共享文件一行未改，怪物管线不受影响（`npm run test:monsters` 保持 51/51）。

### 这套做法带来的两个副产物

**嵌套定义不再被静默丢弃。** 落在已捕获表区间内的 `newEntity` 会被单独记为 `nested`，
在覆盖报告里可核对，而不是凭空消失。回看计数：`world-artifacts.lua` 里 `grep` 到 186 处
`newEntity{`，其中 3 处位于多行字符串/注释内（tokenizer 已剔除），实际顶层定义 183 个。

**token 重建必须给词之间补空格。** 源码里 `return _t"..."` 如果原样拼接会变成
`return_t` 一个标识符，函数体文本抽取会全部失败。`reconstruct()` 在相邻的
`name`/`number`/`keyword` 之间强制插入空格，`lua-entities.test.mjs` 有断言。

---

## 3. 收录口径

扫描范围：四个源码根目录下的 `data/general/objects/**`（含 `egos/`、`tinkers/`、
`random-artifacts/`）以及 `data/zones/**/{objects.lua,npcs.lua}`。共 391 个文件、2358 个定义。

**`unique = true` 不等于「固定神器」**，这是最容易搞错的一点：

- 药水、卷轴等消耗品也用 `unique` 标记「不可堆叠」；
- 每个 Boss 的 `newEntity` 同样带 `unique`，那是怪物定义；
- 宝石、剧情书页、教程测试实体也在同一批文件里。

### 神器判定

| 判定 | 条件 | 本次数量 |
| --- | --- | --- |
| 收录（可装备） | `unique` + 有 `name` + 解析出 `type` ∈ 武器/护甲/首饰/光照/工具/弹药/护符/水晶球/蒸汽工具 | **416** |
| 收录（非装备类） | 同上但 `type` ∈ 宝石/卷轴/药水/书册/手札/杂项/箱子 | **80** |
| 排除 `npc-definition` | 解析出的 `type` 属于怪物类型（humanoid/giant/undead/dragon/…） | 281 |
| 排除 `not-unique` | 没有 `unique` 标记 | 863 |
| 排除 `no-type` | 继承链走完仍无法确定 `type` | 64 |
| 排除 `quest-item` | `quest = true` 的纯任务物品 | 28 |
| 排除 `no-name` | 无名称的抽象基类 | 16 |
| 记为同名不同形态 | 同一个 `define_as` 但定义内容不同 | 2 |

`type` / `slot` 多数定义自己**不写**，靠 `base = "BASE_XXX"` 继承。
因此必须先建立全局 `define_as` 索引、再沿 `base` 链解析，不能只看单个文件的字面字段。

### 词缀判定

所有位于 `**/egos/**` 且带 `name` 的定义都收录，共 **608** 条
（本体 603 / 兽人 DLC 5）。词缀没有图片，页面也不配图——游戏里就没有对应素材，
造一个图标等于伪造数据。

### 同一件物品在多处定义

`RUNE_RIFT`（daikara 与 temporal-rift）、`VOID_STAR`（abashed-expanse 与 unhallowed-morass）
在两处有**逐字节相同**的定义。这类合并为一行，`definitions[]` 列出全部位置；
`items-report.json` 的 `duplicateDefinitions` 记录合并明细。
判定按解析后的定义内容比较（比较前剥掉每行的 `line`，否则不同偏移量会误判为不同），
**不按名字去重**——同一个 `define_as` 但内容不同的是真实变体，保留为两行并标注
`variantNote`（本次 2 例，均在兽人 DLC 的 kaltor-shop）。

---

## 4. 属性映射：从游戏源码提取，而不是手抄

物品 tooltip 的权威定义在 `mod/class/Object.lua`：

- `desc_wielder`（局部闭包，写在 `getTextualDesc` 内部）负责穿戴属性；
- `descCombat`（方法）负责武器本体与盾击属性。

这两段的每一行几乎都是

```lua
compare_fields(w, compare_with, field, "combat_armor", "%+d", _t"Armour: ")
```

`scripts/items/field-map.mjs` 直接解析这两个函数体，抽出
**字段名 → `_t` 标签 → 格式串 → 所属区域**，再用汉化快照把标签翻成中文。
好处是游戏更新后重新跑一遍就同步了，不用维护一张会漂移的手抄表。

### 两个必须注意的细节

1. **`compare_scaled` 的参数位置不同**：
   `compare_scaled(scaled, compare_with, field, key, {fn}, format, label)`，
   格式串和标签各往后挪一位。按下标硬取会把 `%+d #LAST#(%+d eff.)` 当成标签。
2. **`desc_wielder` 是局部闭包**，写作 `local desc_wielder = function(...)`，
   不是 `function _M:desc_wielder(...)`。只匹配后者会取到空，而 `descCombat` 的战场字段
   会顺势填满整个 `wielder` 区——静默错位。`extract-items.test.mjs` 有专门断言。

### 机械扫描够不到的部分

`descCombat` 里有一部分（`dam`、`dammod`、`damrange`、`damtype`、`convert_damage`、
`special_on_hit` 等）是用手写算式渲染的，`compare_fields` 扫不到；
`desc_wielder` 里的 `esp`、`can_breath`、`talents_types_mastery` 与若干布尔标志同理。

这些集中在 `field-map.mjs` 的 `MANUAL_FIELDS` 一张显式表里，每条都写了来源函数，
中文取自游戏自己的 `_t` 译文。**手维护的面积只有这一张表**，其余全部机械提取。

### 分区与生效方式是两个维度

页面上的分区标题（`装备本体属性` / `盾击与副手攻击` / `穿戴时生效` / `携带时生效` /
`镶嵌时生效`）来自数据里的 `area`，表达的是**什么时候生效**；
而「进攻 / 防御 / 资源与其他」是**展示归类**，由前端 `FIELD_GROUP` 决定。

两者都保留。合二为一就会出现「把武器自身暴击和角色物理暴击算成一个数」这类错误。

---

## 5. 数值语义：不模拟，但也不许瞎猜

每个属性值都带 `kind`，前端按 `kind` 决定怎么显示：

| `kind` | 含义 | 页面表现 |
| --- | --- | --- |
| `literal` | 源码里写死的常量 | 直接显示数值 + 单位 |
| `resolver` | `resolvers.*` 调用 | 能还原范围时显示 `范围` + 变化原因；不能时显示来源表达式，**绝不当成一个数** |
| `function` | 运行时回调（如命中触发） | 显示「由游戏在运行时计算」，保留来源表达式 |
| `computed` | 依赖角色的表达式 | 同上 |
| `ref` | 引用常量（如 `DamageType.FIRE`） | 显示引用名 |

### 已支持的 resolver 范围还原

| resolver | 含义 | 处理 |
| --- | --- | --- |
| `resolvers.rngrange(a, b)` / `rngavg(a, b)` | 生成时在 `[a,b]` 取值 | 显示区间，标注「生成时随机取值」 |
| `resolvers.mbonus_material(max, add, fct)` | `ceil(rng.mbonus(max, 等级, 90) × 材料等级 / 5) + add`，再按 `fct` 变换 | 显示材料等级 1–5 的范围，并带**每一级各自的区间**（`materialRanges`），标注「随材料等级变化」 |
| `resolvers.mbonus(max, add)` | 同上但只随生成等级变化 | `add ~ add + max`，标注「随生成等级变化」 |
| `resolvers.randartmax(a, b)` | 随机神器上限 | 显示区间 |

#### `mbonus_material(max, add)` 的参数方向（曾经读反过）

`mod/resolvers.lua` 的实现是：

```lua
local ml = e.effective_ego_material_level or e.material_level or 1
local v = math.ceil(rng.mbonus(t[1], resolvers.current_level, resolvers.mbonus_max_level) * ml / 5) + (t[2] or 0)
```

`t[1]` 是**能被掷到的上限**，`t[2]` 是**始终存在的平加值**，所以区间是
`add ~ add + max`。早期把它当成 `offset + 材料等级 × step` 来算，
`balanced`（`mbonus_material(10, 5)`）就显示成 `15~35`，而玩家词缀表里这一行写的是
`5-15命中闪避/20-50缴械免疫`。改对之后，`scripts/items/community.mjs` 会把
Excel 效果列里的 `a-b` 与源码区间逐行比对并写进
[items-community-report.md](items-community-report.md)：506 行有数字区间的记录里
503 行完全一致，剩下 3 行是表格自身的笔误（低值写成了 `max` 或高值写成了 `max`），
页面一律以源码为准。

#### 两处容易被忽略的乘数

1. **价格函数是数值变换，不是价格。** `mbonus_material(30, 20, function(e, v) v=v/100 return 0, v end)`
   的第三个参数会重写掷出的值——这里是除以 100，所以 `disarm_immune` 是 0.20~0.50，
   再乘上字段的百分比标度才是 `20%~50%`。物品库里只有四种形态
   （`/100`、`/10`、取负、恒等），全部由 `valueTransformOf()` 识别；
   认不出来的形态会标成「变换函数未识别」并**不给任何数字**。
2. **字段自身的标度。** 引擎的 `Moddable:compareFields` 打印的是 `raw * mod`，
   免疫与移动速度存的是小数、打印时才乘 100（`compare_fields(..., 100)`）。
   这个因子由 `field-map.mjs` 从 `Object.lua` 里读出、写进 `fieldMeta[key].scale`，
   并在构建时应用到 `range`/`materialRanges` 上，所以数据里的数值**就是页面上的数值**。
   漏掉它会把 `stun_immune` 打成 0、把 `movement_speed` 打成 `0~0`。

#### 材料等级选择器

词缀页面左侧的「材料等级 1–5」是一个**单选的显示参数，不是筛选条件**：
它不改变匹配结果，只把「随材料等级变化」的属性换成该等级自己的区间。
选择器写入 URL 的 `ml`，再点一次取消；不选时显示 1–5 级的最大区间，
也就是玩家词缀表的写法。神器没有这一项——固定神器的属性值都是字面量，
全库 0 条 `mbonus_material`。

`resolvers.genericlast` 之类无法静态求值的，保留 `text` 原表达式并标注，
**不把未知当 0，也不把一次随机采样当固定值**。

### 明确不做的

- 不做材质/人物等级/法强等滑条，不做词缀生成模拟、随机采样、概率分布或组合枚举。
- 不显示依赖假设角色的「有效强度」「装备后净提升」。
- 不把 `rarity` 写成掉落百分比，不把 `level_range` 写成装备需求等级。
  这两句语义在页面上是**可见文字**，不只放在 tooltip 里。

### 名称占位符

词缀名里的 `#RESIST#` / `#STATBONUS#` / `#MASTERY#` / `#REGEN#` 由引擎在运行时填入
（见 `mod/class/Object.lua` 的 `descAttribute`）。**这不是随机变体**——
`of fire` 永远是火抗，伤害类型写死在各自的 `newEntity` 里。页面把占位符显示成一个
带说明的标记，而不是编一个数字，也不展开成组合枚举。全库共 42 处 `#RESIST#`，
分布在 `shield` / `wizard-hat` / `rings` / `robe` 四个词缀池。

### 随机性的实际分布（已核实）

全库扫下来，真正 `kind` 随生成变化的神器极少：

- **命运之轮**：`use_power` 里调 `game.state:generateRandart{base=o, lev=..., egos=3}`，
  每次使用**整件重掷**。它的 `wielder = {}` 是空的，所以页面正确地显示「没有静态属性面板」，
  能力说明用源码文本描述。
- `The Guardian's Totem`、`Lightbringer's Wand`：`atk`/`dam` 用 `resolvers.rngavg`。
- `Great Caller`：`use_talent` 用 `rng.table{...}` 在生成时从 5 种吐息里抽一个。
- 其余「看似随机」的命中都是触发效果里的 `rng.percent`，属性本身固定。

**`random_art_replace` 不是物品随机。** 它的语义在 `mod/resolvers.lua`：

```
random_art_replace (requires defined): table of parameters for replacement object when dropping as loot
    chance: chance to drop in place of the unique object
```

意思是「掉落时有多大比例用随机神器**顶替**这件固定神器」。比尔的树干带
`random_art_replace = {chance = 75}` —— 物品本身完全固定，只是有 75% 概率被顶替而根本不掉。
**这个字段绝不能当掉率显示**，本次没有把它写进任何一个页面字段。

---

### 回调效果的文字从哪来

208 条词缀的效果不在属性表里（护符触发效果、盾牌格挡特效、法杖灌注法术、
「命令法杖」改造等）。这些词缀以前在列表里只写「打开详情查看」，现在按三个来源
给出文字，且每条都标明来源：

| 来源 | `basis` | 说明 |
| --- | --- | --- |
| 游戏自身的说明文本 | `game` | `charm_on_use` / `on_block` / `special_on_*` 里的 `desc` 函数或字符串，以及 `resolvers.charm(_t"...")` 的第一个参数。翻译走与 tooltip 同一张汉化表（**必须用带颜色代码的原文查表，再剥颜色**，否则一条都命中不了）。`%d` 变成 `{0}` 占位符，由前端按同一个数值模型填充——包括材料等级 |
| 手写整理 | `source` | 回调用数字表达、没有说明文本的情况（`charm_power_mods` 的倍率、`masteries`、`imbued_talent_level`、`command_staff` 等）。每条都在 `from` 里写明它出自哪个表达式 |
| 没有 | —— | 目前为 0 条 |

构建产物里有 `effectCoverage` 计数与 `withoutEffect` 列表；`test:items` 里有一条
测试要求「所有没有属性表的词缀都必须有 note」。

回调里的占位符只有在能静态还原时才填数字，否则保留可见的 `?`，
并在 `values[n].expression` 里写明是运行时计算。

## 6. 词缀适用范围：沿 `load()` 关系解析

物品用 `egos = "/data/general/objects/egos/weapon.lua"` 声明自己的词缀池，
而词缀文件之间还会互相 `load()`。必须沿这条链传递，不能靠文件名或 Excel 分类猜：

- 链锯（steamsaw）的 `egos/steamsaw.lua` 同时 `load` 了 `weapon.lua` 与 `shield.lua`
  → 链锯共享近战武器与盾牌两个词缀池；
- 弓与投石索各自 `load` 了 `ranged.lua` → 共享远程词缀；
- 轻甲/重甲/板甲各自 `load` 了 `armor.lua` → 共享通用护甲词缀。

数据里每条词缀都带：

- `pool`：定义所在的池（自己的文件）；
- `pools[]`：可达池集合（含被谁 `load`）；
- `applicable[]`：展开到具体装备类型/亚类/栏位，`via` 标 `own`（本池）或
  `shared`（共享池）。页面把 `shared` 显式标成「共享词缀池」，
  而不是让读者以为那是该部位专属。

**同一词缀名出现在多个池是正常的**，例如 `acidic` 在 `weapon`（rarity 5）、`shield`（rarity 8）、
`ammo` 各有一条，属性不同，必须分开收录。

`keywords` 是引擎自己的词缀键，但 charm 类词缀有**普通档与 `greater_ego` 高级档同名同键**。
两者是两条不同词缀，ID 里带 `:greater` 后缀区分，`variantOf` 指回普通档，不做去重。

---

## 7. 社区补充层

`scripts/items/community.mjs` 只读导入 `others/物品词缀表（1.7.6版本适用）.xlsx`
（原文件不改动），产出：

- `public/data/ego-community.json`：按 ego ID 索引，每条保留 `sheet` + `row` + 原文；
- `docs/items-community-report.md`：可读的核对报告。

xlsx 用自写的 `scripts/items/xlsx.mjs` 解析（ZIP 中央目录 + OOXML），**不引入任何依赖**。
单元格按 `r="C5"` 定位，稀疏行不会左移，行号与 Excel 行号一致。

### 匹配规则

1. 按中文名匹配（`normalizeZh` 先剥掉尾部的 `(#RESIST#)` 这类占位符，再剥 `的`/`之`，
   其余部分精确比较）。
2. 工作表决定允许的词缀池：`allowedPoolsFor(P) = poolClosure(P) ∪ poolAncestors(P)`，
   由 `items-report.json` 里的 `loads` 图推导，**不硬编码**。
   - 闭包（自己 `load` 的）：`重甲` → `{heavy-armor, armor}`、`远程武器` → `{ranged, bow, sling, steamgun}`
   - 祖先（`load` 自己的）：`近战武器` → `{weapon, steamsaw}`、`盾牌` → `{shield, steamsaw}`
3. 匹配用词缀**自己所在的池**落在允许集合内，而不是用展开后的 `pools[]`。
   这一点很关键：`pools[]` 是**前向可达集**，链锯同时 `load` 了 weapon 与 shield，
   于是 shield 词缀的 `pools[]` 里含 `weapon`。用 `pools[]` 求交集会把
   `tome:shield:acidic` 拉进「近战武器」表、把 `tome:weapon:enhanced:greater` 拉进「盾牌」表，
   正是要避免的静默串池。改用「自己所在的池」后兄弟池永不泄漏。
4. `confidence`：`high` = 本池命中；`shared-pool` = 经允许的共享池命中（如 `armor` 被三张护甲表命中）；
   `medium` = 同池内多个同名词缀。

本次结果：594 数据行，**命中 570**（本池 505 / 共享池 65），未命中 24，稀有度冲突 14。

### 已核实的三处数据质量问题（原文件未改）

1. **法袍第 3、4 行完全重复**：都是 `冰冻`，`A3:E4` 内容逐格相同。
2. **近战武器第 5 行「强酸」稀有度 10**，源码 `tome:weapon:acidic` 是 `rarity = 5`；
   弹药第 3 行同类问题（`tome:ammo:acidic`）。共 14 处稀有度冲突，**一律以源码为准**，
   表内值只作为证据留在 `conflicts` 里。
3. **法师帽第 5/6/8 行名称与效果错位**：源码里 `of lightning`→闪电、`of light`→光系、
   `of darkness`→暗影、`of corrosion`→酸性；表里「光系」写闪电效果、「暗影」写光系效果、
   「腐蚀」写暗影效果。第 7 行「酸性」的效果本身正确，但该池里没有叫「酸性」的词缀，
   因此进入待核实清单。

**社区推荐度和玩家备注属于社区评价，不是游戏客观数据**，页面把它们放在明确标注的
「社区参考」区域。推荐度只用来说明一句话：

> 列表排序的第二关键字是推荐度降序（第一关键字是普通档先于高级档）。

社区数据**不参与收录判定、不参与筛选**：表里没覆盖到的词缀照样收录，只是排在同档末尾。

---

## 7.1 界面上的呈现约定

用户的明确要求，改动筛选栏时不要退化：

- **高级词缀（`greater_ego`）用琥珀色标记**，与普通 chip 区分；亮色 `text-amber-800`、
  暗色 `text-amber-300`，实测对比度 6.32:1 / 9.34:1（AA 正文阈值 4.5:1）。
- **列表排序**：普通档在前、高级档在后；同一档内按社区推荐度降序；
  推荐度缺失的排在同档末尾（不因为表里没有就隐藏）。
- **卡片上直接显示推荐度**（`推荐 4`），不用点开详情才能看到。
- **两个筛选栏都用标签切换，不用下拉框**：同一个维度内多选是「或」，不同维度之间是「且」。
  空列表 = 不限制，所以「默认状态」和「清空后状态」是同一个。
- **`适用部位` 与 `收录范围` 默认展开**，常用路径一次点击；其余分区折叠。
- **神器侧的「可装备 / 非装备」是两个独立标签**，默认只勾「可装备」。
  取消「可装备」并勾上「非装备」= 只看非装备；两个都勾 = 全部；两个都不勾 = 空列表
  （页面说明原因，而不是悄悄显示全部）。URL 用 `scope=non|all|none` 表达后三种状态。
- **「材料等级 1–5」是单选显示参数，不是筛选条件**：不改变匹配结果，只换数值区间；
  写入 URL 的 `ml`，再点一次取消，不选时显示 1–5 级最大范围。
- **卡片必须直接写出效果**，不能写「打开详情查看」。效果行的构造顺序是
  结构化属性（与详情面板同一套 `fieldMeta`、同一个 `formatPropValue`）→ 回调说明，
  最多 3 行；详情面板顶部同样给出这三行，打开前后不会互相矛盾。
- **详情面板钉在视口上时必须从 header 下方开始**：`fixed` 定位用
  `top: calc(var(--header-h) + 2px)`，不能用 `inset-y-0`/`top: 0`。
  header 是 `sticky top-0 z-30`，层级更高，`top: 0` 会让词缀名和关闭按钮被横幅盖住。
  `--header-h` 由 `useHeaderHeight` 跟着真实高度同步（窄屏 header 会折行）。

### 部位分类为什么是 21 个而不是全部词缀池

`EGO_SLOT_GROUPS`（`src/lib/items.ts`）按玩家词缀表的 20 个分类组织，并做了三处合并：

| 合并 | 原因 |
| --- | --- |
| `bow` / `sling` / `steamgun` → 远程武器 | 共享 `ranged` 池；表里没有蒸汽枪这一列 |
| `weapon` + 链锯（`steamsaw` 池） | 链锯的 `egos/steamsaw.lua` 直接 `load` 了 `weapon.lua`，词缀相同 |
| `heavy-armor` / `massive-armor` / `light-armor` → 三种护甲 | 各自 `load` 共享的 `armor.lua`；表里也分成三张工作表 |
| `charms` + `wands` → 护符（项圈 / 图腾 / 魔杖） | 同一个 `charms` 池服务三种亚类 |

**不列出的池**：`charged-attack` / `charged-defensive` / `charged-utility`（NPC 专用的
充能攻击词缀）、`potions` / `scrolls` / `infusions`（消耗品与符文，不是装备词缀）、
`armor`（共享池，已并入三种护甲）、`*-powers`（已被基础池加载，词缀已在父类目下）。

**标签名必须来自这张表，不能从物品亚类推。** 早期版本取「该池第一个适用物品的
`subtypeZh`」当标签，于是 `charms` 池被标成「项圈」——而它同时服务 torque（项圈）、
totem（图腾）和 wand（魔杖）。同理 `armor` 被标成「重甲」、`shield` 被标成「双手斧」。
`torques.lua` / `totems.lua` 本身只是 `load("charms.lua")` 的加载桩，不是独立词缀池，
所以列表里不该出现「项圈」和「torque」两个条目。

## 8. 图片

- 神器图标来自游戏原始资源，**不使用 AI 重绘**。
- 本体图标在 `t-engine4-src-1.7.6/game/modules/tome-1.7.6-gfx.team` 的
  `data/gfx/shockbolt/object/artifact/`；DLC 图标在各自的
  `overload/data/gfx/shockbolt/object/artifact/`。
- 复用怪物管线的 `ZipArchive` 与索引构建（只读），**只复制实际引用的文件**：
  本次 493 件神器解析到图标（全部 `exact` 命中），去重后复制 456 个 PNG。
- 缺图 3 件，进入覆盖报告：`Brain Cap`、`Fanged Collar`（源码没有 `image` 字段）、
  `Great Caller`（`image = "object"`，不是完整路径）。页面用类别文字兜底。
- 图标按原生像素尺寸显示（`image-rendering: pixelated`），不放大低分辨率像素图。
- `image = resolvers.image_material(...)` 这类由材质模板生成的图标会记入
  `resolverGeneratedImages`（本次 0 件），页面同样走兜底。

---

## 9. 稳定 ID

**神器**：`<来源包>:<define_as>`；没有 `define_as` 的退回
`<来源包>:<路径 slug>:<行号>`，只要源码树不变就可复现。

**词缀**：`<来源包>:<词缀池>:<keywords 键>`，高级档追加 `:greater`；
charm 类用 `unique_ego` 字符串作为身份。**不用中文名，也不用遍历序号**——
中文名会重复（同名的 `acidic` 在多池），序号会随扫描顺序变动。

同一 `define_as` 但内容不同的变体，ID 追加 `#<行号>` 并写 `variantNote`。

---

## 10. 产物与体积

| 文件 | 内容 |
| --- | --- |
| `public/data/egos.json` | 608 条词缀 |
| `public/data/artifacts.json` | 496 件神器（416 可装备 + 80 非装备） |
| `public/data/items-report.json` | 覆盖报告 + `files` 路径字典 + `fieldMeta` 字段表 |
| `public/data/ego-community.json` | 社区补充层 |
| `public/img/object/**` | 456 个被引用的图标 |

两页各自懒加载自己的 JSON，**不影响技能首页的启动体积**（技能首页仍然只读
`talents.json` / `meta.json` / `manifest.json`）。

为控制体积做了两项归一化，改动数据格式时要注意：

1. **路径字典**：`file` 字段是 `items-report.json.files` 的下标，不是路径字符串。
   属性、定义、行级 `file` 全部如此。逐属性重复一个 70 字符的路径曾是数据集最大的开销。
2. **字段表**：`fieldMeta[key]` 保存每个属性键的 `area`/`label`/`labelZh`/`format`/`unit`，
   行内的属性只保留 `key`、`separator`、`kind`、数值与 `source`。
   这些字段对每件物品都相同，重复存储没有意义。

两项合计把神器数据从 3.2 MB 降到 2.3 MB、词缀从 1.9 MB 降到 1.6 MB。

---

## 11. 未映射字段与已知缺口

`items-report.json` 记录所有**在源码里出现、但属性映射表还没覆盖**的字段：

- `unmappedPropertyKeys`：60 个键。多数是引擎内部字段（`sound`、`moddable_tile_nude`、
  `tg_type`）、DLC 专属（`sawwheel_speed`、`combat_steampower`）或内部标记
  （`artifact_power_obsidian`）。这些字段**不会消失**：详情页会列出「待完善映射的属性字段」，
  数值既没被丢弃也没被当成 0。其中 `combat` 是入口合并带来的假缺口，已在本轮修掉
  （`wielder = { combat = {...} }` 现在归到 `combat` 区）。
- `untranslatedLabels`：64 条游戏 `_t` 标签在汉化里没有对应中文，页面显示英文原文并标注「未翻译」。
- `missingTranslations`：神器/词缀中文名缺失 **0** 条。
- `placeholderText` 类的函数文本：100 条 `special_desc` 中 97 条能读出文字，其余 3 条
  由运行时条件拼装，页面说明「由游戏按当前角色状态动态生成」。
- `effectCoverage`：本轮新增。`withProperties` 557 / `callbackTemplates` 61 /
  `curatedNotes` 31 / `partialNotes` 38 / `withoutEffect` 0。`partialNotes` 是
  「句子能读、但里面某个数字要运行时才算」的条数（例如命中触发的附加伤害由角色强度算出），
  这些在卡片与详情里显示成 `?`，`values[n].expression` 写明是谁算的。

`items-report.json` 里还有各池的 `baseItems`、`loads` 与词缀计数，便于核对适用范围。

---

## 12. 以后怎样更新数据

```bash
# 1. 源码就位后，重新生成物品数据与图标
npm run data:items

# 2. 若汉化表变了，先刷新规范化快照（四个源码根目录都要在）
npm run data:locale

# 3. 社区补充层已包含在第 1 步里；xlsx 更新后可单独重跑
node scripts/items/community.mjs   # 只读原表，不改动原文件
# 该表不存在时会自动跳过并打印提示，不会让构建失败

# 4. 回归
npm run typecheck && npm run test:items && npm run test:monsters
npm run build && npm run smoke && npm run e2e
```

改动数据格式时，注意 §10 的两项归一化，以及 `src/lib/items.ts` 里对应的类型定义。

**不要把整个游戏源码包、DLC 媒体、依赖或临时扫描结果加入仓库。**
`public/data` 与 `public/img` 属于提交产物（与怪物管线一致），
`npm run build:pages` 会在部署前检查它们是否存在。
