import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { tokenizeLua, extractTalents, buildLuaIndex } from './extract-lua-coefficients.mjs';
import { parseAcronyms, defaultSimParams, evaluateAcronym, talentPowerDamage, fitCoefficients, simAtAxis, formatAcronymValue, valueInputs, inputValue, exportCondition, rawCombatStat, rescaleCombatStat, paradoxModifier } from '../src/lib/scaling-core.js';
import { evaluateLuaExpression } from '../src/lib/lua-formula.js';
import { matchLuaFormula, matchesDisplayed, ladderAxis, resolveIntegerRounding, integerRounding } from './lua-scaling.mjs';

const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const oracle=JSON.parse(fs.readFileSync(path.join(root,'scripts/fixtures/lua-oracle.json')));
const index=JSON.parse(fs.readFileSync(path.join(root,'data/lua-coefficients.json')));
const raw=fs.readdirSync(path.join(root,'data/raw/master')).filter(f=>/^talents\..*-1\.5\.json$/.test(f)).flatMap(f=>JSON.parse(fs.readFileSync(path.join(root,'data/raw/master',f))).flatMap(t=>t.talents||[]));
const byId=new Map(raw.map(t=>[t.id,t]));
const acronyms=id=>parseAcronyms(byId.get(id).info_text,{fit:false});
const near=(a,b,message='')=>assert.ok(Math.abs(a-b)<=Math.max(1,Math.abs(b))*1e-10,`${message}: ${a} != ${b}`);
const snippet=(getter='self:combatTalentSpellDamage(t,10,250)',info='t.getDamage(self,t)')=>`newTalent{ name="Test", type={"spell/test",1}, getDamage=function(self,t) return ${getter} end, info=function(self,t) return ([[%d]]):tformat(${info}) end }`;

test('Lua lexer ignores comments, escaped quotes and long strings containing fake definitions',()=>{
  const source=`-- newTalent{type={"bad",1}}\n--[=[ newTalent{} ]=]\nlocal s=[==[ newTalent{ nested } ]==]\nlocal q="escaped \\" newTalent{}"\n`+snippet();
  assert.equal(extractTalents(source).length,1);
  assert.ok(tokenizeLua(source).some(t=>t.kind==='string'&&t.v.includes('nested')));
});

test('Lua table fields survive nested functions, loops and braces',()=>{
  const source=snippet().replace('getDamage=', 'action=function(self,t) for i=1,5 do if i>1 then local x={a=function() return {} end} end end return true end, getDamage=');
  assert.deepEqual(extractTalents(source)[0].candidates[0].expr,['spellDamage',10,250]);
});

test('pure getter dependencies preserve arithmetic and rounding in info',()=>{
  const record=extractTalents(snippet('self:combatTalentScale(t,2,5)', 'math.floor(t.getDamage(self,t)*100)/2'))[0];
  assert.deepEqual(record.candidates[0].expr,['/',['floor',['*',['talentScale',2,5,0.5,0,0,false],100]],2]);
});

test('simple local aliases and damDesc resolve to the actual info argument',()=>{
  const record=extractTalents(snippet().replace('return ([[%d]]):tformat(t.getDamage(self,t))','local damage=t.getDamage(self,t) return ([[%d]]):tformat(damDesc(self,DamageType.FIRE,damage))'))[0];
  assert.equal(record.candidates[0].argument,1);
  assert.deepEqual(record.candidates[0].expr,['spellDamage',10,250]);
});

for(const [name,getter] of [
 ['expression coefficients','self:combatTalentSpellDamage(t,25+self:getWil()/10,250)'],
 ['literal arithmetic arguments','self:combatTalentSpellDamage(t,10/2,250)'],

 ['other talent','self:combatTalentSpellDamage(self.T_OTHER,10,250)'],
 ['unknown helper','self:combatTalentUnknown(t,10,250)'],

 ['recursive getter','t.getDamage(self,t)'],
]) test(`rejects ${name}`,()=>assert.equal(extractTalents(snippet(getter))[0].candidates.length,0));

test('the paradox modifier saturates at 675, where it stops mattering',()=>{
  // chronomancer.lua:153 — PMod drives paradox cost and chronomancy spellpower.
  assert.equal(paradoxModifier(300),1);
  assert.equal(paradoxModifier(150),0.5);
  assert.equal(paradoxModifier(675),1.5);
  assert.equal(paradoxModifier(900),1.5);
  assert.ok(paradoxModifier(600) < 1.5 && paradoxModifier(600) > 1.4);
  // The slider therefore stops where the modifier does.
  assert.equal(Math.round(1.5 ** 2 * 300), 675);
});

test('a power override is an expression, and the title must pin its inputs',()=>{
  const record=extractTalents(snippet('self:combatTalentSpellDamage(t,20,220,getParadoxSpellpower(self,t))'))[0];
  assert.deepEqual(record.candidates[0].expr,
    ['spellDamage',20,220,['power','法术强度',['*',1,['pmod',['actor','paradox']]]]]);
  // A constant override still needs the title to declare nothing of its own.
  const constant=extractTalents(snippet('self:combatTalentSpellDamage(t,10,250,300)'))[0];
  assert.equal(constant.candidates.length,1);
  const declaresPower=parseAcronyms('<acronym class="variable" title="技能等级 1-5,<br>技能系数 1.50,<br>法术强度 100">181, 246, 297, 340, 378</acronym>',{fit:false})[0];
  assert.equal(matchLuaFormula(declaresPower,constant).reason,'reference mismatch');
});

test('actor attributes are inputs the title must declare',()=>{
  // `self:getWil()` used to be rejected outright; it is a real input now, so it
  // parses — and matching keeps the fail-closed rule that the title has to pin it.
  const record=extractTalents(snippet('self:combatTalentSpellDamage(t,10,250)*self:getWil()'))[0];
  assert.deepEqual(record.candidates[0].expr,['*',['spellDamage',10,250],['actor','意志']]);
  const undeclared=parseAcronyms('<acronym class="variable" title="技能等级 1-5,<br>技能系数 1.50,<br>法术强度 100">1, 2, 3, 4, 5</acronym>',{fit:false})[0];
  assert.equal(matchLuaFormula(undeclared,record).reason,'reference mismatch');
});

test('conditional getters and conditional info fail closed',()=>{
  assert.equal(extractTalents(snippet().replace('return self:combat','if self.flag then return 3 end return self:combat'))[0].candidates.length,0);
  assert.equal(extractTalents(snippet().replace('return ([[%d]])','if self.flag then return "x" end return ([[%d]])'))[0].candidates.length,0);
});

test('unbalanced Lua input is reported instead of producing a partial candidate',()=>assert.throws(()=>extractTalents('newTalent{ type={"spell/test",1}')));

test('nil defaults, signed literals and log scaling are preserved',()=>{
  assert.deepEqual(extractTalents(snippet('self:combatTalentScale(t,-2,5,"log",nil,1,true)'))[0].candidates[0].expr,['talentScale',-2,5,'log',0,1,true]);
});

test('DLC ordering replaces base definitions; patch references disable unsafe extraction',()=>{
  const dir=fs.mkdtempSync(path.join(os.tmpdir(),'tome-lua-test-'));
  try {
    const roots=['tome-src-full','dlc-src/ashes-urhrok/tome-ashes-urhrok','dlc-src/cults/tome-cults','dlc-src/orcs/tome-orcs'];
    for(const folder of roots) fs.mkdirSync(path.join(dir,folder,'data/talents'),{recursive:true});
    const rawDir=path.join(dir,'raw'); fs.mkdirSync(rawDir);
    fs.writeFileSync(path.join(rawDir,'talents.spell-1.5.json'),JSON.stringify([{talents:[{id:'T_TEST',short_name:'TEST',type:['spell/test',1],source_code:['data/talents/test.lua',1]}]}]));
    for(const [i,folder] of roots.entries()) fs.writeFileSync(path.join(dir,folder,'data/talents/test.lua'),snippet(`self:combatTalentSpellDamage(t,${i+10},250)`));
    let result=buildLuaIndex({workspace:dir,rawDir});
    assert.equal(result.talents.T_TEST.addon,'orcs');
    assert.equal(result.talents.T_TEST.candidates[0].expr[1],13);
    fs.mkdirSync(path.join(dir,roots[3],'hooks'));
    fs.writeFileSync(path.join(dir,roots[3],'hooks/load.lua'),'local t=Talents.talents_def.T_TEST; t.getDamage=function() return 1 end');
    result=buildLuaIndex({workspace:dir,rawDir});
    assert.equal(result.talents.T_TEST.candidates.length,0);
    assert.equal(result.talents.T_TEST.reason,'possible DLC patch');
  } finally {fs.rmSync(dir,{recursive:true,force:true});}
});

test('Flameshock uses source base=10 max=250 and coefficient=1.5',()=>{
  const a=acronyms('T_FLAMESHOCK')[1];
  const {formula}=matchLuaFormula(a,index.talents.T_FLAMESHOCK);
  assert.equal(formula.base,10); assert.equal(formula.max,250); assert.equal(formula.mastery,1.5);
  const resolved={...a,...formula}; const sim=defaultSimParams(resolved);
  assert.deepEqual([1,2,3,4,5].map(talentLevel=>Math.round(evaluateAcronym(resolved,{...sim,talentLevel}))),[181,246,297,340,378]);
  // Powers are per type, so override the label the family reads (and the legacy
  // single field for callers that still pass one).
  for(const power of [10,50,100,300]) for(const coefficient of [0.5,1,1.5,3]) near(evaluateAcronym(resolved,{...sim,power,powers:{...sim.powers,法术强度:power},coefficient}),talentPowerDamage(coefficient,10,250,power));
});

test('Flameshock radius source mismatch is not force-matched',()=>assert.equal(matchLuaFormula(acronyms('T_FLAMESHOCK')[0],index.talents.T_FLAMESHOCK).reason,'reference mismatch'));

test('matching refuses indistinguishable candidates with different cross-power behavior',()=>{
  const a=acronyms('T_FLAMESHOCK')[1];
  const record={...index.talents.T_FLAMESHOCK,candidates:[{expr:['spellDamage',10,250],argument:1},{expr:['spellDamage',95,250],argument:2}]};
  assert.equal(matchLuaFormula(a,record).reason,'ambiguous formula');
});

test('matching checks every ladder point at display precision',()=>{
  const a=acronyms('T_FLAMESHOCK')[1];a.displayed[2]+=1;
  assert.equal(matchLuaFormula(a,index.talents.T_FLAMESHOCK).reason,'reference mismatch');
});

test('the ladder axis is read from the title, not assumed to be talent level',()=>{
  // A talent-level ladder matches on the talent-level axis...
  const byLevel=acronyms('T_FLAMESHOCK')[1];
  assert.equal(matchLuaFormula(byLevel,index.talents.T_FLAMESHOCK).formula.lua.axis,'技能等级');
  // ...and relabelling it to an input the formula never reads must not match.
  const relabelled=acronyms('T_FLAMESHOCK')[1];
  relabelled.params[0].label='角色等级';
  relabelled.axisLabel='角色等级';
  assert.equal(matchLuaFormula(relabelled,index.talents.T_FLAMESHOCK).reason,'reference mismatch');
});

test('a character-level ladder is reproduced from source',()=>{
  // 被捕猎's radius is ceil(10 + self.level/5) and the export lists it for
  // character levels 1/10/25/40/50, so the axis really is the character level.
  const a=acronyms('T_HUNTED_PLAYER').find(x=>x.params.some(p=>p.label==='角色等级'&&p.ladder.length>1)&&x.displayed[0]===10);
  const matched=matchLuaFormula(a,index.talents.T_HUNTED_PLAYER);
  assert.equal(matched.formula?.lua.axis,'角色等级',JSON.stringify(matched));
  assert.deepEqual(matched.formula.lua.expr,['+',10,['/',['actor','角色等级'],5]]);
  const shown=[1,10,25,40,50].map(v=>evaluateLuaExpression(matched.formula.lua.expr,{...defaultSimParams(a),characterLevel:v}));
  assert.deepEqual(shown.map(v=>Math.round(v)),a.displayed);
});

test('two varying inputs in one title are rejected',()=>{
  const a=acronyms('T_FLAMESHOCK')[1];
  a.params[2].value=null; a.params[2].ladder=[10,25,50,75,100];
  a.params.push({label:'意志',kind:'stat',value:null,ladder:[10,25,50,75,100],editable:true});
  assert.equal(matchLuaFormula(a,index.talents.T_FLAMESHOCK).reason,'unsupported input dimensions');
});

test('all supported JS formulas match 1200 values executed by actual Combat.lua',()=>{
  for(const c of oracle.cases) near(evaluateLuaExpression(oracle.formulas[c.formula],c.sim),c.expected,JSON.stringify(c));
});

test('five seeded random talents reproduce all their source-matched exported values',()=>{
  for(const sample of oracle.samples) {
    const a=acronyms(sample.id)[sample.acronym];
    const {formula}=matchLuaFormula(a,index.talents[sample.id]);
    assert.deepEqual(formula.lua.expr,sample.expr);
    assert.deepEqual([1,2,3,4,5].map(talentLevel=>Number(evaluateAcronym({...a,...formula},{...sample.sim,talentLevel}).toFixed(sample.precision))),sample.displayed,sample.id);
  }
});

test('entire source-matched dataset agrees at all reference points',()=>{
  let matched=0;
  for(const t of raw) for(const a of acronyms(t.id)) {
    const {formula}=matchLuaFormula(a,index.talents[t.id]); if(!formula) continue;
    matched++;
    // Re-evaluate along the ladder's own axis, which is not always talent level.
    const axis=ladderAxis(a);
    for(const [i,value] of axis.ladder.entries()) {
      const v=evaluateAcronym({...a,...formula},simAtAxis(a,defaultSimParams(a),value));
      // Same display-semantics rule the matcher used to accept this match.
      assert.ok(matchesDisplayed(v,a.displayed[i],a.precision),`${t.id} point ${i}: ${v} vs ${a.displayed[i]}`);
    }
  }
  assert.ok(matched>=2200,`Only ${matched} source values`);
});

test('every source value re-renders its own ladder exactly as exported',()=>{
  // Rendering used to round every integer, which is wrong wherever the export
  // printed it with Lua's `%d`. The ladder itself identifies the specifier, so
  // the rendered string must reproduce the exported number exactly.
  let rendered=0;
  for(const t of raw) {
    const list=acronyms(t.id).map(a=>{const {formula}=matchLuaFormula(a,index.talents[t.id]);return formula?{...a,...formula}:null;}).filter(Boolean);
    if(!list.length) continue;
    resolveIntegerRounding(list);
    for(const a of list) {
      const axis=ladderAxis(a);
      for(const [i,value] of axis.ladder.entries()) {
        const text=formatAcronymValue(a,evaluateAcronym(a,simAtAxis(a,defaultSimParams(a),value)));
        assert.equal(Number(text.replace(a.suffix??'','')),a.displayed[i],`${t.id} point ${i}: ${text} vs ${a.displayed[i]}${a.suffix??''}`);
      }
      rendered++;
    }
  }
  assert.ok(rendered>=2200,`Only ${rendered} source values`);
});

test('the integer reading is inferred from the ladder, never guessed',()=>{
  // `%d` truncates: 被捕猎's percentage sibling proves it for the whole call, so
  // the radius (integral at all five reference levels) inherits it — at
  // character level 24 the game prints 14, not 15.
  const hunted=acronyms('T_HUNTED_PLAYER').map(a=>({...a,...matchLuaFormula(a,index.talents.T_HUNTED_PLAYER).formula}));
  const radius=hunted.find(a=>a.displayed[0]===10);
  // On its own the radius ladder cannot tell the two readings apart...
  assert.equal(integerRounding(radius),null);
  // ...but the percentage it is printed beside can.
  resolveIntegerRounding(hunted);
  assert.equal(radius.lua.rounding,'trunc');
  const at24={...defaultSimParams(radius),characterLevel:24};
  assert.equal(formatAcronymValue(radius,evaluateAcronym(radius,at24)),'14');
  assert.equal(formatAcronymValue(radius,evaluateAcronym(radius,{...at24,characterLevel:25})),'15');
  // `%.0f` rounds: 初现光芒's damage and 火焰冲击's both round up to theirs.
  const illuminate=acronyms('T_CHANT_ILLUMINATE').map(a=>({...a,...matchLuaFormula(a,index.talents.T_CHANT_ILLUMINATE).formula}));
  resolveIntegerRounding(illuminate);
  assert.equal(illuminate.find(a=>a.displayed[1]===46).lua.rounding,'round');
  const shock=acronyms('T_FLAMESHOCK').map(a=>({...a,...matchLuaFormula(a,index.talents.T_FLAMESHOCK).formula}));
  resolveIntegerRounding(shock);
  assert.equal(shock[1].lua.rounding,'round');
});

test('the coefficient maps a value onto its exported ladder exactly',()=>{
  // 火焰冲击's ladder was exported at coefficient 1.50, so dialling the slider
  // back to that value must reproduce it, and 1.0 must be lower everywhere.
  const shock=acronyms('T_FLAMESHOCK').map(a=>({...a,...matchLuaFormula(a,index.talents.T_FLAMESHOCK).formula}));
  const damage=shock[1];
  const at=(coefficient,talentLevel)=>Number(formatAcronymValue(damage,evaluateAcronym(damage,{...defaultSimParams(damage),coefficient,talentLevel})).replace('%',''));
  assert.deepEqual([1,2,3,4,5].map(t=>at(1.5,t)),damage.displayed);
  assert.ok([1,2,3,4,5].every(t=>at(1,t)<at(1.5,t)));
});

test('a value describes only the inputs it really reads',()=>{
  // 被捕猎's numbers move with the character level and nothing else, so its
  // tooltip must not claim a talent level it never uses.
  const [chance,radius]=acronyms('T_HUNTED_PLAYER').map(a=>({...a,...matchLuaFormula(a,index.talents.T_HUNTED_PLAYER).formula}));
  assert.deepEqual(valueInputs(radius).map(i=>i.key),['characterLevel']);
  assert.deepEqual(valueInputs(chance).map(i=>i.key),['characterLevel']);
  const shift={...defaultSimParams(radius),characterLevel:24};
  assert.equal(inputValue(shift,'characterLevel'),24);
  // A spell damage value reads level, coefficient and power.
  const shock=acronyms('T_FLAMESHOCK').map(a=>({...a,...matchLuaFormula(a,index.talents.T_FLAMESHOCK).formula}))[1];
  assert.deepEqual(valueInputs(shock).map(i=>i.key),['talentLevel','coefficient','powers:法术强度']);
  assert.deepEqual(exportCondition(shock),['技能等级 1/2/3/4/5','技能系数 1.5','法术强度 100']);
});

test('the effective combat stat is the raw one rescaled, and the inverse is minimal',()=>{
  // Combat.lua:1477 — the damage helpers read combatSpellpower(), i.e. the raw
  // stat pushed through this diminishing curve, never the raw stat itself.
  assert.equal(rescaleCombatStat(20),20);
  assert.equal(rescaleCombatStat(60),40);
  assert.equal(rescaleCombatStat(300),100);
  assert.equal(rescaleCombatStat(1100),200);
  for(const effective of [1,10,20,21,40,60,100,120,150,200]){
    const raw=rawCombatStat(effective);
    assert.equal(rescaleCombatStat(raw),effective,`effective ${effective} -> raw ${raw}`);
    assert.ok(rescaleCombatStat(raw-1)<effective,`raw ${raw-1} must not already reach ${effective}`);
  }
  // That curve is why the power slider stops at 200: effective 100 needs raw 300.
  assert.equal(rawCombatStat(100),300);
});

test('source-unavailable path preserves the existing approximate fallback',()=>{
  const a=acronyms('T_FLAMESHOCK')[2];
  assert.equal(matchLuaFormula(a,null).reason,'source unavailable');
  Object.assign(a,fitCoefficients(a));
  assert.notEqual(evaluateAcronym(a,defaultSimParams(a)),null);
  assert.equal(a.lua,undefined);
});

test('unrecognized or non-finite source expressions do not display invalid numbers',()=>{
  const a={...acronyms('T_FLAMESHOCK')[1],lua:{expr:['unknown',1]}};
  assert.equal(evaluateAcronym(a,defaultSimParams(a)),null);
  a.lua.expr=['/',1,0]; assert.equal(evaluateAcronym(a,defaultSimParams(a)),null);
});

test('uber and inscription blocks are indexed the way the export indexes them',()=>{
  // `uberTalent` carries no type (the file names the tree) and every
  // `newInscription` declares index 1, so both need a synthesized position.
  const uber=extractTalents(snippet().replace('newTalent{', 'uberTalent{'), 'tome-src-full/data/talents/uber/str.lua')[0];
  assert.equal(uber.tree,'uber/strength');
  assert.equal(uber.index,0);
  const uberSnippet=snippet().replace('newTalent{', 'uberTalent{');
  const second=extractTalents(uberSnippet+uberSnippet, 'data/talents/uber/cun.lua');
  assert.deepEqual(second.map(r=>[r.tree,r.index]),[['uber/cunning',0],['uber/cunning',1]]);
  const inscription=extractTalents(snippet().replace('newTalent{', 'newInscription{').replace('type={"spell/test",1}','type={"inscriptions/runes", 1}'))[0];
  assert.equal(inscription.tree,'inscriptions/runes');
  assert.equal(inscription.index,0);
  // `type = {"spell/other", }` has no index at all — the position still exists.
  const indexed=extractTalents(snippet().replace('type={"spell/test",1}','type={"spell/other", }'))[0];
  assert.deepEqual([indexed.tree,indexed.index],['spell/other',0]);
});

test('an unquoted short_name no longer drops the whole block',()=>{
  const record=extractTalents(snippet().replace('name="Test"','name="Warden\'s Focus", short_name=WARDEN_S_FOCUS'))[0];
  assert.equal(record.shortName,'WARDEN_S_FOCUS');
  assert.equal(record.candidates.length,1);
});

test('extra math functions and an expression weapon-damage bonus parse',()=>{
  const root=extractTalents(snippet('self:combatTalentScale(t,2,6,0.75) * math.sqrt(self.level)'))[0];
  assert.deepEqual(root.candidates[0].expr,['*',['talentScale',2,6,0.75,0,0,false],['sqrt',['actor','角色等级']]]);
  const weapon=extractTalents(snippet('self:combatTalentWeaponDamage(t,0.1,0.8,self:getTalentLevel(self.T_SHIELD_EXPERTISE))'))[0];
  assert.deepEqual(weapon.candidates[0].expr,['weaponDamage',0.1,0.8,['talentRef','T_SHIELD_EXPERTISE',false]]);
  const generic=extractTalents(snippet('self:combatScale(self:getMag(), 0, 0, 75, 75)'))[0];
  assert.deepEqual(generic.candidates[0].expr.slice(0,2),['combatScale',['actor','魔力']]);
});

test('attribute conditions keep the branch the export was rendered with',()=>{
  const source=snippet('self:combatTalentSpellDamage(t,3,35) * (self:attr("sun_paladin_avatar") and 2 or 1)');
  const record=extractTalents(source)[0];
  assert.deepEqual(record.candidates[0].expr,['*',['spellDamage',3,35],['cond','sun_paladin_avatar',2,1]]);
  // The exported ladder is the un-buffed one, and the flag is recorded.
  const a=parseAcronyms('<acronym class="variable" title="技能等级 1-5,<br>技能系数 1.50,<br>法术强度 100">23, 32, 38, 44, 49</acronym>',{fit:false})[0];
  const {formula}=matchLuaFormula(a,record);
  assert.deepEqual(formula.lua.conditions,{sun_paladin_avatar:false});
  const resolved={...a,...formula};
  assert.equal(Math.round(evaluateAcronym(resolved,defaultSimParams(resolved))),23);
});

test('another talent level binds to a title parameter, or to the export baseline',()=>{
  const record=extractTalents(snippet('self:combatTalentWeaponDamage(t,0.1,0.8,self:getTalentLevel(self.T_SHIELD_EXPERTISE)) * 100'))[0];
  const ladder='48, 64, 76, 86, 95';
  // No title parameter names it: the export rendered the fake actor at level 0.
  const bare=parseAcronyms(`<acronym class="variable" title="技能等级 1-5,<br>技能系数 1.50">${ladder}</acronym>`,{fit:false})[0];
  const bound=matchLuaFormula(bare,record);
  assert.ok(bound.formula,JSON.stringify(bound));
  assert.deepEqual(bound.formula.lua.assumed,[{talent:'T_SHIELD_EXPERTISE',level:0}]);
  const resolved={...bare,...bound.formula};
  assert.deepEqual([1,2,3,4,5].map(t=>Math.trunc(evaluateAcronym(resolved,{...defaultSimParams(resolved),talentLevel:t}))),[48,64,76,86,95]);
  // A title that does name it binds the input instead of guessing.
  const named=parseAcronyms(`<acronym class="variable" title="技能等级 1-5,<br>技能系数 1.50,<br>盾牌专精 等级 0">${ladder}</acronym>`,{fit:false})[0];
  const withParam=extractTalents(snippet('self:combatTalentWeaponDamage(t,0.1,0.8,self:getTalentLevel(self.T_SHIELD_EXPERTISE)) * 100'))[0];
  const namedMatch=matchLuaFormula(named,withParam);
  assert.ok(namedMatch.formula,JSON.stringify(namedMatch));
  assert.ok(JSON.stringify(namedMatch.formula.lua.expr).includes('盾牌专精 等级'));
});

test('powers stay separate so the best of two can be recomputed',()=>{
  const a=parseAcronyms('<acronym class="variable" title="技能等级 1-5,<br>技能系数 1.50,<br>法术强度 100,<br>精神强度 100">27, 37, 44, 51, 56</acronym>',{fit:false})[0];
  const record=extractTalents(snippet('math.max(self:combatTalentSpellDamage(t,15,40), self:combatTalentMindDamage(t,15,40))'))[0];
  const {formula}=matchLuaFormula(a,record);
  assert.ok(formula,JSON.stringify(matchLuaFormula(a,record)));
  const resolved={...a,...formula};
  const sim=defaultSimParams(resolved);
  assert.deepEqual(valueInputs(resolved).map(i=>i.key),['talentLevel','coefficient','powers:法术强度','powers:精神强度']);
  const at=(spell,mind)=>evaluateAcronym(resolved,{...sim,powers:{...sim.powers,法术强度:spell,精神强度:mind}});
  assert.ok(at(200,100)>at(100,100),'spell power alone must raise it');
  assert.equal(at(200,100),at(100,200),'the stronger power wins either way');
});

test('a percent ladder has one suffix and retains source decimal precision',()=>{
  const [a]=parseAcronyms('<acronym class="talent-variable" title="技能等级 1-5">1.2%, 2.3%, 3.4%, 4.5%, 5.6%</acronym>',{fit:false});
  assert.equal(a.suffix,'%');assert.equal(a.precision,1);
});

test('text the export wrapped around the numbers is read from the outer edges',()=>{
  // The unit is what follows the last number, not "everything that is not a
  // number": that reading concatenated every copy and produced "+++++".
  const wrap=(inner)=>{const [a]=parseAcronyms(`<acronym class="variable" title="技能等级 1-5">${inner}</acronym>`,{fit:false});return {d:a.displayed,prefix:a.prefix,suffix:a.suffix,tail:a.tail};};
  assert.deepEqual(wrap('+16, +22, +27, +30, +34'),{d:[16,22,27,30,34],prefix:'+',suffix:'',tail:''});
  assert.deepEqual(wrap('：+13, ：+18'),{d:[13,18],prefix:'：+',suffix:'',tail:''});
  assert.deepEqual(wrap('1.2%, 2.3%'),{d:[1.2,2.3],prefix:'',suffix:'%',tail:''});
  assert.deepEqual(wrap('10% 几率, 20% 几率'),{d:[10,20],prefix:'',suffix:'% 几率',tail:''});
  // A closing period belongs to the sentence, so it is printed once.
  assert.deepEqual(wrap('0.36, 1.38.'),{d:[0.36,1.38],prefix:'',suffix:'',tail:'.'});
  // A repeated sentence fragment is the unit in its own right.
  assert.deepEqual(wrap('增加你的生命回复18。回复量受等级加成。, 增加你的生命回复29。回复量受等级加成。'),
    {d:[18,29],prefix:'增加你的生命回复',suffix:'。回复量受等级加成。',tail:''});
});
