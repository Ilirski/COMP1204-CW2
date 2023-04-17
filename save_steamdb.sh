#!/bin/bash

# Read input from stdin if present. Else, read from file (https://superuser.com/a/747905)
[ $# -ge 1 ] && [ -f "$1" ] && INPUT="$1" || INPUT="-"
INPUT=$(cat "$INPUT")

# Join lines with commas (https://stackoverflow.com/a/6539865/17771525)
VALUES=$(paste -sd "," <<<"$INPUT")

echo "USE steam_games_db; INSERT INTO DATABASE steam_games_db VALUES (${VALUES});"

# eval /opt/lampp/bin/mysql -u root -e "USE steam_games_db; INSERT INTO DATABASE steam_games_db VALUES $VALUES;"
