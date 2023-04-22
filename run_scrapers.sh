#!/bin/bash

# Log output (https://blog.tratif.com/2023/01/09/bash-tips-1-logging-in-shell-scripts/)
LOGFILE="steamdb_scraper.log"
exec 3>&1 1>"$LOGFILE" 2>&1
trap "echo 'ERROR: An error occurred during execution, check \""$LOGFILE\"" for details.' >&3" ERR
trap '{ set +x; } 2>/dev/null; echo -n "[$(date -Is)]  "; set -x' DEBUG

draw_progress_bar() {
    # Don't log this function
    set +x
    local PROGRESS_BAR_WIDTH=50
    # Arguments: current value, max value, unit of measurement (optional)
    local __value=$1
    local __max=$2
    local __unit=${3:-""}  # if unit is not supplied, do not display it

    # Calculate percentage
    if (( __max < 1 )); then __max=1; fi  # anti zero division protection
    local __percentage=$(( 100 - (__max*100 - __value*100) / __max ))

    # Rescale the bar according to the progress bar width
    local __num_bar=$(( __percentage * PROGRESS_BAR_WIDTH / 100 ))

    # Draw progress bar
    printf "[" >&3
    for _ in $(seq 1 $__num_bar); do printf "#" >&3; done
    for _ in $(seq 1 $(( PROGRESS_BAR_WIDTH - __num_bar ))); do printf " " >&3; done
    printf "] $__percentage%% ($__value / $__max $__unit)\r" >&3
    set -x
}

echo "Starting ${0##*/}..." 
echo "Testing redirection"

# Fail if any command fails (https://stackoverflow.com/a/32684221/17771525)
set -e
set -o pipefail

# Check if app_ids.txt exists
if [ ! -f app_ids.txt ]; then
    echo "app_ids.txt not found, please run add_app_id.sh" >&3
    exit 1
fi

# Get number of app ids
app_ids=$(tail -n+5 app_ids.txt)
app_ids_length=$(wc -l <<< "$app_ids")
count=1

# tail - Skip the first 4 lines of app_ids.txt
while IFS= read -r APP_ID; do
    draw_progress_bar $count "$app_ids_length" "apps"
    # fetch_steamdb_html - Curl HTML content from steamdb
    # scrape_game_stats - Scrape the HTML content for game stats
    # save_game_stats - Save the scraped stats to MySQL database
    ./fetch_steamdb_html.sh "$APP_ID" | ./scrape_game_stats.sh | ./save_game_stats.sh
    
    count=$((count + 1))
done < <(tail -n +5 app_ids.txt)

echo "${0##*/} complete..."
