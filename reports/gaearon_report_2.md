# GitHub Developer Report — gaearon

> 生成时间：2026-08-27 ｜ 调查工具：GitHub Scout Skill（Claude adapter）
> 参数：`top_n=5`、`depth=standard`、`focus=无`

## 基本信息

| 项 | 值 |
|---|---|
| 用户名 | gaearon |
| 显示名 | dan |
| 加入时间 | 2011-05-25 |
| 公开仓库数 | 299 |
| Followers | 91,651 |
| 个人站点 | danabra.mov |

（profile 无 bio、company、location 字段，已按规则删除对应行）

## 技术方向

**主要语言**（60 个原创仓库，按代码字节数加权 + 仓库数佐证）：

| 语言 | 代码体积占比 | 主语言仓库数 |
|---|---|---|
| JavaScript | 83.8%（2,298 KB） | 41 |
| TypeScript | 10.6%（291 KB） | 6 |
| CSS | 3.2%（87 KB） | 3 |

**主要领域**（每项均有 ≥2 个项目佐证）：

- **React 热重载与运行时基础设施** — react-hot-loader（12,165 stars）、react-proxy、react-hot-api、react-deep-force-update、react-transform 系列。这类项目直接操作 React 组件原型与实例，属工具链层而非应用层。
- **React 生态的解释性内容与教学工具** — overreacted.io（7,270 stars，博客）、rscexplorer（1,108 stars）、whatthefuck.is（3,037 stars）、react-makes-you-sad（2,071 stars）、the-redux-journey。
- **React 应用架构示例** — flux-react-router-example（1,420 stars）、todos、react-elmish-example，用于演示状态管理与路由的组合模式。

**近期方向**（最近 12 个月有 push 的原创仓库，共 7 个）：

集中在 **React Server Components 协议**与 **Next.js / Turbopack 缺陷复现**两条线。rscexplorer（2026-01）在浏览器内同时运行 RSC 的 Server 与 Client 端以逐步检视 RSC 流；另有 4 个最小复现仓库：next-cc-activity-problem（2026-07）、turbopack-seal-bug（2026-06）、react-udv-bug（2026-03）、next-bug-repro（2025-11）。

## 代表项目

> 按本次评分排序。架构复杂度与技术栈难度两项（共 20 分）只对 Top 5 计算，第 6 名理论上仍可能反超，排序非客观定论。

### 1. react-proxy ★★★★★

| 项 | 内容 |
|---|---|
| 用途 | 通用 React 组件代理，作为 React Hot Loader 的底层引擎 |
| 技术栈 | JavaScript / Babel 工具链；运行时依赖仅 lodash + react-deep-force-update |
| 代码规模 | 约 3,007 行（90 KB 源码） |
| 复杂度 | ★★★★★（得分 87） |
| 个人贡献 | 191 / 208 commits（92%），owner 且非 fork |
| 活跃情况 | commit 跨度 2014-12 → 2020-09（约 5.7 年）；已停止更新 |

**说明**：src/ 下为 createClassProxy、createPrototypeProxy、bindAutoBindMethods 等 6 个模块，配 15 个测试文件与 .travis.yml。README 明确说明它不面向应用开发者，只供热重载工具调用。技术栈难度按「需要专门领域知识」计 8 分——它做的是原型级别的运行时改写，而非框架常规使用；这一项是本次评分中判断成分最重的一处。

### 2. overreacted.io ★★★★★

| 项 | 内容 |
|---|---|
| 用途 | 个人技术博客站点（依据：目录结构与依赖清单推断，仓库无 README） |
| 技术栈 | TypeScript + Next.js App Router + MDX（next-mdx-remote-client、rehype-pretty-code、remark-gfm）+ Tailwind CSS |
| 代码规模 | 约 1,646 行（49 KB 源码，359 个文件含文章与资源） |
| 复杂度 | ★★★★★（得分 82） |
| 个人贡献 | 301 / 323 commits（93%），owner 且非 fork |
| 活跃情况 | commit 跨度 2023-10 → 2026-07（约 2.7 年）；最近 push 2 个月内 |

**说明**：app/ 下按 Next.js App Router 组织，含 [slug] 动态路由、opengraph-image.tsx 动态封面图生成、atom.xml 与 llms.txt 两个 route handler。无 tests/ 与 CI 配置，架构分档为「有模块划分」而非「多模块 + 测试 + CI」。7,270 stars 是本次候选中最高的。

### 3. react-hot-loader ★★★★★

| 项 | 内容 |
|---|---|
| 用途 | React 组件实时热替换工具 |
| 技术栈 | JavaScript + Babel 插件（src/fresh/babel.js）；含 preact adapter；Jest + Enzyme 测试 |
| 代码规模 | 约 11,660 行（350 KB 源码） |
| 复杂度 | ★★★★★（得分 80） |
| 个人贡献 | 564 / 1,715 commits（33%）；首位贡献者为 theKashey（652 commits） |
| 活跃情况 | commit 跨度 2014-07 → 2023-02（约 8.5 年）；README 声明已由 React Fast Refresh 取代 |

**说明**：Top 5 中代码规模与 commit 数最大者（12,165 stars 亦为全账号最高）。src/ 下分 adapters/、fresh/、global/ 等子模块，69 个测试文件，scripts/ 内有针对 React 15/16/17 的分版本 CI 脚本。本人 commit 占比 33% 落在 20%–50% 档，是该项目得分低于前两名的主要原因——后期维护主要由他人承担。

### 4. rscexplorer ★★★★☆

| 项 | 内容 |
|---|---|
| 用途 | 面向教学者与探索者的 React Server Components 协议检视工具 |
| 技术栈 | TypeScript + react-server-dom-webpack + @babel/standalone + CodeMirror 6 + Vitest（browser + playwright） |
| 代码规模 | 约 7,467 行（224 KB 源码） |
| 复杂度 | ★★★★☆（得分 75） |
| 个人贡献 | 38 / 44 commits（86%），owner 且非 fork |
| 活跃情况 | commit 跨度 2025-12-16 → 2026-01-05（20 天）；分布仅跨 2 个月 |

**说明**：README 说明它在浏览器中同时运行 RSC 的 Server 与 Client 部分，可逐步检视 RSC 流与每一步的 React 树，并附 12 个示例（含 CVE-2025-55182 的复现）。工程配置是 Top 5 中最完整的：.github/workflows 两个、husky + lint-staged、tests/ 16 个文件、独立 eslint/ 与 types/ 目录。得分受限于时间维度——20 天跨度只得 3/9 分，持续维护项计 0 分。

### 5. flux-react-router-example ★★★★☆

| 项 | 内容 |
|---|---|
| 用途 | Flux + React Router 的实战示例应用，调用 GitHub API 展示用户 starred 仓库与仓库 stargazers |
| 技术栈 | JavaScript（ES6/Babel）+ flux + react-router + normalizr + Webpack HMR |
| 代码规模 | 约 1,077 行（32 KB 源码） |
| 复杂度 | ★★★★☆（得分 70） |
| 个人贡献 | 72 / 110 commits（66%） |
| 活跃情况 | commit 跨度 2014-08 → 2017-08（约 3 年） |

**说明**：scripts/ 下按 actions/、api/、components/、constants/、pages/、stores/ 分层。README 记录了作者当时关注的具体问题（分页、嵌套 JSON 归一化、Store 避免大 switch、返回即时性），并已注明作者后来更倾向 Redux、该示例已被移植到 Redux 仓库。无测试目录与 CI 配置。

## GitHub 活跃度

| 项 | 值 |
|---|---|
| 最近活动 | 2026-08-23，向 react/react 提交 PR |
| 近 12 个月活动分布 | 公开事件集中在他人/组织仓库：react/react、vercel/next.js、reactjs/react.dev（PR、PR review、issue comment）；自有仓库中 7 个原创仓库在近 12 个月有 push |
| 长期维护的项目数 | Top 5 中 4 个 commit 分布跨越 ≥3 个月（rscexplorer 除外）；全量 299 仓库未逐个核实 |
| 原创 / fork 比例 | 60 原创 / 239 fork（fork 占 79.9%） |
| 归档 / 空仓库 | 4 个 archived，1 个 empty |
| 原创仓库创建年份分布 | 2014–2016 年 38 个（占原创的 63%），2017–2023 年逐年 1–5 个，2024–2026 年 8 个 |

## 综合评价

**主要方向**：React 生态的工具链与运行时基础设施建设，并以博客、可交互工具等形式产出解释性内容。JavaScript 占其原创代码体积的 83.8%，TypeScript 集中在 2023 年后的新项目。

**技术特征**（均为可观察事实的描述）：

- **参与他人项目的比重高于自建**：239/299 仓库为 fork，近期公开事件几乎全部发生在 react/react、vercel/next.js、reactjs/react.dev 而非自有仓库。
- **自有项目集中在工具层而非应用层**：Top 5 中 3 个（react-proxy、react-hot-loader，及支撑二者的 react-deep-force-update）操作 React 内部机制，1 个是内容站点，1 个是示例应用。
- **早期开新坑频繁，近期集中**：原创仓库 63% 创建于 2014–2016 年三年内；2017 年后每年 1–5 个，且近两年新建的多为单一用途的缺陷复现仓库。
- **长期单项目维护与短期突击并存**：react-hot-loader 跨度 8.5 年、react-proxy 5.7 年，而 rscexplorer 的 44 次 commit 集中在 20 天内。
- **早期项目的主导权逐步移交**：react-hot-loader 中本人 commit 占 33%，首位贡献者为他人。

**值得关注的项目**：rscexplorer 是近期唯一的完整新建工具（工程配置最完备，含 CI、husky、浏览器端测试），可反映其当前技术关注点；react-proxy 与 react-hot-loader 反映其在 React 运行时层的长期投入。

## 数据说明

本次调查的数据缺口与估算项：

1. **overreacted.io 无 README**（API 返回 404）。其「用途」为从目录结构（app/[slug]、atom.xml route、og/）与依赖清单（next-mdx-remote-client、feed、gray-matter）推断，属推测，未经 README 证实。
2. **commit 总数为近似值**。由 contributors 接口的各贡献者 commit 数求和得出，与 commits 接口的分页末页号存在小幅出入（react-hot-loader：1,715 vs 1,890；react-proxy：208 vs 211；flux-react-router-example：110 vs 112；overreacted.io 与 rscexplorer 两者一致）。分档结论不受影响。
3. **commit 跨度的末端取 pushedAt 而非末次 commit 时间**。首次 commit 时间为实测（commits 接口末页），末次以 pushedAt 近似。对 Top 5 的跨度分档（均落在 <1 周 / 1 周–1 月 / >6 月 的明确档位）无影响。
4. **教程/模板识别仅覆盖元数据信号**。命名、来源（isTemplate）、空仓库三类信号对全部 299 个仓库执行，结果为 0 命中；README 与 commit message 两类信号未执行——因元数据粗排后 Top 15 中无任何仓库命中 ≥1 条信号，无触发必要。
5. **Step 4 存在 17 个仓库精确同分（23.0 分）**。33 分制下 stars ≥200 的老仓库全部为「影响力 15 + 最近 push 0 + owner 8」，Top 12 的截断落在该同分区内，由规则指定的 stars 降序破平决定（第 12 名 react-proxy 455 stars vs 第 13 名 react-pure-render 447 stars）。截断确定但区分度低。
6. **fork 降权系数在 Step 4 统一按 ×0.6（较宽松档）处理**，因该阶段无 contributors 数据、无法区分「无实质自有 commit」（×0.1）与「有显著自有改动」（×0.6）。实际影响为零：得分最高的 fork（gaearon/react，12.6 分）距 Top 12 截断线（23.0）仍有较大差距，两种系数下均不入选。
7. **Step 5b 的 20 分（架构复杂度 + 技术栈难度）只对 Top 5 计算**，第 6 名 whatthefuck.is（5a 得 43 分，与第 5 名 flux-react-router-example 的 45 分相差 2 分）未获此项补分，理论上存在反超可能。
8. **react-proxy 与 react-hot-loader 的技术栈难度按 8 分（需要专门领域知识）计入**。评分表列举的领域不含「运行时代码改写 / 热重载引擎」，此判断依据其原型改写与 Babel 插件实现归入编译器/工具链一类，是本次评分中主观成分最高的一项。若按 3 分（主流框架常规应用）计，react-proxy 降至 82 分（与 overreacted.io 并列，按 stars 破平则退居第 2）、react-hot-loader 降至 75 分（与 rscexplorer 并列，按 stars 破平仍居第 3）。
9. **API 配额窗口在调查过程中重置**，故无法用 rate_limit 前后差值反查调用数；附录 C 的计数为逐条调用台账。
10. 全程仅使用公开数据，`gh repo list` 显式带 `--visibility public`，返回 299 条与 profile 的 `public_repos: 299` 完全一致，无非公开仓库泄漏。

---

## 附录 A · 最终 Top 5

| 排名 | 项目名 | 100 分制得分 | 星级 |
|---|---|---|---|
| 1 | react-proxy | 87 | ★★★★★ |
| 2 | overreacted.io | 82 | ★★★★★ |
| 3 | react-hot-loader | 80 | ★★★★★ |
| 4 | rscexplorer | 75 | ★★★★☆ |
| 5 | flux-react-router-example | 70 | ★★★★☆ |

Step 5a（66 分制）选出的名单顺序为 overreacted.io(57) → react-proxy(53) → rscexplorer(52) → react-hot-loader(46) → flux-react-router-example(45)。Step 5b 补入跨度、持续维护、架构、技术栈四项后**只改变了内部顺序，入选名单未变**——与 `repo-ranking.md` 第六节的预期一致。

### Top 5 得分构成

| 项目 | 5a 小计 | 跨度 | 持续维护 | 架构 | 技术栈 | 总分 |
|---|---|---|---|---|---|---|
| react-proxy | 53 | 9 | 5 | 12 | 8 | **87** |
| overreacted.io | 57 | 9 | 5 | 8 | 3 | **82** |
| react-hot-loader | 46 | 9 | 5 | 12 | 8 | **80** |
| rscexplorer | 52 | 3 | 0 | 12 | 8 | **75** |
| flux-react-router-example | 45 | 9 | 5 | 8 | 3 | **70** |

## 附录 B · Step 5a 的 12 个候选名单

按进入 Step 5a 时的 Step 4 粗筛顺序（33 分制，同分按 stars 降序破平）：

| # | 仓库名 | Step 4 得分 | Stars | Step 5a 得分（/66） | 是否入选 Top 5 |
|---|---|---|---|---|---|
| 1 | overreacted.io | 31.0 | 7,270 | 57 | ✅ |
| 2 | rscexplorer | 25.0 | 1,108 | 52 | ✅ |
| 3 | react-hot-loader | 23.0 | 12,165 | 46 | ✅ |
| 4 | react-hot-boilerplate | 23.0 | 3,889 | 40 | — |
| 5 | whatthefuck.is | 23.0 | 3,037 | 43 | — |
| 6 | react-makes-you-sad | 23.0 | 2,071 | 38 | — |
| 7 | react-document-title | 23.0 | 1,850 | 40 | — |
| 8 | flux-react-router-example | 23.0 | 1,420 | 45 | ✅ |
| 9 | react-side-effect | 23.0 | 1,215 | 36 | — |
| 10 | todos | 23.0 | 786 | 38 | — |
| 11 | subliminal | 23.0 | 625 | 38 | — |
| 12 | react-proxy | 23.0 | 455 | 53 | ✅ |

值得注意的是 **react-proxy 在粗筛中排第 12（最后一名）、在主排序中升至第 2**——正是 `repo-ranking.md` 中「粗筛必须放宽到 Top 12」所要防范的情形。若按 `top_n × 1` 截断到 5，它会直接出局。

## 附录 C · GitHub API 调用台账

**合计 56 次**（REST 54 + GraphQL 2），上限 80，预算参考值 66。

| 阶段 | 调用 | 次数 |
|---|---|---|
| 前置检查 | rate_limit | 1 |
| Step 1 | users/gaearon | 1 |
| Step 2 | gh repo list（--limit 200，被截断作废） | 1 (GraphQL) |
| Step 2 | gh repo list（--limit 300，采用） | 1 (GraphQL) |
| Step 2 | users/gaearon/events/public | 1 |
| Step 5a | languages × 12 | 12 |
| Step 5a | contributors × 12 | 12 |
| Step 5b | readme × 5 | 5 |
| Step 5b | git/trees × 5 | 5 |
| Step 5b | contents/package.json × 5 | 5 |
| Step 5b | commits（取 Link 末页号）× 5 | 5 |
| Step 5b | commits 末页日期（首次尝试，4 个因 shell 重定向失败未发出） | 1 |
| Step 5b | commits 末页日期（重试） | 5 |
| 收尾核对 | rate_limit | 1 |

其中 **2 次为浪费**：`--limit 200` 那次仓库枚举（299 > 200 被截断，需重取）、以及首次末页日期批次中实际发出的 1 次（其余 4 次因 `cd X && (...) &` 的作用域问题在重定向阶段即失败，未产生 API 调用）。Step 3 的 README 检查因元数据信号 0 命中而未触发，节省了预算中的 ≤15 次。
