#! /bin/bash

FILE_ID=$1
KEY=$2
VALUE=$3

if [ -z "${FILE_ID}" ] && [ -z "${KEY}" ] && [ -z "${VALUE}" ]; then
	echo "ERROR: issues with params specified.  Please specify a fileId, key and value in that order."
	exit
fi

access_token=$(cat "${HOME}/.google_token_config" | awk -F= '/ACCESS_TOKEN/{print $2}')

curl "https://www.googleapis.com/drive/v2/files/${FILE_ID}/properties?access_token=${access_token}" \
	-XPOST \
	-H 'Content-Type: application/json; charset=UTF-8' \
	-d '{"key":"'"$KEY"'","value": "'"$VALUE"'"}'
