#! /bin/bash

if [ -z "$1" ]; then
	echo No param specified.  Please specify a fileId.
	exit
fi
file_id="$1"

access_token=$(cat "${HOME}/.google_token_config" | awk -F= '/ACCESS_TOKEN/{print $2}')

output=$(curl -s "https://www.googleapis.com/drive/v2/files/$file_id/properties?access_token=$access_token" | jq .items)

title="$(./view_file_details.sh ${file_id} | jq -r .title)"

echo
echo "title: ${title}"
echo "fileId: ${file_id}"
echo ======================
echo $output  | jq -r '.[] | "\(.key)%%%\(.value)"' | while read line; do
	key=$(echo $line | awk -F%%% '{print $1}')
	value=$(echo $line | awk -F%%% '{print $2}')

	echo -e "$key:\t$value"
done
echo
