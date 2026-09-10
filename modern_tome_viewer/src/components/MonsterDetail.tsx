import { useMemo, useState } from 'react';
import { Highlight } from './Highlight';
import { MonsterArtwork, CategoryBadge, TypeChip } from './MonsterBits';
import type { Monster, MonsterTalentRef } from '../lib/monsters';
import { describeTalentRule, monsterDisplayName } from '../lib/monsters';
import { stripMarkup } from '../lib/data';
import type { TalentEntry } from '../lib/types';

interface MonsterDetailProps {
  monster: Monster;
  /** Resolve a talent id to the dataset entry, when the talent is known. */
  talentOf: (id: string) => TalentEntry | undefined;
  onClose: () => void;
  /** Show the talent in the host page's talent panel; does not navigate away. */
  onSelectTalent: (talent: TalentEntry) => void;
  /** Talent currently shown in the side panel, so the row can be marked. */
  selectedTalentId: string | null;
  terms: string[];
  compact?: boolean;
}

const SOURCE_LABELS: Record<string, string> = {
  tome: '本体',
  orcs: '兽人 DLC',
  ashes: '灰烬 DLC',
  cults: '邪教 DLC',
};

/**
 * One talent entry.
 *
 * The talent is shown with the level rule the monster actually declares. The
 * side panel it opens is explicitly a *generic* talent simulation: the
 * monster's other parameters (stats, level, equipment) are not injected, and its
 * raw talent level can exceed the simulator's default of 5.
 */
function TalentRow({
  ref_,
  talent,
  terms,
  onOpen,
  selected,
}: {
  ref_: MonsterTalentRef;
  talent: TalentEntry | undefined;
  terms: string[];
  onOpen: (talent: TalentEntry) => void;
  selected: boolean;
}) {
  const plain = talent?.plainName ?? ref_.id;
  const rule = describeTalentRule(ref_);
  return (
    <button
      type="button"
      disabled={!talent}
      onClick={() => talent && onOpen(talent)}
      aria-pressed={selected}
      className={`flex w-full items-start gap-2 rounded-md px-2 py-1.5 text-left disabled:cursor-default disabled:hover:bg-transparent ${
        selected ? 'bg-accent-soft text-accent-strong' : 'hover:bg-hover'
      }`}
      title={talent ? '在右侧技能栏中查看（不离开本页）' : '该技能不在技能库中，无法打开详情'}
    >
      <span className="mt-0.5 w-4 shrink-0 text-[11px] text-subtle">{talent ? '↗' : '·'}</span>
      <span className="min-w-0 flex-1">
        <span className="flex flex-wrap items-baseline gap-x-1.5">
          <span className="text-[12.5px] font-medium">
            <Highlight text={plain} terms={terms} />
          </span>
          <span className="text-[11px] text-subtle">{ref_.id}</span>
          {ref_.origin === 'override' && (
            <span className="chip bg-chip text-[10px] text-subtle" title="该技能在父模板中已配置，此模板重新定义">
              覆盖父模板
            </span>
          )}
          {!talent && (
            <span className="chip bg-red-500/15 text-[10px] text-red-500" title="源码引用了它，但技能库中没有该技能">
              未收录
            </span>
          )}
        </span>
        <span className="mt-0.5 block text-[11.5px] text-muted">{rule}</span>
      </span>
    </button>
  );
}

/**
 * Short factual notes about mechanics that the raw talent list does not convey.
 *
 * Everything here is read from the resolved entity fields, and the engine
 * citation is printed with the note so a reader can tell a source fact from an
 * editorial summary. Scripts that produce effects (for example a `on_die`
 * function) are reported as "scripted" rather than being turned into fake
 * talents.
 */
function mechanicNotes(monster: Monster): { text: string; source: string }[] {
  const notes: { text: string; source: string }[] = [];
  if (typeof monster.canMultiply === 'number') {
    notes.push({
      text:
        monster.canMultiply === 0
          ? '不会繁殖（can_multiply = 0）。'
          : `可繁殖最多 ${monster.canMultiply} 次（can_multiply = ${monster.canMultiply}）。`,
      source: 'data/talents/misc/npcs.lua 的 T_MULTIPLY 读取实体字段',
    });
  }
  if (monster.rngSets.length) {
    notes.push({
      text: `除固定技能外，会从 ${monster.rngSets.length} 套互斥技能组中随机获得一套（不是同时拥有）。`,
      source: 'engine/resolvers.lua 的 resolvers.rngtalentsets',
    });
  }
  if (monster.rngPools.length) {
    const detail = monster.rngPools
      .map((pool) => `${pool.count ?? '若干'} 个（候选 ${pool.talents.length}）`)
      .join('、');
    notes.push({ text: `会从随机技能池中抽取 ${detail}。`, source: 'engine/resolvers.lua 的 resolvers.rngtalents' });
  }
  if (monster.randboss) {
    notes.push({
      text: '源码标记为可随机生成的首领（randboss），不是固定位置的首领。',
      source: 'data/general/npcs 中的 randboss 字段',
    });
  }
  if (monster.autoClasses?.length) {
    notes.push({
      text: `声明了职业：${monster.autoClasses.map((c) => c.name ?? c.raw).join('、')}。但 auto_classes 不保证获得该职业全部技能，实际由等级与点数随机分配。`,
      source: 'mod/class/Actor.lua 的 levelupClass、mod/class/GameState.lua',
    });
  }
  if (monster.unresolved?.length) {
    notes.push({
      text: `父模板未能解析：${monster.unresolved.map((u) => `${u.base}（${u.reason}）`).join('、')}。该模板的技能与属性可能不完整。`,
      source: '本提取管线的未解析记录',
    });
  }
  if (monster.imageKind === 'auto-fuzzy') {
    notes.push({
      text: `图片由命名规则推断（${monster.imageMatch ?? '近似匹配'}），并非本模板直接声明。`,
      source: 'mod/class/NPC.lua 的自动图片命名回退',
    });
  }
  return notes;
}

export function MonsterDetail({
  monster,
  talentOf,
  onClose,
  onSelectTalent,
  selectedTalentId,
  terms,
  compact = false,
}: MonsterDetailProps) {
  const [showRaw, setShowRaw] = useState(false);
  const display = monsterDisplayName(monster);
  const description = monster.descZh ?? monster.desc;
  const notes = useMemo(() => mechanicNotes(monster), [monster]);

  const hasRandom = monster.rngSets.length > 0 || monster.rngPools.length > 0;

  return (
    <section className="panel flex h-full flex-col overflow-hidden" aria-label={`${display.primary} 的详情`}>
      <div className="flex items-start gap-3 border-b border-line p-3">
        <MonsterArtwork monster={monster} size={80} />
        <div className="min-w-0 flex-1">
          <div className="flex flex-wrap items-baseline gap-x-2">
            <h2 className="text-[16px] font-bold">
              <Highlight text={display.primary} terms={terms} />
            </h2>
            {display.secondary && (
              <span className="text-[11.5px] text-subtle">
                <Highlight text={display.secondary} terms={terms} />
              </span>
            )}
          </div>
          <div className="mt-1 flex flex-wrap gap-1">
            <CategoryBadge category={monster.category} label={monster.categoryLabel} />
            {monster.rank !== null && <span className="chip">rank {monster.rank}</span>}
            <TypeChip monster={monster} />
            {monster.levelRange && (monster.levelRange[0] !== null || monster.levelRange[1] !== null) && (
              <span className="chip" title="源码中的 level_range">
                等级 {monster.levelRange[0] ?? '?'}
                {monster.levelRange[1] ? `–${monster.levelRange[1]}` : '+'}
              </span>
            )}
            {monster.lifeRating !== null && <span className="chip">每级生命 {monster.lifeRating}</span>}
            {monster.sizeCategory !== null && <span className="chip" title="size_category：1 极小 … 6 巨大">体型 {monster.sizeCategory}</span>}
            {monster.rarity !== null && <span className="chip" title="生成权重，不是携带技能的概率">rarity {monster.rarity}</span>}
            {monster.unique && <span className="chip" title="源码标记 unique，通常是固定命名实体">固定命名</span>}
          </div>
        </div>
        <button type="button" className="btn px-2" onClick={onClose} aria-label="关闭详情">
          ✕
        </button>
      </div>

      <div className="min-h-0 flex-1 overflow-y-auto p-3">
        {description && (
          <p className="mb-3 text-[12.5px] leading-relaxed text-muted">
            {stripMarkup(description)}
            {monster.descZh ? (
              <span className="ml-1 text-[10.5px] text-subtle">（中文来自游戏汉化表）</span>
            ) : (
              <span className="ml-1 text-[10.5px] text-subtle">（汉化表缺少该条目，回退英文原文）</span>
            )}
          </p>
        )}

        {notes.length > 0 && (
          <div className="mb-3 rounded-md border border-line bg-raised p-2">
            <h3 className="mb-1 text-[11.5px] font-semibold text-muted">特殊机制</h3>
            <ul className="space-y-1">
              {notes.map((note) => (
                <li key={note.text} className="text-[11.5px] leading-relaxed text-muted">
                  <span>{note.text}</span>
                  <span className="ml-1 text-[10.5px] text-subtle">［依据：{note.source}］</span>
                </li>
              ))}
            </ul>
          </div>
        )}

        <div className="mb-3">
          <h3 className="mb-1 flex items-baseline gap-1.5 text-[12px] font-semibold">
            固定技能
            <span className="font-normal text-subtle">{monster.talents.length}</span>
          </h3>
          {monster.talents.length ? (
            <div className="rounded-md border border-line">
              {monster.talents.map((talent) => (
                <TalentRow
                  key={talent.id}
                  ref_={talent}
                  talent={talentOf(talent.id)}
                  terms={terms}
                  onOpen={onSelectTalent}
                  selected={talent.id === selectedTalentId}
                />
              ))}
            </div>
          ) : (
            <p className="text-[11.5px] text-subtle">源码未给这个模板配置固定技能。</p>
          )}
        </div>

        {hasRandom && (
          <div className="mb-3">
            <h3 className="mb-1 text-[12px] font-semibold">随机技能</h3>
            <p className="mb-1.5 text-[11px] text-subtle">
              下列技能是互斥候选，同一只怪物只会获得其中一组或若干个，不能按“同时拥有”理解。
            </p>
            {monster.rngSets.map((set, index) => (
              <details key={index} className="mb-1.5 rounded-md border border-line">
                <summary className="cursor-pointer px-2 py-1.5 text-[12px] font-medium">
                  技能组 {index + 1}
                  <span className="ml-1.5 font-normal text-subtle">{set.length} 个技能</span>
                </summary>
                <div className="border-t border-line">
                  {set.map((talent) => (
                    <TalentRow
                      key={`${index}-${talent.id}`}
                      ref_={talent}
                      talent={talentOf(talent.id)}
                      terms={terms}
                      onOpen={onSelectTalent}
                      selected={talent.id === selectedTalentId}
                    />
                  ))}
                </div>
              </details>
            ))}
            {monster.rngPools.map((pool, index) => (
              <details key={`pool-${index}`} className="mb-1.5 rounded-md border border-line">
                <summary className="cursor-pointer px-2 py-1.5 text-[12px] font-medium">
                  随机技能池 {index + 1}
                  <span className="ml-1.5 font-normal text-subtle">
                    抽取 {pool.count ?? '?'} / 候选 {pool.talents.length}
                  </span>
                </summary>
                <div className="border-t border-line">
                  {pool.talents.map((talent) => (
                    <TalentRow
                      key={`pool-${index}-${talent.id}`}
                      ref_={talent}
                      talent={talentOf(talent.id)}
                      terms={terms}
                      onOpen={onSelectTalent}
                      selected={talent.id === selectedTalentId}
                    />
                  ))}
                </div>
              </details>
            ))}
          </div>
        )}

        <div className="rounded-md border border-line bg-raised px-2 py-1.5 text-[11px] text-subtle">
          <button type="button" className="text-left hover:text-fg" onClick={() => setShowRaw((v) => !v)}>
            {showRaw ? '▾' : '▸'} 数据来源与继承
          </button>
          {showRaw && (
            <ul className="mt-1 space-y-0.5">
              <li>来源包：{SOURCE_LABELS[monster.source] ?? monster.source}</li>
              <li>
                定义位置：{monster.file}:{monster.line}
              </li>
              {monster.defineAs && <li>define_as：{monster.defineAs}</li>}
              {monster.inheritance?.length && <li>父模板链：{monster.inheritance.join(' ← ')}</li>}
              {monster.zone && <li>所在区域文件：{monster.zone}</li>}
              {monster.image && <li>图片：{monster.image}（{monster.imageKind}）</li>}
              <li>点击技能会在右侧技能栏打开通用技能详情，不会离开本页；页面未注入这只怪物的属性与装备，模拟器使用的是技能自身的默认值。</li>
            </ul>
          )}
        </div>

        {!compact && (
          <p className="mt-2 text-[10.5px] leading-relaxed text-subtle">
            收录口径：只统计带字面量名称、且不是抽象 BASE 模板的实体。身份未确认（缺少名称或无 rank）的模板不计入。
          </p>
        )}
      </div>
    </section>
  );
}
