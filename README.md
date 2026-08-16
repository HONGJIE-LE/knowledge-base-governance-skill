# Knowledge Base Governance Skill

一个用于 Obsidian、MOMA 和本地 Markdown 知识库的跨平台 Skill，可供 Codex、Claude Code 和其他兼容 `SKILL.md` 的 AI 使用。

## 两个独立模块

### 模块一：通用知识库检查

- 先识别知识库实际板块可能承担的功能，再检查问题。
- 不强制采用 Raw、Wiki、Projects、Outputs 或固定属性。
- 使用真实目录名和文件名报告，并区分已确认结论与候选映射。
- 默认只读，不自动移动、删除、改名或修改配置。

### 模块二：通用六维健康度诊断

- 按 D1-D6 共 100 分诊断知识库成熟度。
- 输出阶段、降级触发器、关键证据、改进动作和三周复测目标。
- 先识别各知识库中功能等价的板块，再按统一评分口径诊断，不要求固定目录名称。

## v1.2.0 主要变化

- 新增路径、依赖、超时、不可读文件、应用不可用、脏工作树和凭证等失败处理分支。
- 扫描器输出统一视为候选线索，必须去重、抽样核验，并区分已核验与未核验数量。
- 禁止把链接数、候选数或更新时间直接当作成熟度证据，也不重复使用同一问题降分。
- 新增高影响写入检查点；安全、可逆、目标明确的单文件操作可直接执行并报告。
- 新增 `test-prompts.json`，覆盖模块一、模块二和危险修改拦截。

## 安装

1. 下载 Release 中的 `lhjwork-vault-governance-v1.2.0.zip`。
2. 解压后取得 `lhjwork-vault-governance` 文件夹。
3. 将整个文件夹复制到当前 AI 支持的 Skill 目录，例如 Codex 的 `~/.codex/skills/`、Claude Code 的 `~/.claude/skills/`，或项目自己的 Skills 目录。
4. 重启或重新载入当前 AI 的 Skills。

安装后的核心文件应位于：

```text
lhjwork-vault-governance/
├── SKILL.md
├── agents/openai.yaml
├── references/
├── scripts/
└── test-prompts.json
```

## 使用示例

```text
检查一下这个知识库
```

```text
对这个知识库做一次六维健康度诊断
```

```text
检查知识库的属性、Dataview、插件、同步和备份设置
```

## 运行条件

- Bash
- `find`、`grep`、`awk`、`sed`、`sort`、`wc`、`stat`、`date` 等系统基础命令
- 不要求安装 ripgrep（`rg`）；扫描直接使用系统自带的 `grep`
- `jq` 为可选依赖，用于读取部分 Obsidian 配置的结构信息
- Obsidian CLI 为可选能力；Obsidian 未运行时只完成文件层检查

## 跨平台说明

- `SKILL.md` 按自身实际安装目录定位脚本，不写死 `.codex/skills` 或 `.claude/skills`。
- `agents/openai.yaml` 只提供 OpenAI/Codex 界面元数据，Claude Code 和其他 AI 可直接忽略。
- 脚本通过 `bash` 调用，不依赖文件的可执行权限。

## 安全边界

- 扫描脚本默认只读。
- 不读取或展示凭证值。
- 不因检查而自动修改、移动或删除知识库文件。
- 需要高影响写入、改配置、安装插件或处理重复文件时，必须先预览并获得确认。

## 版本

- 当前版本：`v1.2.0`
- 发布日期：2026-08-17

## 授权说明

本仓库未附加开源许可证，保留全部权利。未经仓库所有者许可，不授予复制、修改、再发布或商业使用权。
