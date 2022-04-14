#! /bin/bash

FILE_ID=$1
NEW_FILENAME=$2

if [ -z "${FILE_ID}" ] && [ -z "${NEW_FILENAME}" ]; then
	echo "ERROR: issues with params specified.  Please specify a fileId and filename in that order."
	exit
fi

access_token=$(cat "${HOME}/.google_token_config" | awk -F= '/ACCESS_TOKEN/{print $2}')

#OLD_PARENT_ID=$( curl "https://www.googleapis.com/drive/v2/files/${FILE_ID}?access_token=${access_token}" | jq -r '.parents[0].id' )

curl "https://www.googleapis.com/drive/v2/files/${FILE_ID}?access_token=${access_token}" --data "{\"title\": \"${NEW_FILENAME}\"}" \
	-H 'Content-Type: application/json; charset=UTF-8' \
	-XPATCH
