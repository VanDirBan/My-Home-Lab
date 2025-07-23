#!/bin/bash


TOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
CHAT_ID="xxxxxxxx"
TEXT="$1"

curl -s -X POST https://api.telegram.org/bot$TOKEN/sendMessage \
  -d chat_id="$CHAT_ID" \
  -d text="$TEXT" \
  -d parse_mode="Markdown"
