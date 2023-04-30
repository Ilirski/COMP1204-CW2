#!/bin/bash

usage() {
    cat <<EOM

    $0 [OPTIONS] ...

    OPTIONS:
        -h, --help
            Show this help message and exit.
        -t, --tags
            Plot most popular tags.
        -d, --devs
            Plot games per developers.
        -o, --os
            Plot most popular OS.

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
    ORDER BY num_games DESC;
EOM
    mysql steam_games_db -u root -B <<<"$sql_query" >"$tmp_file"

    gnuplot <<-EOM
    set terminal pngcairo size 1920,1080 enhanced font 'Verdana,10'
    set output 'most_popular_tags.png'
    set title "Most popular tags"
    set xlabel "Tags"
    set ylabel "Number of games"
    set xrange [0:15]
    set style data histogram
    set style histogram cluster gap 1
    set style fill solid border -1
    set xtics rotate by -45
    set grid y
    set datafile separator "\t"
    plot "$tmp_file" using 2:xtic(1) title "Games per tag"
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

    gnuplot <<-EOM
    set terminal pngcairo size 1920,1080 enhanced font 'Verdana,10'
    set output 'games_per_developers.png'
    set title "Games per developers"
    set xlabel "Developers"
    set ylabel "Number of games"
    set xrange [0:15]
    set style data histogram
    set style histogram cluster gap 1
    set style fill solid border -1
    set xtics rotate by -45
    set grid y
    set datafile separator "\t"
    plot "$tmp_file" using 2:xtic(1) title "Games per developer"
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
    set terminal pngcairo size 1920,1080 enhanced font 'Verdana,10'
    set output 'most_popular_os.png'
    set title "Most popular OS"
    set xlabel "OS"
    set ylabel "Number of games"
    set xrange [0:15]
    set style data histogram
    set style histogram cluster gap 1
    set style fill solid border -1
    set xtics rotate by -45
    set grid y
    set datafile separator "\t"
    plot "$tmp_file" using 2:xtic(1) title "Games per OS"
EOM
}

# If no arguments are supplied, display usage (https://stackoverflow.com/a/687816/17771525)
[ -z "$1" ] && { usage; }

# Create temporary file (https://stackoverflow.com/a/66070270/17771525)
if ! tmp_file=$(mktemp); then
    # Check if mktemp failed
    printf "error: mktemp had non-zero exit code.\n" >&2
    exit 1
fi

# Set trap to remove temp file on termination, interrupt, or exit
trap 'rm -f "$tmp_file"' SIGTERM SIGINT EXIT

if [ ! -f "$tmp_file" ]; then
    # Verify that tempfile exists
    printf "error: tempfile does not exist.\n" >&2
    exit 1
fi

TEMP=$(getopt -o htdo --long help,tags,devs,os -n "$0" -- "$@")

eval set -- "$TEMP"

# extract options (https://stackoverflow.com/a/28466267/17771525)
while true; do
    case "$1" in
    -h | --help)
        usage
        exit 1
        ;;
    -t | --tags)
        plot_most_popular_tags
        exit 0
        ;;
    -d | --devs)
        plot_games_per_developers
        exit 0
        ;;
    -o | --os)
        plot_most_popular_os
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
