#!/bin/bash

# Read input from stdin if present. Else, read from file (https://superuser.com/a/747905)
[ $# -ge 1 ] && [ -f "$1" ] && INPUT="$1" || INPUT="-"
HTML_CONTENT=$(cat "$INPUT")

TIMESTAMP="$(date +'%F %T')"

# pup - Selects all "strong" elements within div tags that have the "row-app-charts" class (https://github.com/ericchiang/pup)
# sed - Removing any remaining HTML tags, leaving only the context text. (https://stackoverflow.com/a/19878198/17771525)
PARSED_HTML=$(pup 'div.row.row-app-charts div.span6 ul li strong text{}' <<<"$HTML_CONTENT")


# Clean input
# tr - Removes all non-numeric characters (https://stackoverflow.com/a/19724582/17771525)
# awk - Trims any leading or trailing whitespace and removes any blank lines (https://stackoverflow.com/a/48282526/17771525)
CLEANED_HTML+=$(sed 's/\.\.//g' <<< "$PARSED_HTML" | tr -dc ".[:digit:]\n" | awk 'NF { $1=$1; print }')$'\n'

# Get App ID
CLEANED_HTML+=$(pup 'div.header-wrapper table tbody tr:first-child td:nth-child(2) text{}' <<<"$HTML_CONTENT")$'\n'
CLEANED_HTML+="$TIMESTAMP"

# Output to STDOUT
printf "%s\n" "$CLEANED_HTML"
