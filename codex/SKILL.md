---
name: github-scout
description: Investigate a GitHub user's public repositories and produce a developer technical profile — what they build, their tech stack, their strongest projects, and how actively they maintain them. Use when asked to look up, scout, investigate, profile, or analyze a GitHub user or username, find someone's best repositories, or distinguish original projects from tutorials and forks.
---

# GitHub Scout — Codex Adapter

调查一个 GitHub 用户的公开项目，产出可回溯、克制、中立的开发者技术画像。

## 开始前

按阶段读取规则，不要凭印象替代规则：

| 文件 | 内容 | 何时读 |
|---|---|---|
| `references/methodology.md` | 调查流程、输入、产出与降级方式 | 开始调查前必读 |
| `references/repo-ranking.md` | 过滤信号与三阶段评分模型 | 进入仓库过滤前必读 |
| `references/report-format.md` | 报告结构、事实/推测边界与语气 | 生成报告前必读 |

这些 references 由仓库的 `core/` 同步而来，是方法与规则的唯一真源。遇到冲突时以 references 为准。

## 数据边界

- 只调查公开 GitHub 资料与公开仓库，不访问私有仓库或需额外授权的信息。
- 默认使用 GitHub CLI。先运行 `gh auth status`；若在 Windows 托管沙箱中失败，先在获准的系统上下文复查同一个只读命令，再判断凭据是否有效。不要直接执行 `gh auth login` 或 `gh auth logout`。
- 未登录或 GitHub CLI 不可用时，说明将降级为公开网页/API 调查，并在报告“数据说明”中写明影响。
- 调查开始时检查 REST 与 GraphQL 两份配额：`gh api rate_limit --jq '{core: .resources.core.remaining, graphql: .resources.graphql.remaining}'`。
- GitHub 数据与“最近”活动会变化；需要网页补充或核实时，使用当前公开来源并保留链接。

## Codex 工具映射

### 1. 解析用户

```powershell
gh api users/{username} --jq '{login, name, bio, company, location, blog, public_repos, followers, following, created_at, type}'
```

- 404：用户不存在，停止，不猜测相近用户名。
- `type` 为 `Organization`：说明个人贡献维度不适用，并在继续前询问用户。

### 2. 枚举公开仓库

```powershell
gh repo list {username} --limit 1000 --visibility public --json name,description,primaryLanguage,languages,stargazerCount,forkCount,isFork,isArchived,isEmpty,isTemplate,createdAt,pushedAt,diskUsage,url,parent
```

- `--visibility public` 不可省略；不要使用 `--source`。
- 返回条数必须等于用户资料中的 `public_repos`。偏少时提高上限或分批获取；偏多时先排查是否混入非公开仓库。未取得完整全集前不要进入排名。
- `languages` 是代码规模的数据源；`diskUsage` 仅可辅助判断是否近乎为空，禁止用来估算代码行数。
- GraphQL 暂时失败可重试一次；仍失败时分批取回，不要静默跳过。

读取近期公开活动：

```powershell
gh api users/{username}/events/public --jq '[.[] | {type, repo: .repo.name, created_at}] | .[0:30]'
```

### 3. 过滤与粗筛

严格执行 `repo-ranking.md`：

- 对全部仓库逐词检查名称与描述中的教程/模板信号并记录命中词。
- 对粗排前 15 个候选读取 README 与目录结构，不得因为元数据“看起来正常”而跳过。
- 粗筛按 48 分制计算影响力、最近 push、owner 身份和代码规模，取 `max(15, top_n × 3)`；这不是最终排名。
- 不得用创建时间到 push 时间替代 commit 跨度，也不得用仓库体积替代代码规模。拿不到的项目计 0 并记录缺口。

读取 README 时优先使用原始内容：

```powershell
gh api repos/{owner}/{repo}/readme -H "Accept: application/vnd.github.raw"
```

### 4. 主排序

对候选仓库获取贡献者数据；候选彼此独立时可并行执行：

```powershell
gh api "repos/{owner}/{repo}/contributors?per_page=100" --jq '.[] | "\(.login)\t\(.contributions)"'
```

在粗筛分上追加 commit 数与本人占比，按 66 分制应用降权系数。同分依次按 stars 降序和仓库名字典序破平，再选 Top N。

### 5. 深度分析

仅对 Top N 获取 README、目录树、依赖清单与真实 commit 首末时间；同一仓库的独立读取可并行执行。

```powershell
gh api repos/{owner}/{repo}/readme -H "Accept: application/vnd.github.raw"
gh api "repos/{owner}/{repo}/git/trees/HEAD?recursive=1" --jq '.tree[].path'
gh api repos/{owner}/{repo}/contents/{package.json|requirements.txt|pyproject.toml|go.mod|Cargo.toml|pom.xml} -H "Accept: application/vnd.github.raw"
gh api "repos/{owner}/{repo}/commits?per_page=1" --jq '.[0].commit.author.date'
gh api "repos/{owner}/{repo}/commits?per_page=1" -i
gh api "repos/{owner}/{repo}/commits?per_page=1&page={last}" --jq '.[0].commit.author.date'
```

- 从首个 commits 请求的 `Link` 响应头读取末页页码，再取首次 commit。
- 末次 commit 也必须来自 commits API，不能用 `pushedAt` 代替。
- 技术栈以依赖清单为主，README 为佐证；架构复杂度看模块划分、测试与 CI，不用代码行数代替。
- 任一数据读取失败，按 methodology 的降级规则处理，并写入“数据说明”。

### 6. 输出报告

严格按 `report-format.md` 的章节与必填字段输出。默认直接在对话中呈现；只有用户要求存档时才写文件。

## 执行纪律

- 先广后深：全集元数据 → 候选 → Top N 深度读取。
- 不写自动评分脚本替代对 README 和目录结构的语义判断。
- 失败不静默；任何数据缺口、估算与推测都必须明确标注。
- 只陈述公开证据支持的技术特征，不评价个人能力，不臆测动机。
- 不做代码质量、安全或价值排名，不扩展到 GitHub 之外的平台。

## 参数

| 参数 | 默认值 | 说明 |
|---|---|---|
| `top_n` | 5 | 深度分析项目数，范围 1–10 |
| `depth` | `standard` | `quick` 仅元数据；`standard` 执行标准流程；`deep` 增加完整 commit 历史分析 |
| `focus` | 无 | 调整报告侧重，不改变排序 |
