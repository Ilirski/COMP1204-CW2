#!/bin/bash

usage() {
    cat <<EOM

    $0 [OPTIONS] ...

    OPTIONS:
        -h, --help
            Show this help message and exit.
        -a. --app APP_IDs
            Plot live stats for the given APP_IDs (comma-separated). Default value is 'all'.
            IMPORTANT: --app or app must be passed as the first argument.
            e.g: $0 --app 730,440
                 $0 -a 730
                 $0 --app all
        -t, --tags
            Plot most popular tags.
        -d, --devs
            Plot games per developers.
        -o, --os
            Plot most popular OS.
        -w, --reviews
            Plot reviews for a given APP_ID.
            e.g: $0 --app 730 --reviews
        -r, --released
            Plot games released per year.
        -p, --players
            Plot total players over time.
            Either pass APP_IDs in --app or if APP_IDs not passed, by default plots all APP_IDs.
            e.g: $0 --app 730,440 --players
        -v, --viewers
            Plot total viewers over time.
            Either pass APP_IDs in --app or if APP_ID not passed, by default plots all APP_IDs.
        -f, --followers
            Plot total followers over time.
            Either pass APP_IDs in --app or if APP_ID not passed, by default plots all APP_IDs.
        -s, --source {playtracker, vg_insights, steamspy}
            Plot total owners over time according to source.
            Either pass APP_IDs in --app or if APP_ID not passed, by default plots all APP_IDs.
EOM
}

plot_most_popular_tags() {
    # https://www.percona.com/blog/tpcc-mysql-simple-usage-steps-and-how-to-build-graphs-with-gnuplot/
    # (https://stackoverflow.com/a/1497377/17771525)

    # Read multiline string into variable (https://stackoverflow.com/a/23930212/17771525)
    read -r -d '' sql_query <<-EOM
    SELECT tag.tag_name, COUNT(DISTINCT app_tag.app_id) as num_games
    FROM tag
    JOIN app_tag ON tag.tag_id = app_tag.tag_id
    GROUP BY tag.tag_id
    ORDER BY num_games DESC
    LIMIT 15;
EOM
    mysql steam_games_db -u root -B <<<"$sql_query" >"$tmp_file"

    gnuplot <<-EOM
    set terminal pngcairo size 1920,1080 font 'Arial,12' enhanced 
    set output 'most_popular_tags.png'
    set xlabel "Tag"
    set ylabel "Number of Games"
    set title "Most popular tags"
    set auto fix
    set offsets graph 0, 0, 1, 1
    set style data boxes
    set style fill solid border -1
    set boxwidth 0.75
    set ytics 1
    set xtics rotate by -45
    set datafile separator "\t"
    plot "$tmp_file" using 2:xtic(1) skip 1 lc rgb '#3366cc' title ""
EOM
}

plot_games_per_developers() {
    read -r -d '' sql_query <<-EOM
    SELECT developer.developer_name, COUNT(DISTINCT app_developer.app_id) as num_games
    FROM developer
    JOIN app_developer ON developer.developer_id = app_developer.developer_id
    GROUP BY developer.developer_id
    ORDER BY num_games DESC;
EOM

    mysql steam_games_db -u root -B <<<"$sql_query" >"$tmp_file"

    # offset (http://www.manpagez.com/info/gnuplot/gnuplot-4.4.0/gnuplot_272.php)
    gnuplot <<-EOM
    set terminal pngcairo size 1920,1080 font 'Arial,12' enhanced 
    set output 'games_per_developers.png'
    set xlabel "Developer"
    set ylabel "Number of Games"
    set title "Number of Games by Developer"
    set auto fix
    set offsets graph 0, 0, 1, 1
    set style data boxes
    set style fill solid border -1
    set boxwidth 0.75
    set ytics 1
    set xtics rotate by -45
    set rmargin 4
    set datafile separator "\t"
    plot "$tmp_file" using 2:xtic(1) skip 1 lc rgb '#3366cc' title ""
EOM
}

plot_most_popular_os() {
    read -r -d '' sql_query <<-EOM
    SELECT os.os_name, COUNT(DISTINCT app_os.app_id) as num_games
    FROM os
    JOIN app_os ON os.os_id = app_os.os_id
    GROUP BY os.os_id
    ORDER BY num_games DESC;
EOM

    mysql steam_games_db -u root -B <<<"$sql_query" >"$tmp_file"

    gnuplot <<-EOM
    set terminal pngcairo size 1920,1080 font 'Arial,12' enhanced 
    set output 'most_popular_os.png'
    set xlabel "OS"
    set ylabel "Number of Games"
    set title "Most popular OS"
    set auto fix
    set offsets graph 0, 0, 1, 1
    set style data boxes
    set style fill solid border -1
    set boxwidth 0.75
    set ytics 1
    set xtics rotate by -45
    set datafile separator "\t"
    plot "$tmp_file" using 2:xtic(1) skip 1 lc rgb '#3366cc' title ""
EOM
}

plot_game_reviews() {
    local app_id="$1"
    echo "Plotting reviews for app_id: $app_id"

    if ! [[ "$app_id" =~ ^[0-9]+$ ]]; then
        echo "Error: There must only be a single app_id."
        exit 1
    fi

    read -r -d '' sql_query <<-EOM
    SELECT app.app_name, DATE_FORMAT(log.logged_at, '%Y-%m-%d') AS day_and_hour, MAX(log.store_pos_reviews) AS store_pos_reviews, MAX(log.store_neg_reviews) AS store_neg_reviews
    FROM log
    JOIN app ON log.app_id = app.app_id AND app.app_id = $app_id
    GROUP BY app.app_name, day_and_hour
    ORDER BY day_and_hour DESC;
EOM

    mysql steam_games_db -u root -B <<<"$sql_query" >"$tmp_file"

    cat "$tmp_file"

    gnuplot <<-EOM
    set terminal pngcairo size 1920,1080 font 'Arial,14' enhanced 
    set output 'store_reviews_histogram.png'
    set xlabel "Store Reviews" font "Arial,16"
    set ylabel "Frequency" font "Arial,16"
    set title "Store Reviews Histogram" font "Arial,20"
    set style data histograms
    set style histogram clustered
    set style fill solid border -1
    set boxwidth 0.9 relative
    set ytics nomirror
    set grid ytics
    set datafile separator "\t"
    plot '$tmp_file' using 3:xtic(2) title columnheader(3), '' using 4 title columnheader(4)
EOM
}

plot_games_released_over_time() {
    read -r -d '' sql_query <<-EOM
    SELECT YEAR(app_release_date) AS ReleaseYear, COUNT(app_id) AS AppCount
    FROM app
    GROUP BY ReleaseYear
    ORDER BY ReleaseYear;
EOM

    mysql steam_games_db -u root -B <<<"$sql_query" >"$tmp_file"

    gnuplot <<-EOM
    set terminal pngcairo size 1920,1080 font 'Arial,12' enhanced 
    set output 'games_released_per_year.png'
    set xlabel "Year"
    set ylabel "Number of Games"
    set title "Games released per year"
    set auto fix
    set offsets graph 0, 0, 1, 1
    set style data boxes
    set style fill solid border -1
    set boxwidth 0.75
    set xtics 1
    set ytics 1
    set datafile separator "\t"
    plot "$tmp_file" using 1:2 lc rgb '#3366cc' lw 5 title ""
EOM
}

# Helper function to generate SQL query for live stats per game.
generate_sql_query() {
    local app_id="$1"
    local stat="$2"
    if [[ "$app_id" = "all" ]]; then
        app_id="" # Empty string means no filter.
    else
        app_id="AND app.app_id IN ($app_id)" # Filter by app_id.
    fi

    read -r -d '' sql_query <<-EOM
    SELECT app.app_name, DATE_FORMAT(log.logged_at, '%Y-%m-%dT%H:00:00') AS day_and_hour, log.$stat
    FROM log
    JOIN app ON log.app_id = app.app_id $app_id
    JOIN (
      SELECT app_id, SUM($stat) AS total_$stat
      FROM log
      GROUP BY app_id
    ) AS app_$stat ON app_$stat.app_id = app.app_id
    ORDER BY app_$stat.total_$stat DESC, app.app_name, day_and_hour;
EOM
    echo "$sql_query"
}

# Helper function to plot live stats per game.
plot_live_stats_per_game() {
    local app_id="$1"
    local stat="$2"
    local title="$3"
    local y_axis_label="$4"
    local output_file_name="$5"
    local smooth="$6"
    
    if [[ -z "$smooth" ]]; then
        smooth=""
    else
        smooth="smooth $smooth"
    fi

    local sql_query
    sql_query=$(generate_sql_query "$app_id" "$stat" "app_name")
    mysql steam_games_db -u root -B <<<"$sql_query" >"$tmp_file"
    
    # Reshape data from wide to long format.
    mlr --tsv -I reshape -s app_name,"$stat" "$tmp_file"
    
    local column_count;
    column_count=$(head -n 1 "$tmp_file" | awk -F '\t' '{print NF; exit}') # (https://stackoverflow.com/a/25366099/17771525)

    #(https://stackoverflow.com/a/14947085/17771525)
    gnuplot <<-EOM
    set terminal pngcairo size 1920,1080 font 'Arial,14' enhanced 
    set output '$output_file_name'
    set xlabel "Time" font "Arial,16"
    set ylabel "$y_axis_label" font "Arial,16"
    set title "$title" font "Arial,20"
    set xdata time
    set timefmt "%Y-%m-%dT%H:00:00"
    set format x "%Y-%m-%d"
    set auto fix
    set xtics rotate by -45 font "Arial,12"
    set grid xtics ytics
    set key autotitle columnheader
    set key outside center bottom horizontal font "Arial,14"
    set rmargin 10
    set datafile separator "\t"
    plot for [col=2:$column_count] '$tmp_file' using 1:col with lines lw 2 $smooth
EOM
}

plot_live_players_per_game() {
    plot_live_stats_per_game "$1" "players_live" "Live Players per Game" "Players" "live_players_over_time.png"
}

plot_live_twitch_viewers_per_game() {
    plot_live_stats_per_game "$1" "twitch_viewers" "Live Twitch Viewers per Game" "Viewers" "live_twitch_viewers_over_time.png"
}

plot_live_followers_per_game() {
    plot_live_stats_per_game "$1" "store_followers" "Store Followers over time" "Store followers" "store_followers_over_time.png" "bezier"
}

plot_owners_per_game_from_source() {
    if ! [[ "$2" =~ ^(playtracker|vg_insights|steamspy)$ ]]; then
        echo "ERROR: $2 is not a valid source. Valid sources are: playtracker, vg_insights, steamspy"
        exit 1
    fi

    # append word with owner
    plot_live_stats_per_game "$1" "owner_$2" "Game owner over time (according to $2)" "Owners" "$2_owners_over_time.png" "bezier"
}


# If no arguments are supplied, display usage (https://stackoverflow.com/a/687816/17771525)
[ -z "$1" ] && { usage; }

# Create temporary file (https://stackoverflow.com/a/66070270/17771525)
if ! tmp_file=$(mktemp); then
    # Check if mktemp failed
    printf "Error: mktemp had non-zero exit code.\n" >&2
    exit 1
fi

# Set trap to remove temp file on termination, interrupt, or exit
trap 'rm -f "$tmp_file"' SIGTERM SIGINT EXIT

if [ ! -f "$tmp_file" ]; then
    # Verify that tempfile exists
    printf "Error: tempfile does not exist.\n" >&2
    exit 1
fi

if ! command -v mlr &>/dev/null; then
    echo "miller could not be found. Please install miller with \`sudo apt install miller\`."
    exit 1
fi

TEMP=$(getopt -o ha:tdowrpvfs --long help,app:,tags,devs,os,reviews,released,players,viewers,followers,source -n "$0" -- "$@")

eval set -- "$TEMP"

# extract options (https://stackoverflow.com/a/28466267/17771525)

app_id="all"
source=
while true; do
    case "$1" in
    -h | --help)
        usage
        exit 1
        ;;
    -a | --app)
        app_id="$2"
        shift 2
        ;;
    -t | --tags)
        plot_most_popular_tags
        shift
        ;;
    -d | --devs)
        plot_games_per_developers
        shift
        ;;
    -o | --os)
        plot_most_popular_os
        shift
        ;;
    -w | --reviews)
        plot_game_reviews "$app_id"
        shift
        ;;
    -r | --released)
        plot_games_released_over_time
        shift
        ;;
    -p | --players)
        plot_live_players_per_game "$app_id"
        shift
        ;;
    -v | --viewers)
        plot_live_twitch_viewers_per_game "$app_id"
        shift
        ;;
    -f | --followers)
        plot_live_followers_per_game "$app_id"
        shift
        ;;
    -s | --source)
        source="$3"
        plot_owners_per_game_from_source "$app_id" "$source"
        exit 0
        ;;
    --)
        exit 1
        ;;
    *)
        exit 1
        ;;
    esac
done
