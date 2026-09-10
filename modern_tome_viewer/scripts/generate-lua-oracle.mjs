#!/usr/bin/env node
/** Optional maintainer tool: execute actual Combat.lua functions using a minimal actor. */
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { parseAcronyms, defaultSimParams } from '../src/lib/scaling-core.js';
import { matchLuaFormula } from './lua-scaling.mjs';

const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const workspace=path.resolve(process.argv[2]||path.dirname(root));
const sourceFiles=['tome-src-full/mod/class/interface/Combat.lua','dlc-src/orcs/tome-orcs/superload/mod/class/interface/Combat.lua'];
const sources=sourceFiles.map(f=>fs.readFileSync(path.join(workspace,f),'utf8'));
const methods={spellDamage:'combatTalentSpellDamage',mindDamage:'combatTalentMindDamage',physicalDamage:'combatTalentPhysicalDamage',steamDamage:'combatTalentSteamDamage',talentScale:'combatTalentScale',talentLimit:'combatTalentLimit',weaponDamage:'combatTalentWeaponDamage',statDamage:'combatTalentStatDamage',statScale:'combatStatScale'};
const snippets=Object.values(methods).concat('rescaleDamage').map(name=>{
  for(const source of sources) {
    const match=source.match(new RegExp(`^function _M:${name}\\([^]*?^end\\s*$`,'m'));
    if(match) return match[0];
  }
  throw new Error(`Missing Lua function ${name}`);
});
const luaValue=(v)=>typeof v==='string'?JSON.stringify(v):v===null?'nil':String(v);
const luaExpr=(expr)=>{
  if(typeof expr==='number') return String(expr);
  const [fn,...a]=expr;
  if(['+','-','*','/','^'].includes(fn)) return `(${luaExpr(a[0])}${fn}${luaExpr(a[1])})`;
  if(['floor','ceil','min','max'].includes(fn)) return `math.${fn}(${a.map(luaExpr).join(',')})`;
  if(fn==='talentLevel') return `actor:${a[0]?'getTalentLevelRaw':'getTalentLevel'}(t)`;
  if(!methods[fn]) throw new Error(`Unsupported expression ${fn}`);
  return `actor:${methods[fn]}(${fn==='statScale'?'':'t,'}${a.map(luaValue).join(',')})`;
};
const raw=fs.readdirSync(path.join(root,'data/raw/master')).filter(f=>/^talents\..*-1\.5\.json$/.test(f)).flatMap(f=>JSON.parse(fs.readFileSync(path.join(root,'data/raw/master',f))).flatMap(t=>t.talents||[]));
const index=JSON.parse(fs.readFileSync(path.join(root,'data/lua-coefficients.json')));
const eligible=raw.flatMap(t=>parseAcronyms(t.info_text,{fit:false}).flatMap((a,i)=>{
  const match=matchLuaFormula(a,index.talents[t.id]);
  return match.formula ? [{id:t.id,acronym:i,displayed:a.displayed,sim:defaultSimParams(a),...match.formula.lua}] : [];
}));
// Reproducible pseudo-random sample, one formula per distinct talent.
const ranked=eligible.sort((a,b)=>crypto.createHash('sha256').update(`20260910:${a.id}:${a.acronym}`).digest('hex').localeCompare(crypto.createHash('sha256').update(`20260910:${b.id}:${b.acronym}`).digest('hex')));
const samples=[];
for(const item of ranked) { if(!samples.some(s=>s.id===item.id)) samples.push(item); if(samples.length===5) break; }
const formulas=[
 ['spellDamage',10,250],['mindDamage',20,100],['physicalDamage',10,200],['steamDamage',20,240],
 ['talentScale',2.5,5.5,0.5,0,0,false],['talentScale',1,10,1,2,1,true],['talentScale',1,10,'log',0,1,false],
 ['talentLimit',100,20,50,false,1.3],['talentLimit',0,20,5,false,1.3],['talentLimit',100,20,50,true,1],
 ['weaponDamage',0.7,1.5],['statDamage','mag',10,250,false],['statDamage','mag',10,250,true],
 ['statScale','wil',2,30,0.5,0,0],['statScale','mag',2,30,'log',2,1],
 ...samples.map(s=>s.expr),
];
const cases=[];
for(let formula=0;formula<formulas.length;formula++) for(const coefficient of [0.5,1,1.5,3]) for(const talentLevel of [1,2,3,4,5]) for(const power of [10,100,300]) {
  const sim={talentLevel,coefficient,power,stats:{力量:power,敏捷:power,体质:power,魔力:power,意志:power,灵巧:power,幸运:power}};
  cases.push({formula,sim});
}
const prelude=`local _M = {}\nmath.log10 = math.log10 or function(x) return math.log(x,10) end\n${snippets.join('\n')}\nlocal actor=setmetatable({}, {__index=_M})\nlocal t={}\nfunction actor:getTalentLevel(t) return self.level*self.coefficient end\nfunction actor:getTalentLevelRaw(t) return self.level end\nfunction actor:combatSpellpower() return self.power end\nfunction actor:combatMindpower() return self.power end\nfunction actor:combatPhysicalpower() return self.power end\nfunction actor:combatSteampower() return self.power end\nfunction actor:getStat(stat) return self.power end\n`;
const commands=cases.map(c=>`actor.level=${c.sim.talentLevel}; actor.coefficient=${c.sim.coefficient}; actor.power=${c.sim.power}; print(string.format('%.17g',${luaExpr(formulas[c.formula])}))`).join('\n');
const result=spawnSync('lua',['-'],{input:prelude+commands,encoding:'utf8',maxBuffer:10*1024*1024});
if(result.status!==0) throw new Error(result.stderr);
const values=result.stdout.trim().split(/\s+/).map(Number);
if(values.length!==cases.length || values.some(v=>!Number.isFinite(v))) throw new Error('Invalid oracle output');
const fixture={generator:'scripts/generate-lua-oracle.mjs',seed:'20260910',sources:sourceFiles.map((file,i)=>({file,sha256:crypto.createHash('sha256').update(sources[i]).digest('hex')})),samples,formulas,cases:cases.map((c,i)=>({...c,expected:values[i]}))};
fs.mkdirSync(path.join(root,'scripts/fixtures'),{recursive:true});
fs.writeFileSync(path.join(root,'scripts/fixtures/lua-oracle.json'),JSON.stringify(fixture)+'\n');
console.log(JSON.stringify({cases:cases.length,samples:samples.map(s=>({id:s.id,acronym:s.acronym,displayed:s.displayed,file:s.file,line:s.line}))},null,2));
