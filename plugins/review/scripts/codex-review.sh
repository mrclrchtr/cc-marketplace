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
#   --prompt-file FILE    Custom prompt file (only used with --uncommitted scope)
#   --prompt TEXT          Inline prompt text (only used with --uncommitted scope)
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

# --- Capture working directory (git root preferred) ---
WORK_DIR=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# --- Generate session name and output path ---
SESSION_NAME="codex-review-$(date +%s)-$$"
REVIEW_OUTPUT=$(mktemp /tmp/codex-review.XXXXXX)
CLEANUP_PROMPT=""

# --- Validate / write prompt file ---
# codex exec review has its own built-in review prompt; we only override
# when the user passes --prompt or --prompt-file (and only for --uncommitted).
if [[ -n "$PROMPT_FILE" ]]; then
  if [[ ! -r "$PROMPT_FILE" || ! -s "$PROMPT_FILE" ]]; then
    echo "Error: prompt file not found, unreadable, or empty: $PROMPT_FILE" >&2
    exit 1
  fi
elif [[ -n "$CUSTOM_PROMPT" ]]; then
  PROMPT_FILE=$(mktemp /tmp/codex-prompt.XXXXXX)
  CLEANUP_PROMPT="$PROMPT_FILE"
  printf '%s\n' "$CUSTOM_PROMPT" > "$PROMPT_FILE"
fi

# --- Write extra args file (NUL-delimited to preserve argv boundaries) ---
EXTRA_ARGS_FILE=""
if [[ ${#EXTRA_ARGS[@]} -gt 0 ]]; then
  EXTRA_ARGS_FILE=$(mktemp /tmp/codex-extra-args.XXXXXX)
  printf '%s\0' "${EXTRA_ARGS[@]}" > "$EXTRA_ARGS_FILE"
fi

# --- Write runner script (quoted heredoc prevents shell injection) ---
RUNNER_SCRIPT=$(mktemp /tmp/codex-runner.XXXXXX)
cat > "$RUNNER_SCRIPT" << 'RUNNER'
#!/usr/bin/env bash
set -o pipefail
trap 'rm -f "$CODEX_CLEANUP_PROMPT" "$CODEX_EXTRA_ARGS_FILE" "$0"' EXIT

# Reconstruct extra args array from NUL-delimited file
EXTRA=()
if [[ -n "$CODEX_EXTRA_ARGS_FILE" && -s "$CODEX_EXTRA_ARGS_FILE" ]]; then
  while IFS= read -r -d '' arg; do
    EXTRA+=("$arg")
  done < "$CODEX_EXTRA_ARGS_FILE"
fi

# Build the codex command. Custom prompt (via stdin) is only supported with
# --uncommitted; --base and --commit reject a positional prompt argument.
# shellcheck disable=SC2086
if [[ "$CODEX_SCOPE" == "--uncommitted" && -n "$CODEX_PROMPT_FILE" && -s "$CODEX_PROMPT_FILE" ]]; then
  codex exec review $CODEX_SCOPE -m "$CODEX_MODEL" -c model_reasoning_effort="\"$CODEX_REASONING\"" --full-auto "${EXTRA[@]}" - < "$CODEX_PROMPT_FILE" 2>&1 | tee "$CODEX_REVIEW_OUTPUT"
else
  codex exec review $CODEX_SCOPE -m "$CODEX_MODEL" -c model_reasoning_effort="\"$CODEX_REASONING\"" --full-auto "${EXTRA[@]}" 2>&1 | tee "$CODEX_REVIEW_OUTPUT"
fi
EXIT_CODE=$?
tmux wait-for -S "$CODEX_SESSION_NAME"
exit $EXIT_CODE
RUNNER
chmod +x "$RUNNER_SCRIPT"

# --- Launch tmux session ---
# Pass env vars into the tmux session, then start the runner.
# set remain-on-exit atomically with session creation to avoid race condition.
tmux new-session -d -s "$SESSION_NAME" -c "$WORK_DIR" \
  -e CODEX_SCOPE="$SCOPE_FLAG" \
  -e CODEX_MODEL="$MODEL" \
  -e CODEX_REASONING="$REASONING" \
  -e CODEX_PROMPT_FILE="$PROMPT_FILE" \
  -e CODEX_REVIEW_OUTPUT="$REVIEW_OUTPUT" \
  -e CODEX_SESSION_NAME="$SESSION_NAME" \
  -e CODEX_CLEANUP_PROMPT="$CLEANUP_PROMPT" \
  -e CODEX_EXTRA_ARGS_FILE="$EXTRA_ARGS_FILE" \
  "$RUNNER_SCRIPT" \; \
  set-option -t "$SESSION_NAME" remain-on-exit on

# --- Report ---
echo "SESSION_NAME=$SESSION_NAME"
echo "REVIEW_OUTPUT=$REVIEW_OUTPUT"
