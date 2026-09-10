# 覆盖层报告：`batch04-techniques`（8 个战术系）

范围：`technique/finishing-moves`、`technique/combat-training`、`technique/munitions`、`technique/mobility`、
`technique/magical-combat`、`technique/tireless-combatant`、`technique/pugilism`、`technique/assassination`
（源码目录 `tome-src-full/data/talents/techniques/`）。

- 目标数：**52** 条 acronym（`node scripts/try-formula.mjs --list --tree <大系>` 逐系枚举，去重后 52）
- PASS：**49** 条（写入 `data/overlay-batches/batch04-techniques.json`）
- 跳过并记录：**3** 条（均为「源码 ↔ 导出」不一致，见「疑点」）
- 批次自检：`node scripts/try-formula.mjs --overlay data/overlay-batches/batch04-techniques.json`
  → `覆盖层校验：49/49 通过`（通过数 = 数组长度）

| 大系 | 目标数 | PASS | 跳过 |
| --- | --- | --- | --- |
| `technique/finishing-moves` | 11 | 11 | 0 |
| `technique/combat-training` | 8 | 7 | 1 |
| `technique/munitions` | 7 | 7 | 0 |
| `technique/mobility` | 6 | 5 | 1 |
| `technique/magical-combat` | 6 | 6 | 0 |
| `technique/tireless-combatant` | 5 | 4 | 1 |
| `technique/pugilism` | 5 | 5 | 0 |
| `technique/assassination` | 4 | 4 | 0 |
| **合计** | **52** | **49** | **3** |

## 已完成（每条均 `结论：PASS（三套 15 点全中，输入集合覆盖）`）

| 技能id | acronym | 表达式 | source | 三套 |
| --- | --- | --- | --- | --- |
| `T_UPPERCUT` | #0 | `["*",100,["weaponDamage",1.1,1.8]]` | `finishing-moves.lua:35` | 15/15 |
| `T_UPPERCUT` | #1 | `["+",2,["ceil",["*",0.25,["talentScale",1,5]]]]` | `finishing-moves.lua:36` | 15/15 |
| `T_UPPERCUT` | #2 | `["+",2,["ceil",["*",1.25,["talentScale",1,5]]]]` | `finishing-moves.lua:36` | 15/15 |
| `T_CONCUSSIVE_PUNCH` | #0 | `["*",100,["weaponDamage",0.6,1.5]]` | `finishing-moves.lua:92` | 15/15 |
| `T_CONCUSSIVE_PUNCH` | #1 | `["*",0.25,["statDamage","str",10,450]]` | `finishing-moves.lua:93` | 15/15 |
| `T_CONCUSSIVE_PUNCH` | #2 | `["*",1.25,["statDamage","str",10,450]]` | `finishing-moves.lua:93` | 15/15 |
| `T_BUTTERFLY_KICK` | #0 | `["*",100,["weaponDamage",1,1.5]]` | `finishing-moves.lua:149` | 15/15 |
| `T_HAYMAKER` | #0 | `["*",100,["weaponDamage",1.2,3]]` | `finishing-moves.lua:214` | 15/15 |
| `T_HAYMAKER` | #1 | `["*",200,["weaponDamage",1.2,3]]` | `finishing-moves.lua:259` | 15/15 |
| `T_HAYMAKER` | #2 | `["*",100,["combatLimit",["talentLevel"],0.5,0,0,0.2,10]]` | `finishing-moves.lua:216` | 15/15 |
| `T_HAYMAKER` | #3 | `["*",100,["combatLimit",["+",5,["talentLevel"]],0.5,0,0,0.2,10]]` | `finishing-moves.lua:216` | 15/15 |
| `T_ARMOUR_TRAINING` | #0 | `["*",1.5,["talentScale",1,7,0.75]]` | `combat-training.lua:59` | 15/15 |
| `T_ARMOUR_TRAINING` | #1 | `["combatLimit",["*",7.5,["talentLevel"]],100,5,3.75,50,37.5]` | `combat-training.lua:62` | 15/15 |
| `T_ARMOUR_TRAINING` | #2 | `["*",1.5,["talentScale",1,9]]` | `combat-training.lua:65` | 15/15 |
| `T_LIGHT_ARMOUR_TRAINING` | #2 | 见批次文件：`combatTalentLimit(t,50,10,25,false,1.0)` 手工长写（`limit*(1-exp(sqrt(tl)*a+b))`） | `combat-training.lua:132` | 15/15 |
| `T_WEAPONS_MASTERY` | #0 | `["/",["*",100,["sqrt",["/",["talentLevel"],5]]],1.5]` | `combat-training.lua:184` | 15/15 |
| `T_KNIFE_MASTERY` | #0 | `["/",["*",100,["sqrt",["/",["talentLevel"],5]]],1.5]` | `combat-training.lua:202` | 15/15 |
| `T_EXOTIC_WEAPONS_MASTERY` | #0 | `["/",["*",100,["sqrt",["/",["talentLevel"],5]]],1.5]` | `combat-training.lua:220` | 15/15 |
| `T_EXOTIC_MUNITIONS` | #1 | `["min",2,["+",1,["floor",["/",["talentLevel"],3]]]]` | `munitions.lua:42` | 15/15 |
| `T_EXOTIC_MUNITIONS` | #5 | `["talentLimit",30,5,25,true]` | `munitions.lua:45` | 15/15 |
| `T_ALLOYED_MUNITIONS` | #0 | `["talentLimit",30,5,25,true]` | `munitions.lua:432` | 15/15 |
| `T_ALLOYED_MUNITIONS` | #3 | `["min",2,["+",1,["floor",["/",["talentLevel"],3]]]]` | `munitions.lua:429` | 15/15 |
| `T_EXPLOSIVE_SHOT` | #1 | `["floor",["talentScale",1.3,2.7]]` | `munitions.lua:295` | 15/15 |
| `T_EXPLOSIVE_SHOT` | #6 | `["floor",["talentScale",1.3,2.7]]` | `munitions.lua:295` | 15/15 |
| `T_EXPLOSIVE_SHOT` | #10 | `["floor",["talentScale",1.3,2.7]]` | `munitions.lua:295` | 15/15 |
| `T_DISENGAGE` | #0 | `["floor",["talentLimit",10,3.5,7.5]]` | `mobility.lua:62` | 15/15 |
| `T_DISENGAGE` | #1 | `["talentScale",100,200,"log"]` | `mobility.lua:50` | 15/15 |
| `T_EVASION` | #0 | `["combatLimit",["+",["*",5,["talentLevel"]],["/",["*",["actor","敏捷"],50],100]],50,10,10,37.5,75]` | `mobility.lua:220` | 15/15 |
| `T_TRAINED_REACTIONS` | #1 | `["*",12,["max",0.1,["talentLimit",0.8,0.25,0.45]]]` | `mobility.lua:306` | 15/15 |
| `T_TRAINED_REACTIONS` | #2 | 见批次文件：`max(0.1,talentLimit(t,0.8,0.25,0.6)) * combatLimit(combatDefense(true),1.0,0.25,0,0.55,50) * 100`（`combatDefense` 内联展开） | `mobility.lua:303` | 15/15 |
| `T_ARCANE_COMBAT` | #0 | `["combatLimit",["*",["talentLevel"],["+",1,["/",["*",["actor","灵巧"],9],100]]],100,20,0,70,50]` | `magical-combat.lua:31` | 15/15 |
| `T_ARCANE_CUNNING` | #1 | `["/",["*",["actor","灵巧"],["talentScale",20,40,0.75]],100]` | `magical-combat.lua:190` | 15/15 |
| `T_ARCANE_FEED` | #0 | `["/",["talentScale",1,5,0.75],7]` | `magical-combat.lua:209` | 15/15 |
| `T_ARCANE_DESTRUCTION` | #0 | `["*",100,["/",["talentScale",1,5],7]]` | `magical-combat.lua:239` | 15/15 |
| `T_ARCANE_DESTRUCTION` | #1 | `["*",["actor","魔力"],["/",["talentScale",1,5],7]]` | `magical-combat.lua:239` | 15/15 |
| `T_ARCANE_DESTRUCTION` | #2 | `["min",2,["+",1,["floor",["/",["talentLevel"],5]]]]` | `magical-combat.lua:237` | 15/15 |
| `T_SKIRMISHER_BREATHING_ROOM` | #0 | `["talentScale",1.5,6,0.75]` | `tireless-combatant.lua:25` | 15/15 |
| `T_SKIRMISHER_DAUNTLESS_CHALLENGER` | #0 | `["talentScale",0.3,1.5,0.75]` | `tireless-combatant.lua:140` | 15/15 |
| `T_SKIRMISHER_DAUNTLESS_CHALLENGER` | #1 | `["talentScale",1,5,0.75]` | `tireless-combatant.lua:143` | 15/15 |
| `T_SKIRMISHER_PACE_YOURSELF` | #1 | 见批次文件：`combatScale(combatDefense()*tl, 5, 10, 30, 550)`（`combatDefense` 内联展开） | `tireless-combatant.lua:101` | 15/15 |
| `T_DOUBLE_STRIKE` | #0 | `["*",100,["weaponDamage",0.5,0.8]]` | `pugilism.lua:86` | 15/15 |
| `T_SPINNING_BACKHAND` | #0 | `["*",100,["weaponDamage",1,1.7]]` | `pugilism.lua:172` | 15/15 |
| `T_SPINNING_BACKHAND` | #1 | `["*",100,["combatScale",["-",["ceil",["+",2,["talentScale",2.2,4.3]]],1],0.15,1,0.5,5]]` | `pugilism.lua:167` | 15/15 |
| `T_AXE_KICK` | #0 | `["*",100,["weaponDamage",0.8,2]]` | `pugilism.lua:285` | 15/15 |
| `T_FLURRY_OF_FISTS` | #0 | `["*",100,["weaponDamage",0.3,1]]` | `pugilism.lua:337` | 15/15 |
| `T_COUP_DE_GRACE` | #0 | `["*",100,["weaponDamage",1,1.5]]` | `assassination.lua:32` | 15/15 |
| `T_MARKED_FOR_DEATH` | #0 | `["talentScale",15,40]` | `assassination.lua:167` | 15/15 |
| `T_MARKED_FOR_DEATH` | #1 | `["statDamage","dex",15,180]` | `assassination.lua:169` | 15/15 |
| `T_MARKED_FOR_DEATH` | #2 | `["talentLimit",50,20,40]` | `assassination.lua:168` | 15/15 |

## 发现的写法模式

1. **`combatTalentWeaponDamage` 直译**：`self:combatTalentWeaponDamage(t, base, max)` → `["weaponDamage", base, max]`；info 里 `*100`
   写 `["*",100,…]`。`+ getStrikingStyle(self, dam)` 在本库所有调用点上都可**整体省略**——它对 `dam` 这个未定义全局调用
   `self:isTalentActive(self.T_STRIKING_STANCE)`，导出基准角色没有 Striking Stance，返回 0（`cunning/tactical.lua:20`）。
   代表：`T_UPPERCUT` #0、`T_DOUBLE_STRIKE` #0、`T_AXE_KICK` #0。
2. **`combatTalentScale` 的第 4 参是 `power`（缺省 0.5 = √ 曲线）**，不是上限或步长；`0.75` 与 `"log"` 在本批大量出现。
   外层 `math.floor/ceil` 照抄成 `["floor"]`/`["ceil"]`。代表：`T_THICK_SKIN`（0.75）、`T_DISENGAGE` #1（"log"）。
3. **`["+"]/["-"]/["*"]/["/"]` 只吃两个操作数**，三项相加必须嵌套成 `["+",["+",a,b],c]`。
   同一批里还有 `["min", …]`/`["max", …]` 是变参、`["talentScale", low, high, …]` 的前两参**只认数字字面量**（不走
   `value()`），所以 `["/",1,7]` 当 low 会直接算出 `—`。等价改写：分数常量写成小数，或把除法提到外层
   （`combatTalentScale(t,1/7,5/7,0.75)` = `["/",["talentScale",1,5,0.75],7]`，scale 对 low/high 线性）。
   代表：`T_ARCANE_FEED` #0、`T_ARCANE_DESTRUCTION` #0。
4. **离散 `if` 分支用 floor 阶梯精确编码**：`if getTalentLevel(t)>=3 then 2 else 1 end` 等价于
   `["min",2,["+",1,["floor",["/",["talentLevel"],3]]]]`（对任意正等级都成立）；`< 5 then 1 or 2` 同理用 `/5`。
   代表：`T_EXOTIC_MUNITIONS` #1、`T_ALLOYED_MUNITIONS` #3、`T_ARCANE_DESTRUCTION` #2。
5. **`combatTalentLimit` 的第 5 参是 `raw`，不是 `mastery`**：`self:combatTalentLimit(t, 30, 5, 25, 0.75)` 里的 `0.75`
   是真值 → 用**原始**等级，`mastery` 仍是默认 1.3。因为原始等级不随技能系数变，这类值三套数字完全相同。
   写成 `["talentLimit",30,5,25,true]`。代表：`T_EXOTIC_MUNITIONS` #5、`T_ALLOYED_MUNITIONS` #0。
6. **带 prop 的原始属性读取 `getCun(9,true)` / `getDex(50,true)` = 属性 × prop / 100**（`getStat` 末尾统一 `/100`）。
   与现有批次一致：`["/",["*",["actor","灵巧"],9],100]`、`["/",["*",["actor","敏捷"],50],100]`（= 敏捷/2）。
   代表：`T_ARCANE_COMBAT` #0、`T_EVASION` #0。
7. **不带 `raw` 的 `getXxx()` 在本导出基准上就是标题里的裸属性值**：`T_ARCANE_CUNNING` #1 的 `getCun()`、
   `T_ARCANE_DESTRUCTION` #1 的 `getMag()` 都直接对应 `["actor","灵巧"]` / `["actor","魔力"]`（导出基准 100），
   没有额外 `rescaleCombatStats`。注意这与 `combatDefense()` 内部的自洽性不同（见下条）。
8. **导出基准角色的隐式常量**（标题未声明，冻结成常数是允许的）：`getStrikingStyle`=0、`combatFatigue`=0、
   `T_ARMOUR_TRAINING.ArmorEffect`=1.5（身体槽是重甲，从护甲/护甲强度/暴击减免三条阶梯**同时**反推出来）、
   `combat_def`≈39（装备基础闪避）。但**能保住滑条的尽量展开**：`T_TRAINED_REACTIONS` #2 与
   `T_SKIRMISHER_PACE_YOURSELF` #1 把 `combatDefense()` 里的
   `rescaleCombatStats(d) = floor(min over k of (20k + (d - 10k(k+1))/(k+1)))` 用 `["min", …]`/`["floor"]` **原样展开**，
   于是 `敏捷`/`幸运` 滑条仍然有效（两处都是 d = combat_def + (dex−10)·0.7 + (lck−50)·0.4）。
9. **同一 `info` 里重复出现的数值会产生重复 acronym**：`T_EXPLOSIVE_SHOT` 的 radius 在 tformat 里出现 3 次
   （#1/#6/#10），三条写同一条公式即可。acronym 序号只按 `tformat(...)` 的**实参顺序**对齐，`info` 里的
   `local area = …` 只是缓存；`damDesc(self, DamageType.X, v)` 只是包裹，直接取 `v`。
10. **浮点边界要照抄源码的算法顺序**：`T_LIGHT_ARMOUR_TRAINING` #2 用 `combatTalentLimit` 闭式会返回**正好 10**，
    而游戏读数是 9；把节点表里的 `talentLimit` 换成源码里 `limit*(1-exp(sqrt(tl)*a+b))` 的长写（同样的 double 运算顺序）
    后得到 `9.999999999999998`，15 点全中。等价展开在这一批里是**必要**手段，不只是"更好的写法"。

## 无法建模

本批没有"读懂了但写不出来"的条目：52 条里 49 条写出来了，剩下 3 条**不是**公式难写，而是
「仓库里的 1.7.6 源码」与「导出数据」本身对不上（见「疑点」一节），按规则不硬凑。

未纳入本批（也未被要求处理）的类别在本批没有出现：没有依赖运行时数据表 `data.*`/`incStats.*`、没有依赖玩家武器
真实伤害（`combatTalentWeaponDamage` 返回的是**倍率**，凡是要把它乘到武器伤害上的值都不在本批目标里）、
没有真随机、没有投影链。

## 疑点

### 1. `T_THICK_SKIN` #0 —— 源码与导出数字系统性不一致

| 系数 | 导出 | 源码 `combatTalentScale(t,3.16,12.2,0.75)` 算得 |
| --- | --- | --- |
| 1.00 | `4.0 / 7.2 / 10 / 13 / 15` | `3.16 / 5.79 / 8.10 / 10.21 / 12.2` |
| 1.30 | 同上（三套完全相同） | 同上 |
| 1.50 | 同上 | 同上 |

- 源码：`tome-src-full/data/talents/techniques/combat-training.lua:27` `getRes = self:combatTalentScale(t, 3.16, 12.2, 0.75)`。
- 导出：`4.0, 7.2, 10%, 13%, 15%`，**恰好等于** `["talentScale",4,15,0.75]`（已实测 15/15 PASS）。站点自己的自动拟合
  也把这条记成 `talentScale(4,15)`。
- 三套数字完全相同 ⇒ 用原始/有效等级都一样，不是等级口径问题；`getRes` 是纯函数，也不可能是基准角色状态问题。
- 额外核对：仓库源码 `mod/init.lua` 是 1.7.6，上游 master（`git.net-core.org/tome/t-engine4`）与 te4.org 1.7.6 wiki
  都是 `3.16 / 12.2`，即**两边都与导出不一致**。
- 处置：按规则不写入覆盖层。若主项目决定以导出为准，一行即可补上且能过闸门：
  `{"talent":"T_THICK_SKIN","acronym":0,"expr":["talentScale",4,15,0.75]}`。

### 2. `T_SKIRMISHER_PACE_YOURSELF` #2（格挡几率）—— 同一条 info 内 #0 对得上、#2 对不上

| 系数 | 导出 | 源码 `combatTalentLimit(t,100,20,40)` 算得 |
| --- | --- | --- |
| 1.00 | `21 / 32 / 39 / 45 / 49` | `17.68 / 24.35 / 29.10 / 32.88 / 36.04` |
| 1.30 | `25 / 36 / 44 / 50 / 55` | `20.00 / 27.35 / 32.53 / 36.61 / 40.00` |
| 1.50 | `27 / 39 / 47 / 53 / 57` | `21.37 / 29.10 / 34.52 / 38.76 / 42.27` |

- 源码：`tome-src-full/data/talents/techniques/tireless-combatant.lua:105` `getBlockChance = self:combatTalentLimit(t, 100, 20, 40)`；
  info 第三个 `tformat` 实参（`tireless-combatant.lua:125`）。
- 反证不成立的关键点：**同一个 talent 的 #0（减速，`combatTalentLimit(t,0,0.15,0.05)*100`）与源码逐点吻合**，
  所以不是"整个文件版本不同"；而 #2 的 acronym 标题只声明了 `技能等级/技能系数`（**没有** 敏捷/幸运），
  即它只随技能等级变化，任何"基准角色装备/状态"都无法解释这个系统性偏差。
- 形状检验：导出阶梯是 `limit*(1-exp(a*sqrt(tl)+b))`，最小二乘拟合 `L≈102, a≈-0.3444, b≈0.1139`（rms 0.25）。
  对 `combatTalentLimit` 做穷举（limit 50–300、low/high 1–99、mastery 1.0–1.5）**没有任何整数参数组**能同时命中 15 点；
  最接近的 `(100, 21, 49, mastery=1)` 在 1.30/tl=6.5 处给 54.36（导出 55）即告失败。
- 处置：不写入覆盖层。站点目前的兜底是把它拟合成 `talentScale(27,57)`，滑条一动就偏，建议标注为"近似值"。

### 3. `T_EVASION` #1 —— 15 点里只差 1 点，且是 1 ulp 的浮点边界

| 系数 | 导出 | 算得（`combatScale(tl*敏捷/2, 0,0,55,250,0.75)`） |
| --- | --- | --- |
| 1.00 | `16 / 27 / 37 / 46 / 54` | `16.4488 / 27.6635 / 37.4952 / 46.5243 / 55` |
| 1.30 | `20 / 33 / 45 / 56 / 66` | `20.0259 / 33.6795 / 45.6492 / 56.6419 / 66.9607` |
| 1.50 | `22 / 37 / 50 / 63 / 74` | `22.2948 / 37.4952 / 50.8212 / 63.0592 / 74.5472` |

- 源码：`tome-src-full/data/talents/techniques/mobility.lua:221`
  `self:combatScale(self:getTalentLevel(t) * self:getDex(50,true), 0, 0, 55, 250, 0.75)`。
- 唯一失配点是 1.00/lv5：此时 `x = 5 × 50 = 250` **正好落在锚点 `x_high`** 上，按定义应得 `y_high = 55`。
  判分器的 `**`（V8 Math.pow）返回**正好 55**（读 55），而游戏侧 libm 的 `pow` 落在 55 的下方一个 ulp（读 54）。
- 已尝试的**等价**写法（都不改变浮点结果，仍是 55）：`55*(x/250)^0.75`、`exp(0.75*log(250))` 形式。
  没有任何"忠于源码"的写法能落回 54；能落回 54 的只有人为减去 epsilon，那属于固化导出伪影，按规则不做。
- 处置：不写入覆盖层。其余 14 点都对得上，源码公式本身是对的，问题在判分器与游戏 libm 的 pow 实现差异。

### 4. 其它

- 本批**没有**出现"标题过度声明输入"导致输入集合闸门过不了的情况：49 条全部以
  `✅ 完全一致` 或 `✅ 覆盖（标题是超集…）` 通过。
- `T_ARMOUR_TRAINING` 三条阶梯共同锁定 `ArmorEffect = 1.5`（重甲）。这是**导出基准角色的装备**，不是公式的一部分；
  已按常量冻结并在 `note` 里写明。若将来基准角色换成布甲，这三条必须重算。
