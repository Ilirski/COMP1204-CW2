#!/bin/bash
# app_ids.txt contains all app_ids to be scraped
INPUT="$1"

# Check if app_ids.txt exists
if [ ! -f app_ids.txt ]; then
    HEADER="# DO NOT EDIT THIS FILE\n# This file is automatically generated by add_app_id.sh\n# Run add_app_id.sh for more info\n"
    echo -e "$HEADER" >>app_ids.txt
fi

# Check if input is an integer (https://stackoverflow.com/a/806923/17771525)
RE='^[0-9]+$'
if [[ "$INPUT" =~ $RE ]]; then
    # Check if app_ids.txt contain same app_id
    if grep -q "$INPUT" app_ids.txt; then
        echo "app_id already exists"
        exit 1
    fi

    # Append app_id to app_ids.txt
    echo "$INPUT" >>app_ids.txt
else
    echo "$INPUT is not an integer"
fi
