---
name: lhjwork-vault-governance
description: "Govern Obsidian, MOMA and local Markdown knowledge bases through two separate modules: (1) a general read-only inspection that discovers the vault's actual functional regions before judging structure, links, metadata, projects, decisions, outputs, plugins, sync and backup, without forcing fixed folder or tag labels; and (2) an LHJWork six-dimension 100-point health diagnosis that judges maturity stage, downgrade triggers and three-week targets. Use for 检查一下知识库, 知识库检查, 健康度诊断, 六维打分, vault improvements, properties, dashboard and Dataview maintenance, workflows, plugins, sync, backup, or user-approved repairs."
---

# LHJWork Vault Governance

## Goal

Keep the target knowledge base understandable, traceable, and safe to maintain. Module 1 works with any Obsidian, MOMA or local Markdown knowledge base; Module 2 applies the embedded LHJWork health standard. Inspect current files before drawing conclusions, separate temporary counts from lasting rules, and preserve the user's final confirmation authority.

## Determine scope and local rules

1. For either module, inspect the vault path supplied by the user; if none is supplied, use the current workspace. Module 2 applies its embedded LHJWork standard only when that structure is present or explicitly adopted.
2. Read the target vault's `AGENTS.md` and any local rules completely when present.
3. In Module 1, discover START, README, home, dashboard, map, index, about, current-focus and equivalent entry candidates from the actual vault. Do not assume the LHJWork entry paths exist.
4. In Module 2 or an approved LHJWork repair, read these current sources of truth:
   - `00 关于我/知识库工作台.md`
   - `00 关于我/关于我.md`
   - `00 关于我/当前主线.md`
   - `05 技能手册/知识库属性与状态规范.md`
   - `02 Wiki AI编译层/00 Raw索引.md`
   - `03 Projects 我的项目/项目地图.md` and the owning project现场
   - `02 Wiki AI编译层/02 判断候选/判断候选索引.md`
   - `04 Outputs 输出成果/输出索引.md`
   - `02 Wiki AI编译层/05 编译日志/编译日志.md`
5. Treat dashboards and indexes as navigation or summary layers until their claims are checked against actual sources.

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
3. Run:

```bash
bash .codex/skills/lhjwork-vault-governance/scripts/audit-vault.sh "<vault-path>"
```

4. Build a functional-candidate map before diagnosing problems. For each relevant actual path, record possible functions, evidence and high/medium/low confidence. Allow one region to serve multiple functions and one function to span multiple regions.
5. Open representative files from candidate regions. Use names only as weak hints; use content, links, properties, activity and navigation references as stronger evidence.
6. Check capture, sources, knowledge reuse, active work, decisions, review, outputs, retrieval, metadata, automation, plugins, sync, backup and security only where the evidence shows they are relevant.
7. Organize the report around actual paths and the most important usage problems. Do not mechanically reproduce the template's section names.
8. Separate confirmed findings from candidate mappings and user-confirmation questions.
9. Do not output D1-D6 scores, a total score, maturity stage, downgrade rules, three-week targets, A-D direction selection or the health-diagnosis hard-truth line.
10. State that no files were modified.

## Module 2: run a health-degree diagnosis

For a health score or maturity-stage diagnosis:

1. Read [health-diagnosis-standard.md](references/health-diagnosis-standard.md) completely.
2. Run the read-only inventory and activity scan:

```bash
bash .codex/skills/lhjwork-vault-governance/scripts/health-diagnosis-scan.sh "<vault-path>"
```

3. Scan the whole repository inventory, top-level structure, functional regions and active-time distribution. Do not claim that every file body was read.
4. Open the required samples from projects, judgments, source summaries, topics, methods, output index, compile log and project backgrounds. If a category is empty, report it as a diagnostic signal.
5. Check entry freshness against the latest 7-14 day activity and current source indexes. Mark process-layer activity without entry-layer synchronization as structural imbalance.
6. Verify application-level links, Dataview and plugin runtime through Obsidian CLI when the app is available. Inspect MOMA presence and activity without exposing credentials.
7. Score D1-D6 directly against their weighted evidence rubric, add the six numbers, apply downgrade triggers, and report confidence.
8. Use repository-relative file paths for every evidence claim; when possible, make them clickable with absolute local link targets.
9. Mark claims as `[文件证据]`, `[统计证据]`, or `[推断]`. Never present an inference as a verified fact.
10. Use a direct coaching voice. Remove hedging words such as “或许”, “可能” and “建议”; use “问题”, “结论”, “动作” and “必须”. Critique the system and operating behavior, not the user's dignity.
11. End with exactly one next-direction choice and one hard truth of no more than 25 Chinese characters.
12. Complete the arithmetic and compliance checklist before sending the report.

Keep Module 2 read-only. It may reuse factual output from `audit-vault.sh` through the diagnosis scanner, but must not switch to Module 1's report format. A later repair requires a separate file-level preview and confirmation.

Do not ask the user to provide the tutorial again. In either module, do not say “对照文档”; report directly against the embedded standards.

## Verify in the live Obsidian app

Use the repository's `obsidian-cli` skill when Obsidian is running. Check command help before using unfamiliar CLI syntax, then inspect broken links, unresolved links, orphans, properties, Dataview rendering, enabled plugins, sync state, and application errors as relevant.

If the CLI says it cannot find Obsidian, report that only file-level checks were completed. Do not claim that graph links, Dataview rendering, or plugin runtime behavior were verified.

## Apply a declared property standard

First identify the target vault's own property rules and follow those rules. Do not treat the LHJWork fields as a universal schema. Only for LHJWork or a vault that explicitly adopts `05 技能手册/知识库属性与状态规范.md`:

1. Use `note_type`, `last_reviewed`, and `version` only where their meanings apply.
2. Use one of these five domain status fields instead of generic `status`:
   - `processing_status`
   - `confirmation`
   - `project_status`
   - `output_status`
   - `document_status`
3. Determine the old field's meaning file by file. Never perform a mechanical repository-wide rename.
4. Never change `confirmation: 候选` or `待确认` to `已确认` without the user's explicit confirmation.
5. Update `last_reviewed` only after actually reviewing the file's content.
6. After changing a property, inspect every Dataview query that may depend on the old field.
7. Do not force properties onto PDF, PPT, Word, Excel, or image files; maintain their state in the Raw index.

## Maintain LHJWork cross-file consistency when applicable

Apply these synchronization rules only to LHJWork or another vault that explicitly adopts the same structure. For a general Module 1 inspection, discover equivalent relationships instead of requiring these paths.

- Raw index changes → refresh the workbench's Raw counts and named queue.
- Project state or next action changes → update the project现场, project map, and relevant workbench view.
- Output registration or ownership changes → update output index, owning project现场, `output_count`, and workbench total together.
- Long-term understanding changes → keep it candidate until confirmed, then synchronize the confirmed entry notes and compile log.
- Any approved knowledge compilation → update the compile log with changed files, links, remaining gaps, and user confirmation points.

Keep material entities in `01 收进来 Raw`, compiled knowledge in `02 Wiki AI编译层`, live project state in `03 Projects 我的项目`, and output registration in `04 Outputs 输出成果`. Do not move output entities into Outputs by default.

## Preserve inspection boundaries

Use [knowledge-base-inspection-template.md](references/knowledge-base-inspection-template.md) only in Module 1 and approved repairs. Prefer existing capabilities, do not expose credentials, and do not install or change plugins, automation, queries or configuration without explicit user approval.

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
2. Confirm that changed properties follow the target vault's declared rules; for LHJWork, also confirm there are no unintended generic `status` fields.
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
