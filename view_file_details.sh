#! /bin/bash

if [ -z "$1" ]; then
	echo No param specified.  Please specify a fileId.
	exit
fi
file_id="$1"

access_token=$(cat "${HOME}/.google_token_config" | awk -F= '/ACCESS_TOKEN/{print $2}')

output=$(curl -s "https://www.googleapis.com/drive/v2/files/$file_id?access_token=$access_token")

echo $output | jq .
