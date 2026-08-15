# Knowledge Base Governance Skill

一个用于 Obsidian、MOMA 和本地 Markdown 知识库的 Codex Skill。

## 两个独立模块

### 模块一：通用知识库检查

- 先识别知识库实际板块可能承担的功能，再检查问题。
- 不强制采用 Raw、Wiki、Projects、Outputs 或固定属性。
- 使用真实目录名和文件名报告，并区分已确认结论与候选映射。
- 默认只读，不自动移动、删除、改名或修改配置。

### 模块二：LHJWork 六维健康度诊断

- 按 D1-D6 共 100 分诊断知识库成熟度。
- 输出阶段、降级触发器、关键证据、改进动作和三周复测目标。
- 该模块采用内置 LHJWork 健康标准；其他知识库使用前应先确认结构和规则是否适用。

## 安装

1. 下载 Release 中的 `lhjwork-vault-governance-v1.0.0.zip`。
2. 解压后取得 `lhjwork-vault-governance` 文件夹。
3. 将整个文件夹复制到个人 Skill 目录 `~/.codex/skills/`，或项目目录 `.codex/skills/`。
4. 重启 Codex，让 Skill 重新载入。

安装后的核心文件应位于：

```text
lhjwork-vault-governance/
├── SKILL.md
├── agents/openai.yaml
├── references/
└── scripts/
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
- ripgrep（`rg`）
- `jq` 为可选依赖，用于读取部分 Obsidian 配置的结构信息
- Obsidian CLI 为可选能力；Obsidian 未运行时只完成文件层检查

## 安全边界

- 扫描脚本默认只读。
- 不读取或展示凭证值。
- 不因检查而自动修改、移动或删除知识库文件。
- 需要写入、改配置、安装插件或处理重复文件时，必须先预览并获得确认。

## 版本

- 当前版本：`v1.0.0`
- 发布日期：2026-08-15

## 授权说明

本仓库未附加开源许可证，保留全部权利。未经仓库所有者许可，不授予复制、修改、再发布或商业使用权。
