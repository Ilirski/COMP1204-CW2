#!/bin/bash

usage() {
    cat <<HELP_USAGE

    $0 [OPTIONS] ...

    OPTIONS:
        -h, --help
            Show this help message and exit.
        -t, --tags
            Plot most popular tags.

HELP_USAGE
    exit 1
}

die() {
    # complain to STDERR and exit with error
    echo "$*" >&2
    exit 2
}

plot_most_popular_tags() {
    # https://www.percona.com/blog/tpcc-mysql-simple-usage-steps-and-how-to-build-graphs-with-gnuplot/
    # (https://stackoverflow.com/a/1497377/17771525)
    
    # Read multiline string into variable (https://stackoverflow.com/a/23930212/17771525)
    read -r -d '' sql_query <<- EOM
    SELECT tag.tag_name, COUNT(DISTINCT app_tag.app_id) as num_games
    FROM tag
    JOIN app_tag ON tag.tag_id = app_tag.tag_id
    GROUP BY tag.tag_id
    ORDER BY num_games DESC;
EOM
    mysql steam_games_db -u root -B <<<"$sql_query" >"$tmp_file"
    # set datafile = "$tags_data"
    gnuplot <<EOF
    set terminal pngcairo size 1920,1080 enhanced font 'Verdana,10'
    set output 'most_popular_tags.png'
    set title "Most popular tags"
    set xlabel "Tags"
    set ylabel "Number of games"
    set yrange [0:10]
    set style data histogram
    set style histogram cluster gap 1
    set style fill solid border -1
    set boxwidth 0.9
    set xtics rotate by -45
    set datafile separator "\t"
    plot "$tmp_file" using 2:xtic(1) title "Number of games"
EOF
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

# Getopts (https://stackoverflow.com/a/28466267/17771525)
while getopts "ht:-:" OPT; do
    if [ "$OPT" = "-" ]; then     # long option: reformulate OPT and OPTARG
        OPT="${OPTARG%%=*}"       # extract long option name
        OPTARG="${OPTARG#"$OPT"}" # extract long option argument (may be empty)
        OPTARG="${OPTARG#=}"      # if long option argument, remove assigning `=`
    fi
    case $OPT in
    h | help) # display usage
        usage
        ;;
    t | tags) # plot most popular tags
        plot_most_popular_tags
        ;;
    ??*)
        die "illegal option --$OPT"
        ;; # bad long option
    ?)
        exit 2
        ;; # bad short option (error reported via getopts)
    esac
done
shift $((OPTIND - 1)) # remove parsed options and args from $@ list
