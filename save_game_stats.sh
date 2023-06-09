#!/bin/bash

# Read input from stdin if present. Else, read from file (https://superuser.com/a/747905)
[ $# -ge 1 ] && [ -f "$1" ] && INPUT="$1" || INPUT="-"
INPUT=$(cat "$INPUT")

# Array indices to content
# 0. Players live
# 1. Players 24h peak
# 2. Players all time peak
# 3. Twitch viewers
# 4. Twitch viewers 24 peak
# 5. Twitch viewers all time peak
# 6. Store followers
# 7. Store top seller position
# 8. Store positive reviews
# 9. Store negative reviews
# 10 Store percentage positive reviews
# 11. Owner review lower bound estimation
# 12. Owner review upper bound estimation
# 13. Owner playtracker estimation
# 14. Owner VG Insights estimation
# 15. Owner SteamSpy estimation
# 16. App ID
# 17. Logged at timestamp
readarray -t a <<<"$INPUT"

if ! command -v mysql &>/dev/null; then
    echo "mysql could not be found. Please add mysql to PATH."
    exit 1
fi

if [ ! -d /var/lib/mysql/steam_games_db ]; then
    echo "Database steam_games_db does not exist. Please run create_steam_games_db.sh first."
    exit 1
fi

# Iterate through owner estimations
for i in {11..15}; do
    # bc - Convert to million by multiplying by 100000
    a[i]=$(echo "scale=0; ${a[i]} * 1000000 / 1" | bc)
done

# Insert into `log` table with heredoc
read -r -d '' sql_query <<-EOM
INSERT INTO log (logged_at, players_live, players_24h_peak, players_all_time_peak,
twitch_viewers, twitch_viewers_24h_peak, twitch_viewers_all_time_peak,
store_followers, store_top_seller_pos, store_pos_reviews, store_neg_reviews,
owner_review_lower, owner_review_upper, owner_playtracker, owner_vg_insights, owner_steamspy, app_id)
VALUES ('${a[17]}', ${a[0]}, ${a[1]}, ${a[2]}, ${a[3]}, ${a[4]}, ${a[5]}, ${a[6]}, ${a[7]},
${a[8]}, ${a[9]}, ${a[11]}, ${a[12]}, ${a[13]}, ${a[14]}, ${a[15]}, ${a[16]});
EOM

echo "$sql_query"
mysql -u root -e "$sql_query" steam_games_db
