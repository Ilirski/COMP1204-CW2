#!/bin/bash

# Log output (https://blog.tratif.com/2023/01/09/bash-tips-1-logging-in-shell-scripts/)
LOGFILE="steamdb_scraper.log"
exec 3>&1 1>>"$LOGFILE" 2>&1
trap "echo 'ERROR: An error occurred during execution, check $LOGFILE for details.' >&3" ERR
trap '{ set +x; } 2>/dev/null; echo -n "[$(date -Is)]  "; set -x' DEBUG

echo "Starting ${0##*/}..."

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
    # fetch_steamdb_html - Curl HTML content from steamdb
    # scrape_game_stats - Scrape the HTML content for game stats
    # save_game_stats - Save the scraped stats to MySQL database
    ./fetch_steamdb_html.sh "$APP_ID" | ./scrape_game_stats.sh | ./save_game_stats.sh
done < <(tail -n +5 app_ids.txt)

echo "${0##*/} complete..."
