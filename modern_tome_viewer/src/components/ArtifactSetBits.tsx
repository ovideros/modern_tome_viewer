import { useState, type ReactNode } from 'react';
import { assetUrl } from '../lib/data';
import { STAT_TAGS } from '../lib/item-labels';
import type { Artifact, ArtifactDataset, ArtifactSet, ArtifactSetBranch, ArtifactSetEffect } from '../lib/items';
import type { TalentEntry, TalentTree } from '../lib/types';

const CUSTOM_LABELS: Record<string, string> = {
  skullcracker_mult: '碎颅倍率',
  demonblood_dam: '恶魔之血伤害加成',
  demonblood_def: '恶魔之血防御加成',
  size_category: '体型等级',
  paradox_reduce_anomalies: '悖论异常减少',
  ms_set_harmonious: '和谐共鸣条件',
  ms_set_resonating: '共鸣条件',
  talents_add_levels: '技能等级加成',
  talents_types_mastery: '技能树掌握加成',
  max_steam: '蒸汽上限',
  steam_boots_on_move: '移动时蒸汽回复',
};

const TREE_LABELS: Record<string, string> = {
  'cunning/stealth': '潜行',
  'psionic/kinetic-mastery': '动能掌握',
  'psionic/thermal-mastery': '热能掌握',
  'psionic/charged-mastery': '电能掌握',
};

const BRANCH_LABELS: Record<string, string> = {
  complete: '完整套装',
  seasons: '季节平衡',
  harmonious: '和谐共鸣',
  kinchar: '动能 + 电能',
  charther: '电能 + 热能',
  kinther: '动能 + 热能',
  resonating: '三件共鸣',
};

const CONDITION_LABELS: Record<string, string> = {
  ms_set_harmonious: '和谐共鸣',
  ms_set_resonating: '三件共鸣',
};

function numberText(value: number, scale = 1) {
  const scaled = Math.round(value * scale * 1000) / 1000;
  return Number.isInteger(scaled) ? String(scaled) : scaled.toFixed(3).replace(/0+$/, '').replace(/\.$/, '');
}

function entryLabel(key: string, dataset: ArtifactDataset) {
  return dataset.labels.damageTypes[key] ?? dataset.labels.actorTypes?.[key] ?? TREE_LABELS[key] ?? STAT_TAGS[key] ?? key;
}

function scalarText(value: number | string, scale = 1) {
  return typeof value === 'number' ? numberText(value, scale) : value;
}

export function setEffectText(effect: ArtifactSetEffect, dataset: ArtifactDataset): string {
  if (effect.kind === 'talent') return effect.text;
  if (effect.kind === 'runtime') return effect.text;
  const meta = effect.key ? dataset.fieldMeta[effect.key] : undefined;
  const label = meta?.labelZh ?? CUSTOM_LABELS[effect.key ?? ''] ?? effect.key ?? '特殊属性';
  const method = effect.method === 'specialWearAdd' ? '穿戴效果' : '套装效果';
  const values = effect.entries?.length
    ? effect.entries.map((entry) => `${entryLabel(entry.key, dataset)} ${scalarText(entry.value, meta?.scale ?? 1)}${meta?.unit ?? ''}`).join('、')
    : effect.value === null || effect.value === undefined
      ? ''
      : `${scalarText(effect.value, meta?.scale ?? 1)}${meta?.unit ?? ''}`;
  return `${method}：${label}${values ? ` ${values}` : ''}`;
}

function TalentReference({
  id,
  talentOf,
  onOpenTalent,
}: {
  id: string;
  talentOf?: (id: string) => TalentEntry | undefined;
  onOpenTalent?: (id: string) => void;
}) {
  const talent = talentOf?.(id);
  const label = talent?.plainName ?? id;
  if (!onOpenTalent) return <>{label}</>;
  return (
    <button
      type="button"
      className="text-accent-strong hover:underline"
      onClick={() => onOpenTalent(id)}
      title={`在高级搜索中查看「${label}」`}
    >
      {label}
    </button>
  );
}

function TreeReference({
  id,
  treeOf,
  onOpenTree,
}: {
  id: string;
  treeOf?: (id: string) => TalentTree | undefined;
  onOpenTree?: (id: string) => void;
}) {
  const tree = treeOf?.(id);
  const label = tree?.plainName ?? TREE_LABELS[id] ?? id;
  if (!onOpenTree) return <>{label}</>;
  return (
    <button
      type="button"
      className="text-accent-strong hover:underline"
      onClick={() => onOpenTree(id)}
      title={`在高级搜索中查看「${label}」技能树`}
    >
      {label}
    </button>
  );
}

function effectLevel(effect: ArtifactSetEffect) {
  return effect.text.match(/（等级\s*([^）]+)）/)?.[1] ?? null;
}

function EffectContent({
  effect,
  dataset,
  talentOf,
  treeOf,
  onOpenTalent,
  onOpenTree,
}: {
  effect: ArtifactSetEffect;
  dataset: ArtifactDataset;
  talentOf?: (id: string) => TalentEntry | undefined;
  treeOf?: (id: string) => TalentTree | undefined;
  onOpenTalent?: (id: string) => void;
  onOpenTree?: (id: string) => void;
}): ReactNode {
  if (effect.kind === 'runtime') return effect.text;
  if (effect.kind === 'talent') {
    if (!effect.talentId) return effect.text;
    return (
      <>
        获得技能 <TalentReference id={effect.talentId} talentOf={talentOf} onOpenTalent={onOpenTalent} />
        {effectLevel(effect) && `（等级 ${effectLevel(effect)}）`}
      </>
    );
  }

  const meta = effect.key ? dataset.fieldMeta[effect.key] : undefined;
  const label = meta?.labelZh ?? CUSTOM_LABELS[effect.key ?? ''] ?? effect.key ?? '特殊属性';
  const method = effect.method === 'specialWearAdd' ? '穿戴效果' : '套装效果';
  const formatValue = (value: number | string) => `${scalarText(value, meta?.scale ?? 1)}${meta?.unit ?? ''}`;
  const entries = effect.entries?.map((entry) => {
    const value = formatValue(entry.value);
    if (effect.key === 'talents_add_levels' && /^T_[A-Z0-9_]+$/.test(entry.key)) {
      return (
        <span key={entry.key}>
          <TalentReference id={entry.key} talentOf={talentOf} onOpenTalent={onOpenTalent} /> {value}级
        </span>
      );
    }
    if (effect.key === 'talents_types_mastery' && entry.key.includes('/')) {
      return (
        <span key={entry.key}>
          <TreeReference id={entry.key} treeOf={treeOf} onOpenTree={onOpenTree} /> +{value}
        </span>
      );
    }
    return <span key={entry.key}>{`${entryLabel(entry.key, dataset)} ${value}`}</span>;
  });
  const scalar = effect.value === null || effect.value === undefined ? '' : formatValue(effect.value);
  return (
    <>
      {method}：{label}{entries?.length ? <> {entries.reduce<ReactNode[]>((out, entry, index) => { if (index) out.push('、'); out.push(entry); return out; }, [])}</> : scalar ? ` ${scalar}` : ''}
    </>
  );
}

function artifactName(artifact: Artifact | undefined, fallback: string) {
  return artifact ? artifact.nameZh ?? artifact.name : fallback;
}

export function setBranchLabel(id: string) {
  return BRANCH_LABELS[id] ?? id;
}

export function SetConditionText({
  branch,
  dataset,
}: {
  branch: ArtifactSetBranch;
  dataset: ArtifactDataset;
}) {
  const artifactConditions = branch.conditions
    .filter((condition) => condition.kind === 'artifact')
    .map((condition) => artifactName(
      dataset.artifacts.find((artifact) => artifact.id === condition.artifactId),
      condition.ref ?? '未收录物品',
    ));
  const flagConditions = branch.conditions
    .filter((condition) => condition.kind === 'flag')
    .map((condition) => `${CONDITION_LABELS[condition.key ?? ''] ?? condition.key} = ${String(condition.value)}`);
  if (!artifactConditions.length && !flagConditions.length) return null;
  return (
    <p className="text-[11.5px] text-subtle">
      条件：{artifactConditions.length ? `同时装备 ${artifactConditions.join('、')}` : '满足运行时条件'}
      {flagConditions.length > 0 && `；${flagConditions.join('、')}`}
    </p>
  );
}

export function SetEffectList({
  branch,
  dataset,
  talentOf,
  treeOf,
  onOpenTalent,
  onOpenTree,
}: {
  branch: ArtifactSetBranch;
  dataset: ArtifactDataset;
  talentOf?: (id: string) => TalentEntry | undefined;
  treeOf?: (id: string) => TalentTree | undefined;
  onOpenTalent?: (id: string) => void;
  onOpenTree?: (id: string) => void;
}) {
  return (
    <div className="space-y-1">
      <SetConditionText branch={branch} dataset={dataset} />
      {branch.effects.length > 0 ? (
        <ul className="space-y-0.5 text-[12px]">
          {branch.effects.map((effect, index) => (
            <li key={`${effect.kind}-${effect.key ?? effect.talentId ?? 'runtime'}-${index}`} className={effect.kind === 'runtime' ? 'text-amber-700 dark:text-amber-300' : ''}>
              <EffectContent
                effect={effect}
                dataset={dataset}
                talentOf={talentOf}
                treeOf={treeOf}
                onOpenTalent={onOpenTalent}
                onOpenTree={onOpenTree}
              />
            </li>
          ))}
        </ul>
      ) : (
        <p className="text-[12px] text-subtle">源码未定义额外静态数值。</p>
      )}
      {branch.brokenEffects.length > 0 && (
        <p className="text-[11.5px] text-subtle">
          {branch.brokenEffects.map((effect) => {
            if (effect.kind !== 'runtime') return `解除时：${setEffectText(effect, dataset)}`;
            return effect.text.startsWith('解除套装时：') ? effect.text : `解除时：${effect.text}`;
          }).join('；')}
        </p>
      )}
    </div>
  );
}

export function ArtifactSetSummary({
  set,
  dataset,
  onOpenSet,
  talentOf,
  treeOf,
  onOpenTalent,
  onOpenTree,
}: {
  set: ArtifactSet;
  dataset: ArtifactDataset;
  onOpenSet?: (id: string) => void;
  talentOf?: (id: string) => TalentEntry | undefined;
  treeOf?: (id: string) => TalentTree | undefined;
  onOpenTalent?: (id: string) => void;
  onOpenTree?: (id: string) => void;
}) {
  const members = set.memberIds.map((id) => dataset.artifacts.find((artifact) => artifact.id === id));
  return (
    <section className="rounded-lg border border-line bg-surface-raised/60 px-3 py-2.5">
      <div className="flex flex-wrap items-baseline justify-between gap-2">
        <h3 className="text-[13px] font-semibold">所属套装</h3>
        {onOpenSet && (
          <button type="button" className="btn px-2 py-0.5 text-[11px]" onClick={() => onOpenSet(set.id)}>
            查看套装详情
          </button>
        )}
      </div>
      <p className="mt-1 text-[12.5px] font-medium">{set.name}</p>
      <div className="mt-2 flex flex-wrap gap-2">
        {members.map((member, index) => (
          <span key={member?.id ?? index} className="inline-flex items-center gap-1.5 rounded border border-line bg-surface px-1.5 py-1 text-[11px]">
            {member && <ArtifactThumbnail artifact={member} size={30} />}
            <span className="max-w-[14rem] truncate">{artifactName(member, set.memberIds[index])}</span>
          </span>
        ))}
      </div>
      <div className="mt-2 space-y-2">
        {set.branches.map((branch) => (
          <div key={branch.id}>
            {branch.id !== 'complete' && <p className="mb-0.5 text-[12px] font-semibold">分支：{setBranchLabel(branch.id)}</p>}
            <SetEffectList
              branch={branch}
              dataset={dataset}
              talentOf={talentOf}
              treeOf={treeOf}
              onOpenTalent={onOpenTalent}
              onOpenTree={onOpenTree}
            />
          </div>
        ))}
      </div>
    </section>
  );
}

/** Small pixel-art preview used when a set is represented as a card. */
export function ArtifactThumbnail({ artifact, size = 40 }: { artifact: Artifact; size?: number }) {
  const [failed, setFailed] = useState(false);
  if (!artifact.imagePath || failed) {
    return (
      <span
        className="flex shrink-0 items-center justify-center rounded border border-line bg-sunken px-1 text-[9px] text-subtle"
        style={{ width: size, height: size }}
        title={artifact.image ? `缺少图标：${artifact.image}` : '该物品没有独立图标文件'}
      >
        {artifact.typeZh ?? artifact.type ?? '?'}
      </span>
    );
  }
  return (
    <img
      src={assetUrl(artifact.imagePath)}
      alt=""
      width={size}
      height={size}
      className="shrink-0 rounded border border-line bg-sunken"
      style={{ width: size, height: size, imageRendering: 'pixelated' }}
      onError={() => setFailed(true)}
    />
  );
}
