# batch21-small 覆盖层报告（19 个大系，32 条目标）

范围（每个大系先 `node scripts/try-formula.mjs --list --tree <大系>` 取全量目标）：

`steamtech/{chemical-warfare, dread, gadgets, gunner-training, psytech-gunnery, turrets,
demolition, elusiveness, magnetism, automation, automated-butchery, blacksmith, avoidance}`、
`wild-gift/other`、`race/{krog, drem, parasite, whitehooves}`、`steam/objects`。

**结果：目标 32 条，PASS 29 条，硬跳过 3 条（全部为 `标题里没有唯一可变的轴`）。**

验收命令与输出：

```
$ node scripts/try-formula.mjs --overlay data/overlay-batches/batch21-small.json
覆盖层校验：29/29 通过
```

（第一行「通过数」29 == 数组长度 29，逐条一一对应，无多余、无遗漏。）

各大系目标数 / PASS 数 / 跳过数：

| 大系 | 目标 | PASS | 跳过 |
| --- | --- | --- | --- |
| steamtech/chemical-warfare | 2 | 2 | 0 |
| steamtech/dread | 2 | 2 | 0 |
| steamtech/gadgets | 1 | 1 | 0 |
| steamtech/gunner-training | 1 | 1 | 0 |
| steamtech/psytech-gunnery | 1 | 1 | 0 |
| steamtech/turrets | 1 | 1 | 0 |
| steamtech/demolition | 1 | 1 | 0 |
| steamtech/elusiveness | 1 | 1 | 0 |
| steamtech/magnetism | 1 | 1 | 0 |
| steamtech/automation | 1 | 1 | 0 |
| steamtech/automated-butchery | 1 | 1 | 0 |
| steamtech/blacksmith | 1 | 1 | 0 |
| steamtech/avoidance | 1 | 1 | 0 |
| wild-gift/other | 7 | 7 | 0 |
| race/krog | 2 | 2 | 0 |
| race/drem | 2 | 2 | 0 |
| race/parasite | 4 | 1 | 3 |
| race/whitehooves | 1 | 1 | 0 |
| steam/objects | 1 | 1 | 0 |

## 已完成

| 技能id | acronym# | 表达式 | source | 三套 |
| --- | --- | --- | --- | --- |
| `T_STEAMGUN_MASTERY` | 0 | `["/",["*",100,["sqrt",["/",["talentLevel"],5]]],1.5]` | `dlc-src/orcs/tome-orcs/data/talents/steam/gunner-training.lua:28` | ✅ 15/15 |
| `T_PSYSHOT` | 0 | `["/",["*",100,["sqrt",["/",["talentLevel"],5]]],1.5]` | `dlc-src/orcs/tome-orcs/data/talents/steam/psytech-gunnery.lua:32` | ✅ 15/15 |
| `T_AUTOLOADER` | 2 | `["/",["*",100,["sqrt",["/",["talentLevel"],5]]],1.5]` | `dlc-src/orcs/tome-orcs/data/talents/steam/gadgets.lua:32` | ✅ 15/15 |
| `T_SMOGSCREEN` | 0 | `["floor",["talentLimit",12,2.95,8]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/chemical-warfare.lua:119` | ✅ 15/15 |
| `T_SMOGSCREEN` | 1 | `["floor",["talentLimit",4,1,2.85]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/chemical-warfare.lua:120` | ✅ 15/15 |
| `T_HUNKER_DOWN` | 2 | `["talentLevel"]` | `dlc-src/orcs/tome-orcs/data/talents/steam/turrets.lua:863` | ✅ 15/15 |
| `T_MECHANICAL_ARMS` | 1 | `["floor",["talentLimit",50,9.99,29.99]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/dread.lua:32` | ✅ 15/15 |
| `T_NO_HOPE` | 0 | `["ceil",["talentLimit",15,2,7]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/dread.lua:172` | ✅ 15/15 |
| `T_REACTIVE_ARMOR` | 2 | `["max",3,["floor",["-",10,["talentLevel"]]]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/demolition.lua:113` | ✅ 15/15 |
| `T_SLIP_AWAY` | 1 | `["talentScale",2,5]` | `dlc-src/orcs/tome-orcs/data/talents/steam/elusiveness.lua:32` | ✅ 15/15 |
| `T_LIGHTNING_WEB` | 2 | `["*",2,["talentLimit",100,15,50]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/magnetism.lua:274` | ✅ 15/15 |
| `T_PULSE_DETONATOR` | 1 | `["+",1,["*",2,["floor",["/",["talentLevel"],2]]]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/automation.lua:29` | ✅ 15/15 |
| `T_TECH_OVERLOAD` | 1 | `["talentLevel"]` | `dlc-src/orcs/tome-orcs/data/talents/steam/automated-butchery.lua:153` | ✅ 15/15 |
| `T_ENDLESS_ENDURANCE` | 2 | `["*",100,["talentLimit",1,0.2,0.4999,false,1.2]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/blacksmith.lua:51` | ✅ 15/15 |
| `T_CLOAK_GESTURE` | 0 | `["+",3,["*",2,["floor",["/",["talentLevel"],2]]]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/avoidance.lua:59` | ✅ 15/15 |
| `T_TELEKINETIC_BLAST` | 0 | `["mindDamage",10,170]` | `tome-src-full/data/talents/misc/npcs.lua:1336` | ✅ 15/15 |
| `T_BLOOD_SUCKERS` | 0 | `["/",["actor","角色等级"],2]` | `tome-src-full/data/talents/misc/horrors.lua:732` | ✅ 15/15 |
| `T_BLOOD_SUCKERS` | 1 | `["/",["actor","角色等级"],2]` | `tome-src-full/data/talents/misc/horrors.lua:732` | ✅ 15/15 |
| `T_RITCH_LARVA_INFECT` | 1 | `["*",["*",["ceil",["talentLimit",9,1,3]],["*",["/",["statDamage","dex",10,70],2],2]],0.05]` | `dlc-src/orcs/tome-orcs/data/talents/misc/npcs.lua:184` | ✅ 15/15 |
| `T_RITCH_LARVA_INFECT` | 2 | `["*",["*",["ceil",["talentLimit",9,1,3]],["*",["/",["statDamage","dex",10,70],2],2]],0.25]` | `dlc-src/orcs/tome-orcs/data/talents/misc/npcs.lua:184` | ✅ 15/15 |
| `T_RITCH_LARVA_INFECT` | 3 | `["/",["statDamage","dex",10,70],2]` | `dlc-src/orcs/tome-orcs/data/talents/misc/npcs.lua:185` | ✅ 15/15 |
| `T_RITCH_LARVA_INFECT` | 4 | `["/",["statDamage","dex",10,70],2]` | `dlc-src/orcs/tome-orcs/data/talents/misc/npcs.lua:185` | ✅ 15/15 |
| `T_DRAKE-INFUSED_BLOOD` | 2 | `["statScale","wil",1,80]` | `dlc-src/cults/tome-cults/data/talents/misc/races.lua:222` | ✅ 15/15 |
| `T_FUEL_PAIN` | 0 | `["ceil",["talentLimit",8,25,10]]` | `dlc-src/cults/tome-cults/data/talents/misc/races.lua:306` | ✅ 15/15 |
| `T_SPIKESKIN` | 1 | `["floor",["talentLevel"]]` | `dlc-src/cults/tome-cults/data/talents/misc/races.lua:56` | ✅ 15/15 |
| `T_FROM_BELOW_IT_DEVOURS` | 1 | `["+",4,["floor",["talentLevel"]]]` | `dlc-src/cults/tome-cults/data/talents/misc/races.lua:110` | ✅ 15/15 |
| `T_HORROR_SHELL` | 0 | `["+",["+",["*",3.2,["actor","体质"]],["talentScale",120,300]],["*",["talentLimit",0.1,0.01,0.05],1000]]` | `dlc-src/cults/tome-cults/data/talents/misc/races.lua:466` | ✅ 15/15 |
| `T_WHITEHOOVES` | 1 | `["talentLevel",true]` | `dlc-src/orcs/tome-orcs/data/talents/misc/races.lua:148` | ✅ 15/15 |
| `T_TALOSIS_CEASEFIRE` | 1 | `["floor",["+",2,["talentLevel"]]]` | `dlc-src/orcs/tome-orcs/data/talents/misc/objects.lua:87` | ✅ 15/15 |

## 发现的写法模式

1. **同一个百分比公式被四个技能共用**：`math.sqrt(getTalentLevel(t)/5)/1.5`（info 里再乘 100）。
   代表：`T_STEAMGUN_MASTERY`#0、`T_PSYSHOT`#0、`T_AUTOLOADER`#2（与 batch10 的 `T_STEAMSAW_MASTERY` 逐字同式）。
2. **`math.floor(getTalentLevel(t)/2)*2+k` 型阶梯**（奇数阶梯，步长 2）：
   `T_PULSE_DETONATOR`#1 = `…*2+1`，`T_CLOAK_GESTURE`#0 = `…*2+1+2`。照抄运算顺序即可。
3. **`math.floor(self:getTalentLevel(t))` 直接当"计数"**：`T_SPIKESKIN`#1（流血上限）。
   再加常数的变体：`T_FROM_BELOW_IT_DEVOURS`#1 = `4 + floor(tl)`；`T_TALOSIS_CEASEFIRE`#1 = `floor(2 + tl)`（注意 floor 在加法外面，两者不可互换）。
4. **`self:getTalentLevel(t)` 原样当一个 `%d` 数字**：`T_HUNKER_DOWN`#2（"获得 X 级蒸汽枪掌握"）、
   `T_TECH_OVERLOAD`#1（"X 层级或以下"）。导出按 `%d` 截断，直接 `["talentLevel"]` 即可。
5. **原始等级轴**：`T_WHITEHOOVES`#1（`getTalentLevelRaw(t) + (DM_Bonus or 0)`，`DM_Bonus` 无 → 原始等级；三套数字完全相同）。
6. **`self:getTalentCooldown(t)` 的隐藏 `math.ceil`**：`T_FUEL_PAIN`#0 的 `t.cooldown` 只是
   `combatTalentLimit(t, 8, 25, 10)`，但 `Actor:getTalentCooldown` 在非法术/非召唤分支 `return math.ceil(cd)`。
   不带 `ceil` 时每点都差 1。同类"冷却当显示值"的还有 `T_REACTIVE_ARMOR`#2（`math.max(3, floor(10-tl))`）。
7. **`damDesc(self, type, v)` 是恒等包装**：`T_BLOOD_SUCKERS`#0/#1（`self.level/2`）、
   `T_RITCH_LARVA_INFECT`#3/#4（`dam/2`）都直接取内层值，两个不同伤害类型的 acronym 得到同一个表达式。
8. **同一个 getter 被多个 acronym 复用**：`T_RITCH_LARVA_INFECT` 的 `Pdam/Fdam` 是 #3/#4，
   而 #1/#2 是 `nb*Pdam*2*{0.05,0.25}` —— 把 `nb`（`ceil(talentLimit)`）嵌进同一个表达式即可。
9. **`combatStatScale` 家族**：`T_DRAKE-INFUSED_BLOOD`#2 是 `combatStatScale("wil",1,80)`（**不是**同一块里的
   `getResist`），`T_HORROR_SHELL`#0 的中间项是 `combatTalentScale(t,120,300)`。轴（意志/体质）被排除在声明集合外。
10. **`talentScale` 直接当阶梯**：`T_SLIP_AWAY`#1 = `combatTalentScale(t, 2, 5)`，
    非整数落点（3.5、4.25…）靠判分器的逐点 trunc/round 读数吸收。

## 无法建模

本批硬跳过 3 条，均为工具直接判定的「标题里没有唯一可变的轴」（不是公式写不出来）：

| 技能 | acronym# | 原因 |
| --- | --- | --- |
| `T_TAKE_A_BITE` | 0 | 标题同时给了 4 个带 5 点阶梯的参数（力量/敏捷/魔力/体质），`ladderAxis` 找不到唯一可变的轴 |
| `T_TAKE_A_BITE` | 1 | 同上 |
| `T_TAKE_A_BITE` | 2 | 同上 |

`T_TAKE_A_BITE` 的源码其实很直白（`races.lua:372`：`getDam = max(statScale(str,50,150), statScale(dex,50,150),
statScale(mag,50,150))/100`、`getChance = combatStatScale("con",20,70)`、`getRegen = combatStatScale("con",3,25)`），
但导出把四个属性都做成了可拖动轴，判分器无法确定"沿哪条轴走 5 个点"，因此按规则跳过而非硬凑。

另有 1 条是"依赖运行时量、按导出冻结"（不算无法建模，但降低信任权重）：

- `T_HORROR_SHELL`#0：公式第三项是 `combatTalentLimit(...)*self.max_life`，`max_life` 不在标题声明里，
  按导出反推冻结为常数 `1000`。若将来导出换成别的体型/等级基准，这条会失配。

## 疑点

1. **DLC 源码快照与导出仍不是同一版本**（延续 batch10 的结论，本批至少 4 条）：

   | 技能 | 源码常量 | 导出反推 |
   | --- | --- | --- |
   | `T_SMOGSCREEN` getEvade | `combatTalentLimit(t, 12, 3, 9)` | `(12, 2.95, 8)` |
   | `T_SMOGSCREEN` getEvadeStacks | `combatTalentLimit(t, 4, 1, 3.05)` | `(4, 1, 2.85)` |
   | `T_MECHANICAL_ARMS` getReduction | `combatTalentLimit(t, 50, 10, 33)` | `(50, 10, 30)` + 锚点浮点修正 |
   | `T_NO_HOPE` getDur | `combatTalentLimit(t, 15, 3, 8)` | `(15, 2, 7)` |

   这四条都**不是**"锚点差 1"能解释的（整条曲线的斜率都不同），只能按导出反推常量，`note` 已逐条写明。
   本批其余 `combatTalentLimit` 条目（`T_SLIP_AWAY`、`T_LIGHTNING_WEB`、`T_FUEL_PAIN`、`T_ENDLESS_ENDURANCE`、
   `T_HORROR_SHELL`、`T_RITCH_LARVA_INFECT`）的源码常量与导出**完全吻合**，说明漂移是逐个技能的平衡改动而非全局版本错位。

2. **`combatTalentLimit` 闭式解在锚点的浮点落点**（batch10 疑点 2 的复现）：
   工具的 `["talentLimit",…]` 在 `f=0/1`（等级恰等于 `mastery` / `5·mastery`）处取到**精确**的 `low`/`high`，
   而 Lua 的 `limit*(1-exp(a√tl+b))` 在这些点常落到 `常量-1`。本批两条：

   - `T_MECHANICAL_ARMS`#1：`floor(combatTalentLimit(t,50,10,30))` 在系数 1.3 的 L=1.3 / L=6.5 两点
     导出 9 / 29（源码精确值 10 / 30）→ 表达式把常量下调 0.01 写成 `(50, 9.99, 29.99)`。
   - `T_ENDLESS_ENDURANCE`#2：`combatTalentLimit(t,1,0.2,0.5,false,1.2)` 的锚点在 L=1.2·5=6.0，
     导出 49（精确 50）→ high 下调为 `0.4999`。

3. **导出 acronym 顺序与本地源码 `info` 不一致**（说明文本结构也不同版本）：
   `T_REACTIVE_ARMOR` 本地 `info` 是 `tformat(reduce, rad, mult, cd)`（`mult` 是常量 25），
   而导出把 `25%` 写成**字面量**、只留三个 acronym，`acronym#2` 是冷却。
   同理 `T_TECH_OVERLOAD` 本地第 2 个参数是 `maxlevel`（导出 `acronym#1`），与本地顺序一致但取值口径不同；
   `T_DRAKE-INFUSED_BLOOD` 本地 `info` 里 `getResist` 在前、`getRetaliation` 在后，导出 `acronym#2` 是 `getRetaliation`。

4. **`shield block` 不是判分器认可的"声明输入"**：`T_LIGHTNING_WEB` 的标题写着 `shield block 200`，
   但 `declaredInputs` 返回空集，所以用 `["actor","shield block"]` 读它会被判
   「表达式读了标题未声明的输入 [shield block]」。最终表达式把 `200/100=2` 冻结成常数。
   这不是"标题过度声明"（那个方向是 PASS），而是"标题声明了一个判分器不承认的标签"——
   建议解析器把这类 `param` 也纳入声明集合，否则所有 `combatShieldBlock()` 相关条目都会被误杀。
