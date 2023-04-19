#!/bin/bash

# Read input from stdin if present. Else, read from file (https://superuser.com/a/747905)
[ $# -ge 1 ] && [ -f "$1" ] && INPUT="$1" || INPUT="-"
INPUT=$(cat "$INPUT")

# get game name
GAME_NAME=$(pup 'h1[itemprop="name"] text{}' <<<"$INPUT" | awk 'NF { $1=$1; print }')
echo "$GAME_NAME"

# get game info
# sed - Remove lines 4, 12, 13, 15, 16
# awk - Delete " – " and " UTC", and then convert datetime to ISO 8601 format
GAME_INFO=$(
    pup <<<"$INPUT" 'div.header-wrapper table tbody tr td:nth-child(2) text{}' |
        awk 'NF { $1=$1; print }' 
        # sed '4d;12d;13d;15d;16d' |
        # awk 'NR == 10 || NR == 11 { 
        #         gsub(/ – /, " ");
        #         gsub(/ UTC/, "");
        #         cmd="date -d \""$0"\" +\"%Y-%m-%d %H:%M:%S\""; 
        #         cmd | getline timestamp; 
        #         $0=timestamp; 
        #         close(cmd); 
        #     } 
        # { print }'
)
echo "$GAME_INFO"
# cat -n <<< "$GAME_INFO"

# get tags of game
GAME_TAGS=$(pup 'a.btn-tag text{}' <<<"$INPUT")
echo "$GAME_TAGS"