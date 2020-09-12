#! /bin/bash

FILE_ID=$1
NEW_PARENT_ID=$2

if [ -z "${FILE_ID}" ] && [ -z "${NEW_PARENT_ID}" ]; then
	echo "ERROR: issues with params specified.  Please specify a fileId and parent in that order."
	exit
fi

access_token=$(cat "${HOME}/.google_token_config" | awk -F= '/ACCESS_TOKEN/{print $2}')

OLD_PARENT_ID=$( curl "https://www.googleapis.com/drive/v2/files/${FILE_ID}?access_token=${access_token}" | jq -r '.parents[0].id' )

curl "https://www.googleapis.com/drive/v2/files/${FILE_ID}?access_token=${access_token}&addParents=${NEW_PARENT_ID}&removeParents=${OLD_PARENT_ID}" \
	-H "Content-Length: 0" \
	-XPUT
