#!/bin/bash

if [ -z "$OPENAI_API_KEY" ]; then
  echo "Error: OPENAI_API_KEY is not set."
  exit 1
fi

DIFF=$(git diff HEAD | grep -E "^(\+|\-).+" | sed 's/\"/\\"/g')

PROMPT="Summarize the following git diff as a Conventional Commit message:
- Use a one-line summary (≤72 characters)
- Then add up to 5 bullet points (≤72 characters each)
- Each bullet should explain why a change was made
- Group related changes where appropriate
- Do not include preamble, backticks, or code snippets
=============
GIT DIFF:
$DIFF"

PROMPT=$(jq -Rn --arg str "$PROMPT" '$str')
RESPONSE=$(curl -s https://api.openai.com/v1/chat/completions \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $OPENAI_API_KEY" \
-d @- <<EOM
{
  "model": "gpt-4o",
  "messages": [
    {
      "role": "user",
      "content": $PROMPT
    }
  ]
}
EOM
)

echo "$RESPONSE" | jq -r '.choices[0].message.content'

exit 0