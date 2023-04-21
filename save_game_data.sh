#!/bin/bash

insert_values_with_join_table() {
    # Insert value into join table of many-to-many relationship (https://stackoverflow.com/a/19734088/17771525)
    local table_name="$1"
    local column_name="$2"
    local values="$3"

    # Skip if values is empty
    if [ -n "$values" ]; then
        # Split the data into individual values separated by comma
        values=$(echo "${3}" | tr ',' '\n')

        # Iterate over values
        while read -r value; do
            # Ignore duplicate keys (https://stackoverflow.com/a/1361368/17771525)
            local query_sql="INSERT INTO $table_name ($column_name) VALUES ('$value')"
            query_sql+=" ON DUPLICATE KEY UPDATE ${table_name}_id=${table_name}_id;"
            query_sql+=" SET @${table_name}_id = LAST_INSERT_ID();"
            echo "$query_sql"
            # mysql -u root -e "$query_sql" steam_games_db

            # Insert into `app_${table_name}` table
            local app_table_sql="INSERT INTO app_${table_name} (app_id, ${table_name}_id) VALUES (${a[0]}, @${table_name}_id);"
            echo "$app_table_sql"
            query_sql+=" $app_table_sql"
            mysql -u root -e "$query_sql" steam_games_db
        done <<<"$values"
    fi
}

insert_app_sql() {
    # Insert into `app` table
    # NULLIF() - Convert empty string to NULL (https://stackoverflow.com/a/75712852/17771525)
    app_sql+=" INSERT INTO app (app_id, app_name, app_type, app_store_name, app_change_number, app_last_change_date, app_release_date)"
    app_sql+=" VALUES (${a[0]}, '${a[1]}', '${a[2]}', NULLIF('${a[3]}', ''), '${a[8]}', '${a[9]}', NULLIF('${a[10]}', ''));"
    # app_sql+=" SET @app_id = LAST_INSERT_ID();"
    echo "$app_sql"
    mysql -u root -e "$app_sql" steam_games_db
}

# Read input from stdin if present. Else, read from file (https://superuser.com/a/747905)
[ $# -ge 1 ] && [ -f "$1" ] && INPUT="$1" || INPUT="-"
INPUT=$(cat "$INPUT")

# Array indices to content
# 0. App ID
# 1. App Name
# 2. App Type
# 3. App Store Name
# 4. App Developer
# 5. App Publisher
# 6. App Franchise
# 7. App Operating System
# 8. App Change Number
# 9. App Last Change Date
# 10. App Release Date
# 11. App Tag
readarray -t a <<<"$INPUT"


insert_app_sql
insert_values_with_join_table "developer" "developer_name" "${a[4]}"
insert_values_with_join_table "publisher" "publisher_name" "${a[5]}"
insert_values_with_join_table "franchise" "franchise_name" "${a[6]}"
insert_values_with_join_table "os" "os_name" "${a[7]}"
insert_values_with_join_table "tag" "tag_name" "${a[11]}"
