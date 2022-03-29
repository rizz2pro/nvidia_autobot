#!/bin/bash

# Run this once a minute in cron to load your CC Account page to keep your cookie alive. If you don't, you'll risk getting a hit but not being able to checkout since you're not associated to your account.

# Figure out base dir and source global vars
base_dir=$(dirname $0)
source  $base_dir/vars.txt

# Copy the template to a temporary file
epoch_time=$(date +%s.%N)
mkdir $base_dir/tmp 2> /dev/null
tmp_file="$base_dir/tmp/keepalive.${epoch_time}"
cp $base_dir/templates/keepalive.json $tmp_file

# Filter the temporary file
sed -i "s/\[cookie_val\]/$cookie_val/g" $tmp_file

# Run the file with newman to send the request
newman run $tmp_file
rm -f $tmp_file
exit
