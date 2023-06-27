#! /bin/bash

JSON="${JSON:-}"
subfolder_id="$1"
COUNT_LIMIT="${COUNT_LIMIT:-}"

access_token=$(cat "${HOME}/.google_token_config" | awk -F= '/ACCESS_TOKEN/{print $2}')

if [ -z "${subfolder_id}" ]; then
	url="https://www.googleapis.com/drive/v2/files?access_token=$access_token"
	#if [ ! -z "${COUNT_LIMIT}" ]; then
	#	url="${url}&maxResults=${COUNT_LIMIT}"
	#fi
	items=$( curl -s "$url" | jq .items )
else
	url="https://www.googleapis.com/drive/v2/files?q='$subfolder_id'+in+parents&access_token=$access_token"
	if [ ! -z "${COUNT_LIMIT}" ]; then
		url="${url}&maxResults=${COUNT_LIMIT}"
	fi
	items=$( curl -s "$url" | jq .items )
fi

echo $items | jq -r '.[] | "\(.modifiedDate)%%%\(.parents[0].id)%%%\(.id)%%%\(.labels.trashed)%%%\(.mimeType)%%%\(.title)"' | while read line; do
	modifiedDate=$(echo $line | awk -F%%% '{print $1}')
	parent_id=$(echo $line | awk -F%%% '{print $2}')
	id=$(echo $line | awk -F%%% '{print $3}')
	trashed=$(echo $line | awk -F%%% '{print $4}')
	mimeType=$(echo $line | awk -F%%% '{print $5}')
	title=$(echo $line | awk -F%%% '{print $6}')

	title_escaped=$( echo "$title" | sed -e 's|"|\\"|g' )

	if [ ! -z "$JSON" ] && [ "$JSON" == 1 ]; then
		line_json="{\"modifiedDate\": \"$modifiedDate\", \"parent_id\": \"$parent_id\", \"id\": \"$id\", \"trashed\": \"$trashed\", \"title\": \"$title_escaped\"}"
		echo "$line_json" | jq .
	else
		if [ "$mimeType" == 'application/vnd.google-apps.folder' ]; then
			blockType=folder
		else
			blockType=file
		fi

		line_json="$modifiedDate\t$parent_id\t$id\t$trashed\t$blockType\t$title_escaped"
		echo -e "$line_json"
	fi
done
