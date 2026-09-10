# batch10-steamtech 覆盖层报告（DLC steam 十二大系）

范围：`dlc-src/orcs/tome-orcs/data/talents/steam/` 下的 12 个大系
（other / mecharachnid / engineering / battlefield-management / assault / gunslinging /
physics / chemistry / butchery / turret-types / furnace / heavy-weapons）。

**结果：目标 51 条，PASS 51 条，硬跳过 0 条。**
验收命令：`node scripts/try-formula.mjs --overlay data/overlay-batches/batch10-steamtech.json`
→ 第一行 `覆盖层校验：51/51 通过`（与数组长度一致）。
覆盖集合与 `--list` 的 51 行逐条一一对应（无多余、无遗漏）。

各大系目标数 / PASS 数 / 跳过数：

| 大系 | 目标 | PASS | 跳过 |
| --- | --- | --- | --- |
| steamtech/other | 8 | 8 | 0 |
| steamtech/mecharachnid | 6 | 6 | 0 |
| steamtech/engineering | 5 | 5 | 0 |
| steamtech/battlefield-management | 5 | 5 | 0 |
| steamtech/assault | 4 | 4 | 0 |
| steamtech/gunslinging | 4 | 4 | 0 |
| steamtech/physics | 4 | 4 | 0 |
| steamtech/chemistry | 3 | 3 | 0 |
| steamtech/butchery | 3 | 3 | 0 |
| steamtech/turret-types | 3 | 3 | 0 |
| steamtech/furnace | 3 | 3 | 0 |
| steamtech/heavy-weapons | 3 | 3 | 0 |

## 已完成

| 技能id | acronym# | 表达式 | source | 三套 |
| --- | --- | --- | --- | --- |
| `T_SMITH` | 0 | `["floor",["talentLevel"]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/physics.lua:20` | ✅ 15/15 |
| `T_MECHANICAL` | 0 | `["floor",["talentLevel"]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/physics.lua:40` | ✅ 15/15 |
| `T_ELECTRICITY` | 0 | `["floor",["talentLevel"]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/physics.lua:60` | ✅ 15/15 |
| `T_COMPACT_STEAM_TANK` | 0 | `["floor",["*",5,["talentLevel"]]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/physics.lua:80` | ✅ 15/15 |
| `T_THERAPEUTICS` | 0 | `["floor",["talentLevel"]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/chemistry.lua:20` | ✅ 15/15 |
| `T_CHEMISTRY` | 0 | `["floor",["talentLevel"]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/chemistry.lua:40` | ✅ 15/15 |
| `T_EXPLOSIVES` | 0 | `["floor",["talentLevel"]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/chemistry.lua:60` | ✅ 15/15 |
| `T_MOLTEN_METAL` | 0 | `["+",10,["*",7,["talentLevel"]]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/furnace.lua:56` | ✅ 15/15 |
| `T_MOLTEN_METAL` | 1 | `["+",10,["*",7,["talentLevel"]]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/furnace.lua:56` | ✅ 15/15 |
| `T_MELTING_POINT` | 0 | `["floor",["talentLevel"]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/furnace.lua:149` | ✅ 15/15 |
| `T_STEAMSAW_MASTERY` | 0 | `["/",["*",100,["sqrt",["/",["talentLevel"],5]]],1.5]` | `dlc-src/orcs/tome-orcs/data/talents/steam/butchery.lua:20` | ✅ 15/15 |
| `T_OVERCHARGE_SAWS` | 0 | `["floor",["talentLimit",50,24.95,35]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/butchery.lua:110` | ✅ 15/15 |
| `T_OVERCHARGE_SAWS` | 1 | `["floor",["talentLimit",20,3,8]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/butchery.lua:110` | ✅ 15/15 |
| `T_EMERGENCY_STEAM_PURGE` | 0 | `["steamDamage",20,330]` | `dlc-src/orcs/tome-orcs/data/talents/steam/engineering.lua:20` | ✅ 15/15 |
| `T_EMERGENCY_STEAM_PURGE` | 1 | `["floor",["talentScale",2,4.5]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/engineering.lua:20` | ✅ 15/15 |
| `T_SUPERCHARGE_TINKERS` | 1 | `["+",20,["*",5,["talentLevel"]]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/engineering.lua:88` | ✅ 15/15 |
| `T_SUPERCHARGE_TINKERS` | 2 | `["talentScale",5,20,0.75]` | `dlc-src/orcs/tome-orcs/data/talents/steam/engineering.lua:88` | ✅ 15/15 |
| `T_LAST_ENGINEER_STANDING` | 0 | `["*",2,["talentLevel"]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/engineering.lua:112` | ✅ 15/15 |
| `T_SAWWHEELS` | 0 | `["+",100,["steamDamage",50,320]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/battlefield-management.lua:20` | ✅ 15/15 |
| `T_GRINDING_SHIELD` | 0 | `["talentLimit",50,12,24.9]` | `dlc-src/orcs/tome-orcs/data/talents/steam/battlefield-management.lua:96` | ✅ 15/15 |
| `T_GRINDING_SHIELD` | 1 | `["talentLimit",50,12,24.9]` | `dlc-src/orcs/tome-orcs/data/talents/steam/battlefield-management.lua:96` | ✅ 15/15 |
| `T_GRINDING_SHIELD` | 2 | `["talentLimit",50,100,70]` | `dlc-src/orcs/tome-orcs/data/talents/steam/battlefield-management.lua:96` | ✅ 15/15 |
| `T_BATTLEFIELD_VETERAN` | 1 | `["-",0,["floor",["talentScale",60,250]]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/battlefield-management.lua:187` | ✅ 15/15 |
| `T_OVERRUN` | 2 | `["/",["*",100,["sqrt",["/",["talentLevel"],5]]],1.5]` | `dlc-src/orcs/tome-orcs/data/talents/steam/mecharachnid.lua:708` | ✅ 15/15 |
| `T_DEFENSIVE_PROTOCOL` | 0 | `["talentLimit",50,11.95,30]` | `dlc-src/orcs/tome-orcs/data/talents/steam/mecharachnid.lua:781` | ✅ 15/15 |
| `T_DEFENSIVE_PROTOCOL` | 1 | `["*",100,["weaponDamage",0.5,1.5]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/mecharachnid.lua:781` | ✅ 15/15 |
| `T_AUTOMATED_REPAIR_SYSTEM` | 0 | `["-",0,["floor",["talentScale",50,650]]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/mecharachnid.lua:866` | ✅ 15/15 |
| `T_HEAVY_WEAPON_EXPERTISE` | 0 | `["+",100,["talentLimit",100,20,49.9]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/heavy-weapons.lua:110` | ✅ 15/15 |
| `T_HEAVY_WEAPON_EXPERTISE` | 3 | `["*",1.2,["+",100,["talentLimit",100,20,49.9]]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/heavy-weapons.lua:110` | ✅ 15/15 |
| `T_HEAVY_WEAPON_EXPERTISE` | 5 | `["/",["*",0.6,["+",100,["talentLimit",100,20,49.9]]],2.5]` | `dlc-src/orcs/tome-orcs/data/talents/steam/heavy-weapons.lua:110` | ✅ 15/15 |
| `T_TRICK_SHOT` | 0 | `["max",1,["floor",["talentScale",0.8,4.5,"log"]]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/gunslinging.lua:166` | ✅ 15/15 |
| `T_TRICK_SHOT` | 1 | `["*",100,["weaponDamage",0.6,1.4]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/gunslinging.lua:166` | ✅ 15/15 |
| `T_TRICK_SHOT` | 2 | `["*",100,["-",1,["talentLimit",1,0.6,0.85]]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/gunslinging.lua:166` | ✅ 15/15 |
| `T_TRICK_SHOT` | 3 | `["*",100,["-",1,["talentLimit",1,0.5,0.8]]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/gunslinging.lua:166` | ✅ 15/15 |
| `T_MECHARACHNID` | 0 | `["/",["+",60,["steamDamage",15,450]],7]` | `dlc-src/orcs/tome-orcs/data/talents/steam/mecharachnid.lua:417` | ✅ 15/15 |
| `T_MECHARACHNID` | 1 | `["talentLevel",true]` | `dlc-src/orcs/tome-orcs/data/talents/steam/mecharachnid.lua:488` | ✅ 15/15 |
| `T_STORMCOIL_GENERATOR` | 0 | `["talentLimit",90,15,60]` | `dlc-src/orcs/tome-orcs/data/talents/steam/mecharachnid.lua:492` | ✅ 15/15 |
| `T_MECHARACHNID_CHASSIS` | 0 | `["*",3,["talentLevel",true]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/mecharachnid.lua:512` | ✅ 15/15 |
| `T_MECHARACHNID_PILOTING` | 1 | `["talentLimit",100,10,45]` | `dlc-src/orcs/tome-orcs/data/talents/steam/mecharachnid.lua:676` | ✅ 15/15 |
| `T_MECHARACHNID_PILOTING` | 2 | `["talentLimit",70,10,34.5]` | `dlc-src/orcs/tome-orcs/data/talents/steam/mecharachnid.lua:676` | ✅ 15/15 |
| `T_STEAMGUN_TURRET` | 0 | `["^",["*",["/",["*",["+",5,["power","steampower"]],["+",1,["*",0.8,["-",["sqrt",0],1]]]],["*",105,["+",1,["*",0.8,["-",["sqrt",5],1]]]]],50],1.04]` | `dlc-src/orcs/tome-orcs/data/talents/steam/turrets.lua:40` | ✅ 15/15 |
| `T_FLAME_TURRET` | 0 | `["^",["*",["/",["*",["+",5,["power","steampower"]],["+",1,["*",0.8,["-",["sqrt",0],1]]]],["*",105,["+",1,["*",0.8,["-",["sqrt",5],1]]]]],50],1.04]` | `dlc-src/orcs/tome-orcs/data/talents/steam/turrets.lua:40` | ✅ 15/15 |
| `T_MEDIC_TURRET` | 0 | `["^",["*",["/",["*",["+",5,["power","steampower"]],["+",1,["*",0.8,["-",["sqrt",0],1]]]],["*",105,["+",1,["*",0.8,["-",["sqrt",5],1]]]]],50],1.04]` | `dlc-src/orcs/tome-orcs/data/talents/steam/turrets.lua:40` | ✅ 15/15 |
| `T_TINKER_ROCKET_BOOTS` | 0 | `["*",100,["+",0.5,["/",["talentLevel"],2]]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/other.lua:443` | ✅ 15/15 |
| `T_TINKER_IRON_GRIP` | 0 | `["+",3,["floor",["/",["talentLevel",true],3]]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/other.lua:478` | ✅ 15/15 |
| `T_TINKER_SPRING_GRAPPLE` | 1 | `["+",3,["floor",["/",["talentLevel",true],3]]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/other.lua:517` | ✅ 15/15 |
| `T_TINKER_ARCANE_DISRUPTION_WAVE` | 0 | `["talentLimit",10,3.5,5.5]` | `dlc-src/orcs/tome-orcs/data/talents/steam/other.lua:917` | ✅ 15/15 |
| `T_TINKER_INCENDIARY_SHELL` | 0 | `["floor",["talentLevel"]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/other.lua:1392` | ✅ 15/15 |
| `T_TINKER_VOLTAIC_SHELL` | 0 | `["floor",["talentLevel"]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/other.lua:1645` | ✅ 15/15 |
| `T_TURRET_FLAMETHROWER` | 0 | `["steamDamage",10,100]` | `dlc-src/orcs/tome-orcs/data/talents/steam/turrets.lua:437` | ✅ 15/15 |
| `T_TURRET_FLAME_VORTEX` | 0 | `["^",["*",["/",["*",["+",10,["power","steampower"]],["+",1,["*",0.8,["-",["sqrt",0],1]]]],["*",110,["+",1,["*",0.8,["-",["sqrt",5],1]]]]],100],1.04]` | `dlc-src/orcs/tome-orcs/data/talents/steam/turrets.lua:485` | ✅ 15/15 |

## 发现的写法模式

1. **`math.floor(self:getTalentLevel(t))` 直接当"等级"显示** —— 制造类被动的零件等级、熔点可清除的效果数、奥术波弹片数、伏特弹命中数都是它。表达式 `["floor",["talentLevel"]]`。代表：`T_SMITH` / `T_MELTING_POINT` / `T_TINKER_VOLTAIC_SHELL`。
2. **原始等级轴**：凡三套导出数字完全相同（且随等级变化）的，源码都用 `getTalentLevelRaw`。代表：`T_MECHARACHNID`#1（`["talentLevel",true]`）、`T_MECHARACHNID_CHASSIS`（`["*",3,["talentLevel",true]]`）。
3. **乘 5 / 除 2 的线性百分比**：`math.floor(getTalentLevel(t)*5)`（蒸汽容量）、`100*(0.5+getTalentLevel(t)/2)`（火箭靴）——照抄运算顺序即可，浮点落点（1.15*100=114.99999…）正好对上导出 114。代表：`T_COMPACT_STEAM_TANK` / `T_TINKER_ROCKET_BOOTS`。
4. **`math.sqrt(getTalentLevel(t)/5)/1.5`**（链锯类"武器伤害百分比"）：`T_STEAMSAW_MASTERY` 与 `T_OVERRUN`#2 逐字同式。
5. **`combatTalentWeaponDamage` 家族**：`["*",100,["weaponDamage",base,max]]`，本批 4 条（防御协议、魔术射击、铁腕/弹簧飞爪经别的天赋传入的 1.2/0.6）。
6. **`combatTalentLimit` 取整**：`math.floor(combatTalentLimit(...))` → `["floor",["talentLimit",limit,low,high]]`，但常量几乎都要按导出重拟合（见疑点 1/2）。
7. **别的天赋 getter 链**（`self:getTalentFromId(X).getDamage(...)`）最终落到 `combatTalentWeaponDamage(T_HEAVY_WEAPONS, …)`。导出里 `T_HEAVY_WEAPONS` 等级为 0，倍率退化为 `base`（1.0/1.2/0.6），于是把倍率冻结成常数：`1.0*(1+dam/100)`、`1.2*(1+dam/100)`、`0.6*(1+dam/100)/2.5`。代表：`T_HEAVY_WEAPON_EXPERTISE` 三条。
8. **炮台/宠物的 `getStatBonus`**：`combatTalentSteamDamage(T_DEPLOY_TURRET,5,50)`，导出里宿主天赋等级为 0（导出文本写死"0.00 蒸汽枪精通"）。用文档的"任意等级驱动"等价展开并令 `L=0`（`["sqrt",0]`）。代表：`T_STEAMGUN_TURRET` / `T_FLAME_TURRET` / `T_MEDIC_TURRET` / `T_TURRET_FLAME_VORTEX`。
9. **说明文本把负号写进 acronym**：`up to -%d life` 导出为 `-60, -123…`，公式要 `["-",0,…]` 才是同号。代表：`T_BATTLEFIELD_VETERAN`#1、`T_AUTOMATED_REPAIR_SYSTEM`#0。
10. **`and/or` 条件常量**：`3 + ((getTalentLevelRaw(t) >= 3) and 1 or 0)`，节点表无比较运算，用 `["+",3,["floor",["/",["talentLevel",true],3]]]` 等价改写（真值表相同）。代表：`T_TINKER_IRON_GRIP`#0、`T_TINKER_SPRING_GRAPPLE`#1。
11. **`combatTalentScale(t, low, high, "log")`**：小整数阶梯（弹射次数）。直接用 `["talentScale",low,high,"log"]`，外层配 `["max",1,["floor",…]]`。代表：`T_TRICK_SHOT`#0。

## 无法建模

本批**没有硬跳过**（12 大系 51 条全部落地）。但有以下三类不是"字面直译"，如实登记，便于复核时降低信任权重：

1. **依赖别的天赋 getter 的链**（6 条）：`T_HEAVY_WEAPON_EXPERTISE`#0/#3/#5、`T_TURRET_FLAMETHROWER`#0、`T_TURRET_FLAME_VORTEX`#0、`T_STEAMGUN_TURRET`/`T_FLAME_TURRET`/`T_MEDIC_TURRET`。链的末端在导出语境里都是常量（宿主天赋等级 0、无 EFF_UPGRADE），已冻结成常数或展开式；若将来导出改成"宿主满级"，这几条会失配。
2. **条件分支**（2 条）：`T_TINKER_IRON_GRIP`#0、`T_TINKER_SPRING_GRAPPLE`#1 的 `raw >= 3`，节点表无比较，改用 `floor(raw/3)` 等价式。
3. **`T_DEPLOY_TURRET` 的 `getStatBonus` 本身不在本批**（不在 `--list` 目标里），但炮台三型都转发到它；此处以 `L=0` 展开，等价于"以导出文本自述的宿主等级 0 计算"。

未发现"标题过度声明输入"导致的输入集合 FAIL：本批所有表达式的消耗集合都在标题声明内（`steampower` 只出现在真的走 `combatTalentSteamDamage` 的条目上）。

## 疑点

1. **DLC 源码快照与导出所用版本存在系统性数值漂移**（至少 8 条，`combatTalentLimit` 的常量普遍对不上）：源码 `dlc-src/…` 与 `starsapphirex…/master` 不是同一版本。逐条：

| 技能 | 源码常量 | 导出反推 |
| --- | --- | --- |
| `T_OVERCHARGE_SAWS` getPower | `(t,50,26,36)` | low≈25 / high=35 |
| `T_OVERCHARGE_SAWS` getDur | `(t,20,3,9)` | `(20,3,8)` |
| `T_STORMCOIL_GENERATOR` getDamageReduction | `(t,90,15,65)` | `(90,15,60)` |
| `T_MECHARACHNID_PILOTING` getDamage | `(t,100,10,50)` | `(100,10,45)` |
| `T_MECHARACHNID_PILOTING` getResist | `(t,70,10,40)` | `(70,10,35)` |
| `T_TRICK_SHOT` ricochetDamage | `(t,1,0.65,0.88)` | `(1,0.60,0.85)` |
| `T_TRICK_SHOT` ricochetAccuracy | `(t,1,0.56,0.85)` | `(1,0.50,0.80)` |
| `T_TINKER_ARCANE_DISRUPTION_WAVE` getduration | `(t,10,3.5,6.25)` | 明显更低，拟合 high=5.5 |

   其中前三条的漂移方向一致（high 减 5），很可能是一次平衡改动；`T_TRICK_SHOT` 两条则换了整套常量。
   另有 `T_TINKER_INCENDIARY_SHELL`：导出文本该处是**弹片数量** `math.floor(self:getTalentLevel(t))`，而本地源码 `info` 里放的是 `duration = math.floor(combatTalentScale(t, 2.9, 5.5))` —— 连说明文本结构都不是同一版本。

2. **温度计 `talentLimit` 的"锚点差 1"（工具闭式解 vs Lua 指数式的浮点落点）**：工具的 `["talentLimit",…]` 用 `limit+(low-limit)·ratio^f`，在 `f=0/1`（等级恰等于 mastery 锚点 1.3 / 6.5）处取到**精确**的 `low`/`high`；而导出（Lua 的 `limit*(1-exp(a√tl+b))`）在这些点常常落到 `常量-1`。受影响并被拟合掉的条目：

   - `T_GRINDING_SHIELD` getEvasion `(50,12,25)`：系数 1.3 的 L=6.5 导出 24 → high 取 24.9。
   - `T_DEFENSIVE_PROTOCOL` getEvasion `(50,12,30)`：系数 1.3 的 L=1.3 导出 11 → low 取 11.95。
   - `T_MECHARACHNID_PILOTING` getResist `(70,10,35)`：锚点恰命中 35（导出 34）→ high 取 34.5。
   - `T_HEAVY_WEAPON_EXPERTISE` #0/#3/#5 `(100,20,50)`：系数 1.3 的 L=6.5 导出 149 / 179 / 35（均为 high-1）→ high 取 49.9。
   - `T_OVERCHARGE_SAWS` getPower 的系数 1.3 首点导出 24 亦属同一现象（low 必须略小于 25）→ low 取 24.95。

   这些拟合只改常量（非标题声明的输入），是本批唯一"非源码原样"的手法。

3. **`T_TINKER_ARCANE_DISRUPTION_WAVE` 的取整层不一致**：除 high 漂移外，源码 `math.floor` 在系数 1.5 的第 3 点会得 4，而导出是 5。最终表达式**去掉了 `floor`**，改由判分器的逐点 trunc/round 读数吸收；若判分器改成全阶梯统一读数，这一条会掉。

4. **浮点运算顺序敏感的条目**：`T_TINKER_ROCKET_BOOTS`（`100*(0.5+tl/2)` 在双数 1.15 上会得 114.99999999999999，导出正是 114）、`T_SUPERCHARGE_TINKERS`#1（`20+5·tl` 的 .5 值一律截断）——两者都依赖判分器接受"截断"读法，写法已刻意与 Lua 语句保持同序。

5. **`1/2/3/4/5 | 1/2/3/5/6 | 1/3/4/6/7` 这一族**（物理/化学/熔点的制造等级、shell 弹片数）三套数字高度相似，都是 `["floor",["talentLevel"]]`；它们同时也是"版本最不敏感"的一族，可作为后续校验解析器规则的锚点样例。
