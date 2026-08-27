# GitHub Developer Report — gaearon

> 由 GitHub Scout Skill 生成 · 调查日期 2026-08-27 · 数据来源：GitHub 公开 API

## 基本信息

| 项 | 值 |
|---|---|
| 用户名 | gaearon |
| 显示名 | dan |
| 加入时间 | 2011-05-25 |
| 公开仓库数 | 299（自有 60 / fork 239） |
| Followers | 91,599 |
| 个人站点 | danabra.mov |

（无 bio，故省略该行）

## 技术方向

**主要语言**（自有仓库，按代码字节数加权 + 仓库数佐证）：

| 语言 | 代码占比 | 主语言仓库数 |
|---|---|---|
| JavaScript | 83.8%（2,298 KB） | 41 / 60 |
| TypeScript | 10.6%（291 KB） | 6 / 60 |
| CSS | 3.2%（87 KB） | 3 / 60 |

字节占比由 2014–2017 年的历史项目主导。近 12 个月有 push 的两个主要自有项目（overreacted.io、rscexplorer）均为 TypeScript——**语言重心的迁移在字节统计中尚未体现**。

**主要领域**（每项 ≥2 个项目佐证）：

- **React 构建期与开发期工具**——react-hot-loader（12,166★）、react-proxy（455★）、react-transform-boilerplate（3,333★）、babel-plugin-react-transform（1,071★）、react-transform-hmr（764★）
- **Redux DevTools 监视器组件**——redux-devtools-log-monitor（308★）、redux-devtools-dock-monitor（402★）
- **小型单一职责 React npm 库**——react-document-title（1,850★）、react-side-effect（1,215★）、react-pure-render（447★）、react-deep-force-update（121★）
- **技术写作与教学站点**——overreacted.io（7,270★）、whatthefuck.is（3,037★）、react-makes-you-sad（2,072★）

**近期方向**（最近 12 个月有 push 的 20 个仓库）：React Server Components 协议（rscexplorer）、个人博客持续更新（overreacted.io）、Claude Skills 工具（woodshed，70★）、AT Protocol / Bluesky 生态 fork（atproto、social-app、indigo）、以及 4 个 bug 复现仓库（next-bug-repro、turbopack-seal-bug、react-udv-bug、next-cc-activity-problem）。

## 代表项目

### 1. react-proxy ★★★★★

| 项 | 内容 |
|---|---|
| 用途 | 通用 React 组件代理，作为 React Hot Loader 的底层引擎，在不卸载组件、不丢失 state 的前提下替换组件实现 |
| 技术栈 | JavaScript、Babel（含 decorators / class-properties transform）、Webpack、Mocha、lodash、react-deep-force-update |
| 代码规模 | 约 3,007 行（90 KB 源码） |
| 复杂度 | ★★★★★（得分 87） |
| 个人贡献 | 208 次 commit 中本人 191 次，占 91.8%；owner 且非 fork |
| 活跃情况 | commit 跨度 2014-12-11 → 2017-03-06，约 27 个月；最近 push 2020-09-04 |
| 得分构成 | 影响力 15 + 最近 push 0 + owner 8 + 规模 12 + commit 数 6 + 占比 12 + 跨度 9 + 持续维护 5 + 架构 12 + 技术栈 8 |

**说明**：src/ 下 6 个模块配 test/ 下 13 个测试文件与 Travis CI，是本次分析中结构最完整的仓库。核心内容是 JS 原型替换与 autobind 方法管理——`createPrototypeProxy.js`、`supportsProtoAssignment.js`、`deleteUnknownAutoBindMethods.js` 处理的是跨 React 版本的类实例语义差异。README 明确说明它面向热重载工具作者而非应用开发者。按本次评分排在首位，主因是 91.8% 的本人 commit 占比与完整的模块/测试/CI 结构；它的 stars（455）远低于 react-hot-loader，但影响力维度在 ≥200★ 处饱和，两者同为 15 分。

### 2. overreacted.io ★★★★★

| 项 | 内容 |
|---|---|
| 用途 | 个人技术博客站点（含文章内容与站点实现） |
| 技术栈 | TypeScript、Next.js App Router、MDX（next-mdx-remote-client、remark-gfm、rehype-pretty-code、shiki）、Tailwind CSS、feed（RSS/Atom）、自建 OG 图片生成 |
| 代码规模 | 约 1,645 行（49 KB 源码，不含 Markdown 文章正文） |
| 复杂度 | ★★★★★（得分 82） |
| 个人贡献 | 323 次 commit 中本人 301 次，占 93.2%；owner 且非 fork |
| 活跃情况 | 可见 commit 跨度 2023-10-21 → 2026-06-19，约 32 个月；最近 push 2026-07-04 |
| 得分构成 | 影响力 15 + 最近 push 10 + owner 8 + 规模 8 + commit 数 6 + 占比 12 + 跨度 9 + 持续维护 5 + 架构 8 + 技术栈 3 |

**说明**：目录结构显示是自建站点而非模板套用——`app/[slug]/mdx.ts` 自定义 MDX 管线、`og/generateImage.js` 配三个 TTF 字体做 OG 图渲染、`app/llms.txt/route.ts` 与 `app/atom.xml/route.ts` 各自成路由。有 `.tangled/workflows/deploy.yaml`（CI）但无测试目录，故架构记 8 而非 12。仓库中存在 `CLAUDE.md`。**该仓库无 README（API 返回 404），上述用途判断来自目录结构与依赖清单。**

### 3. react-hot-loader ★★★★★

| 项 | 内容 |
|---|---|
| 用途 | React 组件热替换工具（README 首段已标注 Deprecated，指向后继方案） |
| 技术栈 | JavaScript、Webpack loader、Babel plugin、Travis CI、Prettier/ESLint |
| 代码规模 | 约 11,660 行（349 KB 源码） |
| 复杂度 | ★★★★★（得分 80） |
| 个人贡献 | 贡献者 commit 求和 1,715 次中本人 564 次，占 32.9%；首位贡献者为 theKashey（652 次） |
| 活跃情况 | commit 跨度 2014-07-13 → 2022-11-13，约 100 个月；最近 push 2023-02-10 |
| 得分构成 | 影响力 15 + 最近 push 0 + owner 8 + 规模 12 + commit 数 6 + 占比 5 + 跨度 9 + 持续维护 5 + 架构 12 + 技术栈 8 |

**说明**：本账号 stars 最高的仓库（12,166★，776 fork）。src/test/docs/examples 四层结构，examples 下有 SSR、all-possible-containers 等多个独立可运行子项目，各带自己的 package.json。跨度 8 年多，是本次分析中维护周期最长的项目。**本人 commit 占比 32.9%——项目后期主导权已转移至 theKashey**，这也是它按本次评分排在 react-proxy 之后的主要原因。

### 4. rscexplorer ★★★★☆

| 项 | 内容 |
|---|---|
| 用途 | 在浏览器中同时运行 RSC 的 Server 与 Client 两端，逐步检视 RSC 流与每一步被流式传输的 React 树 |
| 技术栈 | TypeScript、react-server-dom-webpack、@babel/standalone、CodeMirror 6、Vite/Rolldown、Vitest + Playwright、Wrangler（Cloudflare）、husky |
| 代码规模 | 约 7,467 行（224 KB 源码） |
| 复杂度 | ★★★★☆（得分 75） |
| 个人贡献 | 44 次 commit 中本人 38 次，占 86.4%；owner 且非 fork |
| 活跃情况 | commit 跨度 2025-12-16 → 2026-01-05，20 天；最近 push 2026-01-05 |
| 得分构成 | 影响力 15 + 最近 push 5 + owner 8 + 规模 12 + commit 数 3 + 占比 12 + 跨度 3 + 持续维护 0 + 架构 12 + 技术栈 8 |

**说明**：`src/client/runtime/` 下 `flight-parser.ts`、`steppable-stream.ts`、`module-registry.ts`、`timeline.ts` 是对 RSC Flight 协议的自有解析实现，属协议实现类工作。有 `.github/workflows/ci.yml`、Vitest + Playwright 浏览器测试、自定义 ESLint 规则（`eslint/no-mixed-class-prefixes.js`）。20 天内 1,108★，是账号内近三年最受关注的新项目；但 commit 仅跨 2 个自然月，跨度与持续维护两项合计只拿到 3/14 分。

### 5. redux-devtools-log-monitor ★★★★☆

| 项 | 内容 |
|---|---|
| 用途 | Redux DevTools 的默认监视器，以树形视图展示 state 与 action 日志并支持修改历史 |
| 技术栈 | JavaScript、React、react-json-tree、redux-devtools-themes、lodash.debounce、Mocha、Travis CI |
| 代码规模 | 约 651 行（20 KB 源码） |
| 复杂度 | ★★★★☆（得分 74） |
| 个人贡献 | 110 次 commit 中本人 65 次，占 59.1%；owner 且非 fork |
| 活跃情况 | commit 跨度 2015-09-24 → 2017-11-11，约 26 个月；最近 push 2017-11-11 |
| 得分构成 | 影响力 11 + 最近 push 0 + owner 8 + 规模 8 + commit 数 5 + 占比 9 + 跨度 9 + 持续维护 5 + 架构 12 + 技术栈 3 |

**说明**：src/ 下 10 个模块按 React 组件 + actions + reducers 分层，配 test/ 与 Travis CI。规模最小（651 行）但结构完整度与前几名同级，是「小而分层」的典型。技术栈为 React 组件的常规应用，技术栈难度记 3 分，这是它落在第 5 位的主因。

## GitHub 活跃度

| 项 | 值 |
|---|---|
| 最近活动 | 2026-08-23（事件流最近一条）；最近 30 条公开事件为 vercel/next.js 的 14 次 PR 事件、reactjs/react.dev 的 5 次 PR review + 4 次 review comment + 1 次 issue comment、react/react 的 3 次 PR 事件 + 1 次 push + 2 次 review 相关事件 |
| 近 12 个月活跃仓库 | 20 个仓库有 push |
| 长期维护的项目 | 深度分析的 5 个中有 4 个 commit 跨度 > 6 个月（100 / 32 / 27 / 26 个月），rscexplorer 为 20 天 |
| 原创 / fork 比例 | 60 / 239（20.1% / 79.9%） |
| 自有仓库创建年份分布 | 2014–2016 集中期（38 个），2017 年后每年 1–4 个，2026 年 4 个 |

最近 30 条公开事件**全部发生在他人仓库**，无一条落在自有仓库。近期活跃的 fork 上游包括 react、next.js、atproto、social-app、indigo、hono、agent-browser、leaflet。

## 综合评价

**主要方向**：React 生态的开发期工具与构建期工具，辅以小型单一职责 npm 库与技术写作站点。近期重心转向 React Server Components 协议的可视化探索与 AT Protocol 生态的参与。

**技术特征**（基于可观察数据）：

- **参与他人项目为主，自有仓库为辅**——账号 79.9% 为 fork，最近 30 条公开事件全部发生在他人仓库（vercel/next.js、reactjs/react.dev、react/react）
- **工具建设导向**——代表项目中 4 个是给其他开发者用的工具或库（热重载引擎、组件代理、DevTools 监视器、协议检视器），而非面向终端用户的应用
- **单项目长周期维护**——react-hot-loader 跨度 100 个月、overreacted.io 32 个月、react-proxy 27 个月、redux-devtools-log-monitor 26 个月
- **自有项目高度独立**——4 个自有代表项目本人 commit 占比 59.1%–93.2%；唯一低于 50% 的 react-hot-loader（32.9%）是主导权移交给外部贡献者的结果
- **仓库创建高度集中在早期**——60 个自有仓库中 38 个创建于 2014–2016 年；2017 年后新开仓库减少，且近年新增中有 4 个是 bug 复现仓库而非独立项目
- **持续产出技术写作**——overreacted.io、whatthefuck.is、react-makes-you-sad 三个内容站合计 12,379★

**值得关注的项目**：rscexplorer（近期、协议实现、20 天内 1,108★）、react-proxy（结构最完整、本人主导度最高）、woodshed（70★，Claude Skills 工具，本次未进入深度分析）。

## 数据说明

本次调查的数据缺口与估算项：

1. **本账号不含其最知名的作品**。Redux、React、Create React App 均归属组织账号（reduxjs、react/facebook），不在 gaearon 个人账号下，因此不参与本次排序。本报告只反映其个人账号的 299 个公开仓库。
2. **overreacted.io 与 todos 无 README**（API 返回 404）。overreacted.io 的用途判断来自目录结构与 package.json 依赖，属**从结构推断**。
3. **overreacted.io 的 commit 跨度被低估**。仓库创建于 2018-11-30，但最早可见 commit 为 2023-10-21，git 历史存在重写或截断。报告中的 32 个月是可见跨度，非博客实际存续时间。
4. **commit 总数为近似值**，由 contributors 接口的 commit 数求和得出，且只取第一页（100 名贡献者）。react-hot-loader 求和得 1,715，而 commits 接口 Link 头显示实际为 1,890，偏差约 9%。该偏差不改变其占比档位（两种口径下本人占比均 < 50%）。
5. **教程/模板的 README 检查只覆盖了元数据粗排前 15 个候选**，其余 284 个仓库仅按命名、来源、结构三类元数据信号判定。据此判定为示例/模板并降权（×0.3）的有 4 个：react-hot-boilerplate、flux-react-router-example、todos、library-boilerplate。
6. **subliminal 的代码规模得分为 0 分，可能被低估**。GitHub Linguist 对该仓库返回空语言统计（VS Code 主题以 JSON 承载，不计入语言字节数）。它在 Step 5a 以 38 分并列第 10，即使规模项给满分也无法进入 Top 5，故不影响名单。
7. **react-proxy 与 react-hot-loader 的技术栈难度记 8 分（「需要专门领域知识」）属判断调用**——依据是二者为运行时插桩/原型替换类工作。若改记 3 分，两者总分变为 82 与 75，**Top 5 名单不变**，仅内部顺序变为 react-proxy 82、overreacted.io 82、rscexplorer 75、react-hot-loader 75、redux-devtools-log-monitor 74。
8. **架构复杂度与技术栈难度两项（共 20 分）只对最终 Top 5 计算**，因此第 6 名（whatthefuck.is，66 分制 43 分）理论上仍可能反超。本次排序为按本次评分的结果，不是客观定论。
9. **仓库枚举过程中出现一次失败**：首次 `--limit 200` 被截断（返回 200 < 299），改用 `--limit 400` 时遭遇 GraphQL 502 Bad Gateway，重试一次后成功，最终取回 299 个，与 profile 的 `public_repos` 完全一致，全集完整。
10. **fork 仓库的 parent 字段在返回数据中为空**，上游归属由仓库名推断，未经 API 核实。
11. Step 4 粗筛阶段对 fork 统一采用宽松系数 ×0.6（此时尚无贡献者数据），以避免不可逆淘汰；实际无 fork 进入 Top 12，该处理未影响结果。

---

## 附录 A：Step 5a 的 12 个候选

按 Step 5a 的 66 分制得分降序（这是决定 Top 5 的一步）：

| # | 项目 | 66 分制 | 代码行数 | commit 数 | 本人占比 | Stars |
|---|---|---|---|---|---|---|
| 1 | overreacted.io | 57 | 1,645 | 323 | 93.2% | 7,270 |
| 2 | react-proxy | 53 | 3,007 | 208 | 91.8% | 455 |
| 3 | rscexplorer | 52 | 7,467 | 44 | 86.4% | 1,108 |
| 4 | react-hot-loader | 46 | 11,660 | 1,715 | 32.9% | 12,166 |
| 5 | redux-devtools-log-monitor | 45 | 651 | 110 | 59.1% | 308 |
| 6 | whatthefuck.is | 43 | 1,898 | 32 | 62.5% | 3,037 |
| 7 | react-pure-render | 41 | 46 | 22 | 81.8% | 447 |
| 8 | react-document-title | 40 | 224 | 71 | 66.2% | 1,850 |
| 9 | react-makes-you-sad | 38 | 3 | 40 | 60.0% | 2,072 |
| 10 | subliminal | 38 | 0 | 12 | 91.7% | 625 |
| 11 | redux-devtools-dock-monitor | 38 | 232 | 38 | 71.1% | 402 |
| 12 | react-side-effect | 36 | 403 | 90 | 31.1% | 1,215 |

第 9–11 名三者同为 38 分，按规则以 stars 降序破平（2,072 > 625 > 402）。

Step 4（33 分制）出现了 `repo-ranking.md` 预警过的大面积同分——17 个仓库并列 23 分。是 Step 3 的 README 检查（对前 15 个候选）打破了僵局，以下 4 个各命中 ≥2 条示例/模板信号，降权 ×0.3 后退出候选：

| 仓库 | 命中信号 |
|---|---|
| react-hot-boilerplate | 描述含 "example" + README 仅为 4 行弃用提示、结构为最小脚手架 |
| flux-react-router-example | 名称含 "example" + README 自述为 "a sample Flux app I wrote on a weekend... while learning Flux" |
| todos | 描述含 "Examples" + 自述为配套视频课程（"one branch per video"） |
| library-boilerplate | 名称为 boilerplate + README 自述为 "An opinionated setup I plan to use for my libraries" |

## 附录 B：本次 API 调用开销

**合计 72 次**（REST 69 + GraphQL 3），上限 80 次，预算内。

| 步骤 | 调用 | 次数 |
|---|---|---|
| Step 1 用户解析 | `users/gaearon` | 1 |
| Step 2 仓库枚举 | `gh repo list` × 3（1 次被 limit 截断、1 次 502 失败、1 次成功） | 3（GraphQL） |
| Step 2 近期活动 | `users/gaearon/events/public` | 1 |
| Step 3 教程识别 | 前 15 候选的 README | 15 |
| Step 5a 主排序 | 12 候选 ×（languages + contributors） | 24 |
| Step 5b 结构与依赖 | Top 5 ×（git tree + package.json） | 10 |
| Step 5b commit 跨度 | Top 5 ×（Link 末页 + 首 commit + 末 commit） | 15 |
| Step 5b 补取 | redux-devtools-log-monitor 的 tree + package.json + README（前一次批量输出被截断） | 3 |

另有 2 次 `rate_limit` 探测（调查前后各一次），该接口不消耗配额，未计入上表。

计数为逐条命令记录，非配额差值——调查过程中配额窗口发生了重置（复查时 core 与 graphql 均显示 5000/5000、used=0），差值法在本次不可用。
