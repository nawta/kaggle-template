#!/usr/bin/env bash
# review4.sh - 4モデル並列コードレビュースクリプト
# 設計ドキュメント: .claude/skills/review4/SKILL.md
# 関連ファイル: .claude/skills/review4/SKILL.md, .claude/settings.local.json
#
# Usage: bash review4.sh [staged|unstaged|all]
#   staged   - staged changes のみ (default)
#   unstaged - unstaged changes のみ
#   all      - staged + unstaged 両方

set -euo pipefail

# --- 設定 ---
CLAUDE_MODEL_1="${CLAUDE_MODEL_1:-claude-opus-4-6}"
CLAUDE_MODEL_2="${CLAUDE_MODEL_2:-claude-opus-4-5-20251101}"
CODEX_MODEL_1="${CODEX_MODEL_1:-gpt-5.3-codex}"
CODEX_MODEL_2="${CODEX_MODEL_2:-gpt-5.2-codex}"

CODEX_TIMEOUT="${CODEX_TIMEOUT:-3600}"  # 1時間 (秒)
CODEX_MAX_RETRIES="${CODEX_MAX_RETRIES:-3}"

SCOPE="${1:-staged}"

# --- 一時ディレクトリ ---
TMPDIR_REVIEW="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_REVIEW"' EXIT

CONTEXT_FILE="$TMPDIR_REVIEW/context.txt"
OUT_CLAUDE1="$TMPDIR_REVIEW/claude1.md"
OUT_CLAUDE2="$TMPDIR_REVIEW/claude2.md"
OUT_CODEX1="$TMPDIR_REVIEW/codex1.md"
OUT_CODEX2="$TMPDIR_REVIEW/codex2.md"

# --- git diff 収集 ---
echo "=== [review4] Collecting git diff (scope: $SCOPE) ===" >&2

{
  echo "# Git Status"
  echo '```'
  git status --short
  echo '```'
  echo

  case "$SCOPE" in
    staged)
      echo "# Staged Changes (git diff --cached)"
      echo '```diff'
      git diff --cached
      echo '```'
      ;;
    unstaged)
      echo "# Unstaged Changes (git diff)"
      echo '```diff'
      git diff
      echo '```'
      ;;
    all)
      echo "# Staged Changes (git diff --cached)"
      echo '```diff'
      git diff --cached
      echo '```'
      echo
      echo "# Unstaged Changes (git diff)"
      echo '```diff'
      git diff
      echo '```'
      ;;
    *)
      echo "Error: Unknown scope '$SCOPE'. Use staged|unstaged|all" >&2
      exit 1
      ;;
  esac
} > "$CONTEXT_FILE"

# diff が空かチェック
DIFF_SIZE=$(wc -c < "$CONTEXT_FILE")
if [ "$DIFF_SIZE" -lt 50 ]; then
  echo "=== [review4] No changes detected. Nothing to review. ===" >&2
  echo "No changes detected for scope: $SCOPE"
  exit 0
fi

echo "=== [review4] Context collected ($DIFF_SIZE bytes) ===" >&2

# --- レビュープロンプト ---
read -r -d '' PROMPT <<'REVIEW_PROMPT' || true
You are an expert code reviewer. Review the following code changes thoroughly.

Focus on:
1. **Bugs & Logic Errors**: Identify potential bugs, off-by-one errors, race conditions, null pointer issues
2. **Security**: SQL injection, XSS, command injection, hardcoded secrets, OWASP top 10
3. **Performance**: N+1 queries, unnecessary allocations, missing indexes, algorithmic complexity
4. **Readability & Maintainability**: Naming, code structure, duplication, magic numbers
5. **Best Practices**: Error handling, edge cases, testing gaps, type safety

Output format:
- Use markdown
- Group findings by severity: Critical > Warning > Suggestion > Good
- For each finding, include: file path, line reference, description, and suggested fix
- If the code looks good, say so briefly and note any minor improvements
- Be concise but thorough
- Write your review in Japanese
REVIEW_PROMPT

# --- 並列実行関数 ---
run_claude() {
  local model="$1"
  local out="$2"
  local label="$3"
  echo "=== [review4] Starting $label ($model) ===" >&2
  { echo "$PROMPT"; echo; cat "$CONTEXT_FILE"; } | claude -p \
    --model "$model" \
    --disallowed-tools "Bash Edit Write NotebookEdit" \
    --no-session-persistence \
    >"$out" 2>/dev/null || {
      echo "=== [review4] $label failed (exit=$?) ===" >&2
      echo "_${label} failed to produce output._" > "$out"
    }
  echo "=== [review4] $label completed ===" >&2
}

run_codex() {
  local model="$1"
  local out="$2"
  local label="$3"
  local attempt=1

  while [ "$attempt" -le "$CODEX_MAX_RETRIES" ]; do
    echo "=== [review4] Starting $label ($model) [attempt $attempt/$CODEX_MAX_RETRIES] ===" >&2

    # バックグラウンドで codex を実行し、タイムアウトを監視
    { echo "$PROMPT"; echo; cat "$CONTEXT_FILE"; } | codex exec \
      -m "$model" \
      -s read-only \
      - >"$out" 2>/dev/null &
    local codex_pid=$!

    # タイムアウト監視: CODEX_TIMEOUT 秒ごとにチェック
    local elapsed=0
    while kill -0 "$codex_pid" 2>/dev/null; do
      sleep 10
      elapsed=$((elapsed + 10))
      if [ "$elapsed" -ge "$CODEX_TIMEOUT" ]; then
        echo "=== [review4] $label timed out after ${CODEX_TIMEOUT}s (attempt $attempt/$CODEX_MAX_RETRIES) ===" >&2
        kill "$codex_pid" 2>/dev/null || true
        wait "$codex_pid" 2>/dev/null || true
        break
      fi
    done

    # プロセスがまだ動いていなければ正常終了を確認
    if ! kill -0 "$codex_pid" 2>/dev/null; then
      wait "$codex_pid" 2>/dev/null
      local exit_code=$?
      # 出力が空でなく、正常終了なら成功
      if [ "$exit_code" -eq 0 ] && [ -s "$out" ]; then
        echo "=== [review4] $label completed (attempt $attempt) ===" >&2
        return 0
      fi
      # タイムアウトではなく即座に失敗した場合
      if [ "$elapsed" -lt "$CODEX_TIMEOUT" ]; then
        echo "=== [review4] $label failed (exit=$exit_code, attempt $attempt/$CODEX_MAX_RETRIES) ===" >&2
      fi
    fi

    attempt=$((attempt + 1))
    if [ "$attempt" -le "$CODEX_MAX_RETRIES" ]; then
      echo "=== [review4] Retrying $label... ===" >&2
    fi
  done

  echo "=== [review4] $label failed after $CODEX_MAX_RETRIES attempts ===" >&2
  echo "_${label} failed to produce output after ${CODEX_MAX_RETRIES} attempts._" > "$out"
}

# --- 4モデル並列実行 ---
echo "=== [review4] Launching 4 models in parallel ===" >&2

run_claude "$CLAUDE_MODEL_1" "$OUT_CLAUDE1" "Claude-1(${CLAUDE_MODEL_1})" &
PID_C1=$!

run_claude "$CLAUDE_MODEL_2" "$OUT_CLAUDE2" "Claude-2(${CLAUDE_MODEL_2})" &
PID_C2=$!

run_codex "$CODEX_MODEL_1" "$OUT_CODEX1" "Codex-1(${CODEX_MODEL_1})" &
PID_CX1=$!

run_codex "$CODEX_MODEL_2" "$OUT_CODEX2" "Codex-2(${CODEX_MODEL_2})" &
PID_CX2=$!

echo "=== [review4] Waiting for all models (PIDs: $PID_C1 $PID_C2 $PID_CX1 $PID_CX2) ===" >&2
wait $PID_C1 $PID_C2 $PID_CX1 $PID_CX2
echo "=== [review4] All models completed ===" >&2

# --- 結果統合出力 ---
cat <<EOF
# Code Review Results (4-Model Parallel Review)

**Scope**: ${SCOPE}
**Models**: ${CLAUDE_MODEL_1}, ${CLAUDE_MODEL_2}, ${CODEX_MODEL_1}, ${CODEX_MODEL_2}

---

## Review by ${CLAUDE_MODEL_1}

$(cat "$OUT_CLAUDE1")

---

## Review by ${CLAUDE_MODEL_2}

$(cat "$OUT_CLAUDE2")

---

## Review by ${CODEX_MODEL_1}

$(cat "$OUT_CODEX1")

---

## Review by ${CODEX_MODEL_2}

$(cat "$OUT_CODEX2")

---

_Generated by review4 skill_
EOF
