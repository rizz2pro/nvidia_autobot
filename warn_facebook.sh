#!/bin/bash

# Notify me if we are getting facebook'd

send_notify(){
        curl -s --header "Access-Token: $apikey" \
                --header 'Content-Type: application/json' \
                --data-binary \{\"body\"\:\"FACEBOOK_WARN\"\,\"type\"\:\"note\"\} \
                --request POST \
                https://api.pushbullet.com/v2/pushes > /dev/null &
}

curl https://www.canadacomputers.com > /tmp/warn_facebook-result.log
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
        mv /tmp/warn_facebook-result.log /tmp/warn_facebook-result.$$.log
        echo "$(date) : fail"
        send_notify
else
        echo "$(date) : all good"
fi

