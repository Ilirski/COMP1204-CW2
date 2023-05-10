# COMP1204-CW2 — steamdb web scraper

For Southampton UoSM COMP1204 CW2.
This is a web scraper that scrapes steamdb.info website.
It is a collection of scripts that scrape the website and store the data in a MySQL database.

## Requirements
Download the CLI programs below. Ensure they are added to PATH (`/usr/local/bin`) to run the scripts.
- [curl-impersonate](https://github.com/lwthiker/curl-impersonate)
- [pup](https://github.com/ericchiang/pup)
- [miller](https://miller.readthedocs.io/en/latest/)

Note: `curl-impersonate` and `pup` cannot be downloaded through `apt`. Therefore, you'll need to install them manually by extracting the binaries from the zip files and adding them to path. Here's a general guide:
1. Go to their GitHub repository and click on `Releases` in the right side menu.
2. **Download the correct binary file for your OS.** For example on a Raspberry Pi which runs on the Linux OS and ARM architecture, `aarch64` and `arm` usually work. If you're running these scripts on a VM, keep this in mind.
3. Unzip the zip / tar file.
4. Now, the last and most important part — `sudo mv` the binary files required for the script to `/usr/local/bin` or the scripts will not work!!! To verify that the binaries are added to PATH, try to run the binaries as a command in the CLI.

## Usage
Note: The script assumes that following path exists: `/var/lib/mysql/steam_games_db`. This is the default installation directory if you install `mysql` with `apt`.
1. Run `create_steam_games_db.sh` to create the MySQL database to store the data.
```sh
./create_steam_gams_db.sh
```
2. Run `add_app_id.sh` with one or more steam app id(s) that you want to scrape.
```sh
./app_id_.sh 730
./app_id.sh 550 990 4000
```
3. Run `run_scapers.sh` to scrape live steam and twitch data from all the app id(s) you've added.
```sh
./run_scrapers.sh
```
4. To plot the data, run `plot_steam_games_data.sh` with the app id(s) you want to plot.
```sh
./plot_steam_games_data.sh -a 730 -v
```
