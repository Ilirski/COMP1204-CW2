#!/bin/bash

# Read input from stdin if present. Else, read from file (https://superuser.com/a/747905)
[ $# -ge 1 ] && [ -f "$1" ] && INPUT="$1" || INPUT="-"
INPUT=$(cat "$INPUT")

insert_value_many_to_many() {
    # Insert value into join table of many-to-many relationship (https://stackoverflow.com/a/19734088/17771525)
    local table_name="$1"
    local column_name="$2"
    local value="$3"

    if [ -n "$value" ]; then
        # Insert into `tag` table, ignoring duplicate keys (https://stackoverflow.com/a/1361368/17771525)
        local query_sql="INSERT INTO $table_name ($column_name) VALUES ('$value')"
        query_sql+=" ON DUPLICATE KEY UPDATE ${table_name}_id=${table_name}_id;"
        query_sql+=" SET @${table_name}_id = LAST_INSERT_ID();"
        echo "$query_sql"
        # mysql -u root steam_games_db -e "$sql"
        
        # Insert into `app_${table_name}` table
        local app_table_sql="INSERT INTO app_${table_name} (app_id, ${table_name}_id) VALUES (@app_id, @${table_name}_id);"
        echo "$app_table_sql"
        # mysql -u root steam_games_db -e "$sql"
    fi
}

# Read input into array
readarray -t a <<<"$INPUT"

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

# Insert into `app` table
# insert into tbl (col1,col2) values (nullif('$col1','specialnullvalue') (https://stackoverflow.com/a/75712852/17771525)
app_sql="INSERT INTO app (app_id, app_name, app_type, app_store_name, app_change_number, app_last_change_date, app_release_date)"
app_sql+=" VALUES (${a[0]}, '${a[1]}', '${a[2]}', '${a[3]}', '${a[8]}', '${a[9]}', '${a[10]}';)"
app_sql+=" SET @app_id = LAST_INSERT_ID();"
# mysql -u root -e steam_games_db "$app_sql"
echo "$app_sql"

# Check if developer, publisher, and franchise is not empty. If not empty, insert into their respective table
insert_value_many_to_many "developer" "developer_name" "${a[4]}"
insert_value_many_to_many "publisher" "publisher_name" "${a[5]}"
insert_value_many_to_many "franchise" "franchise_name" "${a[6]}"

# Split the data into individual tags separated by comma
tags=$(echo "${a[11]}" | tr ',' '\n')

# Iterate over tags
while read -r tag; do
    tag_sql="INSERT INTO tag (tag_name) VALUES ('$tag')"
    tag_sql+=" ON DUPLICATE KEY UPDATE tag_id=tag_id;"
    tag_sql+=" SET @tag_id = LAST_INSERT_ID();"
    echo "$tag_sql"
    # mysql -u root -e steam_games_db "$tag_sql"
    
    # Insert into `app_tag` join table
    app_tag_sql="INSERT INTO app_tag (app_id, tag_id) VALUES (@app_id, @tag_id);"
    echo "$app_tag_sql"
    # mysql -u root -e steam_games_db "$app_tag_sql"
done <<< "$tags"