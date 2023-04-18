#!/bin/bash

curl https://www.worldometers.info/coronavirus/ | pup 'table#main_table_countries_today tbody tr td a.mt_a text{}'
