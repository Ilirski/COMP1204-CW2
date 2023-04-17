#!/bin/bash

# Getting arguments for input and output file
INPUT="$1"

URL="https://steamdb.info/app/${INPUT}/"

# curl_chrome110 - A custom curl script that uses the Chrome 110 user agent (https://github.com/lwthiker/curl-impersonate)
# https://stackoverflow.com/questions/38906626/curl-to-return-http-status-code-along-with-the-response
response=$(./curl_chrome110 -s -w "%{http_code}" "$URL")

http_code=${response: -3}                 # get the last 3 digits
CONTENT=$(echo "${response}" | head -c-4) # get all but the last 3 digits

if [ "$http_code" -eq 200 ]; then
    echo "$CONTENT"
else
    echo "Failure"
    exit 1
fi
