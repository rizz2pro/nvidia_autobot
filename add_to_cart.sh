#!/bin/bash

# Verify cookie is valid by adding an item to the cart and making sure it shows up.

# Random item with high stock to trigger alert
item_id_test="108012"
short_loc="GT"

# Figure out base dir and source global vars
base_dir=$(dirname $0)
source  $base_dir/vars.txt

# Prep a temporary file to filter the template out to
epoch_time=$(date +%s.%N)
mkdir $base_dir/tmp 2> /dev/null
tmp_file="$base_dir/tmp/add_to_cart.${epoch_time}"
cp $base_dir/templates/add_to_cart.json $tmp_file
	
echo kk
# Filter the temporary file with the values from above and vars.txt
sed -i "s/\[item_id\]/$item_id_test/g" $tmp_file
sed -i "s/\[cookie_val\]/$cookie_val/g" $tmp_file
sed -i "s/\[short_loc\]/$short_loc/g" $tmp_file
sed -i "s/\[phone_area\]/$phone_area/g" $tmp_file
sed -i "s/\[phone_3\]/$phone_3/g" $tmp_file
sed -i "s/\[phone_4\]/$phone_4/g" $tmp_file
sed -i "s/\[emailaddress\]/$emailaddress/g" $tmp_file
sed -i "s/\[first_name\]/$first_name/g" $tmp_file
sed -i "s/\[last_name\]/$last_name/g" $tmp_file
sed -i "s/\[fprint\]/$fprint/g" $tmp_file
echo $tmp_file is temp file

echo h
# Craft a curl command using the filtered file and run it with newman
newman run $tmp_file
exit
