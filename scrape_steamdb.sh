#!/bin/bash

# Read input from stdin if present. Else, read from file (https://superuser.com/a/747905)
[ $# -ge 1 ] && [ -f "$1" ] && INPUT="$1" || INPUT="-"
HTML_CONTENT=$(cat "$INPUT")

TIMESTAMP="$(date +'%F %T')"

# pup - Selects all "strong" elements within div tags that have the "row-app-charts" class (https://github.com/ericchiang/pup)
# sed - Removing any remaining HTML tags, leaving only the context text. (https://stackoverflow.com/a/19878198/17771525)
PARSED_HTML=$(pup 'div.row.row-app-charts div.span6 ul li strong text{}' <<<"$HTML_CONTENT")

# Get App ID
CLEANED_HTML=$(pup 'div.header-wrapper table tbody tr:first-child td:nth-child(2) text{}' <<<"$HTML_CONTENT")$'\n'

# Get current timestamp when this script is run
CLEANED_HTML+="$TIMESTAMP"

# Clean input
# tr - Removes all non-numeric characters (https://stackoverflow.com/a/19724582/17771525)
# awk - Trims any leading or trailing whitespace and removes any blank lines (https://stackoverflow.com/a/48282526/17771525)
CLEANED_HTML+=$(tr -dc "0-9\n" <<<"$PARSED_HTML" | awk 'NF { $1=$1; print }')

# Output to STDOUT
printf "%s\n" "$CLEANED_HTML"
