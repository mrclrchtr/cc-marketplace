#!/usr/bin/env bash
# codex-review.sh — Launch a Codex CLI code review in a tmux session.
#
# Usage:
#   codex-review.sh [OPTIONS] [-- EXTRA_CODEX_ARGS...]
#
# Options:
#   --scope FLAG          Git scope (--uncommitted, "--base main", "--commit SHA")
#                         Default: --uncommitted
#   --model MODEL         Codex model. Default: gpt-5.3-codex
#   --reasoning LEVEL     model_reasoning_effort value. Default: xhigh
#   --prompt-file FILE    Custom prompt file (skips default prompt generation)
#   --prompt TEXT          Inline prompt text (written to temp file)
#   --help                Show this help
#
# Output (on stdout):
#   SESSION_NAME=<name>
#   REVIEW_OUTPUT=<path>
#
# The review runs inside a named tmux session. Attach with:
#   tmux attach -t <SESSION_NAME>
#
# Wait for completion with:
#   tmux wait-for <SESSION_NAME>

set -euo pipefail

# --- Defaults ---
MODEL="gpt-5.3-codex"
REASONING="xhigh"
SCOPE_FLAG="--uncommitted"
PROMPT_FILE=""
CUSTOM_PROMPT=""
EXTRA_ARGS=()

# --- Parse arguments ---
while [[ $# -gt 0 ]]; do
  case $1 in
    --scope)      SCOPE_FLAG="$2";      shift 2 ;;
    --model)      MODEL="$2";           shift 2 ;;
    --reasoning)  REASONING="$2";       shift 2 ;;
    --prompt-file) PROMPT_FILE="$2";    shift 2 ;;
    --prompt)     CUSTOM_PROMPT="$2";   shift 2 ;;
    --help)
      sed -n '2,/^$/{ s/^# \{0,1\}//; p; }' "$0"
      exit 0
      ;;
    --)           shift; EXTRA_ARGS=("$@"); break ;;
    *)            echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

# --- Pre-flight checks ---
if ! command -v codex &>/dev/null; then
  echo "Error: codex is not installed. Install with: npm install -g @openai/codex" >&2
  exit 1
fi

if ! command -v tmux &>/dev/null; then
  echo "Error: tmux is not installed. Install with: brew install tmux" >&2
  exit 1
fi

# --- Generate session name and output path ---
SESSION_NAME="codex-review-$(date +%s)"
REVIEW_OUTPUT=$(mktemp /tmp/codex-review.XXXXXX)
CLEANUP_PROMPT=""

# --- Write prompt file if not provided ---
if [[ -z "$PROMPT_FILE" ]]; then
  PROMPT_FILE=$(mktemp /tmp/codex-prompt.XXXXXX)
  CLEANUP_PROMPT="$PROMPT_FILE"

  if [[ -n "$CUSTOM_PROMPT" ]]; then
    printf '%s\n' "$CUSTOM_PROMPT" > "$PROMPT_FILE"
  else
    cat > "$PROMPT_FILE" << 'PROMPT'
Review for: (1) correctness — logic errors, edge cases, off-by-one, race conditions;
(2) security — injection, XSS, secrets in code, insecure patterns;
(3) performance — N+1 queries, unnecessary allocations, algorithmic complexity;
(4) error handling — missing try/catch, unhandled promises, silent failures;
(5) code quality — naming, readability, DRY, SOLID principles;
(6) testing — missing test coverage for new or changed code paths.
Provide findings with file and line references.
PROMPT
  fi
fi

# --- Write runner script ---
# Runner runs inside tmux. Quoted heredoc prevents shell injection —
# all runtime values are passed via environment variables.
RUNNER_SCRIPT=$(mktemp /tmp/codex-runner.XXXXXX)
cat > "$RUNNER_SCRIPT" << 'RUNNER'
#!/usr/bin/env bash
set -o pipefail
trap 'rm -f "$CODEX_CLEANUP_PROMPT" "$0"' EXIT
# shellcheck disable=SC2086
codex exec review $CODEX_SCOPE -m "$CODEX_MODEL" -c model_reasoning_effort="\"$CODEX_REASONING\"" --full-auto --prompt-file "$CODEX_PROMPT_FILE" $CODEX_EXTRA_ARGS 2>&1 | tee "$CODEX_REVIEW_OUTPUT"
EXIT_CODE=$?
tmux wait-for -S "$CODEX_SESSION_NAME"
exit $EXIT_CODE
RUNNER
chmod +x "$RUNNER_SCRIPT"

# --- Launch tmux session ---
# Pass env vars into the tmux session, then start the runner.
# set remain-on-exit atomically with session creation to avoid race condition.
tmux new-session -d -s "$SESSION_NAME" \
  -e CODEX_SCOPE="$SCOPE_FLAG" \
  -e CODEX_MODEL="$MODEL" \
  -e CODEX_REASONING="$REASONING" \
  -e CODEX_PROMPT_FILE="$PROMPT_FILE" \
  -e CODEX_REVIEW_OUTPUT="$REVIEW_OUTPUT" \
  -e CODEX_SESSION_NAME="$SESSION_NAME" \
  -e CODEX_CLEANUP_PROMPT="$CLEANUP_PROMPT" \
  -e CODEX_EXTRA_ARGS="${EXTRA_ARGS[*]+${EXTRA_ARGS[*]}}" \
  "$RUNNER_SCRIPT" \; \
  set-option -t "$SESSION_NAME" remain-on-exit on

# --- Report ---
echo "SESSION_NAME=$SESSION_NAME"
echo "REVIEW_OUTPUT=$REVIEW_OUTPUT"
