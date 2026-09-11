# 部署到 GitHub Pages

**当前状态：已上线**（2026-09-11，发布提交 `cb27214`）

| 项 | 地址 |
| --- | --- |
| 主地址 | <https://ovideros.github.io/modern_tome_viewer/> |
| 账号自定义域名 | <http://old.ovideros.site/modern_tome_viewer/>（见文末说明） |
| 仓库 | <https://github.com/ovideros/modern_tome_viewer>（public） |
| Actions | <https://github.com/ovideros/modern_tome_viewer/actions> |

## 组成

| 部分 | 位置 |
| --- | --- |
| 工作流 | `.github/workflows/deploy-pages.yml`（push 到 `main` 或手动触发） |
| 构建入口 | `modern_tome_viewer/scripts/build-pages.mjs`（= `npm run build:pages`） |
| 产物 | `modern_tome_viewer/dist`（Vite 构建，含 `data/` 与 `img/`） |

Vite 用 `base: './'`，所以构建产物既可以放在仓库根，也可以放在
`/modern_tome_viewer/` 这样的子路径下，不需要为 Pages 改配置。页面是 hash 路由
（`#/monsters`），深链接不依赖服务端重写。

## 线上验证记录（2026-09-10）

在 <https://ovideros.github.io/modern_tome_viewer/> 用真实浏览器跑过：

- `#/monsters` 列出 812 个怪物；`?cat=boss&m=WALROG` 得 98 条，刷新后仍是 98；
  点技能在页内打开面板，URL 仍停在 `#/monsters`。
- 怪物页 93 张图片全部加载成功，0 张破损。
- `#/search`、`#/classes`、`#/races`、`#/favorites` 均正常，0 控制台报错、
  0 失败请求。

## 为什么提交 `public/data` 与 `public/img`

站点在运行时 `fetch` 这些文件，而生成它们需要游戏本体源码包：

- `t-engine4-src-1.7.6/.../tome-1.7.6-gfx.team`（约 24 MB 的图集压缩包）
- `tome-src-full/data/locales/zh_hans.lua` 等语言表（16 MB，仓库策略不上传）

仓库按既有策略**不追踪这些游戏媒体/语言表**，所以 GitHub Actions 的干净 checkout
跑不了 `npm run data`。因此把生成结果提交进仓库，CI 只做 `vite build`：

- 提交：`public/data/*.json`（约 5.4 MB）+ `public/img/**`（约 19 MB，681 张怪物图、
  技能图标、职业与种族画像）
- 不提交：`dist/`、`node_modules/`、`t-engine4-src-1.7.6/`（638 MB 引擎解压树，
  已加进 `.gitignore`）
- 本体的 Lua（`tome-src-full/data/**` 与 `dlc-src/**/*.lua`）**是**提交的，所以克隆
  后仍能重跑数据管线的大部分内容；缺的只是 gfx 图集与语言表。

`.gitignore` 里显式写了 `!public/data/`、`!public/img/` 的例外，并在注释里说明原因。
提交的是**从本地源码生成的产物**，用 `npm run data` 可以完整重放；`build-pages.mjs`
会在构建前检查必需文件是否存在，缺了就明确报错而不是发布一个坏站点。

## 本地发布前检查

```bash
cd modern_tome_viewer
npm run data            # 需要本机有游戏源码包；会刷新 public/data 与 public/img
npm run build:pages     # 校验数据文件存在后执行 vite build
npm run serve           # http://127.0.0.1:4173/ 预览 dist/
git add modern_tome_viewer/public && git commit -m "更新站点数据"
```

注意：`npm run data` 会把 `public/data`、`public/img` 中**不再被引用**的旧文件留在
原地（历史图片、旧版本技能图标）。要得到干净的产物，删掉这两个目录再重跑：

```bash
rm -rf public/data public/img && npm run data
```

## 首次启用 Pages

工作流需要 Pages 的 `build_type` 为 `workflow`。两种方式：

1. **网页**：Settings → Pages → Build and deployment → Source 选 **GitHub Actions**。
2. **命令行**（本机已用过的做法，仓库需 public 或账号为 Pro）：

```bash
TOKEN=$(printf 'protocol=https\nhost=github.com\n\n' | git credential fill | sed -n 's/^password=//p')
curl -sS -X POST -H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/ovideros/modern_tome_viewer/pages \
  -d '{"build_type":"workflow"}'
```

之后每次 push 到 `main` 都会自动部署；也可以在 Actions 页面手动 `Run workflow`。

## 克隆后能做什么

| 命令 | 干净克隆（无游戏媒体） | 本机完整源码 |
| --- | --- | --- |
| `npm run build:pages` | ✅ 直接可用（已提交产物） | ✅ |
| `npm run smoke` / `verify` / `test:monsters` | ✅（3 项需要图集/语言表的用例会显示 skip） | ✅ monsters 51/51 · verify 87/87 · smoke 70/70 |
| `npm run e2e` | ✅（需先 `npm run serve`） | ✅ |
| `npm run data` | ❌ 缺 gfx 图集与语言表 | ✅ |

`npm run data` 缺图集时不会崩，只是把怪物图片记为缺口并在
`public/data/monsters-report.json` 的 `missingArtSources` 里写明。

## 提交与推送（接手时先看这段）

发布提交是 `cb27214`，远程 `main` 就在这里。本地若还停在旧提交，先同步：

```bash
cd /Users/ovideros/Codes/senior1/modern_tome
git remote add origin https://github.com/ovideros/modern_tome_viewer.git   # 已存在会报错，忽略
git fetch origin main
git switch -c main --track origin/main      # 若已有 main 分支，跳过这步
git reset --hard origin/main
```

之后正常提交即可，push 到 `main` 就会自动部署：

```bash
git add -A && git commit -m "…" && git push
```

**提交前务必看一眼 `git status --short`**：根目录是白名单式 `.gitignore`
（`dlc-src/**/*.*` 这类规则不覆盖新目录），历史上曾一次性暂存进 666 MB 的
`t-engine4-src-1.7.6/` 引擎树。现在该目录已被显式忽略，但仍建议提交前确认
暂存区里没有它（`git diff --cached --name-only | grep t-engine4`）。

## 账号级自定义域名

`ovideros.github.io` 仓库设置了自定义域名 `old.ovideros.site`，GitHub 会把它套用到
该账号下**所有** `*.github.io/<repo>/` 站点，所以本项目除主地址外还有
<http://old.ovideros.site/modern_tome_viewer/>（两者返回同一份页面）。

本仓库里**没有** `CNAME` 文件；要改或删这个域名，得去 `ovideros.github.io` 仓库的
Settings → Pages。默认的 `ovideros.github.io/modern_tome_viewer/` 始终有效。

## 常见问题

| 现象 | 原因与处理 |
| --- | --- |
| Actions 报 `Get Pages site failed` / `Not Found` | Pages 还没启用，按上一节设置 Source 为 GitHub Actions |
| 页面白屏、`data/*.json` 404 | 提交产物时漏了文件：确认 `public/data` 已在版本控制里（`git ls-files modern_tome_viewer/public/data`），再重新跑 `npm run build:pages` 检查 |
| 图片 404 但页面能开 | `public/img` 没提交全；`npm run data` 后 `git status` 应显示新增图片 |
| 技能图标缺失（少量） | 上游导出本身缺 65 个图标，界面用首字母占位，属预期 |
| 部署成功但仍是旧版本 | Pages 有 CDN 缓存；等待一两分钟，或看 Actions 里 `deploy` 步骤的页面 URL |
