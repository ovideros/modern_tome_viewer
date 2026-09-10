# 覆盖层审计报告 · 超集清单 A（50 条）

范围：`.snapshots/audit-superset-A.json` 的全部 50 条。每条审查「标题声明了、但公式没读」的标签
（`unused`），逐个回到 `source` 指向的 `newTalent{...}` 块，按 `info` 里 `tformat(...)` 的实参顺序
（导出侧的中文 tooltip 会重排 acronym，故以 `--talent`/导出数据里该 acronym 的实际读数为准）
找出**真正喂给这个 acronym 的 getter**，再判断该 getter 是否真的使用那个标签。

判定口径：`--overlay` 只要求 `表达式消耗 ⊆ 标题声明`，所以这 50 条**本来就是全 PASS 的**。
本报告回答的是更细的问题：**它是「标题过度声明」还是「公式漏读」**。判据只有一条——
「把该输入从导出钉死的基准值挪开，这个值会不会跟着动」。导出把 `paradox` 钉在 300
（`pmod(300)=1.000`）、把 `灵巧`/`力量`/… 钉在 100，所以漏读的公式在 15 个点上和正确的公式
**数值完全相同**，判分器分不出来。

## 汇总

| 项 | 数 |
| --- | --- |
| 审计条目 | 50 |
| 判定「源码真用未读标签」 | **8** |
| 判定「导出过度声明，公式正确」 | **42** |
| 处置「改」 | **8** |
| 未能判定 | **0** |

改动文件（只动清单里的条目，且只写盘这两个文件）：

- `modern_tome_viewer/data/overlay-batches/batch16-chronomancy.json`（7 条）
- `modern_tome_viewer/data/overlay-batches/spell__other.json`（1 条）

## 两类漏读

### 1) `getExtensionModifier`（7 条 · 全是 `paradox`）

`tome-src-full/data/talents/chronomancy/chronomancer.lua:187`：

```lua
getExtensionModifier = function(self, t, value)
	local pm = getParadoxModifier(self)          -- paradox 300 -> 1.000
	local mod = 1                                -- T_EXTENSION 未激活
	...
	value = math.floor(value * pm)               -- 下取整
	value = math.ceil(value * mod)
	return math.max(1, value)
end
```

`getDuration = getExtensionModifier(self, t, X)` 的 getter 真的乘 `pmod`。原式只留下了最外层
`["max",1,…]`（对应 `return math.max(1, value)`），原 note 里普遍写着「pm=1」——那正是
**导出把 paradox 钉在 300** 造成的假象。统一改成（`X` 为源码实参自身的模型）：

```
["max",1,["floor",["*", X, ["pmod",["actor","paradox"]]]]]
```

这与主项目已修好的 `T_TEMPORAL_REPRIEVE` / `T_STOP#2` / `T_PHASE_PULSE#2` 写法一致。
后果演示（`T_BREACH#1`）：paradox 300 → 675 时 `pmod` 1.000 → 1.5，持续时间本该
3/5/6/7/8 → 4/7/9/10/12（长 50%），原式纹丝不动。

### 2) `getCun(15, true)`（1 条 · `T_AMBUSCADE#3`）

`tome-src-full/data/talents/misc/npcs.lua:3538`：

```lua
getStealthPower = function(self, t)
	return self:combatScale(self:getCun(15, true) * self:getTalentLevel(t), 25, 0, 100, 75)
end,
```

`getCun(mult, raw)` 的 `raw=true` 只表示「取基准属性（忽略临时加成）」，`mult` 仍是百分比：
`Combat.lua:1377` 用 `getCun(100, true)` 取满值属性，故 `getCun(15, true) = 灵巧 × 0.15`。
原式把 100×0.15 的结果**冻结成常数 15**（原 note 还声称「写成 `["actor","灵巧"]` 会让 15 点全错」），
导出把 灵巧 钉在 100 上所以两者同分。已补 `["*",0.15,["actor","灵巧"]]`。

## 逐条判定

`源码是否真用` 一列同时给出真用的那个 getter（括号内）。`新表达式` 只在「改」时给出。

| 技能id#acronym | 未读标签 | 源码是否真用 | 处置 | 新表达式 |
| --- | --- | --- | --- | --- |
| `T_AMBUSCADE#1` | 灵巧 | 否（getHealth = combatLimit(combatTalentSpellDamage(t,20,500),…) 只吃 法术强度） | 不改 | — |
| `T_AMBUSCADE#2` | 灵巧 | 否（getDam = combatLimit(combatTalentSpellDamage(t,10,500),…) 只吃 法术强度） | 不改 | — |
| `T_AMBUSCADE#3` | 法术强度, 灵巧 | **是·灵巧**（getStealthPower = combatScale(getCun(15,true)·tl, 25,0,100,75)）；法术强度否 | **改** | `["combatScale",["*",["*",0.15,["actor","灵巧"]],["talentLevel"]],25,0,100,75]` |
| `T_ARCANE_DESTRUCTION#1` | 法术强度 | 否（getMag()·getSPMult，getSPMult = combatTalentScale(t,1/7,5/7)） | 不改 | — |
| `T_ASHES_TO_ASHES#2` | paradox | 否（getDuration = 5 + ceil(getTalentLevel(t))） | 不改 | — |
| `T_AUGMENTATION#1` | 灵巧 | 否（str_power = ceil(getMult·getWil())） | 不改 | — |
| `T_AUGMENTATION#2` | 意志 | 否（dex_power = ceil(getMult·getCun())） | 不改 | — |
| `T_BANISH#0` | paradox | 否（getTeleport = floor(combatTalentScale(t,8,16))） | 不改 | — |
| `T_BANISH#1` | paradox | 否（同上，getTeleport 的整个值） | 不改 | — |
| `T_BERSERKER#0` | 力量 | 否（getAtk = combatScale(getDex(7,true)·tl, 5,0,40,35)） | 不改 | — |
| `T_BERSERKER#1` | 敏捷 | 否（getDam = combatScale(getStr(7,true)·tl, 5,0,40,35)） | 不改 | — |
| `T_BERSERKER_RAGE#0` | 力量 | 否（getAtk = combatScale(getDex(7,true)·tl, …)） | 不改 | — |
| `T_BERSERKER_RAGE#1` | 敏捷 | 否（getDam = combatScale(getStr(7,true)·tl, …)） | 不改 | — |
| `T_BOULDER_ROCK#0` | 力量 | 否（getDam = 5 + combatTalentSpellDamage(t,10,250)/10，只吃 法术强度；即文档已记的元数据缺陷） | 不改 | — |
| `T_BOULDER_ROCK#3` | 法术强度 | 否（嵌套 T_THROW_BOULDER.getDam = combatScale(getStr()·getTalentLevel(t), 12,0,262,500)） | 不改 | — |
| `T_BRAID_LIFELINES#0` | paradox | **是**（getDuration = getExtensionModifier(self,t,floor(combatTalentScale(t,3,7)))） | **改** | `["max",1,["floor",["*",["floor",["combatScale",["talentLevel"],3,1,7,5]],["pmod",["actor","paradox"]]]]]` |
| `T_BREACH#1` | paradox | **是**（getDuration = getExtensionModifier(self,t,floor(combatTalentScale(t,3,7)))） | **改** | `["max",1,["floor",["*",["floor",["combatScale",["talentLevel"],3,1,7,5]],["pmod",["actor","paradox"]]]]]` |
| `T_CALL_OF_THE_OOZE#0` | 灵巧 | 否（getLife = callTalent(T_MITOSIS,"getMaxHP")·getModHP；getMaxHP 只吃 精神强度+max_life） | 不改 | — |
| `T_CELERITY#1` | paradox | **是**（getDuration = getExtensionModifier(self,t,floor(combatTalentScale(t,1,2)))） | **改** | `["max",1,["floor",["*",["floor",["combatScale",["talentLevel"],1,1,2,5]],["pmod",["actor","paradox"]]]]]` |
| `T_CHARGE_LEECH#0` | psi | 否（radius = floor(combatTalentScale(t,1,4))） | 不改 | — |
| `T_CHARGE_LEECH#2` | psi | 否（getDam(self,t,0)：info 显式传 psi=0，Lua 中 0 为真值，因子 max(0.5,1.5−0/100)=1.5 是常量） | 不改 | — |
| `T_CHARGE_LEECH#4` | psi | 否（getDaze(self,t,0)，同上因子冻结 1.5） | 不改 | — |
| `T_CHARGE_LEECH#6` | psi | 否（getLeech(self,t,0)，同上因子冻结 1.5） | 不改 | — |
| `T_CHRONO_TIME_SHIELD#1` | paradox | **是**（getDuration = getExtensionModifier(self,t,bound(5+floor(getTalentLevel(t)),5,15))） | **改** | `["max",1,["floor",["*",["min",15,["max",5,["+",5,["floor",["talentLevel"]]]]],["pmod",["actor","paradox"]]]]]` |
| `T_CHRONO_TIME_SHIELD#2` | paradox | 否（getTimeReduction = 25 + bound(15+floor(getTalentLevel(t)·2), 15, 35)） | 不改 | — |
| `T_DAMAGE_SMEARING#0` | paradox | 否（getPercent = combatTalentLimit(t,50,10,30)/100） | 不改 | — |
| `T_DEFENSIVE_THROW#0` | physical power, 力量, 敏捷 | 否；真用 **灵巧**（getchance = combatLimit(tl·(5+getCun(5,true)),100,0,0,50,50)） | 不改 | — |
| `T_DEFENSIVE_THROW#1` | 力量, 敏捷, 灵巧 | 否；真用 **physical power**（getDamage = combatTalentPhysicalDamage(t,5,50)·getUnarmedTrainingBonus） | 不改 | — |
| `T_DEFENSIVE_THROW#2` | 力量, 敏捷, 灵巧 | 否；真用 **physical power**（getDamageTwo = combatTalentPhysicalDamage(t,10,75)·…） | 不改 | — |
| `T_DUAL_WEAPON_MASTERY#2` | 灵巧 | 否；真用 **敏捷**（getDeflectChance = min(100, combatLimit(tl·getDex(),90,15,20,60,250))） | 不改 | — |
| `T_ENTROPY#0` | paradox | **是**（getDuration = getExtensionModifier(self,t,floor(combatTalentScale(t,1,7)))） | **改** | `["max",1,["floor",["*",["floor",["max",0,["+",["*",["/",6,["-",["sqrt",5],1]],["sqrt",["talentLevel"]]],["-",1,["/",6,["-",["sqrt",5],1]]]]]],["pmod",["actor","paradox"]]]]]` |
| `T_FOLD_FATE#0` | paradox | 否（getChance = callTalent(T_WEAPON_MANIFOLD,"getChance") = combatTalentLimit(t,40,10,30)） | 不改 | — |
| `T_FOLD_FATE#1` | paradox | 否（radius = getTalentLevel(T_WEAPON_MANIFOLD)>=4 and 2 or 1） | 不改 | — |
| `T_FOLD_GRAVITY#0` | paradox | 否（同 T_FOLD_FATE#0） | 不改 | — |
| `T_FOLD_GRAVITY#1` | paradox | 否（同 T_FOLD_FATE#1） | 不改 | — |
| `T_FOLD_WARP#0` | paradox | 否（同 T_FOLD_FATE#0） | 不改 | — |
| `T_FOLD_WARP#1` | paradox | 否（同 T_FOLD_FATE#1） | 不改 | — |
| `T_GLYPH_OF_REPULSION#1` | 法术强度 | 否；真用 **魔力**（trapPower·0.8 = max(1,combatScale(tl·getMag(15,true),0,0,75,75))·0.8） | 不改 | — |
| `T_GLYPH_OF_REPULSION#2` | 法术强度 | 否；真用 **魔力**（trapPower 本体） | 不改 | — |
| `T_GRAVITY_WELL#0` | paradox | **是**（getDuration = getExtensionModifier(self,t,floor(combatTalentScale(t,4,8)))） | **改** | `["max",1,["floor",["*",["floor",["combatScale",["talentLevel"],4,1,8,5]],["pmod",["actor","paradox"]]]]]` |
| `T_INVIGORATE#0` | paradox | **是**（getDuration = getExtensionModifier(self,t,floor(combatTalentLimit(t,14,4,8)))） | **改** | `["max",1,["floor",["*",["floor",["*",14,["-",1,["exp",["+",["*",["sqrt",["talentLevel"]],-0.3624587951042149],0.07679437416765682]]]]],["pmod",["actor","paradox"]]]]]` |
| `T_KINETIC_LEECH#0` | psi | 否（radius = floor(combatTalentScale(t,1,4))） | 不改 | — |
| `T_KINETIC_LEECH#2` | psi | 否（getSlow(self,t,0)：因子 max(0.5,1.5−0/100)=1.5 常量） | 不改 | — |
| `T_KINETIC_LEECH#4` | psi | 否（getDam(self,t,0)：因子 1.5 常量） | 不改 | — |
| `T_KINETIC_LEECH#6` | psi | 否（getLeech(self,t,0)：因子 1.5 常量） | 不改 | — |
| `T_LAST_STAND#1` | 敏捷 | 否（lifebonus = combatTalentStatDamage(t,"con",30,500) + max_life·combatTalentLimit(t,1,0.02,0.10)；敏捷只被 getDefense/getArmor 用） | 不改 | — |
| `T_LAST_STAND#2` | 敏捷 | 否（同上，info 里取负） | 不改 | — |
| `T_MITOSIS#0` | 灵巧 | 否（getMaxHP = 50 + combatTalentMindDamage(t,30,250) + max_life·combatTalentLimit(t,0.25,.035,.125)；灵巧只被 getChance/combatTalentStatDamage("cun") 用） | 不改 | — |
| `T_NULLMAIL#0` | 法术强度 | 否；真用 **魔力**（getArmor = combatTalentStatDamage(t,"mag",10,50)·ArmorEffect） | 不改 | — |
| `T_NULLMAIL#1` | 魔力 | 否；真用 **法术强度**（getAbsorb = (50+combatTalentSpellDamage(t,30,200))·ArmorEffect） | 不改 | — |

## 未能判定

无（0 条）。50 条都能定位到唯一的 getter：

- 30 条是 `info` 里 `tformat` 的**直接实参**，getter 一眼可读；
- `T_BOULDER_ROCK#3` 经 `getTalentFullDescription(T_THROW_BOULDER, getTalentLevelRaw(t)*2)` 嵌套，
  已顺到 `npcs.lua:1167` 的 `getDam`；
- `T_CALL_OF_THE_OOZE#0` 经 `callTalent(T_MITOSIS,"getMaxHP")`、`T_FOLD_*#0` 经
  `callTalent(T_WEAPON_MANIFOLD,"getChance")`，均已顺到被调 getter；
- `T_BANISH#0/#1`、`T_CHRONO_TIME_SHIELD#2`、`T_FOLD_*#1` 等的 acronym 归属，用导出里该 acronym 的
  实际读数（如 `T_BANISH#0=4,6,7,8,9` 恰为 `getTeleport/2`）回验过。

三处**当时**看似可疑、复核后各有结论：

1. `T_AMBUSCADE#3` 原 note 断言「写成 `["actor","灵巧"]` 会让 15 点全错」——实测
   `["*",0.15,["actor","灵巧"]]` 在 灵巧=100 时给 15，三套 15 点全中，原 note 是误判，
   已按**真用**改；
2. `psi` 的「max 档」条目（`getDam(self,t,0)` 等）：Lua 里 `0` 为真值，`psi or self:getPsi()`
   返回 0，因子恒为 1.5，与标题钉死的 `psi 50%` **无关**，冻结 1.5 是对的，不改；
3. `T_BOULDER_ROCK#0`：`tformat` 的 `力量` 是整份 tooltip 的参数并集，`getDam` 只用 法术强度，
   属文档已记录的「标题过度声明输入」元数据缺陷，不改。

## 收尾自检

```
$ node scripts/try-formula.mjs --overlay data/overlay-batches/spell__other.json
覆盖层校验：13/13 通过
$ node scripts/try-formula.mjs --overlay data/overlay-batches/batch16-chronomancy.json
覆盖层校验：47/47 通过
```

两个文件的「通过数 == 数组长度」，无条目因本次改动被丢弃。
