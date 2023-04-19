#!/bin/bash

mysql -u root -e "CREATE DATABASE steam_games_db;"
mysql -u root steam_games_db < steam_games_db_create.sql
