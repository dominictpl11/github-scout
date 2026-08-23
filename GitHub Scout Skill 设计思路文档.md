# GitHub Scout Skill 设计思路文档

## 1. 项目背景

目标：开发一个用于调查 GitHub 用户公开项目情况的 AI Skill。

使用场景：

> 输入一个 GitHub 用户名，自动分析该用户公开 GitHub 活动、仓库和项目情况，帮助快速了解一个开发者正在做什么、技术方向、项目质量和贡献情况。

典型用途：

- 调查身边同学/开发者的 GitHub 公开项目

- 快速了解某人的技术栈

- 找出其最有价值的项目

- 判断项目复杂度和个人技术方向

- 为学习交流、招聘、合作提供参考

---

# 2. Skill 命名

推荐名称：

## GitHub Scout

Skill ID：

```
github-scout
```

含义：

- GitHub：明确数据来源

- Scout：侦察、探索、发现

相比：

- `github-analyzer`：偏代码分析，不突出用户调查

- `repo-analyzer`：只针对单个仓库

- `github-investigator`：语气偏调查取证

`github-scout` 更符合：

> 先发现一个人的 GitHub 世界，再深入分析重点项目。

---

# 3. 核心设计理念

采用两阶段分析模式：

```
GitHub User    |    ↓阶段1：Profile Scout    |    ↓发现用户主要项目    |    ↓阶段2：Repository Analyzer    |    ↓深入分析重点仓库    |    ↓生成开发者画像
```

---

# 4. 基础能力组合

## 第一部分：GitHub Profile Analysis

来源思路：

`github-profile`

作用：

负责用户级扫描。

主要功能：

- 获取 GitHub 用户信息

- 获取公开仓库列表

- 获取最近活动

- 分析语言分布

- 查看 Stars / Forks

- 查看更新时间

- 判断 GitHub 活跃程度

输出：

例如：

```
用户：xxx主要语言：PythonJavaScriptC++最近一年主要方向：AI AgentWeb DevelopmentMachine Learning代表项目：project-Aproject-Bproject-C
```

---

## 第二部分：Repository Deep Analysis

来源思路：

`repo-analyzer`

作用：

负责单个项目深度分析。

主要功能：

- 分析项目结构

- 分析代码规模

- 分析技术架构

- 分析依赖

- 分析 README

- 分析 Git history

- 判断项目复杂度

输出：

例如：

```
项目：AI-Agent Framework技术栈：PythonLangChainFastAPI项目特点：- 多模块架构- 有完整 README- 有持续 commit- 非简单 demo复杂度：★★★★☆
```

---

# 5. 完整工作流程

## Step 1：输入用户

输入：

```
github username
```

例如：

```
username: xxx
```

---

## Step 2：扫描 Profile

获取：

- 用户简介

- 所有公开仓库

- 最近 commit

- 最近 PR

- Star 项目

- Fork 项目

---

## Step 3：过滤仓库

自动区分：

保留：

- 原创项目

- 长期维护项目

- 有 README 的项目

- 有持续 commit 的项目

降低权重：

- fork 项目

- 空仓库

- tutorial

- demo

- 课程模板

---

## Step 4：选择重点项目

根据以下指标排序：

### 项目影响力

- Stars

- Forks

- Watchers

### 活跃程度

- 最近更新时间

- commit 频率

- issue / PR 活跃度

### 技术价值

- 代码规模

- 架构复杂度

- 技术栈难度

### 个人贡献

- commit 数量

- 作者占比

- 是否主要维护者

---

## Step 5：深入分析 Top 项目

对排名最高的 3～5 个项目运行 repo analyzer。

分析：

- 项目目的

- 技术路线

- 架构设计

- 难度

- 实际贡献

---

# 6. 最终输出格式

生成开发者画像：

```
# GitHub Developer Report## 基本信息用户名：加入时间：## 技术方向主要语言：主要领域：## 代表项目1. Project A用途：技术栈：复杂度：个人贡献：2. Project B用途：技术栈：复杂度：## GitHub 活跃度Commit：PR：最近活动：## 综合评价该开发者主要方向：技术水平：值得关注项目：
```

---

# 7. 仓库架构：Core + Adapters（跨 Agent 设计）

## 7.1 为什么要拆分

GitHub Scout 的本质是一套**调查工作流**，而不是某个模型独有的能力：

```
GitHub 用户 → 获取公开信息 → 判断活跃仓库 → 筛选代表项目
→ 深入分析 → 判断技术栈/项目方向 → 生成用户画像
```

这条链路在任何 Agent 平台上都完全一致，真正有差异的只是**如何拿到数据**和**如何组织指令**。

因此不应该做成两个（或五个）彼此独立的项目，而应该做成：

> **一个项目、多个 Skill 版本** —— 共用核心方法论，只替换平台适配层。

预估拆分比例：**约 80% 核心逻辑共用，20% 平台适配**。

---

## 7.2 目录结构

初期（双平台）：

```text
github-scout/
├── core/
│   ├── methodology.md      # 调查方法论：两阶段流程
│   ├── repo-ranking.md     # 仓库筛选与评分规则
│   └── report-format.md    # 开发者画像输出格式
│
├── chatgpt/
│   └── SKILL.md
│
├── claude/
│   └── SKILL.md
│
└── README.md
```

后续扩展到更多平台时，收敛到 `adapters/`：

```text
adapters/
├── chatgpt/
├── claude/
├── codex/
├── cursor/
└── gemini/
```

新增一个平台 = 新增一个 adapter，而不是把整套逻辑重做一遍。

---

## 7.3 职责划分

| 层                       | 内容                  | 是否共用   |
| ----------------------- | ------------------- | ------ |
| `core/methodology.md`   | 调查方法（Step 1～5 完整流程） | ✅ 共用   |
| `core/repo-ranking.md`  | 仓库筛选规则、项目评分维度       | ✅ 共用   |
| `core/report-format.md` | 开发者画像报告结构           | ✅ 共用   |
| adapter                 | 工具调用方式              | ❌ 平台特有 |
| adapter                 | 数据获取通道              | ❌ 平台特有 |
| adapter                 | Skill 指令格式与元数据      | ❌ 平台特有 |
| adapter                 | 输出呈现细节              | ❌ 平台特有 |

具体差异对照：

| 共用能力   | ChatGPT 版                 | Claude 版              |
| ------ | ------------------------- | --------------------- |
| 调查方法   | ChatGPT 工具调用方式            | Claude 工具调用方式         |
| 仓库筛选规则 | ChatGPT Skill 指令格式        | Claude Skill 指令格式     |
| 项目评分   | GitHub connector / Web 检索 | MCP / `gh` CLI / Bash |
| 输出格式   | ChatGPT-specific 呈现       | Claude-specific 呈现    |

---

## 7.4 设计约束

为保证 core 真正可复用，需要遵守几条约束：

- **core 不提工具名**：只描述"需要获取用户的公开仓库列表"，不写 `gh repo list` 或某个 connector 名称。
- **core 只定义输入/输出契约**：每一步说明"需要什么信息、产出什么结论"，具体怎么拿由 adapter 决定。
- **adapter 保持薄**：只做工具映射 + 平台指令包装，不复制粘贴方法论内容，通过引用 core 文件来复用。
- **评分规则集中在 core**：任何平台上对同一个用户的调查结论应当基本一致，避免各版本结论漂移。

---

## 7.5 项目定位

基于这一架构，仓库可以直接定位为**跨 Agent 的 GitHub Intelligence Skill**。

README 一句话定位：

> **GitHub Scout — AI-powered GitHub developer intelligence skill for ChatGPT and Claude.**

后续支持更多平台时，这句话只需扩展平台列表，定位本身不变。

---

# 8. 后续增强方向

## AI 项目识别

自动判断：

- 是否 AI 项目

- 是否使用 LLM

- 是否 Agent

- 是否科研方向

---

## 项目真实性分析

判断：

- 是否只是教程项目

- 是否大量复制模板

- 是否本人主要开发

- 是否长期维护

---

## 技术成长轨迹

分析：

```
2023:Python 基础项目2024:Web 应用2025:AI Agent
```

推测开发路线。

---

## 横向比较

未来可以支持：

```
Compare:User A vs User B技术方向：项目质量：活跃程度：科研潜力：工程能力：
```

---

# 9. 最终目标

打造一个：

> 输入 GitHub 用户名，即可快速生成该开发者公开技术画像的 AI Skill。

核心定位：

**GitHub Scout = 发现用户 + 分析项目 + 总结开发者能力。**
