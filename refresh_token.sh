#! /bin/bash

refresh_token=$(cat "${HOME}/.google_token_config" | awk -F= '/REFRESH_TOKEN/{print $2}')
client_id=$(cat "${HOME}/.google_token_config" | awk -F= '/CLIENT_ID/{print $2}')
client_secret=$(cat "${HOME}/.google_token_config" | awk -F= '/CLIENT_SECRET/{print $2}')

output=$(curl -s \
-XPOST "https://www.googleapis.com/oauth2/v4/token" \
-H 'Content-Type: application/x-www-form-urlencoded' \
-d "client_id=${client_id}&client_secret=${client_secret}&refresh_token=${refresh_token}&grant_type=refresh_token" )

access_token=$( echo $output | jq -r .access_token)
sed -i "s|^ACCESS_TOKEN=.*|ACCESS_TOKEN=${access_token}|" $HOME/.google_token_config

echo $output | jq .
