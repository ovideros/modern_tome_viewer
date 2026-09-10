# batch01 — spell/dreadmaster · rime-wraith · death · master-necromancer · master-of-bones

范围：`spell/dreadmaster`、`spell/rime-wraith`、`spell/death`、`spell/master-necromancer`、`spell/master-of-bones`
（`tome-src-full/data/talents/spells/*.lua`）。共 51 条目标，51 条 PASS，0 条跳过。

覆盖层文件：`modern_tome_viewer/data/overlay-batches/batch01-spells.json`（51 条）。

验收命令与结果：

```
$ node scripts/try-formula.mjs --overlay data/overlay-batches/batch01-spells.json
覆盖层校验：51/51 通过
```

## 各大系小结

| 大系 | 目标数 | PASS | 跳过 | 主要写法 |
| --- | --- | --- | --- | --- |
| spell/dreadmaster | 11 | 11 | 0 | `floor(combatTalentScale)` / `combatTalentSpellDamage` / `floor(getTalentLevel)` / `level+getLevel` |
| spell/rime-wraith | 11 | 11 | 0 | 同上；`combatTalentScale` + `×2` 包装 |
| spell/death | 10 | 10 | 0 | 同上；`dam*incFormula(nb)` 条件倍率；`ceil` |
| spell/master-necromancer | 10 | 10 | 0 | `util.bound` / `combatTalentLimit` / `combatTalentScale` |
| spell/master-of-bones | 9 | 9 | 0 | `floor(combatTalentScale)`、`"log"` 模式、`level+getLevel` |

## 已完成

三套 = 系数 1.00 / 1.30 / 1.50，各 5 点；下表 15/15 表示三套全中且输入集合覆盖。

| 技能id | acronym#N | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| T_DREAD | 0 | `["max",1,["+",["actor","角色等级"],["floor",["combatScale",["talentLevel"],-6,0.9,2,5]]]]` | dreadmaster.lua:122 | ✅ |
| T_DREAD | 1 | `["floor",["talentLevel"]]` | dreadmaster.lua:157 | ✅ |
| T_DREAD | 2 | `["floor",["talentLevel"]]` | dreadmaster.lua:157 | ✅ |
| T_DREAD | 3 | `["floor",["talentLevel"]]` | dreadmaster.lua:157 | ✅ |
| T_DREAD | 4 | `["+",2,["floor",["talentLevel"]]]` | dreadmaster.lua:165 | ✅ |
| T_DREAD | 5 | `["floor",["talentLevel"]]` | dreadmaster.lua:165 | ✅ |
| T_SOULEATER | 0 | `["+",10,["spellDamage",30,200]]` | dreadmaster.lua:175 | ✅ |
| T_SOULEATER | 1 | `["floor", combatTalentScale(1,4) 展开式]`（见 batch01-spells.json） | dreadmaster.lua:176 | ✅ |
| T_SOULEATER | 2 | `["floor", combatTalentScale(2,8) 展开式]` | dreadmaster.lua:177 | ✅ |
| T_NEVERENDING_PERIL | 0 | `["floor",["talentScale",3,9]]` | dreadmaster.lua:227 | ✅ |
| T_DREADMASTER | 0 | `["floor",["talentLevel"]]` | dreadmaster.lua:260 | ✅ |
| T_RIME_WRAITH | 0 | `["floor",["talentScale",10,20]]` | rime-wraith.lua:33 | ✅ |
| T_RIME_WRAITH | 1 | `["*",2,["floor", combatTalentScale(5,15) 展开式]]` | rime-wraith.lua:34（:57 处 ×2） | ✅ |
| T_RIME_WRAITH | 2 | `["floor",["talentScale",12,30]]` | rime-wraith.lua:35 | ✅ |
| T_RIME_WRAITH | 3 | `["floor", combatTalentScale(5,15) 展开式]` | rime-wraith.lua:34 | ✅ |
| T_RIME_WRAITH | 4 | `["floor",["talentScale",20,40]]` | rime-wraith.lua:36 | ✅ |
| T_FRIGID_PLUNGE | 0 | `["spellDamage",10,50]` | rime-wraith.lua:68 | ✅ |
| T_FRIGID_PLUNGE | 1 | `["spellDamage",15,100]` | rime-wraith.lua:67 | ✅ |
| T_GELID_HOST | 0 | `["floor",["talentScale",5,10]]` | rime-wraith.lua:90 | ✅ |
| T_GELID_HOST | 1 | `["spellDamage",20,220]` | rime-wraith.lua:91 | ✅ |
| T_PERMAFROST | 0 | `["floor", combatTalentScale(10,30) 展开式]` | rime-wraith.lua:120 | ✅ |
| T_PERMAFROST | 1 | `["floor", combatTalentScale(10,30) 展开式]` | rime-wraith.lua:120 | ✅ |
| T_RIGOR_MORTIS | 0 | `["spellDamage",30,300]` | death.lua:31 | ✅ |
| T_RIGOR_MORTIS | 1 | `["floor",["talentScale",1,9]]` | death.lua:32 | ✅ |
| T_RIGOR_MORTIS | 2 | `["*",["spellDamage",30,300],["+",1,["*",1.5,["log10",2]]]]` | death.lua:40 | ✅ |
| T_RIGOR_MORTIS | 3 | `["*",["spellDamage",30,300],["+",1,["*",1.5,["log10",5]]]]` | death.lua:40 | ✅ |
| T_RIGOR_MORTIS | 4 | `["*",["spellDamage",30,300],["+",1,["*",1.5,["log10",10]]]]` | death.lua:40 | ✅ |
| T_RIGOR_MORTIS | 5 | `["*",["spellDamage",30,300],["+",1,["*",1.5,["log10",15]]]]` | death.lua:40 | ✅ |
| T_DRAWN_TO_DEATH | 0 | `["ceil",["talentScale",2,6]]` | death.lua:88 | ✅ |
| T_GRIM_SHADOW | 0 | `["floor",["talentScale",10,25]]` | death.lua:174 | ✅ |
| T_GRIM_SHADOW | 1 | `["floor",["talentScale",5,30]]` | death.lua:175 | ✅ |
| T_GRIM_SHADOW | 2 | `["floor",["talentScale",5,30]]` | death.lua:176 | ✅ |
| T_NECROTIC_AURA | 0 | `["floor",["min",10,["max",4,["+",3,["talentLevel"]]]]]` | master-necromancer.lua:29 | ✅ |
| T_NECROTIC_AURA | 1 | `["floor",["talentScale",8,18]]` | master-necromancer.lua:30 | ✅ |
| T_NECROTIC_AURA | 2 | `["floor", combatTalentLimit(75,20,40) 展开式]` | master-necromancer.lua:31 | ✅ |
| T_SURGE_OF_UNDEATH | 0 | `["floor",["talentScale",2,5]]` | master-necromancer.lua:69 | ✅ |
| T_SURGE_OF_UNDEATH | 1 | `["floor",["talentScale",12,22]]` | master-necromancer.lua:70 | ✅ |
| T_SURGE_OF_UNDEATH | 2 | `["floor",["talentScale",1,5]]` | master-necromancer.lua:72 | ✅ |
| T_SURGE_OF_UNDEATH | 3 | `["floor",["talentScale",1,5]]` | master-necromancer.lua:72 | ✅ |
| T_SURGE_OF_UNDEATH | 4 | `["floor",["talentScale",4,10]]` | master-necromancer.lua:71 | ✅ |
| T_RECALL_MINIONS | 0 | `["ceil",["talentLimit",8,1,6]]` | master-necromancer.lua:123 | ✅ |
| T_SUFFER_FOR_ME | 0 | `["min",40,["max",5,["/",["spellDamage",20,330],10]]]` | master-necromancer.lua:170 | ✅ |
| T_CALL_OF_THE_CRYPT | 0 | `["max",1,["floor",["talentScale",1,2,"log"]]]` | master-of-bones.lua:180 | ✅ |
| T_CALL_OF_THE_CRYPT | 1 | `["max",1,["+",["actor","角色等级"],["floor",["combatScale",["talentLevel"],-6,0.9,2,5]]]]` | master-of-bones.lua:212 | ✅ |
| T_CALL_OF_THE_CRYPT | 2 | `["max",1,["floor",["talentScale",1,4.5]]]` | master-of-bones.lua:183 | ✅ |
| T_SHATTERED_REMAINS | 1 | `["spellDamage",30,200]` | master-of-bones.lua:299 | ✅ |
| T_SHATTERED_REMAINS | 2 | `["floor",["talentScale",30,130]]` | master-of-bones.lua:298 | ✅ |
| T_SHATTERED_REMAINS | 3 | `["floor",["talentScale",6,15]]` | master-of-bones.lua:297 | ✅ |
| T_SHATTERED_REMAINS | 4 | `["talentScale",3,50]` | master-of-bones.lua:296 | ✅ |
| T_ASSEMBLE | 0 | `["max",1,["+",["actor","角色等级"],["floor",["combatScale",["talentLevel"],-6,0.9,2,5]]]]` | master-of-bones.lua:445 | ✅ |
| T_LORD_OF_SKULLS | 0 | `["talentScale",30,80]` | master-of-bones.lua:511 | ✅ |

## 发现的写法模式

1. **`math.floor(self:combatTalentScale(t, low, high))` 是这批的绝对主流**（dreadmaster / rime-wraith / death /
   master-necromancer / master-of-bones 五系共 22 条）。直接映射 `["floor",["talentScale",low,high]]` 即可，
   代表：`T_NEVERENDING_PERIL#0`（dreadmaster.lua:227），`T_GRIM_SHADOW#1`（death.lua:175）。
2. **`"log"` 幂模式**：`combatTalentScale(t, low, high, "log")`（master-of-bones.lua:181，`T_CALL_OF_THE_CRYPT#0`）。
   节点表已支持第三参数 `"log"`，无需展开。
3. **`combatTalentSpellDamage(t, base, max)` / `damDesc(self, DamageType.X, v)`**：`damDesc` 只是包裹，
   直接写 `["spellDamage",base,max]`（rime-wraith.lua:67、death.lua:31、dreadmaster.lua:175）。
   法术强度=100 由标题钉住。
4. **`math.floor(self:getTalentLevel(t))` 及其算术**：dreadmaster.lua:157 的 `local lvl` 在整段说明里复用了 5 次
   （T_DREAD #1/#2/#3/#5），`lvl + 2` 一次（#4）。这类"局部变量复用"是自动提取失败的典型原因。
5. **`self.level + t:_getLevel(self)` + `max(1, …)`**：三个技能共用同一写法（dreadmaster.lua:165、
   master-of-bones.lua:285/498）。`getLevel` 一律是 `floor(combatScale(getTalentLevel(t), -6, 0.9, 2, 5))`
   —— 注意 `combatScale` 的 5 个锚点，且第三参数 0.9 是 x_low 而不是常量偏移。角色等级由标题声明
   （`["actor","角色等级"]`）。
6. **`util.bound(v, lo, hi)`**：写成 `["min",hi,["max",lo,v]]`（master-necromancer.lua:29/170）。
7. **同一 `tformat` 里同一个值出现两次**：`T_SURGE_OF_UNDEATH` 的 `getGhoulDur` 占 #2/#3 两个 acronym
   （master-necromancer.lua:106），两条表达式完全相同——导出把同一数字抄了两遍。
8. **条件倍率由源码字面量给出而非标题输入**：`T_RIGOR_MORTIS` 的 `incFormula(nb) = 1 + log10(nb)*1.5`
   （death.lua:40），`nb` 是 info 里写死的 2/5/10/15，写成 `["log10",2]` 等常数即可（不是硬编码标题输入）。
9. **`×2` 包装**：`T_RIME_WRAITH#1` 是 `getResist*2`（rime-wraith.lua:57），floor 在乘法里面。
10. **`math.ceil(combatTalentScale(...))`**：`T_DRAWN_TO_DEATH#0`（death.lua:88）——`ceil` 而非 `floor`。

### 需要"按源码运算顺序展开"的 5 条（重要）

`combatTalentScale` / `combatTalentLimit` 的**节点实现是代数等价但浮点顺序不同的重排**：

- 源码（Combat.lua:1544）：`m*(tl+shift)^power + b + add`，其中 `b = low - m*x_low_adj`；
- 工具节点（`src/lib/lua-formula.js`）：`m*(tl^power - x_low_adj) + low + add`。

两者数学等价，但在 `tl` 恰好命中锚点（尤其 `tl=5`）时末位舍入不同，`floor` / `ceil` 会翻 1。
实测差异（`low,high` → 源码值 / 节点值，均 `floor`）：

| low,high | 源码顺序 | 工具节点 | 受影响条目 |
| --- | --- | --- | --- |
| 1,4 | 3.9999999999999996 → 3 | 4 → 4 | `T_SOULEATER#1` |
| 2,8 | 7.999999999999999 → 7 | 8 → 8 | `T_SOULEATER#2` |
| 5,15 | 15 → 15 | 14.999999999999998 → 14 | `T_RIME_WRAITH#1`, `#3` |
| 10,30 | 30 → 30 | 29.999999999999996 → 29 | `T_PERMAFROST#0`, `#1` |
| (limit) 75,20,40 | 19.9996 → 19（系数 1.3，1 级） | 恰好 20 → 20 | `T_NECROTIC_AURA#2` |

这 6 条我按源码原式展开（`m`/`b` 各自保持源码的乘加顺序，`combatTalentLimit` 展开成
`limit*(1-exp(sqrt(tl)*a+b))`），全部 15/15 PASS。
其余大批准点(`tl=5`)两式同值，仍用短节点 `["talentScale",…]`。**建议**：把解析器/手写规范里的
`combatTalentScale` 展开改回 `m*x^p + (low - m*x_low^p)` 的运算顺序，可让这 6 条回归短写法。

## 无法建模

本批 51 条全部建模成功，**无**"无法建模"条目。也**没有**出现以下跳过条件：

- `--list` 的 `源码: 无记录`：本批 5 系全部有记录（最差是 `无候选`）。
- `标题里没有唯一可变的轴`：本批 51 条的轴一律是「技能等级」，5 点、唯一。
- 依赖真随机 / 玩家武器 / 别的实体状态：本批只有 `T_DREAD`/`T_CALL_OF_THE_CRYPT`/`T_ASSEMBLE` 的
  `minions_list`（召唤物 HP/装备/fear_immune 等）不可建模，但那些数值**不在** tooltip 的 acronym 里，
  因此不构成目标；`minions_list` 里真正被引用的只有上面的 `getLevel` 公式。

## 疑点

1. **工具节点的浮点重排（本批唯一系统性偏差）**：见上节表格。这不是源码与导出的不一致——源码顺序与
   导出完全吻合（15/15），偏差只存在于工具的等价展开。若构建端用同一节点实现去复算，短写法会让这 6 条被丢弃。
2. **`--list` 的「值」三套顺序是 系数 1.00 / 1.30 / 1.50**（已用 `T_DREAD#1` 的 `floor(tl)` 阶梯反推确认：
   1/2/3/4/5 | 1/2/3/5/6 | 1/3/4/6/7 正好是 `floor(raw*1)`/`floor(raw*1.3)`/`floor(raw*1.5)`）。
   `参数:` 行只回放 built 数据里那一套（恒显示 `技能系数=1.5`），不要据此判断轴。
3. **`T_DREAD` 与 `T_CALL_OF_THE_CRYPT`/`T_ASSEMBLE` 共用同一段说明值**（44/46/48/50/52 | 45/48/50/52/53 |
   45/48/51/53/55）：三者的 `getLevel` 完全相同，`self.level` 由标题钉为 50。属于正常复用，非缺陷。
4. **取整读数混用**：本批既有 `%d`（`floor` 写进源码）也有 `%0.2f`（如 `T_SHATTERED_REMAINS#4` 的
   `8.33`、`T_RIGOR_MORTIS#2` 的 267.66→268）。这些都由判分器的 `matchesDisplayed` 处理，
   公式里**没有**加任何显示层包装。`T_SHATTERED_REMAINS#4` 在系数 1.3 的 1 级显示 `8.33`
   （小数字面精确匹配），其余点按整数读数判。
5. **`T_GRIM_SHADOW` 的 `radius`**（death.lua:171）用 `floor(combatTalentLimit(t, 10, 1, 3))`，其值
   （0.77 / … / 2.6）是整数显示，且该 acronym 不在本次目标清单里（已由自动提取或另有处理），未纳入本批。
