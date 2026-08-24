---
name: github-scout
description: Investigate a GitHub user's public repositories and produce a developer technical profile — what they build, their tech stack, their strongest projects, and how actively they maintain them. Use when asked to look up, scout, investigate, profile, or analyze a GitHub user or username, to find someone's best repositories, or to judge whether their projects are original work or tutorial follow-alongs.
---

# GitHub Scout — Claude Adapter

调查一个 GitHub 用户的公开项目，产出开发者技术画像。

## 本文件的职责

本文件是 **Claude 平台适配层**，只负责把方法论的每一步映射到具体工具调用。

**调查方法、评分规则、报告格式不在本文件中。** 开始工作前，按需读取：

| 文件 | 内容 | 何时读 |
|---|---|---|
| `references/methodology.md` | 两阶段调查流程，每步的输入/判断/产出/降级 | 开始调查前必读 |
| `references/repo-ranking.md` | 过滤规则与评分模型 | 进入 Step 3 前必读 |
| `references/report-format.md` | 报告结构与填写规则 | 进入 Step 6 前必读 |

这三份文件由 `core/` 同步而来，是唯一真源。**遇到规则冲突时以它们为准**，不要在本文件里另立规则。

---

## 前置检查

```bash
gh auth status
```

未登录时告知用户，并说明将以降级模式运行（公开页面读取，功能范围收窄，需在报告「数据说明」中注明）。

调查开始前查看预算余量：

```bash
gh api rate_limit --jq '{core: .resources.core.remaining, graphql: .resources.graphql.remaining}'
```

**两个配额是分开的**：`gh repo list`（Step 2）走 GraphQL，`gh api`（Step 1、3、5）走 REST。只看其中一个会误判余量。

---

## 工具映射

### Step 1 · 用户解析

```bash
gh api users/{username} --jq '{login, name, bio, company, location, blog, public_repos, followers, following, created_at, type}'
```

- 返回 404 → 用户不存在，终止调查，不要猜测相近用户名
- `type` 为 `Organization` → 告知用户调查对象是组织，「个人贡献」维度不适用，询问是否继续

### Step 2 · 仓库枚举

一次取回全部公开仓库的元数据。**此步不读取任何仓库内容。**

```bash
gh repo list {username} --limit 200 --visibility public --json \
  name,description,primaryLanguage,languages,stargazerCount,forkCount,\
isFork,isArchived,isEmpty,isTemplate,createdAt,pushedAt,diskUsage,url,parent
```

- **`--visibility public` 不可省略。** 当调查对象就是当前登录账号（或你所属组织的成员）时，省略它会连私有仓库一起返回，违反「只使用公开信息」的边界。这个泄漏不会报错，只会静默发生
- **不要加 `--source`**——它会排除 fork，而方法论要求 fork 降权而非排除
- 交叉校验：返回条数应与 `gh api users/{username} --jq .public_repos` 一致。**条数偏多说明取到了非公开仓库，停下来检查**；条数正好等于 `--limit` 且小于 public_repos，属于被 limit 截断，是正常的，转入下面的粗筛分支
- 仓库数 > 100 时，先按 `pushedAt` 和 `stargazerCount` 粗筛前 50 个候选，控制预算
- `languages` 字段给出每种语言的字节数，用于 Step 6 的加权语言统计
- `diskUsage`（KB）用于 Step 4 的代码规模估算

用户近期公开活动：

```bash
gh api users/{username}/events/public --jq \
  '[.[] | {type, repo: .repo.name, created_at}] | .[0:30]'
```

### Step 3 · 仓库过滤

纯判断步骤，无工具调用。按 `references/repo-ranking.md` 第一节分类。

教程/模板识别需要 README 时，用轻量方式只取开头：

```bash
gh api repos/{username}/{repo}/readme -H "Accept: application/vnd.github.raw" 2>/dev/null | head -40
```

### Step 4 · 代表项目排序

纯计算步骤，无工具调用。按 `references/repo-ranking.md` 第二、三节打分并应用降权系数。

此时只有元数据，代码规模按 `diskUsage` 估算（注意排除仓库内的大体积资源文件），进入 Step 5 后修正。

### Step 5 · 深度分析

对 Top N（默认 5）逐个执行。**这一步是预算大头，只对入选项目做。**

```bash
# README —— 判断项目意图的首要依据
gh api repos/{owner}/{repo}/readme -H "Accept: application/vnd.github.raw"

# 目录结构 —— 判断架构组织方式
gh api "repos/{owner}/{repo}/git/trees/HEAD?recursive=1" --jq '.tree[].path' | head -200

# 语言构成（字节数）
gh api repos/{owner}/{repo}/languages

# 贡献者与 commit 占比
gh api repos/{owner}/{repo}/contributors --jq '.[] | "\(.login)\t\(.contributions)"'

# 最近一次 commit
gh api "repos/{owner}/{repo}/commits?per_page=1" --jq '.[0].commit.author.date'

# 本人的 commit 时间跨度：最近一条与最早一条
gh api "repos/{owner}/{repo}/commits?author={username}&per_page=1" \
  --jq '.[0].commit.author.date'
```

**commit 时间跨度**（评分需要）：先取最后一页页码，再取该页最早一条。

```bash
# 从 Link 头拿到末页页码
gh api "repos/{owner}/{repo}/commits?per_page=1" -i 2>/dev/null \
  | grep -i '^link:' | grep -o 'page=[0-9]*>; rel="last"'
# 再取末页
gh api "repos/{owner}/{repo}/commits?per_page=1&page={last}" --jq '.[0].commit.author.date'
```

**技术栈判定**：以依赖清单为准，README 声明作为佐证。按语言取对应文件：

```bash
gh api repos/{owner}/{repo}/contents/{package.json|requirements.txt|pyproject.toml|go.mod|Cargo.toml|pom.xml} \
  -H "Accept: application/vnd.github.raw" 2>/dev/null
```

**架构复杂度**：从目录树观察模块划分、`tests/`、`.github/workflows/` 的存在，**不看代码行数**。

**降级**：任一调用失败（仓库已删除、转私有、无 README）按 `references/methodology.md` Step 5 的降级处理，并记入数据缺口。

### Step 6 · 画像生成

按 `references/report-format.md` 组织输出。直接在对话中呈现报告；用户要求存档时再写入文件。

---

## 执行纪律

- **广度在前，深度在后**——Step 2 只取元数据，Step 5 才读内容。这是预算不失控的关键。
- **并行调用**——Step 5 中同一仓库的多个 `gh api` 之间无依赖，放在同一条消息里并行执行。
- **不写脚本代替判断**——评分依赖对 README 和目录结构的语义理解，不要试图用 shell 脚本自动打分。
- **失败不静默**——任何调用失败都要记入报告的「数据说明」。
- **只用公开数据**——不访问私有仓库，不获取需额外授权的信息。

## 参数

| 参数 | 默认 | 说明 |
|---|---|---|
| `top_n` | 5 | 深度分析的项目数，范围 1～10 |
| `depth` | standard | `quick` 仅元数据（跳过 Step 5）｜ `standard` ｜ `deep` 含完整 commit 历史分析 |
| `focus` | 无 | 关注方向提示，影响报告侧重，**不影响排序** |

## 边界

不做代码质量评判，不对人做能力排名，不访问 GitHub 之外的平台。报告呈现事实，判断留给读者——完整边界见 `references/report-format.md` 第五节。
