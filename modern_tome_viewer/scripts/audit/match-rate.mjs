/**
 * Coverage audit for the Lua-sourced scaling index.
 *
 * Reports how many exported numbers can be reproduced by a real source formula,
 * grouped by the reason the rest could not. Run from the project root:
 *   node scripts/audit/match-rate.mjs
 */

import fs from 'node:fs';
import { parseAcronyms } from '../../src/lib/scaling-core.js';
import { matchLuaFormula } from '../../scripts/lua-scaling.mjs';
import { formulaCalls } from '../../src/lib/lua-formula.js';
const idx = JSON.parse(fs.readFileSync('data/lua-coefficients.json'));
const raw = fs.readdirSync('data/raw/master').filter(f=>/^talents\..*-1\.5\.json$/.test(f))
  .flatMap(f=>JSON.parse(fs.readFileSync('data/raw/master/'+f)).flatMap(t=>t.talents||[]));
const reasons=new Map(), mismatchFam=new Map(), noSrc=new Map();
let total=0, ok=0;
for (const t of raw) for (const a of parseAcronyms(t.info_text, {fit:false})) {
  total++;
  const rec = idx.talents[t.id];
  const m = matchLuaFormula(a, rec);
  if (m.formula) { ok++; continue; }
  reasons.set(m.reason,(reasons.get(m.reason)||0)+1);
  if (m.reason==='reference mismatch' && rec) {
    for (const c of rec.candidates) {
      const call = formulaCalls(c.expr)[0];
      const fam = call ? call[0] : 'none';
      mismatchFam.set(fam,(mismatchFam.get(fam)||0)+1);
    }
  }
  if (m.reason==='source unavailable') {
    const q = !rec ? 'no record' : (rec.reason || 'empty candidates');
    noSrc.set(q,(noSrc.get(q)||0)+1);
  }
}
console.log(`total ${total}, matched ${ok} (${(ok/total*100).toFixed(1)}%)`);
console.log('reasons:', JSON.stringify(Object.fromEntries([...reasons].sort((a,b)=>b[1]-a[1])), null, 1));
console.log('mismatch candidate families:', JSON.stringify(Object.fromEntries([...mismatchFam].sort((a,b)=>b[1]-a[1])), null, 1));
console.log('source unavailable reasons:', JSON.stringify(Object.fromEntries([...noSrc].sort((a,b)=>b[1]-a[1])), null, 1));
