#!/bin/bash
set -euo pipefail

PROGRAM="${1:-all}"
SEMESTER=su24

# cd into this dir
cd $(dirname "$0")

echo "Downloading Venus..."
venus_time_cond_flag=""
[[ -f venus.jar ]] && venus_time_cond_flag="-z venus.jar"
curl $venus_time_cond_flag -L "https://inst.eecs.berkeley.edu/~cs61c/$SEMESTER/tools/venus-latest.jar" -o venus.jar
echo "Downloaded Venus!"
