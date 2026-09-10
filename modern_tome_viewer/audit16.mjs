import fs from 'node:fs';
import { parseAcronyms } from './src/lib/scaling-core.js';
const idx = JSON.parse(fs.readFileSync('data/lua-coefficients.json'));
const raw = fs.readdirSync('data/raw/master').filter(f=>/^talents\..*-1\.5\.json$/.test(f))
  .flatMap(f=>JSON.parse(fs.readFileSync('data/raw/master/'+f)).flatMap(t=>t.talents||[]));
const byReason=new Map(), ex=new Map();
let nNoRec=0,nEmpty=0,nCandsButNoMatch=0;
for (const t of raw) {
  const n = parseAcronyms(t.info_text||'',{fit:false}).length; if(!n) continue;
  const rec = idx.talents[t.id];
  if (!rec) { nNoRec+=n; continue; }
  if (!rec.candidates?.length) { nEmpty+=n; const r=rec.reason||'(no candidate found)'; byReason.set(r,(byReason.get(r)||0)+n); ex.set(r,ex.get(r)||`${t.id} ${t.name} (${rec.file?.split('/').pop()}:${rec.line})`); }
}
console.log('acronyms on talents with no Lua record :', nNoRec);
console.log('acronyms on records with no candidate :', nEmpty);
console.log('\nwhy no candidate:');
[...byReason].sort((a,b)=>b[1]-a[1]).forEach(([r,c])=>console.log(`  ${String(c).padStart(4)}  ${r}\n         e.g. ${ex.get(r)}`));
