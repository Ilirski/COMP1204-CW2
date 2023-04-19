#!/bin/bash

# Read input from stdin if present. Else, read from file (https://superuser.com/a/747905)
[ $# -ge 1 ] && [ -f "$1" ] && INPUT="$1" || INPUT="-"
INPUT=$(cat "$INPUT")

# Join lines with commas (https://stackoverflow.com/a/6539865/17771525)
VALUES=$(paste -sd "," <<<"$INPUT")

# eval mysql -u root -proot -e "USE steam_games_db; INSERT INTO DATABASE steam_games_db VALUES (${VALUES});"
# eval mysql -u root -proot -e "CREATE DATABASE steam_games_db; USE steam_games_db; CREATE TABLE steam_games_db (id INT NOT NULL AUTO_INCREMENT, name VARCHAR(255) NOT NULL, PRIMARY KEY (id));"
# eval mysql -u phpmyadmin -p -e "SELECT user(), current_user()"
# eval mysql -u phpmyadmin -p

# eval /opt/lampp/bin/mysql -u root -e "USE steam_games_db; INSERT INTO DATABASE steam_games_db VALUES $VALUES;"