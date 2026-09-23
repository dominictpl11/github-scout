# GitHub Scout

> **An evidence-backed GitHub developer intelligence skill for Claude and Codex.**

GitHub Scout investigates a user's public GitHub repositories and activity, then
produces a traceable, neutral technical profile: what they build, which
technologies they use, which projects are most representative, and how their
work has evolved over time.

## What it solves

The difficult part of reviewing a GitHub profile is not opening one repository.
It is separating meaningful work from forks, coursework, tutorial follow-alongs,
and small experiments across dozens of repositories. Star counts alone are a
poor signal for students and early-career developers.

GitHub Scout uses a staged workflow:

1. Inventory the user's complete public repository set.
2. Filter and rank candidates using technical value, activity, ownership, and
   public impact signals.
3. Downweight forks and tutorial-like projects without discarding them silently.
4. Read the strongest candidates in depth and cite the evidence in the report.

## Design principles

- **Downweight, do not erase:** weak signals still produce an explained result.
- **Traceable conclusions:** each claim points to a repository, data point, or
  time range.
- **Explicit gaps:** unavailable or estimated data is stated instead of hidden.
- **Description over judgment:** the output is a technical profile, not a score
  for a person.

## Architecture: core plus adapters

The project is a research workflow rather than a model-specific implementation.
The rules live in `core/`; each platform adapter packages those rules for its
own runtime and tool conventions.

```text
github-scout/
├── core/                       # Single source of truth
│   ├── methodology.md          # Investigation workflow
│   ├── repo-ranking.md         # Filtering and ranking model
│   └── report-format.md        # Report structure and writing rules
│
├── claude/                     # Claude adapter
│   ├── SKILL.md
│   └── references/             # Generated adapter copy
│
├── codex/                      # Codex adapter
│   ├── SKILL.md
│   ├── agents/openai.yaml
│   └── references/             # Generated adapter copy
│
├── scripts/
│   └── sync.ps1                # Sync core/ into adapter references/
│
├── reports/                    # Local investigation output; ignored by Git
└── README.md
```

`core/` is the only source of truth for methodology and scoring rules. Do not
edit adapter `references/` files by hand. After changing `core/`, run:

```powershell
.\scripts\sync.ps1
.\scripts\sync.ps1 -Check
```

The `-Check` form writes nothing and is suitable for validation or CI.

## Requirements

- GitHub CLI (`gh`) is recommended for authenticated API access.
- Without `gh` authentication, the adapters can fall back to public GitHub
  pages/API access with a narrower data set; the report must state that
  limitation.

Check the CLI session with:

```powershell
gh auth status
```

## Installation

Synchronize the adapters first:

```powershell
.\scripts\sync.ps1
```

### Claude

Copy the self-contained Claude adapter into the Claude skills directory:

```powershell
Copy-Item -Recurse .\claude "$env:USERPROFILE\.claude\skills\github-scout"
```

### Codex

Copy the self-contained Codex adapter into the `github-scout` directory under
your Codex skills directory. For example, when `CODEX_HOME` is configured:

```powershell
Copy-Item -Recurse .\codex "$env:CODEX_HOME\skills\github-scout"
```

Start a new session after installation, then invoke the skill with a public
GitHub username or profile URL.

## Usage

Examples:

```text
Investigate the GitHub user torvalds.
Use $github-scout to profile octocat's strongest projects.
```

The workflow accepts these report controls:

| Parameter | Default | Meaning |
| --- | --- | --- |
| `top_n` | `5` | Number of projects to analyze deeply; valid range is 1–10. |
| `depth` | `standard` | `quick` uses metadata only; `standard` follows the normal workflow; `deep` adds complete commit-history analysis. |
| `focus` | none | A topic that changes report emphasis but does not change ranking. |

## Output

The result is a Markdown report with a stable structure:

- profile and account information;
- technical direction and primary technologies;
- representative projects, complexity signals, and scores;
- GitHub activity and maintenance history;
- an overall evidence-based summary;
- all data gaps, estimates, and methodological limitations.

## Boundaries

GitHub Scout does not:

- access private repositories or data requiring extra authorization;
- perform static code-quality scanning, security audits, or complexity counts;
- rank a person's worth or claim to measure their ability;
- crawl platforms outside GitHub;
- generate unsupported negative judgments about individuals.

The output may be used in high-impact contexts such as recruiting, so claims
outside the available public evidence are intentionally excluded.

## Privacy and responsible use

GitHub Scout uses only publicly accessible GitHub data and does not access
private repositories or private email addresses. Do not use its reports to
infer sensitive personal traits or as the sole basis for hiring or other
high-impact decisions. Treat generated reports as local output and do not
commit them to this repository.

## Documentation

The Chinese design document contains the original requirements, acceptance
criteria, non-goals, and full scoring rationale:

[GitHub Scout Skill 设计思路文档.md](GitHub%20Scout%20Skill%20设计思路文档.md)

## 中文简介

GitHub Scout 会调查 GitHub 用户的公开仓库和活动，输出可回溯、克制的
开发者技术画像。`core/` 是规则唯一真源，Claude 和 Codex 目录是各自的
自包含适配层；修改规则后运行 `scripts\sync.ps1` 同步 references。

示例：

```text
调查一下 GitHub 用户 torvalds
使用 $github-scout 分析 octocat 最有代表性的项目
```
