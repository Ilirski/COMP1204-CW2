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
            # Ignore duplicate keys (https://stackoverflow.com/a/3025332)
            local query_sql
            read -r -d '' query_sql <<-EOM
            INSERT INTO $table_name ($column_name)
            SELECT '$value'
            WHERE NOT EXISTS (SELECT * FROM $table_name WHERE $column_name='$value') LIMIT 1;
            SELECT ${table_name}_id INTO @${table_name}_id FROM $table_name WHERE $column_name='$value';
EOM
            echo "$query_sql"

            # Insert into `app_${table_name}` table
            local app_table_sql="INSERT INTO app_${table_name} (app_id, ${table_name}_id) VALUES (${a[0]}, @${table_name}_id);"
            echo "$app_table_sql"
            query_sql+=" $app_table_sql"
            mysql -u root -e "$query_sql" steam_games_db
        done <<<"$values"
    fi
}

insert_app_sql() {
    # Declare app_sql as a local variable
    local app_sql
    # Insert into `app` table
    # NULLIF() - Convert empty string to NULL (https://stackoverflow.com/a/75712852/17771525)
    read -r -d '' app_sql <<-EOM
    INSERT INTO app (app_id, app_name, app_type, app_store_name, app_change_number, app_last_change_date, app_release_date)
    VALUES (${a[0]}, '${a[1]}', '${a[2]}', NULLIF('${a[3]}', ''), '${a[8]}', '${a[9]}', NULLIF('${a[10]}', ''));
EOM
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

if ! command -v mysql &>/dev/null; then
    echo "mysql could not be found. Please add mysql to PATH."
    exit 1
fi

if [ ! -d /var/lib/mysql/steam_games_db ]; then
    echo "Database steam_games_db does not exist. Please run create_steam_games_db.sh first, or if you have,"
    echo "check if the path exists."
    exit 1
fi

insert_app_sql
insert_values_with_join_table "developer" "developer_name" "${a[4]}"
insert_values_with_join_table "publisher" "publisher_name" "${a[5]}"
insert_values_with_join_table "franchise" "franchise_name" "${a[6]}"
insert_values_with_join_table "os" "os_name" "${a[7]}"
insert_values_with_join_table "tag" "tag_name" "${a[11]}"
