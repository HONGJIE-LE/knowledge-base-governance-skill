#!/usr/bin/env bash
set -u

vault_path="${1:-.}"

if [[ ! -d "$vault_path" ]]; then
  printf 'ERROR: vault path does not exist: %s\n' "$vault_path" >&2
  exit 2
fi

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

grep_optional() {
  local output status
  output=$(grep "$@" 2>&1)
  status=$?
  if [[ "$status" -eq 0 ]]; then
    printf '%s\n' "$output"
  elif [[ "$status" -gt 1 ]]; then
    printf 'SCAN_WARNING: grep failed with exit %s: %s\n' "$status" "$output" >&2
  fi
}

knowledge_files() {
  local root="${1:-.}"
  find_optional "$root" \
    \( -type d \( -name '.git' -o -name 'node_modules' -o -name 'dist' -o -name 'build' \
       -o -name '.codex' -o -name '.agents' -o -name '.obsidian' \
       -o -name '.moma' -o -name '.claude' -o -name '.claudian' \
       -o -name '.hermes' -o -name '.workbuddy' \) -prune \) -o \
    \( -type f \( -iname '*.md' -o -iname '*.canvas' -o -iname '*.base' \
       -o -iname '*.pdf' -o -iname '*.doc' -o -iname '*.docx' \
       -o -iname '*.xls' -o -iname '*.xlsx' -o -iname '*.csv' \
       -o -iname '*.ppt' -o -iname '*.pptx' -o -iname '*.txt' \
       -o -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \
       -o -iname '*.webp' -o -iname '*.mp3' -o -iname '*.m4a' \
       -o -iname '*.wav' -o -iname '*.mp4' \) -print \)
}

markdown_files() {
  knowledge_files "${1:-.}" | grep_optional -Ei '\.md$'
}

count_nonblank() {
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

recent_file_count() {
  local root="$1"
  find_optional "$root" \
    \( -type d \( -name '.git' -o -name 'node_modules' -o -name 'dist' -o -name 'build' \
       -o -name '.codex' -o -name '.agents' -o -name '.obsidian' \
       -o -name '.moma' -o -name '.claude' -o -name '.claudian' \
       -o -name '.hermes' -o -name '.workbuddy' \) -prune \) -o \
    \( -type f -mtime -14 -print \) | wc -l | tr -d ' '
}

print_name_hints() {
  local label="$1"
  local pattern="$2"
  local paths="$3"
  local matches
  matches=$(printf '%s\n' "$paths" | grep_optional -Ei "$pattern")
  printf '%s_name_hint_count: %s\n' "$label" "$(count_nonblank "$matches")"
  if [[ -n "$matches" ]]; then
    printf '%s\n' "$matches" | head -n 15
  fi
}

all_knowledge_files=$(knowledge_files .)
all_markdown_files=$(markdown_files .)

printf '# General knowledge-base read-only audit\n\n'
printf 'vault: %s\n' "$PWD"
printf 'scan_time: %s\n' "$(date '+%Y-%m-%d %H:%M:%S %z')"
printf 'knowledge_files_excluding_tooling: %s\n' "$(count_nonblank "$all_knowledge_files")"
printf 'markdown_files_excluding_tooling: %s\n' "$(count_nonblank "$all_markdown_files")"
printf 'scope_note: path names are only hints; open representative content before assigning a function.\n'

printf '\n## Top-level inventory and activity\n\n'
find_optional . -mindepth 1 -maxdepth 1 -not -name '.git' -print | sort

while IFS= read -r top_dir; do
  [[ -n "$top_dir" ]] || continue
  top_knowledge=$(knowledge_files "$top_dir")
  printf 'top_level_region: %s | knowledge_files=%s | files_changed_0_14d=%s\n' \
    "$top_dir" "$(count_nonblank "$top_knowledge")" "$(recent_file_count "$top_dir")"
done < <(find_optional . -mindepth 1 -maxdepth 1 -type d -not -name '.git' -print | sort)

printf '\n## Entry and navigation candidates\n\n'
entry_candidates=$(find_optional . -maxdepth 4 -type f \
  \( -iname 'START*.md' -o -iname 'README*.md' -o -iname '*入口*.md' \
     -o -iname '*首页*.md' -o -iname '*工作台*.md' -o -iname '*导航*.md' \
     -o -iname '*地图*.md' -o -iname '*索引*.md' -o -iname '*关于我*.md' \
     -o -iname '*主线*.md' -o -iname '*current*.md' -o -iname '*dashboard*.md' \) \
  -not -path '*/node_modules/*' -not -path '*/dist/*' -not -path '*/build/*' \
  -not -path '*/.git/*' -not -path '*/.codex/*' -not -path '*/.agents/*' \
  -not -path '*/.obsidian/*' -not -path '*/.moma/*' -not -path '*/.claude/*' \
  -not -path '*/.claudian/*' -not -path '*/.hermes/*' -not -path '*/.workbuddy/*' \
  -print | sort)
printf 'entry_candidate_count: %s\n' "$(count_nonblank "$entry_candidates")"
if [[ -n "$entry_candidates" ]]; then
  printf '%s\n' "$entry_candidates" | head -n 50
fi

printf '\n## Functional name hints\n\n'
print_name_hints 'capture_source' '(inbox|incoming|capture|source|raw|收件|收到|采集|来源|原始|附件|会议|参考)' "$all_knowledge_files"
print_name_hints 'knowledge_distillation' '(wiki|knowledge|topic|concept|research|知识|主题|概念|研究|说明|背景)' "$all_knowledge_files"
print_name_hints 'active_work' '(project|task|action|plan|项目|任务|行动|计划|现场|待办)' "$all_knowledge_files"
print_name_hints 'judgment_review' '(decision|judgment|review|retrospective|判断|决策|复盘|假设|验证|经验)' "$all_knowledge_files"
print_name_hints 'output_delivery' '(output|deliver|publish|report|成果|输出|交付|发布|报告|方案|成品)' "$all_knowledge_files"
print_name_hints 'people_organization' '(people|person|contact|organization|人物|人员|联系人|组织|机构|客户)' "$all_knowledge_files"
print_name_hints 'method_template' '(method|template|workflow|sop|skill|方法|模板|流程|规范|技能)' "$all_knowledge_files"
print_name_hints 'archive_reference' '(archive|history|reference|归档|历史|参考)' "$all_knowledge_files"
printf 'hint_note: these groups are sampling leads, not confirmed categories; one path may serve several functions.\n'

printf '\n## Recent active files\n\n'
while IFS= read -r target; do
  [[ -n "$target" ]] && stat_record "$target"
done <<< "$all_knowledge_files" | sort -t'|' -k1,1nr | cut -d'|' -f2- | sed 's/|/ | /' | head -n 60

printf '\n## Frontmatter and query signals\n\n'
frontmatter_keys=$(
  while IFS= read -r target; do
    [[ -n "$target" ]] || continue
    awk '
      NR == 1 && $0 == "---" { in_yaml=1; next }
      in_yaml && $0 == "---" { exit }
      in_yaml && /^[^[:space:]#][^:]*:/ {
        key=$0
        sub(/:.*/, "", key)
        print key
      }
    ' "$target"
  done <<< "$all_markdown_files" | sort | uniq -c | sort -nr
)
printf 'frontmatter_key_candidates:\n'
if [[ -n "$frontmatter_keys" ]]; then
  printf '%s\n' "$frontmatter_keys" | head -n 30
else
  printf 'none_detected\n'
fi

dataview_files=$(
  while IFS= read -r target; do
    [[ -n "$target" ]] || continue
    if grep -Eq '^```dataview(js)?[[:space:]]*$' "$target" 2>/dev/null; then
      printf '%s\n' "$target"
    fi
  done <<< "$all_markdown_files"
)
printf 'files_with_dataview: %s\n' "$(count_nonblank "$dataview_files")"
[[ -z "$dataview_files" ]] || printf '%s\n' "$dataview_files" | head -n 30

printf '\n## Knowledge-base application and extension signals\n\n'
if [[ -d '.obsidian' ]]; then
  printf 'obsidian_config: present\n'
else
  printf 'obsidian_config: absent\n'
fi
if [[ -f '.obsidian/community-plugins.json' ]] && command -v jq >/dev/null 2>&1; then
  printf 'enabled_community_plugins: %s\n' "$(jq 'length' '.obsidian/community-plugins.json' 2>/dev/null || printf '?')"
  jq -r '.[]' '.obsidian/community-plugins.json' 2>/dev/null | sort || true
else
  printf 'enabled_community_plugins: not_structurally_checked\n'
fi
if [[ -d '.obsidian/plugins' ]]; then
  installed_count=$(find_optional '.obsidian/plugins' -mindepth 2 -maxdepth 2 -type f -name manifest.json | wc -l | tr -d ' ')
else
  installed_count=0
fi
printf 'installed_community_plugin_manifests: %s\n' "$installed_count"

printf '\n## Indexing-noise candidates\n\n'
for noise_name in node_modules dist build .cache; do
  noise_dirs=$(find_optional . -type d -name "$noise_name" -prune -print)
  printf '%s_directories: %s\n' "$noise_name" "$(count_nonblank "$noise_dirs")"
  [[ -z "$noise_dirs" ]] || printf '%s\n' "$noise_dirs" | head -n 20
done
if [[ -f '.obsidian/app.json' ]] && command -v jq >/dev/null 2>&1; then
  printf 'obsidian_user_ignore_filters: %s\n' "$(jq '(.userIgnoreFilters // []) | length' '.obsidian/app.json' 2>/dev/null || printf '?')"
else
  printf 'obsidian_user_ignore_filters: not_structurally_checked\n'
fi

printf '\n## Sensitive-configuration ignore signals\n\n'
for sensitive_path in '.moma/moma-settings.json' '.obsidian/plugins/moma-obsidian-sync/data.json'; do
  [[ -e "$sensitive_path" ]] || continue
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if git check-ignore -q "$sensitive_path"; then
      printf 'ignored: %s\n' "$sensitive_path"
    else
      printf 'REVIEW_REQUIRED_not_ignored: %s\n' "$sensitive_path"
    fi
  else
    printf 'present_not_git_checked: %s\n' "$sensitive_path"
  fi
done
printf 'security_note: credential values were not read.\n'

printf '\n## Git working-tree summary\n\n'
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git status --porcelain | awk '
    BEGIN {modified=0; deleted=0; untracked=0; other=0}
    /^\?\?/ {untracked++; next}
    {code=substr($0,1,2); if (code ~ /D/) deleted++; else if (code ~ /M|A|R|C|U/) modified++; else other++}
    END {
      printf "modified_or_added: %d\n", modified
      printf "deleted: %d\n", deleted
      printf "untracked: %d\n", untracked
      printf "other: %d\n", other
    }'
else
  printf 'not_a_git_working_tree\n'
fi

printf '\nAudit completed without writing to the knowledge base.\n'
printf 'interpretation_note: use actual paths and content evidence; do not turn name hints into fixed labels.\n'
