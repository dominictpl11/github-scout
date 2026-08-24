# GitHub Scout

> **AI-powered GitHub developer intelligence skill for ChatGPT and Claude.**

输入一个 GitHub 用户名，自动调查其公开仓库与活动，产出开发者技术画像：在做什么方向、技术栈是什么、哪些是真正的代表作、维护得是否持续。

## 它解决什么问题

看一个人的 GitHub 主页，最费时的不是读代码，而是**从几十个仓库里分辨出哪三个值得看**。fork、课程作业、跟着教程敲的 demo 常常和真正的作品混在一起，按 star 排序在学生和普通开发者身上完全失效——大家的 star 都是 0。

GitHub Scout 把这个判断过程写成了一套明确的规则：先用元数据覆盖全部仓库，按技术价值、活跃度、个人贡献、影响力四个维度打分并对 fork 与教程项目降权，再只对排名靠前的少数项目做深度分析。

## 设计取向

- **降权而非排除**——即使一个用户的仓库全是 fork，也要产出有依据的结论，而不是「无可分析内容」
- **结论可回溯**——每条判断都能指向具体仓库、数据或时间区间
- **缺口显式声明**——无法核实的数据写进报告，不静默略过
- **描述而非评判**——输出技术画像，不对人做能力排名

## 架构：Core + Adapters

这个 Skill 的本质是一套**调查工作流**，不是某个模型独有的能力。因此核心逻辑与平台适配分离：

```text
github-scout/
├── core/                       # 唯一真源 —— 人只改这里
│   ├── methodology.md          #   两阶段调查流程
│   ├── repo-ranking.md         #   过滤规则与评分模型
│   └── report-format.md        #   报告结构与填写规则
│
├── claude/
│   ├── SKILL.md                # Claude 适配层：工具映射
│   └── references/             # 构建产物 —— 不要手改
│
├── scripts/
│   └── sync.ps1                # core/ → 各 adapter 的 references/
│
├── README.md
└── GitHub Scout Skill 设计思路文档.md
```

约 80% 的逻辑在 `core/`，adapter 只负责剩下 20% 的工具映射与平台指令包装。新增一个平台等于新增一个 adapter，而不是把整套逻辑重做一遍。

### core/ 与 references/ 的关系

Claude Skill 按**目录自包含**分发——`claude/SKILL.md` 若直接引用 `../core/`，skill 被复制或打包安装后会断链。

因此：

- `core/` 是唯一真源，**所有规则改动都在这里做**
- `scripts/sync.ps1` 把 `core/*.md` 同步到各 adapter 的 `references/`
- adapter 只引用自己目录内的 `references/*.md`
- **`references/` 是构建产物，不要手改**，改动会在下次同步时被覆盖

```powershell
# 修改 core/ 之后运行
.\scripts\sync.ps1

# 校验是否同步（不写入，不同步则退出码 1，适合 CI）
.\scripts\sync.ps1 -Check
```

## 安装（Claude）

需要 [GitHub CLI](https://cli.github.com/) 并已登录：

```bash
gh auth status   # 未登录则运行 gh auth login
```

把 skill 目录复制到 Claude 的 skills 目录：

```powershell
.\scripts\sync.ps1
Copy-Item -Recurse .\claude "$env:USERPROFILE\.claude\skills\github-scout"
```

未安装 `gh` 也能用，会降级为公开页面读取，功能范围收窄，报告中会注明。

## 使用

```
调查一下 GitHub 用户 torvalds
看看 octocat 的项目都在做什么方向
github-scout {username} --top-n 3
```

| 参数 | 默认 | 说明 |
|---|---|---|
| `top_n` | 5 | 深度分析的项目数，范围 1～10 |
| `depth` | `standard` | `quick` 仅元数据 ｜ `standard` ｜ `deep` 含完整 commit 历史 |
| `focus` | 无 | 关注方向提示，影响报告侧重，不影响排序 |

## 输出

一份 Markdown 报告，章节固定：基本信息、技术方向、代表项目（含复杂度星级与得分）、GitHub 活跃度、综合评价、数据说明。

最后一节列出本次调查的全部数据缺口与估算项——它是报告可信度的基础。

## 不做什么

- 不访问私有仓库或任何需额外授权的数据
- 不做代码质量静态扫描（不跑 linter、不算圈复杂度、不做安全审计）
- 不对人做价值排名或打分
- 不爬取 GitHub 之外的平台
- 不生成对个人的负面判断

报告可能被用于招聘初筛等有实际影响的场景，因此任何超出公开数据支持范围的评价都被刻意排除在外。

## 路线图

| 阶段 | 范围 |
|---|---|
| **M1** | core 三件套 + Claude adapter，端到端跑通 |
| **M2** | ChatGPT adapter；同一用户在两平台结论一致 |
| **M3** | AI 项目识别、项目真实性分析、技术成长轨迹、横向比较 |

更远期可扩展到 Codex / Cursor / Gemini —— 每个只是一个新 adapter。

## 文档

设计背景、需求规格（功能需求、验收标准、非目标）与完整评分细则见 [GitHub Scout Skill 设计思路文档.md](GitHub%20Scout%20Skill%20设计思路文档.md)。
