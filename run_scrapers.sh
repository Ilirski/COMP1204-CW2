#!/bin/bash

# Fail if any command fails (https://stackoverflow.com/a/32684221/17771525)
set -e
set -o pipefail

# Check if app_ids.txt exists
if [ ! -f app_ids.txt ]; then
    echo "app_ids.txt not found, please run add_app_id.sh"
    exit 1
fi

# tail - Skip the first 4 lines of app_ids.txt
while IFS= read -r APP_ID; do
    # 1. Fetch HTML content from steamdb
    # 2. Scrape the HTML content
    # 3. Save the scraped data to MySQL database
    ./fetch_html.sh "$APP_ID" | ./scrape_steamdb.sh | ./save_steamdb.sh
done < <(tail -n +5 app_ids.txt)
