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
| `references/repo-ranking.md` | 过滤规则与三阶段评分模型 | 进入 Step 3 前必读 |
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
# --limit 必须 >= Step 1 拿到的 public_repos，否则静默截断
gh repo list {username} --limit 1000 --visibility public --json   name,description,primaryLanguage,languages,stargazerCount,forkCount,isFork,isArchived,isEmpty,isTemplate,createdAt,pushedAt,diskUsage,url,parent
```

- **`--visibility public` 不可省略。** 当调查对象就是当前登录账号（或你所属组织的成员）时，省略它会连私有仓库一起返回，违反「只使用公开信息」的边界。这个泄漏不会报错，只会静默发生
- **不要加 `--source`**——它会排除 fork，而方法论要求 fork 降权而非排除
- 交叉校验：返回条数**必须**等于 `gh api users/{username} --jq .public_repos`。偏多 = 取到了非公开仓库；偏少 = 被 `--limit` 静默截断，加大上限重取。两种情况都要停下来处理，**不能带着不完整的全集往下走**——实测两次调查都因上限不足而需要重取
- `languages` 字段给出每个仓库各语言的源码字节数。**这是代码规模的唯一可靠来源，且随批量枚举一并返回、零额外成本**——Step 4 直接用它算代码规模，不要为此再逐仓库调用
- **`diskUsage` 只能判断仓库是否几乎为空（≤2 KB），绝不能用于估算代码规模。** 它含图片与构建产物，实测偏差可达 4,200 倍
- 命令失败（GraphQL 504 等）**重试一次**；仍失败则降低 `--limit` 分批取回，不要跳过——后续所有步骤都依赖这份全集

用户近期公开活动：

```bash
gh api users/{username}/events/public --jq   '[.[] | {type, repo: .repo.name, created_at}] | .[0:30]'
```


### Step 3 · 仓库过滤

按 `references/repo-ranking.md` 第一节分类。命名与来源信号纯元数据判断，无调用。

**命名信号必须逐词机械核对**：把仓库名与描述拼接后小写化，对信号词表逐个做子串匹配，记下命中的词。不要凭对仓库的整体印象判断——实测有一次调查判断「无信号命中」而跳过检查，实际 4 个候选的描述里含 `example`（`Minimal live-editing example for React`、`Examples for "Idiomatic Redux"` 等），漏检直接导致两次调查的 Top 5 不一致。

README 与结构信号需要读取，**对粗排前 15 个候选逐个执行，不论命名信号是否已命中**：

```bash
gh api repos/{username}/{repo}/readme -H "Accept: application/vnd.github.raw" 2>/dev/null | head -40
```

命中 ≥2 条才判定。在报告的「数据说明」里列出被判定的仓库及其**具体命中的信号**，供读者复核。

### Step 4 · 粗筛

纯计算步骤，无工具调用。**这一步不做最终排名。**

用元数据可算的四项——影响力、最近 push、owner 身份、**代码规模**，48 分制（见 `references/repo-ranking.md` 第六节），应用降权系数后取前 `max(15, top_n × 3)` 个候选。

代码规模用 Step 2 已返回的 `languages` 字节数总和折算（约 30 字节 ≈ 1 行），**零额外调用**。这是粗筛阶段唯一有真实区分度的信号——缺了它，老仓库会因「影响力满分 + push 0 + owner 8」而大面积同分：实测出现过 17 路精确并列，最终排名第 1 的项目卡在候选名单最后一格，与被淘汰者只差 8 颗 star。

**不要用 `diskUsage` 补代码规模，不要用 `createdAt→pushedAt` 补 commit 跨度。** 拿不到的信号计 0 分。

### Step 5a · 主排序

对 15 个候选各一次调用。**决定最终 Top N 的是这一步，不是 Step 4。**

```bash
# commit 总数（贡献者求和，近似值，实测与真实值偏差约 10%）与本人占比
gh api "repos/{owner}/{repo}/contributors?per_page=100" --jq '.[] | "\(.login)	\(.contributions)"'
```

在 Step 4 的 48 分基础上追加 commit 数与本人占比，按 66 分制打分，应用降权系数，同分按 stars 降序、再按仓库名字典序破平。取 Top N。


### Step 5b · 深度分析

只对 Step 5a 选出的 Top N 执行。这一步可调整 Top N 内部顺序，但**不改变入选名单**。

```bash
# README —— 判断项目意图的首要依据
gh api repos/{owner}/{repo}/readme -H "Accept: application/vnd.github.raw"

# 目录结构 —— 判断架构组织方式
gh api "repos/{owner}/{repo}/git/trees/HEAD?recursive=1" --jq '.tree[].path' | head -200

# 依赖清单 —— 技术栈以此为准，README 声明只作佐证
gh api repos/{owner}/{repo}/contents/{package.json|requirements.txt|pyproject.toml|go.mod|Cargo.toml|pom.xml}   -H "Accept: application/vnd.github.raw" 2>/dev/null
```

**commit 时间跨度**：两端都必须是**真实 commit 时间**。不要用 `pushedAt` 当末端——push 可由不产生 commit 的操作触发，两者能相差数年。

```bash
# 末次 commit
gh api "repos/{owner}/{repo}/commits?per_page=1" --jq '.[0].commit.author.date'

# 首次 commit：先从 Link 头取末页页码（即 commit 总数），再取该页
gh api "repos/{owner}/{repo}/commits?per_page=1" -i 2>/dev/null   | grep -i '^link:' | grep -o 'page=[0-9]*>; rel="last"'
gh api "repos/{owner}/{repo}/commits?per_page=1&page={last}" --jq '.[0].commit.author.date'
```

**架构复杂度**：从目录树观察模块划分、`tests/`、`.github/workflows/` 的存在，**不看代码行数**。

**降级**：任一调用失败（仓库已删除、转私有、无 README）按 `references/methodology.md` Step 5b 的降级处理，并记入数据缺口。


### Step 6 · 画像生成

按 `references/report-format.md` 组织输出。直接在对话中呈现报告；用户要求存档时再写入文件。

---

## 执行纪律

- **广度在前，深度在后**——Step 2 只取元数据，Step 5 才读内容。这是预算不失控的关键。
- **并行调用**——Step 5a 的 15 次调用彼此无依赖，Step 5b 中同一仓库的多个调用也无依赖，都放在同一条消息里并行执行。
- **预算参考**：Step 1-2 约 2 次、Step 3 15 次、Step 5a 15 次（15 候选 × 1）、Step 5b 约 25 次（5 项目 × 5），合计约 57 次，上限 80 次。
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
