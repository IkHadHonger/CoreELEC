#!/usr/bin/env bash
set -euo pipefail

task_repo=IkHadHonger/CoreELEC
task_base=cube3-wifi6e-samurihl-20260928
task_head=updates/samurihl-ce22
task_upstream=https://github.com/SamuriHL/CoreELEC.git

test "${GITHUB_REPOSITORY:?}" = "$task_repo"
command -v gh >/dev/null
git fetch --no-tags origin "refs/heads/${task_base}:refs/remotes/origin/${task_base}"
git fetch --no-tags "$task_upstream" refs/heads/samurihl-ce22
task_up_sha=$(git rev-parse FETCH_HEAD)
task_base_sha=$(git rev-parse "refs/remotes/origin/${task_base}")

if git merge-base --is-ancestor "$task_up_sha" "$task_base_sha"; then
  printf 'No new SamuriHL commits. Customized branch unchanged.\n' >> "$GITHUB_STEP_SUMMARY"
  exit 0
fi

task_common=$(git merge-base "$task_base_sha" "$task_up_sha")
task_report="${RUNNER_TEMP:?}/samurihl-update.md"
task_merge_report="${RUNNER_TEMP}/samurihl-merge-check.txt"
task_merge_ok=yes
git merge-tree --write-tree "$task_base_sha" "$task_up_sha" > "$task_merge_report" || task_merge_ok=no

{
  printf '## SamuriHL upstream update\n\n'
  printf 'Target: `%s`\n\nUpstream: `SamuriHL/CoreELEC: samurihl-ce22`\n\n' "$task_base"
  printf 'Upstream commit: `%s`\n\nCompared target commit: `%s`\n\n' "$task_up_sha" "$task_base_sha"
  printf 'This is a **draft proposal only**. The customized default branch is not modified, and this workflow never approves or merges pull requests.\n\n'
  if [ "$task_merge_ok" = yes ]; then
    printf '### Merge check\n\nGit reports no textual merge conflicts. This is not a build or hardware test.\n\n'
    task_tree=$(head -n 1 "$task_merge_report")
    for task_path in distributions/CoreELEC/splash/Amlogic-no/progress distributions/CoreELEC/splash/Amlogic-no/splash-1080.png; do
      if ! git diff --quiet "$task_base_sha" "$task_tree" -- "$task_path"; then
        printf '**Review required:** the proposed merge changes the original CoreELEC boot artwork (`%s`).\n\n' "$task_path"
      fi
    done
    for task_path in projects/Amlogic-ce/packages/linux/package.mk projects/Amlogic-ce/packages/linux-drivers/amlogic/mt76/package.mk; do
      if ! git diff --quiet "$task_base_sha" "$task_tree" -- "$task_path"; then
        printf '**Review required:** the proposed merge changes the Wi-Fi driver/package configuration (`%s`).\n\n' "$task_path"
      fi
    done
  else
    printf '### Merge check\n\n**Merge conflicts detected.** Resolve them manually while preserving the Cube 3 Wi-Fi fixes and stock boot animation.\n\n'
  fi
  printf '### Upstream commits (maximum 40)\n\n```text\n'
  git log -40 --format='%h %s' "${task_common}..${task_up_sha}"
  printf '```\n\n### Upstream changed files (maximum 80)\n\n```text\n'
  git diff --name-only "$task_common" "$task_up_sha" | head -80 || true
  printf '```\n\n### Before merging\n\n- Preserve Cube 3 Wi-Fi 6/6E fixes, regional power tables, and the stock CoreELEC boot animation.\n- Review BD-J/playback changes and package versions.\n- Build and check a new update tar; test playback and Wi-Fi on the Cube 3.\n- Merge manually only after review. The existing tar does not update itself.\n'
} > "$task_report"

# Only a dedicated proposal branch is written. No force push: an upstream
# history rewrite or unexpected edits to this branch fail safely for review.
gh auth setup-git
git push origin "${task_up_sha}:refs/heads/${task_head}"
task_pr_url=$(gh pr list --repo "$task_repo" --base "$task_base" --head "$task_head" --state open --json url --jq '.[0].url // empty')
if [ -z "$task_pr_url" ]; then
  task_pr_url=$(gh pr create --repo "$task_repo" --base "$task_base" --head "$task_head" --draft --title 'Review SamuriHL upstream updates for Cube 3 Wi-Fi 6E' --body-file "$task_report")
else
  gh pr edit "$task_pr_url" --repo "$task_repo" --body-file "$task_report"
fi
printf 'Upstream update proposal: %s\n\nNo automatic merge or approval.\n' "$task_pr_url" >> "$GITHUB_STEP_SUMMARY"
