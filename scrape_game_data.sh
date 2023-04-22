#!/bin/bash

# Read input from stdin if present. Else, read from file (https://superuser.com/a/747905)
[ $# -ge 1 ] && [ -f "$1" ] && INPUT="$1" || INPUT="-"
INPUT=$(cat "$INPUT")

# Check if pup is in PATH (https://stackoverflow.com/a/677212)
if ! command -v pup &>/dev/null; then
    echo "pup could not be found. Please install pup or add it to PATH."
    exit 1
fi

# pup - Get HTML element along with their relevant attribute
# awk - Delete leading and trailing whitespace, delete multiple consecutive whitespaces,
extract_data() {
    local selector=$1
    pup <<<"$INPUT" "$selector text{}" | awk 'NF { $1=$1; print }'
}

# Extract data with newline replacement
# paste - Concatenate all lines into one line (https://stackoverflow.com/a/6539865/17771525)
extract_with_newline_replacement() {
    extract_data "$1" | paste -sd ","
}

# Format date string
# sed - Remove " – " from date string
# sed - Trim last 8 characters from date string
# xargs - Pass date string to date command
# date - Parse date string. Timestamps are in UTC
format_date() {
    sed "s/ –/ /" | sed "s/.\{8\}$//" | xargs -I{} date -d "{}" +"%F %T"
}

APP_ID=$(extract_data 'div.header-wrapper table tbody tr:first-child td:last-child')
APP_NAME=$(extract_data 'h1[itemprop="name"]')
APP_TYPE=$(extract_data 'td[itemprop="applicationCategory"]')
APP_STORE_NAME=$(extract_data 'td[itemprop="alternateName"]')
APP_DEVELOPER=$(extract_with_newline_replacement 'a[itemprop="author"]')
APP_PUBLISHER=$(extract_with_newline_replacement 'a[itemprop="publisher"]')
APP_FRANCHISE=$(extract_data 'a[href*="/franchise/"]')
APP_OPERATING_SYSTEM=$(extract_with_newline_replacement 'td.os-icons:last-child')
APP_CHANGE_NUMBER=$(extract_data 'div.scope-app table > tbody > tr:nth-last-child(3) td:last-child')
APP_LAST_CHANGE_DATE=$(extract_with_newline_replacement 'div.scope-app table > tbody > tr:nth-last-child(2) > td:last-child' | format_date)
APP_RELEASE_DATE=$(extract_with_newline_replacement 'div.scope-app table > tbody > tr:last-child > td:last-child' | format_date)
APP_TAG=$(extract_with_newline_replacement 'a.btn-tag')

echo "$APP_ID"
echo "$APP_NAME"
echo "$APP_TYPE"
echo "$APP_STORE_NAME"
echo "$APP_DEVELOPER"
echo "$APP_PUBLISHER"
echo "$APP_FRANCHISE"
echo "$APP_OPERATING_SYSTEM"
echo "$APP_CHANGE_NUMBER"
echo "$APP_LAST_CHANGE_DATE"
echo "$APP_RELEASE_DATE"
echo "$APP_TAG"
