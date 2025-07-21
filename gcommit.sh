#!/bin/bash

AUTO_MODE=false
INPUT_FILE=".commit-msg.txt"
DIFF_MODE="HEAD"

print_help() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS] [FILE]
Generates a commit message based on all changes (both staged and unstaged) since the last commit.

Options:
  -a, --auto       Run in automatic mode (no user prompts)
  -s, --staged     Process staged changes only
  -h, --help       Show this help message and exit

Arguments:
  FILE             Text file where the commit message will be stored (defaults to './.commit-msg.txt')

Defaults:
If "-s|--staged" is not used, all changes (staged and unstaged) will be processed.
If FILE exists and is not empty, its contents will be overwritten with the generated commit message.
EOF
}

generate_commit_message() {
  if [ -z "$OPENAI_API_KEY" ]; then
    echo "Error: OPENAI_API_KEY is not set."
    exit 1
  fi

  DIFF=$(git diff $DIFF_MODE | grep -E "^(\+|\-).+" | sed 's/\"/\\"/g')
  if [ -z "$DIFF" ]; then
    echo "\"git diff $DIFF_MODE\" returned no changes. Exiting."
    echo
    exit 0
  fi

  PROMPT="Summarize the following git diff as a Conventional Commit message:
  - Use a one-line summary (≤72 characters)
  - Then add up to 5 bullet points (≤72 characters each)
  - Each bullet should explain why a change was made
  - Group related changes where appropriate
  - Do not include preamble, backticks, or code snippets
  =============
  GIT DIFF:
  $DIFF"

  if [ "$AUTO_MODE" = false ]; then
    P_TOKENS=$($GCOMMIT_DIR/gcommit_tokenize.py --text "$PROMPT")
    if [ $? -ne 0 ]; then
      echo "Error: Failed to tokenize prompt."
      echo
      exit 1
    fi
    read -p "Prompt will consume $P_TOKENS tokens. Continue? [y/n] " confirm

    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      echo "Aborting operation."
      echo
      exit 0
    fi
  fi

  PROMPT=$(jq -Rn --arg str "$PROMPT" '$str')

  RESPONSE=$(curl -s https://api.openai.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d @- <<EOM
{
  "model": "gpt-4.1",
  "messages": [
    {
      "role": "user",
      "content": $PROMPT
    }
  ]
}
EOM
)

  echo "$RESPONSE" | jq -r '.choices[0].message.content' > "$INPUT_FILE"
  echo "Commit message generated and saved to $INPUT_FILE"
  echo
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -a|--auto)
      AUTO_MODE=true
      shift
      ;;
    -s|--staged)
      DIFF_MODE="--staged"
      shift
      ;;
    -h|--help)
      print_help
      exit 0
      ;;
    -*)
      echo "Unknown option: $1"
      echo "Run '$(basename "$0") --help' for usage information."
      exit 1
      ;;
    *)
      # Assume positional argument is file path
      INPUT_FILE="$1"
      shift
      ;;
  esac
done

generate_commit_message