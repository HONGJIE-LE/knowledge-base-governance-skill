#!/usr/bin/env bash
set -u

vault_path="${1:-.}"

if [[ ! -d "$vault_path" ]]; then
  printf 'ERROR: vault path does not exist: %s\n' "$vault_path" >&2
  exit 2
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "$script_dir/audit-vault.sh" "$vault_path"

cd "$vault_path" || exit 2

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
    -not -path '*/.claude/*' \
    -not -path '*/.claudian/*' \
    -not -path '*/.hermes/*' \
    -not -path '*/.workbuddy/*' \
    -not -path '*/.obsidian/*' \
    -not -path '*/.moma/*' \
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

search_optional() {
  local list_mode=0 only_matches=0 fixed_mode=0 ignore_case=0 pattern=''
  local arg target file grep_status
  local -a paths=()
  while [[ "$#" -gt 0 ]]; do
    arg="$1"
    shift
    case "$arg" in
      -l) list_mode=1 ;;
      -o) only_matches=1 ;;
      -F) fixed_mode=1 ;;
      -i) ignore_case=1 ;;
      --glob) [[ "$#" -gt 0 ]] && shift ;;
      --glob=*) ;;
      --*) ;;
      *)
        if [[ -z "$pattern" ]]; then
          pattern="$arg"
        else
          paths+=("$arg")
        fi
        ;;
    esac
  done
  [[ -n "$pattern" ]] || return 0
  [[ "${#paths[@]}" -gt 0 ]] || paths=(.)

  local -a grep_args=()
  [[ "$fixed_mode" -eq 1 ]] && grep_args+=(-F) || grep_args+=(-E)
  [[ "$ignore_case" -eq 1 ]] && grep_args+=(-i)
  [[ "$only_matches" -eq 1 ]] && grep_args+=(-o)

  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    if [[ "$list_mode" -eq 1 ]]; then
      if grep "${grep_args[@]}" -q -- "$pattern" "$file" 2>/dev/null; then
        printf '%s\n' "$file"
      fi
    else
      output=$(grep "${grep_args[@]}" -- "$pattern" "$file" 2>&1)
      grep_status=$?
      if [[ "$grep_status" -eq 0 ]]; then
        printf '%s\n' "$output"
      elif [[ "$grep_status" -gt 1 ]]; then
        printf 'SCAN_WARNING: grep fallback failed for %s: %s\n' "$file" "$output" >&2
      fi
    fi
  done < <(
    for target in "${paths[@]}"; do
      [[ -e "$target" ]] || continue
      if [[ -f "$target" ]]; then
        [[ "$target" == *.md ]] && printf '%s\n' "$target"
      else
        find_optional "$target" -type f -iname '*.md' \
          -not -path '*/node_modules/*' -not -path '*/dist/*' -not -path '*/build/*' \
          -not -path '*/.git/*' -not -path '*/.codex/*' -not -path '*/.agents/*' \
          -not -path '*/.claude/*' -not -path '*/.obsidian/*' -not -path '*/.moma/*' \
          -print
      fi
    done | sort -u
  )
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
entry_candidates=$(find_optional . -maxdepth 5 -type f \
  \( -iname 'START*.md' -o -iname 'README*.md' -o -iname 'HOME*.md' \
     -o -iname '*入口*.md' -o -iname '*首页*.md' -o -iname '*工作台*.md' \
     -o -iname '*导航*.md' -o -iname '*地图*.md' -o -iname '*索引*.md' \
     -o -iname '*关于*.md' -o -iname '*主线*.md' -o -iname '*current*.md' \
     -o -iname '*dashboard*.md' -o -iname '*index*.md' -o -iname '*map*.md' \) \
  -not -path '*/node_modules/*' \
  -not -path '*/dist/*' \
  -not -path '*/build/*' \
  -not -path './.codex/*' \
  -not -path './.agents/*' \
  -not -path './.claude/*' \
  -not -path './.claudian/*' \
  -not -path './.hermes/*' \
  -not -path './.workbuddy/*' \
  -not -path './.obsidian/*' \
  -not -path './.moma/*' \
  -print | sort)
printf '%s\n' "$entry_candidates" | head -n 80

printf '\n## Step 1: functional-region physical distribution\n\n'
functional_total=$(count_knowledge .)
while IFS= read -r target; do
  candidate_count=$(count_knowledge "$target")
  if [[ "$candidate_count" -gt 0 ]]; then
    printf '%s files | %s%% | %s\n' "$candidate_count" \
      "$(percent_of "$candidate_count" "$functional_total")" "$target"
  fi
done < <(find_optional . -mindepth 1 -maxdepth 1 -type d -not -name '.*' -print | sort)
printf 'function_note: classify every region by actual content and links; folder names are only hints and one function may span several regions.\n'

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
all_markdown_files=$(knowledge_find . | grep -Ei '\.md$' || true)

path_hint_candidates() {
  local pattern="$1"
  printf '%s\n' "$all_markdown_files" | grep -Ei "$pattern" || true
}

content_hint_candidates() {
  local pattern="$1"
  search_optional -l --glob '*.md' "$pattern" .
}

combined_candidates() {
  local path_pattern="$1"
  local content_pattern="$2"
  {
    path_hint_candidates "$path_pattern"
    content_hint_candidates "$content_pattern"
  } | sort -u
}

project_sites=$(combined_candidates \
  '(project|projects|task|action|plan|项目|任务|行动|计划|现场|待办)' \
  '^project_status:|^next_action:|^##+[[:space:]]*(目标|进展|下一步|行动|结果|Goal|Progress|Next|Action)')
judgment_page_candidates=$(combined_candidates \
  '(judgment|decision|hypothesis|review|判断|决策|假设|验证|复盘)' \
  '^confirmation:|判断依据|判断理由|我认为|because|hypothesis|decision|验证状态|修正|推翻')
judgment_container_candidates=$(
  {
    path_hint_candidates '(judgment|decision|判断|决策).*(index|索引|register|台账)'
    content_hint_candidates '^\|[[:space:]]*(判断候选|判断|decision|hypothesis)[[:space:]]*\|'
  } | sort -u
)
judgment_record_candidate_count=$(count_judgment_records "$judgment_container_candidates")
source_summary_candidates=$(combined_candidates \
  '(source|sources|reference|summary|来源|资料|参考|摘要)' \
  '^note_type:[[:space:]]*(source_summary|source-summary|source)[[:space:]]*$|^##+[[:space:]]*(来源摘要|Source summary|Source Summary)')
source_traceability_candidates=$(content_hint_candidates \
  '^(##+[[:space:]]+(来源|Source|References)|>[[:space:]]*(来源|Source)[：:]|\|.*(来源|Source|证据来源).*(摘要|说明|Summary)|\|.*摘要.*关联资料)')
theme_candidates=$(combined_candidates \
  '(wiki|knowledge|topic|theme|concept|research|知识|主题|概念|研究)' \
  '^note_type:[[:space:]]*(topic|theme|knowledge|concept)[[:space:]]*$|^##+[[:space:]]*(主题|核心概念|Topic|Concept)')
methodology_candidates=$(combined_candidates \
  '(method|methodology|template|workflow|sop|playbook|方法|机制|模板|流程|规范|手册)' \
  '^note_type:[[:space:]]*(method|methodology|template|workflow)[[:space:]]*$|^##+[[:space:]].*(方法|机制|工作流|流程|Method|Workflow)')
output_index_candidates=$(combined_candidates \
  '(output|outputs|deliver|publish|portfolio|成果|输出|交付|发布|成品)' \
  '^output_status:|^##+[[:space:]]*(成果|输出|交付|Outputs?|Deliverables?)|\|.*(成果名|Output|Deliverable).*\|')
compile_log_candidates=$(combined_candidates \
  '(compile|change|review|log|history|编译|变更|复盘|维护|日志|记录)' \
  '^##+[[:space:]]*(编译日志|变更记录|复盘记录|Change log|Review log|History)|^last_reviewed:')
background_candidates=$(combined_candidates \
  '(background|context|about|profile|brief|背景|上下文|关于|简介|主线)' \
  '^note_type:[[:space:]]*(background|context|profile)[[:space:]]*$|^##+[[:space:]]*(背景|上下文|目标与范围|Background|Context)')

print_candidate_group 'project_site' "$project_sites" 20
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
while IFS= read -r target; do
  [[ -n "$target" ]] || continue
  print_activity_distribution "$target" "$target"
done < <(find_optional . -mindepth 1 -maxdepth 1 -type d -not -name '.*' -print | sort)

printf '\n## Step 3: critical-entry timestamps\n\n'
print_path_activity "$entry_candidates" 30

link_occurrences=$(count_text_lines "$(search_optional -o -F --glob '*.md' --glob '!**/node_modules/**' --glob '!**/dist/**' \
  --glob '!**/build/**' '[[' .)")
linked_files=$(count_text_lines "$(search_optional -l -F --glob '*.md' --glob '!**/node_modules/**' --glob '!**/dist/**' \
  --glob '!**/build/**' '[[' .)")
judgment_reason_files=$(count_text_lines "$(search_optional -l --glob '*.md' \
  '判断依据|判断理由|我认为|因为|来源|证据|decision reason|because|evidence' .)")
judgment_revision_files=$(count_text_lines "$(search_optional -l --glob '*.md' \
  '修正|推翻|判断变化|验证结果|结果反馈|复盘|revised|overturned|validation result|retrospective' .)")
action_signal_files=$(count_text_lines "$(search_optional -l --glob '*.md' \
  '^next_action:|下一步|行动项|待办|next action|action item|todo' .)")

printf '\n## Step 4: simple network and judgment signals\n\n'
printf 'wikilink_occurrences: %s\n' "$link_occurrences"
printf 'markdown_files_with_wikilinks: %s\n' "$linked_files"
printf 'files_with_judgment_reason_signals: %s\n' "$judgment_reason_files"
printf 'files_with_revision_or_review_signals: %s\n' "$judgment_revision_files"
printf 'files_with_action_signals: %s\n' "$action_signal_files"
printf 'signal_note: keyword signals are sampling leads, not quality scores.\n'
printf 'error_note: if any SCAN_WARNING appeared, do not report the affected category as empty.\n'

printf '\nDeep diagnosis scan completed without writing to the vault.\n'
