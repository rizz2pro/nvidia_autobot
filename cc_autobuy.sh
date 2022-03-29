#!/bin/bash

# The bread and the butter...

# This script will check on a list of CC stores for a list of items in stock. 
# When it finds one, it will add it to the cart, go through the check out process and complete the order. 

# The nice thing about CC is you can filter for 3080/3090 to retrieve their full listing of cards.
# Once you pick a store, all the listings go away if there is no stock.
# That means we only need to pull the page down one time and see if we find any of the IDs from the list we made from id_list.conf

# Pick a number from 1 to 10, then sleep for that number of seconds to appear less botty if running more than one instance
sleep $(shuf -i 1-10 -n 1)

# Site Variables
baseurl="https://www.canadacomputers.com/product_info.php?ajaxstock=true&itemid="
baseurl_web="https://www.canadacomputers.com/product_info.php?cPath=26_1842_1960&item_id="
baseurl_cart="https://www.canadacomputers.com/index.php?action=buy_now&item_id="
#### Filtered 3080/3090 link
baseurl_grid="https://www.canadacomputers.com/index.php?cPath=43_557_559&sf=:3_3,3_5&loc="
#### Test link with item 173777 - DISABLE IT WHEN RUNNING LIVE
#baseurl_grid="https://www.canadacomputers.com/index.php?cPath=710&sf=:&loc="

# Figure out base dir and source global vars
base_dir=$(dirname $0)
source  $base_dir/vars.txt

# Check if already running
pid=$(echo $$)
if ps aux | grep -v sudo | grep -v grep | grep -v $pid | grep -v convert.log | grep [c]c_autobuy.sh
then
        echo "Already running, bitch"
        exit
fi

# Function for pushover message
send_notify(){
        curl -s --header "Access-Token: $apikey" \
                --header 'Content-Type: application/json' \
                --data-binary \{\"body\"\:\"AUTOBUY_SUCCESS-$store\:\ ${baseurl_web}${i}\"\,\"title\"\:\"AUTOBUY_SUCCESS-${store}\"\,\"type\"\:\"note\"\} \
                --request POST \
                https://api.pushbullet.com/v2/pushes > /dev/null &
}

mkdir $base_dir/tmp 2> /dev/null

while true; do
	# Only run between 7AM and and 7PM
	HOUR="$(date +'%H')"
	if [ $HOUR -ge 19 ] || [ $HOUR -lt 7 ] ; then
		echo "Store's closed dude"
		exit
    	fi
        temp_file="$base_dir/tmp/check_location.tmp"
        while read store; do
	# "Rate limiting"
	# If you set this below 2, CC will rate limit you and you will be redirected to facebook.com/canadacomputers for the next 24 hours lol
	# Set it to 3 or above.
	# If you want to go below 3, make sure you have enough vpn config files stored under $base_dir/vpnconfigs
	sleep 5
		# Set your store code name based on the store being queried
		case $store in
                        Store1)  short_loc=Store_ID1  ;;
                        Store2)    short_loc=Store_ID2;;
                        Store3) short_loc=Store_ID3   ;;
                        Store4)  short_loc=Store_ID4  ;;
                        Store5)  short_loc=Store_ID5  ;;
                esac
		echo "Checking $store"

		# Pull down the grid using a location. (the $short_loc, not the preferloc= below)
                curl -s "${baseurl_grid}${short_loc}" \
                	-H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36' \
                        -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' \
                        -H 'Accept-Encoding: gzip, deflate, br' \
                        -H 'Accept-Language: en-US,en;q=0.9' \
                        -H "Cookie: privacyaccepted=yes; preferloc=OTT2" \
                        --compressed > $temp_file

		# Do any of the IDs we want show up on that page? 
		# If so, continue through the checkout process
		# If not, check the list until you find a match
		for i in $(cat $base_dir/id_list.conf); do
			if ! grep -E "https://www.canadacomputers.com/product_info.php.*cPath=.*item_id=${i}" $temp_file; then
				echo "Item: ${i} not in stock"
				continue
			fi

			echo "FOUND ITEM: ${i}"
			epoch_time=$(date +%s.%N)
			tmp_file="$base_dir/tmp/cc_autobuy.${epoch_time}"
			item_id=$i

			# Copy the template then filter it for newman
			cp $base_dir/templates/cc_autobuy.json $tmp_file
			sed -i "s/\[cookie_val\]/$cookie_val/g" $tmp_file
			sed -i "s/\[item_id\]/$item_id/g" $tmp_file
			sed -i "s/\[short_loc\]/$short_loc/g" $tmp_file
			sed -i "s/\[phone_area\]/$phone_area/g" $tmp_file
			sed -i "s/\[phone_3\]/$phone_3/g" $tmp_file
			sed -i "s/\[phone_4\]/$phone_4/g" $tmp_file
			sed -i "s/\[emailaddress\]/$emailaddress/g" $tmp_file
			sed -i "s/\[first_name\]/$first_name/g" $tmp_file
			sed -i "s/\[last_name\]/$last_name/g" $tmp_file
			sed -i "s/\[fprint\]/$fprint/g" $tmp_file
			# Go through the 4 checkout steps
			newman run $tmp_file
			# Send me a notiifcation
       			send_notify
			# Pause for a while so we don't buy another one at the same store too quickly.
			sleep 120
			exit
		done
	done < $base_dir/v3-stores.conf
done
