#!/bin/bash

INPUT="$1"

# get game name
GAME_NAME=$(pup 'h1[itemprop="name"] text{}' <"$INPUT" | awk 'NF { $1=$1; print }')
echo "$GAME_NAME"

# get game info
# sed - Remove lines 4, 12, 13, 15, 16
# awk - Delete " – " and " UTC", and then convert datetime to ISO 8601 format
GAME_INFO=$(
    pup <"$INPUT" 'div.header-wrapper table tbody tr td:nth-child(2) text{}' |
        awk 'NF { $1=$1; print }' |
        sed '5d;13d;14d;16d;17d' |
        awk 'NR == 10 || NR == 11 { 
                gsub(/ – /, " ");
                gsub(/ UTC/, "");
                cmd="date -d \""$0"\" +\"%Y-%m-%d %H:%M:%S\""; 
                cmd | getline timestamp; 
                $0=timestamp; 
                close(cmd); 
            } 
        { print }'
)
echo "$GAME_INFO"

# get tags of game
GAME_TAGS=$(pup 'a.btn-tag text{}' <"$INPUT")
echo "$GAME_TAGS"