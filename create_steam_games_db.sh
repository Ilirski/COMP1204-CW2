#!/bin/bash

# Check if mysql is in PATH (https://stackoverflow.com/a/677212)
if ! command -v mysql &>/dev/null; then
    echo "mysql could not be found. Please add mysql to PATH."
    exit 1
fi

echo -ne "Creating steam_games_db database...\r"

if mysql -u root -e "CREATE DATABASE steam_games_db;"; then
    echo -ne "Populating steam_games_db with tables...\r"
else
    echo -ne "steam_games_db already exists!    \r"
    exit 1
fi

if mysql -u root steam_games_db <steam_games_db_create.sql; then
    echo -ne "steam_games_db successfully created!    \r"
else
    echo -ne "steam_games_db could not be created!    \r"
    exit 1
fi
