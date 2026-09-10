# batch14 · cunning 大系公式覆盖报告

- 范围（只做这 10 个大系）：`cunning/trapping`、`cunning/poisons-effects`、`cunning/poisons`、`cunning/survival`、
  `cunning/stealth`、`cunning/tools`、`cunning/called-shots`、`cunning/shadow-magic`、`cunning/tactical`、`cunning/dirty`
- 覆盖层：`data/overlay-batches/batch14-cunning.json`（51 条）
- 汇总：`node scripts/try-formula.mjs --overlay data/overlay-batches/batch14-cunning.json` → **覆盖层校验：51/51 通过**
- 目标 52 条 → PASS 51、跳过 1（`T_TWIST_THE_KNIFE` #2，见「疑点」）

各大系：目标数 / PASS 数 / 跳过数

| 大系 | 目标 | PASS | 跳过 |
| --- | --- | --- | --- |
| cunning/trapping | 12 | 12 | 0 |
| cunning/poisons-effects | 10 | 10 | 0 |
| cunning/poisons | 8 | 8 | 0 |
| cunning/survival | 6 | 6 | 0 |
| cunning/stealth | 5 | 5 | 0 |
| cunning/tools | 3 | 3 | 0 |
| cunning/called-shots | 3 | 3 | 0 |
| cunning/shadow-magic | 2 | 2 | 0 |
| cunning/tactical | 2 | 2 | 0 |
| cunning/dirty | 1 | 0 | 1 |
| 合计 | 52 | 51 | 1 |

## 一、已完成

每条都跑出「结论：PASS（三套 15 点全中，输入集合覆盖）」；下表 `source` 指向据以写公式的 getter/打印点。

| 技能 | acronym# | 名称 | 大系 | 表达式 | source | 三套 |
| --- | --- | --- | --- | --- | --- | --- |
| `T_TRAP_MASTERY` | 0 | 陷阱专精 | cunning/trapping | `["min",3,["max",1,["talentLevel",true]]]` | `tome-src-full/data/talents/cunning/traps.lua:566` | 15/15 |
| `T_TRAP_MASTERY` | 1 | 陷阱专精 | cunning/trapping | `["min",5,["talentLevel",true]]` | `tome-src-full/data/talents/cunning/traps.lua:665` | 15/15 |
| `T_TRAP_MASTERY` | 2 | 陷阱专精 | cunning/trapping | `["max",1,["combatScale",["*",["talentLevel"],["*",["actor","灵巧"],0.25]],10,3.75,75,125,0.25]]` | `tome-src-full/data/talents/cunning/traps.lua:73` | 15/15 |
| `T_TRAP_MASTERY` | 3 | 陷阱专精 | cunning/trapping | `["*",1.25,["max",1,["combatScale",["*",["talentLevel"],["*",["actor","灵巧"],0.25]],10,3.75,75,125,0.25]]]` | `tome-src-full/data/talents/cunning/traps.lua:636` | 15/15 |
| `T_TRAP_MASTERY` | 4 | 陷阱专精 | cunning/trapping | `["talentScale",25,100]` | `tome-src-full/data/talents/cunning/traps.lua:564` | 15/15 |
| `T_TRAP_MASTERY` | 5 | 陷阱专精 | cunning/trapping | `["min",100,["max",0,["*",10,["*",["+",1,["/",["talentScale",25,100],100]],["statScale","cun",1,5]]]]]` | `tome-src-full/data/talents/cunning/traps.lua:102` | 15/15 |
| `T_TRAP_MASTERY` | 6 | 陷阱专精 | cunning/trapping | `["floor",["talentScale",9,13]]` | `tome-src-full/data/talents/cunning/traps.lua:567` | 15/15 |
| `T_LURE` | 0 | 诱饵 | cunning/trapping | `["floor",["talentScale",4,8]]` | `tome-src-full/data/talents/gifts/summon-utility.lua:28` | 15/15 |
| `T_TRAP_LAUNCHER` | 1 | 高级陷阱放置 | cunning/trapping | `["min",25,["talentLevel"]]` | `tome-src-full/data/talents/cunning/traps.lua:763` | 15/15 |
| `T_TRAP_PRIMING` | 0 | 即爆陷阱 | cunning/trapping | `["talentLevel",true]` | `tome-src-full/data/talents/cunning/traps.lua:850` | 15/15 |
| `T_TRAP_PRIMING` | 1 | 即爆陷阱 | cunning/trapping | `["+",["*",38.83281572999747,["sqrt",["talentLevel"]]],-26.83281572999747]` | `tome-src-full/data/talents/cunning/traps.lua:777` | 15/15 |
| `T_TRAP_PRIMING` | 2 | 即爆陷阱 | cunning/trapping | `["min",100,["max",0,["*",10,["*",["+",1,["/",["talentScale",12,60],100]],["statScale","cun",1,5]]]]]` | `tome-src-full/data/talents/cunning/traps.lua:102` | 15/15 |
| `T_NUMBING_POISON` | 0 | 麻痹毒素 | cunning/poisons-effects | `["*",35,["-",1,["exp",["+",["*",["sqrt",["*",["actor","邪恶毒素 技能等级"],["talentLevel"]]],-0.4918259386509031],0.001152060740653239]]]]` | `tome-src-full/data/talents/cunning/poisons.lua:417` | 15/15 |
| `T_INSIDIOUS_POISON` | 0 | 阴险毒素 | cunning/poisons-effects | `["*",150,["-",1,["exp",["+",["*",["sqrt",["*",["actor","邪恶毒素 技能等级"],["talentLevel"]]],-0.20412620765814088],-0.17272542251766873]]]]` | `tome-src-full/data/talents/cunning/poisons.lua:449` | 15/15 |
| `T_CRIPPLING_POISON` | 0 | 致残毒素 | cunning/poisons-effects | `["*",35,["-",1,["exp",["+",["*",["sqrt",["*",["actor","邪恶毒素 技能等级"],["talentLevel"]]],-0.4918259386509031],0.001152060740653239]]]]` | `tome-src-full/data/talents/cunning/poisons.lua:481` | 15/15 |
| `T_LEECHING_POISON` | 0 | 吸血毒素 | cunning/poisons-effects | `["*",100,["-",1,["exp",["+",["*",["sqrt",["*",["actor","邪恶毒素 技能等级"],["talentLevel"]]],-0.22164697049986795],0.05426549008778476]]]]` | `tome-src-full/data/talents/cunning/poisons.lua:513` | 15/15 |
| `T_VOLATILE_POISON` | 0 | 传染毒素 | cunning/poisons-effects | `["*",100,["-",1,["exp",["+",["*",["sqrt",["*",["actor","邪恶毒素 技能等级"],["talentLevel"]]],-0.31552897794373086],0.11129702725959031]]]]` | `tome-src-full/data/talents/cunning/poisons.lua:550` | 15/15 |
| `T_STONING_POISON` | 0 | 石化毒素 | cunning/poisons-effects | `["+",8,["*",0.4,["*",["*",["+",10,["actor","灵巧"]],["*",["+",1,["*",0.8,["-",["sqrt",["*",["actor","邪恶毒素 技能等级"],["talentLevel"]]],1]]],["/",30,["*",["+",10,100],1.9888543819998319]]]],["-",1,["/",["log10",["*",2,["*",["+",10,["actor","灵巧"]],["*",["+",1,["*",0.8,["-",["sqrt",["*",["actor","邪恶毒素 技能等级"],["talentLevel"]]],1]]],["/",30,["*",["+",10,100],1.9888543819998319]]]]]],7]]]]]` | `tome-src-full/data/talents/cunning/poisons.lua:610` | 15/15 |
| `T_STONING_POISON` | 1 | 石化毒素 | cunning/poisons-effects | `["*",4,["+",8,["*",0.4,["*",["*",["+",10,["actor","灵巧"]],["*",["+",1,["*",0.8,["-",["sqrt",["*",["actor","邪恶毒素 技能等级"],["talentLevel"]]],1]]],["/",30,["*",["+",10,100],1.9888543819998319]]]],["-",1,["/",["log10",["*",2,["*",["+",10,["actor","灵巧"]],["*",["+",1,["*",0.8,["-",["sqrt",["*",["actor","邪恶毒素 技能等级"],["talentLevel"]]],1]]],["/",30,["*",["+",10,100],1.9888543819998319]]]]]],7]]]]]]` | `tome-src-full/data/talents/cunning/poisons.lua:639` | 15/15 |
| `T_STONING_POISON` | 2 | 石化毒素 | cunning/poisons-effects | `["floor",["combatScale",["*",["actor","邪恶毒素 技能等级"],["talentLevel"]],6,1,8,5,0.5]]` | `tome-src-full/data/talents/cunning/poisons.lua:609` | 15/15 |
| `T_STONING_POISON` | 3 | 石化毒素 | cunning/poisons-effects | `["ceil",["-",7,["*",["-",7,1],["-",1,["exp",["+",["*",["sqrt",["*",["actor","邪恶毒素 技能等级"],["talentLevel"]]],-1.2713516082945684],1.449563860437732]]]]]]` | `tome-src-full/data/talents/cunning/poisons.lua:611` | 15/15 |
| `T_STONING_POISON` | 4 | 石化毒素 | cunning/poisons-effects | `["floor",["combatScale",["*",["actor","邪恶毒素 技能等级"],["talentLevel"]],3,1,4,5,0.5]]` | `tome-src-full/data/talents/cunning/poisons.lua:612` | 15/15 |
| `T_VILE_POISONS` | 0 | 邪恶毒素 | cunning/poisons | `["*",20,["talentLevel"]]` | `tome-src-full/data/talents/cunning/poisons.lua:285` | 15/15 |
| `T_VENOMOUS_STRIKE` | 1 | 毒素爆发 | cunning/poisons | `["talentLimit",50,20,35]` | `tome-src-full/data/talents/cunning/poisons.lua:303` | 15/15 |
| `T_VENOMOUS_STRIKE` | 2 | 毒素爆发 | cunning/poisons | `["statDamage","cun",50,550]` | `tome-src-full/data/talents/cunning/poisons.lua:301` | 15/15 |
| `T_VENOMOUS_STRIKE` | 3 | 毒素爆发 | cunning/poisons | `["floor",["talentScale",1,4,"log"]]` | `tome-src-full/data/talents/cunning/poisons.lua:302` | 15/15 |
| `T_VENOMOUS_STRIKE` | 4 | 毒素爆发 | cunning/poisons | `["floor",["*",1.5,["floor",["talentScale",1,4,"log"]]]]` | `tome-src-full/data/talents/cunning/poisons.lua:384` | 15/15 |
| `T_VENOMOUS_STRIKE` | 5 | 毒素爆发 | cunning/poisons | `["statDamage","cun",50,550]` | `tome-src-full/data/talents/cunning/poisons.lua:376` | 15/15 |
| `T_VENOMOUS_STRIKE` | 6 | 毒素爆发 | cunning/poisons | `["*",0.6,["statDamage","cun",50,550]]` | `tome-src-full/data/talents/cunning/poisons.lua:377` | 15/15 |
| `T_VENOMOUS_STRIKE` | 7 | 毒素爆发 | cunning/poisons | `["floor",["talentScale",1,4,"log"]]` | `tome-src-full/data/talents/cunning/poisons.lua:384` | 15/15 |
| `T_HEIGHTENED_SENSES` | 1 | 强化感知 | cunning/survival | `["max",0,["combatScale",["*",["talentLevel"],["*",["actor","灵巧"],0.15]],10,1,80,75,0.25]]` | `tome-src-full/data/talents/cunning/survival.lua:28` | 15/15 |
| `T_HEIGHTENED_SENSES` | 2 | 强化感知 | cunning/survival | `["max",0,["combatScale",["*",["talentLevel"],["*",["actor","灵巧"],0.25]],10,3.75,75,125,0.25]]` | `tome-src-full/data/talents/cunning/survival.lua:29` | 15/15 |
| `T_DEVICE_MASTERY` | 1 | 装置掌握 | cunning/survival | `["max",0,["combatScale",["*",["talentLevel"],["*",["actor","灵巧"],0.25]],10,3.75,90,125,0.25]]` | `tome-src-full/data/talents/cunning/survival.lua:66` | 15/15 |
| `T_TRACK` | 0 | 追踪 | cunning/survival | `["floor",["combatScale",["*",["talentLevel"],["*",["actor","灵巧"],0.1]],5,0,35,55]]` | `tome-src-full/data/talents/cunning/survival.lua:84` | 15/15 |
| `T_DANGER_SENSE` | 0 | 危机感知 | cunning/survival | `["max",0,["combatScale",["*",["talentLevel"],["*",["actor","灵巧"],0.25]],5,3.75,35,125,0.25]]` | `tome-src-full/data/talents/cunning/survival.lua:110` | 15/15 |
| `T_DANGER_SENSE` | 3 | 危机感知 | cunning/survival | `["-",0,["combatLimit",["*",["talentLevel"],["*",["actor","灵巧"],0.25]],5,20,0,10,125]]` | `tome-src-full/data/talents/cunning/survival.lua:113` | 15/15 |
| `T_STEALTH` | 0 | 潜行 | cunning/stealth | `["max",0,["floor",["combatScale",["*",["talentLevel"],["*",["actor","灵巧"],0.1]],15,1,64,50,0.25]]]` | `tome-src-full/data/talents/cunning/stealth.lua:61` | 15/15 |
| `T_STEALTH` | 1 | 潜行 | cunning/stealth | `["ceil",["-",8.5,["*",["-",8.5,0],["-",1,["exp",["+",["*",["sqrt",["talentLevel"]],-0.5348424326459262],0.6098141980031261]]]]]]` | `tome-src-full/data/talents/cunning/stealth.lua:42` | 15/15 |
| `T_SHADOWSTRIKE` | 1 | 影袭 | cunning/stealth | `["+",3,["min",1,["floor",["/",["talentLevel"],3]]]]` | `tome-src-full/data/talents/cunning/stealth.lua:164` | 15/15 |
| `T_SOOTHING_DARKNESS` | 0 | 黑暗亲和 | cunning/stealth | `["floor",["*",10,["-",1,["exp",["+",["*",["sqrt",["talentLevel"]],-0.33349335120482915],0.15709737216349257]]]]]` | `tome-src-full/data/talents/cunning/stealth.lua:187` | 15/15 |
| `T_SOOTHING_DARKNESS` | 3 | 黑暗亲和 | cunning/stealth | `["+",3,["min",1,["floor",["/",["talentLevel"],3]]]]` | `tome-src-full/data/talents/cunning/stealth.lua:191` | 15/15 |
| `T_SMOKESCREEN_MASTERY` | 0 | 强化烟雾弹 | cunning/tools | `["+",30,["*",["*",["+",10,["actor","灵巧"]],["*",["+",1,["*",0.8,["-",["sqrt",0],1]]],["/",150,["*",["+",10,100],1.9888543819998319]]]],["-",1,["/",["log10",["*",2,["*",["+",10,["actor","灵巧"]],["*",["+",1,["*",0.8,["-",["sqrt",0],1]]],["/",150,["*",["+",10,100],1.9888543819998319]]]]]],7]]]]` | `tome-src-full/data/talents/cunning/artifice.lua:594` | 15/15 |
| `T_GRAPPLING_HOOK_MASTERY` | 0 | 钩爪强化 | cunning/tools | `["+",30,["*",["*",["+",15,["actor","灵巧"]],["*",["+",1,["*",0.8,["-",["sqrt",0],1]]],["/",200,["*",["+",15,100],1.9888543819998319]]]],["-",1,["/",["log10",["*",2,["*",["+",15,["actor","灵巧"]],["*",["+",1,["*",0.8,["-",["sqrt",0],1]]],["/",200,["*",["+",15,100],1.9888543819998319]]]]]],7]]]]` | `tome-src-full/data/talents/cunning/artifice.lua:814` | 15/15 |
| `T_GRAPPLING_HOOK_MASTERY` | 1 | 钩爪强化 | cunning/tools | `["+",30,["*",["*",["+",15,["actor","灵巧"]],["*",["+",1,["*",0.8,["-",["sqrt",0],1]]],["/",200,["*",["+",15,100],1.9888543819998319]]]],["-",1,["/",["log10",["*",2,["*",["+",15,["actor","灵巧"]],["*",["+",1,["*",0.8,["-",["sqrt",0],1]]],["/",200,["*",["+",15,100],1.9888543819998319]]]]]],7]]]]` | `tome-src-full/data/talents/cunning/artifice.lua:814` | 15/15 |
| `T_SKIRMISHER_SLING_SNIPER` | 0 | 投石大师 | cunning/called-shots | `["talentScale",3,10]` | `tome-src-full/data/talents/cunning/called-shots.lua:23` | 15/15 |
| `T_SKIRMISHER_SLING_SNIPER` | 1 | 投石大师 | cunning/called-shots | `["*",100,["talentScale",0.1,0.2,0.75]]` | `tome-src-full/data/talents/cunning/called-shots.lua:24` | 15/15 |
| `T_SKIRMISHER_SLING_SNIPER` | 2 | 投石大师 | cunning/called-shots | `["*",100,["-",1,["exp",["+",["*",["^",["actor","灵巧"],0.75],["/",["log",["/",["-",50,100],["-",15,100]]],["-",31.623,5.6234]]],["/",["-",["*",31.623,["log",["/",["-",50,100],["-",15,100]]]],["*",["-",31.623,5.6234],["log",["-",1,["/",50,100]]]]],["-",5.6234,31.623]]]]]]` | `tome-src-full/data/talents/cunning/called-shots.lua:27` | 15/15 |
| `T_SHADOW_CUNNING` | 1 | 影之狡诈 | cunning/shadow-magic | `["*",["actor","灵巧"],["/",["talentScale",20,40,0.75],100]]` | `tome-src-full/data/talents/cunning/shadow-magic.lua:68` | 15/15 |
| `T_SHADOWSTEP` | 0 | 暗影突袭 | cunning/shadow-magic | `["min",5,["+",2,["ceil",["/",["talentLevel"],2]]]]` | `tome-src-full/data/talents/cunning/shadow-magic.lua:124` | 15/15 |
| `T_COUNTER_ATTACK` | 0 | 闪躲反击 | cunning/tactical | `["combatLimit",["*",["talentLevel"],["+",5,["*",["actor","灵巧"],0.05]]],100,0,0,50,50]` | `tome-src-full/data/talents/cunning/tactical.lua:73` | 15/15 |
| `T_COUNTER_ATTACK` | 1 | 闪躲反击 | cunning/tactical | `["*",100,["weaponDamage",0.5,0.9]]` | `tome-src-full/data/talents/cunning/tactical.lua:72` | 15/15 |

## 二、发现的写法模式

1. **「另一个技能的等级」当驱动量**（`self:getTalentLevel(self.T_X)` / `getTalentLevelRaw(其他技能)`）。
   标题把它声明成独立参数（如 `邪恶毒素 技能等级`），轴就是它；表达式写
   `["*",["actor","邪恶毒素 技能等级"],["talentLevel"]]` 还原「该技能有效等级 = 槽位原始等级 × 技能系数」。
   代表：`T_NUMBING_POISON` #0（`poisons.lua:417`）。注意 `defaultSimParams` 只把「技能等级」以外的参数塞进
   `stats`，所以 `["talentLevel"]` 在这里只贡献系数，等级本体必须走 `["actor",…]`。
2. **`getCun(n, true)` = 属性 × n/100**，写作 `["*",["actor","灵巧"],n/100]`；`combatScale(等级*getCun(25,true), …)`
   是陷阱/侦测家族（陷阱专精、强化感知、装置掌握、危机感知）反复出现的形态，区别只在 `y_low/x_low/y_high/x_high`
   与是否有 `math.max(0,…)`/`*1.25`。代表：`T_HEIGHTENED_SENSES` #1（`survival.lua:28`）。
3. **任意等级驱动的 `combatTalentStatDamage` 必须手工展开**（节点表只吃本技能等级）：`T_MASTER_ARTIFICER` 等级在导出里
   是 0（不存在该天赋 → 0 级），所以 `(base+灵巧)·((√0−1)·0.8+1)·max/((base+100)·((√5−1)·0.8+1))` 再乘递减项
   `(1−log10(2·dam)/7)`；`artifice.lua:594/814` 的 30+… 就这样落地。代表：`T_GRAPPLING_HOOK_MASTERY` #0/#1。
4. **节点的浮点顺序在锚点差 1**（`docs/expression-overlay.md` 已预告）：`["talentLimit",…]` 在 tl=1.3/6.5 两个锚点、
   `["talentScale",…]` 在 tl=5 锚点上，JS 端恰好算出整数而导出是 ±1 ulp。按 Lua 的运算顺序手工展开即可逐点复现：
   - `combatTalentLimit` → `limit*(1-exp(sqrt(L)*a+b))`（或 low>high 分支的 `low-(low-limit)*(1-exp(…))`），`a`/`b` 由
     `sqrt(1.3)`/`sqrt(6.5)` 现场算出后写死字面量；
   - `combatTalentScale` → `m*sqrt(L)+b`（`m=(high-low)/(sqrt5-1)`，`b=low-m`）。
   代表：`T_TRAP_PRIMING` #1（tl=5 → 59 而非 60）、`T_STEALTH` #1（6.5 锚点 `4+1ulp → ceil 5`）、
   `T_SOOTHING_DARKNESS` #0（1.3/6.5 锚点各低 1 ulp → floor 1 与 4）、`T_LEECHING_POISON` #0（6.5 锚点 → 39）。
5. **`combatStatLimit` 不在节点表里**：照 `Combat.lua` 展开成 `limit·(1−exp(stat^0.75·a+b))`，`x_low=5.6234`、
   `x_high=31.623` 用源码里的字面量现场算 `a`/`b`。代表：`T_SKIRMISHER_SLING_SNIPER` #2（`called-shots.lua:27`）。
6. **条件式常数没有比较节点**：`getDuration = self:getTalentLevel(t) >= 3 and 4 or 3` 等价写成
   `["+",3,["min",1,["floor",["/",["talentLevel"],3]]]]`——对任意 tl>0 与原条件逐点同值。代表：`T_SHADOWSTRIKE` #1。
7. **同一个 getter 在 tooltip 里打印两次**：两个 acronym 直接用同一表达式。代表：`T_VENOMOUS_STRIKE` #2/#5（都是
   `statDamage`，只是 `idam`/`heal` 两个局部变量）、`T_GRAPPLING_HOOK_MASTERY` #0/#1（物理/自然两份同一 `getSecondaryDamage`）。
8. **`info` 里带注释的「0 级别的天赋」**：`+ getStrikingStyle(self, dam)`（`tactical.lua:73`）在导出基准下是 0，
   冻结成 0 并写进 `note`；`self:attr("disarm_bonus") or 0`（`survival.lua:63`）同理。
9. **导出侧读法**：`T_VENOMOUS_STRIKE` #2 与 #5 在 1.00 套第 4 点是 285 / 284，而两者在 `info` 里是同一个
   `getSecondaryDamage`；`matchesDisplayed` 的四种读数都接受，不需要在公式外包装。

## 三、无法建模

| 技能 | acronym# | 原因 |
| --- | --- | --- |
| `T_TWIST_THE_KNIFE` | 2 | 源码 `dirty.lua:165 floor(combatTalentScale(t,2,5))` 在 15 个点上对不上导出，且与同文件 #1 的导出互相矛盾（见「疑点」1）。不是取整层问题，也不是别的角色状态/随机数，而是导出数据与仓库源码不同版本；无法写出源码依据的唯一公式，按「不许编」跳过。 |

本次 10 个大系里没有出现 `源码: 无记录`，也没有出现工具报的 `标题里没有唯一可变的轴`；没有依赖运行时陷阱实体/装置数据表的条目。

## 四、疑点

1. **`T_TWIST_THE_KNIFE` #2（`cunning/dirty`）源码与导出系统性不一致，与 #1 关联**（`dirty.lua:166` #1 / `dirty.lua:165` #2）。

   | acronym | 套 | 导出 | 源码预测 |
   | --- | --- | --- | --- |
   | #1 `getDebuffs = floor(combatTalentScale(t,1.5,3))` | 1.00 | 1 / 1 / 2 / 2 / 3 | 1 / **2** / 2 / 2 / 3 |
   | #1 | 1.30 | 1 / 2 / 2 / 3 / 3 | 1 / 2 / 2 / 3 / 3 ✅ |
   | #1 | 1.50 | 1 / 2 / 2 / 3 / 3 | 1 / 2 / 2 / 3 / 3 ✅ |
   | #2 `getDuration = floor(combatTalentScale(t,2,5))` | 1.00 | 2 / 2 / 3 / 3 / 4 | 2 / **3** / 3 / **4** / **5** |
   | #2 | 1.30 | 2 / 3 / 3 / 4 / 4 | 2 / 3 / **4** / **5** / **5** |
   | #2 | 1.50 | 2 / 3 / 3 / 4 / 4 | 2 / 3 / **4** / 4 / **5** |

   两点观察：(a) 导出 #2 恒等于 导出 #1 + 1（15/15 成立）；(b) 只有 1.00 那一套的 #1 第 2 点与源码不符
   （源码 `1.2135255·√2+0.2864745 = 2.0027 → 2`，导出 1；差值 0.0027，远超浮点误差，四种读数都试过）。
   同文件 #0（`combatTalentWeaponDamage`）15 点与源码完全吻合，说明差异只在这两个 `combatTalentScale` getter。
   #1 因为已经有自动提取的 `l`（构建只按 1.50 那套校验）而没暴露，所以只有 #2 落到本批目标里。
2. **`T_STEALTH` #0（`stealth.lua:61`）：源码 `math.ceil`，导出等于 `floor`**。导出三套分别是
   37/47/54/59/64、41/52/59/64/69、43/54/61/67/72，与 `math.max(0, combatScale(getCun(10,true)*tl,15,1,64,50,0.25))`
   的 `floor`（= 未取整前的截断）逐点相同（原始值 37.985/47.92/54.58/59.74/64.0…）；源码的 `ceil` 会系统性多 1。
   表中按导出写 `floor`。属导出侧口径与仓库源码不一致，列此存疑。
3. **锚点最后一 ulp**（不是数据缺陷，只是提醒复核者）：`T_TRAP_PRIMING` #1 的 `combatTalentScale(t,12,60)` 在 tl=5
   锚点，JS 端恰好 60、Lua 端 59.99999999999999；表中按 Lua 运算顺序写死
   `38.83281572999747*sqrt(技能等级) - 26.83281572999747`。同类还有 `T_LEECHING_POISON` #0、`T_STEALTH` #1、
   `T_SOOTHING_DARKNESS` #0。
