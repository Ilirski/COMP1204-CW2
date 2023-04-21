#!/bin/bash

echo "Creating database..."
mysql -u root -e "CREATE DATABASE steam_games_db;"
echo "Populating tables..."
mysql -u root steam_games_db < steam_games_db_create.sql
