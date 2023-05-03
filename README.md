# COMP1204-CW2 — steamdb web scraper

For Southampton UoSM COMP1204 CW2.
This is a web scraper that scrapes steamdb.info website.
It is a collection of scripts that scrape the website and store the data in a database.

## Requirements
Download the CLI programs below. Ensure they are added to PATH (`/usr/local/bin`) to run the scripts.
- [curl-impersonate](https://github.com/lwthiker/curl-impersonate)
- [pup](https://github.com/ericchiang/pup)
- [miller](https://miller.readthedocs.io/en/latest/)

## Usage
1. Run `create_steam_games_db.sh` to create the MySQL database to store the data.
2. Run `add_app_id.sh` with one or more steam app id(s) that you want to scrape.
3. Run `run_scapers.sh` to scrape live steam and twitch data from all the app id(s) you've added. 
4. If you want to plot the data, run `plot_steam_games_data.sh` with the app id(s) you want to plot.
