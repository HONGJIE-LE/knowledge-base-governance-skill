#!/usr/bin/env bash
set -u

vault_path="${1:-.}"

if [[ ! -d "$vault_path" ]]; then
  printf 'ERROR: vault path does not exist: %s\n' "$vault_path" >&2
  exit 2
fi

if ! command -v rg >/dev/null 2>&1; then
  printf 'ERROR: rg is required for this read-only diagnosis scan.\n' >&2
  exit 3
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "$script_dir/audit-vault.sh" "$vault_path"

cd "$vault_path" || exit 2

for required_path in \
  '00 关于我' \
  '01 收进来 Raw' \
  '02 Wiki AI编译层' \
  '03 Projects 我的项目' \
  '04 Outputs 输出成果'; do
  if [[ ! -r "$required_path" ]]; then
    printf 'SCAN_WARNING: required path is missing or unreadable: %s\n' "$required_path" >&2
  fi
done

find_optional() {
  local output status
  output=$(find "$@" 2>&1)
  status=$?
  if [[ "$status" -eq 0 ]]; then
    [[ -z "$output" ]] || printf '%s\n' "$output"
  else
    printf 'SCAN_WARNING: find failed with exit %s: %s\n' "$status" "$output" >&2
  fi
}

knowledge_find() {
  local root="$1"
  shift
  [[ -e "$root" ]] || return 0
  find_optional "$root" -type f \
    \( -iname '*.md' -o -iname '*.canvas' -o -iname '*.base' \
       -o -iname '*.pdf' -o -iname '*.doc' -o -iname '*.docx' \
       -o -iname '*.xls' -o -iname '*.xlsx' -o -iname '*.csv' \
       -o -iname '*.ppt' -o -iname '*.pptx' -o -iname '*.txt' \
       -o -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \
       -o -iname '*.webp' -o -iname '*.mp3' -o -iname '*.m4a' \
       -o -iname '*.wav' -o -iname '*.mp4' \) \
    -not -path '*/node_modules/*' \
    -not -path '*/dist/*' \
    -not -path '*/build/*' \
    -not -path '*/.git/*' \
    -not -path '*/.codex/*' \
    -not -path '*/.agents/*' \
    "$@"
}

count_knowledge() {
  local root="$1"
  shift
  knowledge_find "$root" "$@" | wc -l | tr -d ' '
}

count_recent_files() {
  local root="$1"
  [[ -e "$root" ]] || { printf '0'; return; }
  find_optional "$root" -type f -mtime -14 \
    -not -path '*/node_modules/*' \
    -not -path '*/dist/*' \
    -not -path '*/build/*' | wc -l | tr -d ' '
}

rg_optional() {
  local output status
  output=$(rg "$@" 2>&1)
  status=$?
  if [[ "$status" -eq 0 ]]; then
    printf '%s\n' "$output"
  elif [[ "$status" -gt 1 ]]; then
    printf 'SCAN_WARNING: rg failed with exit %s: %s\n' "$status" "$output" >&2
  fi
}

percent_of() {
  local part="$1"
  local total="$2"
  awk -v part="$part" -v total="$total" 'BEGIN { if (total == 0) printf "0.0"; else printf "%.1f", part * 100 / total }'
}

count_text_lines() {
  local content="$1"
  if [[ -z "$content" ]]; then
    printf '0'
  else
    printf '%s\n' "$content" | sed '/^[[:space:]]*$/d' | wc -l | tr -d ' '
  fi
}

stat_record() {
  local target="$1"
  if stat -f '%m|%Sm|%N' -t '%Y-%m-%d %H:%M:%S' "$target" >/dev/null 2>&1; then
    stat -f '%m|%Sm|%N' -t '%Y-%m-%d %H:%M:%S' "$target"
  else
    stat -c '%Y|%y|%n' "$target" 2>/dev/null || true
  fi
}

display_stat_record() {
  local target="$1"
  stat_record "$target" | sed -E 's/^[^|]*\|([^|]*)\|/\1 | /'
}

print_path_activity() {
  local content="$1"
  local limit="$2"
  if [[ -z "$content" ]]; then
    printf '该类目前空缺\n'
    return
  fi
  while IFS= read -r target; do
    [[ -n "$target" ]] && stat_record "$target"
  done <<< "$content" | sort -t'|' -k1,1nr | cut -d'|' -f2- | sed 's/|/ | /' | head -n "$limit"
}

count_judgment_records() {
  local content="$1"
  local target rows total=0
  if [[ -z "$content" ]]; then
    printf '0'
    return
  fi
  while IFS= read -r target; do
    [[ -n "$target" ]] || continue
    rows=$(awk '
      /^\|[[:space:]]*判断候选[[:space:]]*\|/ { in_table=1; next }
      in_table && /^\|[[:space:]:|-]+\|?[[:space:]]*$/ { next }
      in_table && /^\|/ { count++; next }
      in_table && !/^\|/ { in_table=0 }
      END { print count + 0 }
    ' "$target")
    total=$((total + rows))
  done <<< "$content"
  printf '%s' "$total"
}

print_candidate_group() {
  local title="$1"
  local content="$2"
  local limit="$3"
  local count
  count=$(count_text_lines "$content")
  printf '%s_count: %s\n' "$title" "$count"
  print_path_activity "$content" "$limit"
}

print_activity_distribution() {
  local label="$1"
  local root="$2"
  local total last_7 days_8_14 days_15_30 older_30
  total=$(count_knowledge "$root")
  last_7=$(count_knowledge "$root" -mtime -7)
  days_8_14=$(count_knowledge "$root" -mtime +6 -mtime -15)
  days_15_30=$(count_knowledge "$root" -mtime +14 -mtime -31)
  older_30=$(count_knowledge "$root" -mtime +30)
  printf '%s | total=%s | 0-7d=%s | 8-14d=%s | 15-30d=%s | >30d=%s\n' \
    "$label" "$total" "$last_7" "$days_8_14" "$days_15_30" "$older_30"
}

printf '\n# Deep health diagnosis inventory\n\n'
printf 'scan_time: %s\n' "$(date '+%Y-%m-%d %H:%M:%S %z')"
printf 'scope_note: full path and metadata inventory; content quality requires the mandatory samples below.\n'

printf '\n## Step 1: all top-level entries\n\n'
find_optional . -mindepth 1 -maxdepth 1 -not -name '.git' -print | sort

printf '\n## Step 1: core entry candidates\n\n'
find_optional . -maxdepth 4 -type f \
  \( -iname 'START*.md' -o -iname 'README.md' -o -iname '*入口*.md' \
     -o -iname '*工作台*.md' -o -iname '*关于我*.md' -o -iname '*主线*.md' \
     -o -iname '*项目地图*.md' -o -iname '*Raw索引*.md' -o -iname '*输出索引*.md' \) \
  -not -path '*/node_modules/*' \
  -not -path '*/dist/*' \
  -not -path '*/build/*' \
  -not -path './.codex/*' \
  -not -path './.agents/*' \
  -not -path './.obsidian/*' \
  -not -path './.moma/*' \
  -print | sort | head -n 80

raw_count=$(count_knowledge '01 收进来 Raw')
wiki_count=$(count_knowledge '02 Wiki AI编译层')
projects_count=$(count_knowledge '03 Projects 我的项目')
outputs_count=$(count_knowledge '04 Outputs 输出成果')
functional_total=$((raw_count + wiki_count + projects_count + outputs_count))

printf '\n## Step 1: functional-region physical distribution\n\n'
printf 'Raw_equivalent: %s files | %s%%\n' "$raw_count" "$(percent_of "$raw_count" "$functional_total")"
printf 'Wiki_equivalent: %s files | %s%%\n' "$wiki_count" "$(percent_of "$wiki_count" "$functional_total")"
printf 'Projects_equivalent: %s files | %s%%\n' "$projects_count" "$(percent_of "$projects_count" "$functional_total")"
printf 'Outputs_physical_folder: %s files | %s%%\n' "$outputs_count" "$(percent_of "$outputs_count" "$functional_total")"
printf 'distribution_note: Outputs is an index/entry area; physical file share is not the registered-output count.\n'
printf 'other_top_level_function_candidates:\n'
while IFS= read -r target; do
  case "$target" in
    './01 收进来 Raw'|'./02 Wiki AI编译层'|'./03 Projects 我的项目'|'./04 Outputs 输出成果') continue ;;
  esac
  candidate_count=$(count_knowledge "$target")
  if [[ "$candidate_count" -gt 0 ]]; then
    printf '%s files | %s\n' "$candidate_count" "$target"
  fi
done < <(find_optional . -mindepth 1 -maxdepth 1 -type d -not -name '.*' -print | sort)
printf 'function_note: manually classify these candidates by actual function; canonical folder names are not the scoring boundary.\n'

printf '\n## Step 1: Obsidian and MOMA presence signals\n\n'
for target in '.obsidian' '.moma' '.obsidian/plugins/moma' '.obsidian/plugins/moma-obsidian-sync'; do
  if [[ -e "$target" ]]; then
    printf 'present: %s | ' "$target"
    display_stat_record "$target"
    printf 'recent_files_0_14d: %s | %s\n' "$(count_recent_files "$target")" "$target"
  else
    printf 'absent: %s\n' "$target"
  fi
done
if command -v pgrep >/dev/null 2>&1 && pgrep -x Obsidian >/dev/null 2>&1; then
  printf 'obsidian_process: running\n'
else
  printf 'obsidian_process: not_detected\n'
fi
printf 'other_ai_bases:\n'
for target in '.codex' '.agents' '.claude' '.claudian' '.hermes' '.workbuddy'; do
  if [[ -e "$target" ]]; then
    printf 'present: %s | ' "$target"
    display_stat_record "$target"
    printf 'recent_files_0_14d: %s | %s\n' "$(count_recent_files "$target")" "$target"
  else
    printf 'absent: %s\n' "$target"
  fi
done
printf 'security_note: presence and timestamps only; credential values were not read.\n'

printf '\n## Step 2: knowledge-object counts and sample candidates\n\n'
project_sites=$(find_optional . -type f -name '*-项目现场.md' \
  -not -path '*/node_modules/*' -not -path '*/dist/*' -not -path '*/build/*' \
  -not -path './.codex/*' -not -path './.agents/*' -not -path './.obsidian/*' \
  -not -path './.moma/*' -print | sort)
project_sites_in_region=''
project_sites_outside_region=''
while IFS= read -r target; do
  [[ -n "$target" ]] || continue
  if [[ "$target" == './03 Projects 我的项目/'* ]]; then
    project_sites_in_region+="${project_sites_in_region:+$'\n'}$target"
  else
    project_sites_outside_region+="${project_sites_outside_region:+$'\n'}$target"
  fi
done <<< "$project_sites"
judgment_page_candidates=$(find_optional '02 Wiki AI编译层/02 判断候选' -type f -name '*.md' \
  -not -name '*索引.md' -print | sort)
judgment_container_candidates=$(find_optional '02 Wiki AI编译层/02 判断候选' -type f -name '*索引*.md' \
  -print | sort)
judgment_record_candidate_count=$(count_judgment_records "$judgment_container_candidates")
source_summary_candidates=$(
  {
    find_optional . -type f -iname '*来源摘要*.md' \
      -not -path '*/node_modules/*' -not -path '*/dist/*' -not -path '*/build/*' \
      -not -path './.codex/*' -not -path './.agents/*' -print
    rg_optional -l --glob '*.md' --glob '!**/node_modules/**' --glob '!**/dist/**' --glob '!**/build/**' \
      --glob '!.codex/**' --glob '!.agents/**' \
      '^note_type:[[:space:]]*(source_summary|source-summary|source)[[:space:]]*$' .
  } | sort -u
)
source_traceability_candidates=$(
  rg_optional -l --glob '*.md' \
    '^(##+[[:space:]]+来源|>[[:space:]]*来源[：:]|\|.*(来源|证据来源).*(摘要|说明)|\|.*摘要.*关联资料)' \
    '02 Wiki AI编译层/01 主题页' \
    '02 Wiki AI编译层/03 人物组织' \
    '02 Wiki AI编译层/04 项目背景' | sort -u
)
theme_candidates=$(find_optional '02 Wiki AI编译层/01 主题页' -type f -name '*.md' \
  -not -name '*索引.md' -print | sort)
methodology_candidates=$(
  {
    find_optional '02 Wiki AI编译层' '05 技能手册' -type f \
      \( -iname '*方法*.md' -o -iname '*机制*.md' -o -iname '*工作流*.md' -o -iname '*规范*.md' \) \
      -not -path '*/node_modules/*' -not -path '*/dist/*' -not -path '*/build/*' -print
    rg_optional -l --glob '*.md' '^note_type:[[:space:]]*(method|methodology)[[:space:]]*$|^##+[[:space:]].*(方法|机制|工作流)' \
      '02 Wiki AI编译层' '05 技能手册'
  } | sort -u
)
output_index_candidates=$(find_optional '04 Outputs 输出成果' -type f -name '*输出索引*.md' -print | sort)
compile_log_candidates=$(find_optional '02 Wiki AI编译层/05 编译日志' -type f -name '*.md' -print | sort)
background_candidates=$(find_optional '02 Wiki AI编译层/04 项目背景' -type f -name '*.md' \
  -not -name '*索引.md' -print | sort)

print_candidate_group 'project_site' "$project_sites" 20
printf 'project_site_in_projects_region_count: %s\n' "$(count_text_lines "$project_sites_in_region")"
printf 'project_site_outside_projects_region_count: %s\n' "$(count_text_lines "$project_sites_outside_region")"
if [[ -n "$project_sites_outside_region" ]]; then
  printf 'project_site_outside_projects_region:\n%s\n' "$project_sites_outside_region"
fi
print_candidate_group 'judgment_page' "$judgment_page_candidates" 10
print_candidate_group 'judgment_container' "$judgment_container_candidates" 10
printf 'judgment_record_candidate_count: %s\n' "$judgment_record_candidate_count"
printf 'judgment_count_note: separate pages and records concentrated in an index are reported separately; verify record quality by opening samples.\n'
print_candidate_group 'source_summary_page_candidate' "$source_summary_candidates" 10
print_candidate_group 'source_traceability_equivalent_candidate' "$source_traceability_candidates" 10
printf 'source_count_note: equivalent source-summary candidates require content review before they count as source summaries.\n'
print_candidate_group 'theme_page' "$theme_candidates" 10
print_candidate_group 'methodology_candidate' "$methodology_candidates" 10
print_candidate_group 'output_index' "$output_index_candidates" 5
print_candidate_group 'compile_log' "$compile_log_candidates" 5
print_candidate_group 'project_background' "$background_candidates" 10

printf '\n## Step 3: active-time distribution\n\n'
print_activity_distribution 'About_and_entry' '00 关于我'
print_activity_distribution 'Raw' '01 收进来 Raw'
print_activity_distribution 'Wiki' '02 Wiki AI编译层'
print_activity_distribution 'Projects' '03 Projects 我的项目'
print_activity_distribution 'Outputs' '04 Outputs 输出成果'
print_activity_distribution 'Methods' '05 技能手册'

printf '\n## Step 3: critical-entry timestamps\n\n'
for target in \
  '00 关于我/知识库工作台.md' \
  '00 关于我/关于我.md' \
  '00 关于我/当前主线.md' \
  '02 Wiki AI编译层/00 Raw索引.md' \
  '03 Projects 我的项目/项目地图.md' \
  '04 Outputs 输出成果/输出索引.md'; do
  if [[ -f "$target" ]]; then
    display_stat_record "$target"
  else
    printf 'missing: %s\n' "$target"
  fi
done

core_paths=('00 关于我' '01 收进来 Raw' '02 Wiki AI编译层' '03 Projects 我的项目' '04 Outputs 输出成果' '05 技能手册')
link_occurrences=$(count_text_lines "$(rg_optional -o -F --glob '*.md' --glob '!**/node_modules/**' --glob '!**/dist/**' \
  --glob '!**/build/**' '[[' "${core_paths[@]}")")
linked_files=$(count_text_lines "$(rg_optional -l -F --glob '*.md' --glob '!**/node_modules/**' --glob '!**/dist/**' \
  --glob '!**/build/**' '[[' "${core_paths[@]}")")
judgment_reason_files=$(count_text_lines "$(rg_optional -l --glob '*.md' '判断依据|判断理由|因为|来源|证据' \
  '02 Wiki AI编译层/02 判断候选' '03 Projects 我的项目')")
judgment_revision_files=$(count_text_lines "$(rg_optional -l --glob '*.md' '修正|推翻|判断变化|验证结果|结果反馈|复盘' \
  '02 Wiki AI编译层/02 判断候选' '03 Projects 我的项目')")
action_signal_files=$(count_text_lines "$(rg_optional -l --glob '*.md' '^next_action:|下一步|行动项|待办' \
  '02 Wiki AI编译层' '03 Projects 我的项目')")

printf '\n## Step 4: simple network and judgment signals\n\n'
printf 'wikilink_occurrences: %s\n' "$link_occurrences"
printf 'markdown_files_with_wikilinks: %s\n' "$linked_files"
printf 'files_with_judgment_reason_signals: %s\n' "$judgment_reason_files"
printf 'files_with_revision_or_review_signals: %s\n' "$judgment_revision_files"
printf 'files_with_action_signals: %s\n' "$action_signal_files"
printf 'signal_note: keyword signals are sampling leads, not quality scores.\n'
printf 'error_note: if any SCAN_WARNING appeared, do not report the affected category as empty.\n'

printf '\nDeep diagnosis scan completed without writing to the vault.\n'
