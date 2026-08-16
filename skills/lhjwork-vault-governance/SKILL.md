---
name: lhjwork-vault-governance
description: "Inspect and govern Obsidian, MOMA and local Markdown knowledge bases through two separate, portable modules: (1) a read-only inspection that discovers actual functional regions before checking structure, links, metadata, projects, decisions, outputs, plugins, sync and backup; and (2) a six-dimension 100-point health diagnosis that judges maturity, downgrade triggers and three-week targets. Use in Codex, Claude Code or another SKILL.md-compatible agent for 检查一下知识库, 知识库检查, 健康度诊断, 六维打分, vault improvements, properties, dashboards, Dataview, workflows, plugins, sync, backup, or user-approved repairs."
---

# Knowledge Base Governance

## Goal

Keep a knowledge base understandable, traceable and safe to maintain. Module 1 performs a compact inspection. Module 2 performs a full six-dimension health diagnosis. Both modules discover functional equivalents from the target vault instead of requiring fixed folder names, tags, properties or a specific AI platform.

## Resolve the Skill and vault paths

1. Set `SKILL_DIR` to the absolute directory containing this loaded `SKILL.md`.
2. Obtain that directory from the current skill loader or actual file path. Never guess `.codex/skills`, `.claude/skills`, `.agents/skills` or another platform-specific location.
3. Set `VAULT_PATH` to the user-supplied knowledge-base path; if none is supplied, use the current workspace.
4. Invoke bundled scripts with `bash`. Do not require executable permission on the script files.

```bash
bash "$SKILL_DIR/scripts/audit-vault.sh" "$VAULT_PATH"
bash "$SKILL_DIR/scripts/health-diagnosis-scan.sh" "$VAULT_PATH"
```

The scripts require Bash and standard commands such as `find`, `grep`, `awk`, `sed`, `sort`, `wc`, `stat` and `date`. They do not require `rg`. `git`, `jq` and Obsidian CLI add optional checks when available; their absence must not abort the scan.

`agents/openai.yaml` is optional OpenAI/Codex interface metadata. Other agents may ignore it. Never treat it as a runtime dependency or rewrite the Skill because of it.

## Determine scope and local rules

1. Read the target vault's `AGENTS.md` and other local rules completely when present.
2. Discover the vault's actual entry, context, capture, source, knowledge, project, action, judgment, review, output, method, archive, configuration and automation candidates.
3. Treat START, README, home, dashboard, map, index, about and current-focus names only as weak entry hints.
4. Treat dashboards and indexes as navigation or summary layers until their claims are checked against actual source files.
5. Prefer the target vault's confirmed rules over the embedded general templates.

## Route to exactly one module

| Module | Trigger examples | Output boundary |
|---|---|---|
| 1. 知识库检查 | “检查一下知识库”“知识库检查”“再看有什么问题”“健康检查” | Discover actual functional regions first, then report problems and actions using the vault's own names. Do not force Skill labels or health scoring. |
| 2. 健康度诊断 | “健康度诊断”“六维打分”“判断知识库在哪一层”“三周后复测” | Full D1-D6 score, stage, downgrade triggers, evidence, actions, one direction and three-week retest target. |

Default an ambiguous “检查” or “健康检查” to Module 1. Enter Module 2 only when the user explicitly asks for health-degree diagnosis, scoring, stage judgment or retesting. If the user explicitly requests both, run them as two separately titled reports; never blend their templates.

For “给改进建议、看看还能怎么优化”, use Module 1 and return a prioritized proposal without changing files or configuration. For “按这个处理、确认、执行修改”, apply only the previously previewed and confirmed changes.

If the requested action includes moving, deleting, overwriting, project ownership, output registration, or promotion from candidate to confirmed, show a file-level preview and wait for explicit confirmation. Do not turn either read-only module into a repair pass.

## Module 1: run a knowledge-base inspection

1. Read [knowledge-base-inspection-template.md](references/knowledge-base-inspection-template.md) and [governance-checklist.md](references/governance-checklist.md) completely. Do not load the health-diagnosis standard.
2. Treat all template terms as functional hypotheses, not required folder names, tags, properties or report headings.
3. Run `bash "$SKILL_DIR/scripts/audit-vault.sh" "$VAULT_PATH"`.

4. Build a functional-candidate map before diagnosing problems. For each relevant actual path, record possible functions, evidence and high/medium/low confidence. Allow one region to serve multiple functions and one function to span multiple regions.
5. Open representative files from candidate regions. Use names only as weak hints; use content, links, properties, activity and navigation references as stronger evidence.
6. Check capture, sources, knowledge reuse, active work, decisions, review, outputs, retrieval, metadata, automation, plugins, sync, backup and security only where the evidence shows they are relevant.
7. Organize the report around actual paths and the most important usage problems. Do not mechanically reproduce the template's section names.
8. Separate confirmed findings from candidate mappings and user-confirmation questions.
9. Do not output D1-D6 scores, a total score, maturity stage, downgrade rules, three-week targets, A-D direction selection or the health-diagnosis hard-truth line.
10. State that no files were modified.

## Module 2: run a health diagnosis

For a health score or maturity-stage diagnosis:

1. Read [health-diagnosis-standard.md](references/health-diagnosis-standard.md) completely. Do not load the Module 1 report template.
2. Run `bash "$SKILL_DIR/scripts/health-diagnosis-scan.sh" "$VAULT_PATH"`.
3. Scan the whole repository inventory, top-level structure, functional candidates and active-time distribution. Do not claim that every file body was read.
4. Open the required samples from project workspaces, judgments, source summaries, topics, methods, output indexes, review or compile logs, and project backgrounds. Use functional equivalents; if a category has no supported candidate, report it as a diagnostic signal.
5. Check entry freshness against the latest 7-14 day activity and current source indexes. Mark process-layer activity without entry-layer synchronization as structural imbalance.
6. Verify application-level links, Dataview and plugin runtime through Obsidian CLI when the app is available. Inspect MOMA presence and activity without exposing credentials.
7. Score D1-D6 directly against their weighted evidence rubric, add the six numbers, apply downgrade triggers, and report confidence.
8. Use repository-relative file paths for every evidence claim; when possible, make them clickable with absolute local link targets.
9. Mark claims as `[文件证据]`, `[统计证据]`, or `[推断]`. Never present an inference as a verified fact.
10. Use a direct coaching voice. Remove hedging words such as “或许”, “可能” and “建议”; use “问题”, “结论”, “动作” and “必须”. Critique the system and operating behavior, not the user's dignity.
11. End with exactly one next-direction choice and one hard truth of no more than 25 Chinese characters.
12. Complete the arithmetic and compliance checklist before sending the report.

Keep Module 2 read-only. It may reuse factual output from `audit-vault.sh` through the diagnosis scanner, but must not switch to Module 1's report format. A later repair requires a separate file-level preview and confirmation.

Do not ask the user to provide an external tutorial again. In either module, report directly against the embedded standards without saying “对照文档”.

## Verify in the live application

Use a compatible Obsidian CLI or application-control tool when Obsidian is running. Check its help before using unfamiliar syntax, then inspect broken links, unresolved links, orphans, properties, query rendering, enabled plugins, sync state and application errors as relevant.

If no compatible application-control capability is available, report that only file-level checks were completed. Do not claim that graph links, Dataview rendering or plugin runtime behavior were verified.

## Apply a declared property standard

1. Identify the target vault's own property rules before editing. Do not impose a universal schema.
2. Determine each field's meaning file by file. Never perform a mechanical repository-wide rename of an ambiguous field such as `status`.
3. Never promote candidate, draft or unverified content to confirmed without explicit user confirmation.
4. Update review timestamps only after actually reviewing the file's content.
5. After changing a property, inspect every query, template or automation that may depend on the old field.
6. Do not force Markdown properties onto binary files; track their state in an existing index or equivalent registry.

For a vault that explicitly adopts the legacy LHJWork profile, preserve its five separate status fields: `processing_status`, `confirmation`, `project_status`, `output_status` and `document_status`. Do not impose these fields on other vaults.

## Maintain cross-file consistency

Apply only relationships that the target vault actually uses:

- Capture or source-index changes → refresh related dashboards and processing queues.
- Project stage or next-action changes → refresh the project workspace, map and summary views.
- Output registration or ownership changes → refresh the output index, owning project and output counts together.
- Long-term understanding changes → keep them provisional until confirmed, then update the relevant entry notes and change history.
- Approved knowledge compilation → record changed files, links, remaining gaps and confirmation points in the vault's review log or equivalent.

Discover these relationships from actual content and links. Do not move files merely to imitate a preferred directory structure.

## Preserve inspection and security boundaries

- Prefer existing capabilities and local rules.
- Do not expose credentials or inspect secret values.
- Do not install or change plugins, automation, queries, permissions or configuration without explicit user approval.

## Handle duplicates and Git safely

1. Preserve unrelated working-tree changes.
2. Report a dirty Git state before backup, commit, bulk rename, or plugin update.
3. For suspected duplicates, calculate hashes and compare content before proposing deletion.
4. Classify candidates as byte-identical, same-name-different-content, or unique.
5. Delete only byte-identical copies after approval. Preserve meaningful historical versions.
6. Never use filename equality alone as deletion evidence.

## Verify an approved change

After editing:

1. Re-run `audit-vault.sh` and compare only task-relevant indicators.
2. Confirm that changed properties follow the target vault's declared rules.
3. Verify changed summaries, relationships and counts against the actual source files or indexes detected in that vault.
4. Verify changed links point to real files or explicit external-link notes.
5. Open or query changed notes in Obsidian when the app is available.
6. Run `git diff --check`.
7. Review `git diff -- <approved paths>` and confirm no unrelated file was changed.
8. Report exactly what changed, what was verified, and what still needs user confirmation.

## Keep module outputs separate

- Module 1 uses only the compact inspection report defined in its workflow and [governance-checklist.md](references/governance-checklist.md).
- Module 2 uses only the complete template in [health-diagnosis-standard.md](references/health-diagnosis-standard.md).
- An approved repair is neither module; report changed files, verification and remaining confirmations after applying it.
