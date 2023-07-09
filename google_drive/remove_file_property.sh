#! /bin/bash

FILE_ID=$1
KEY=$2

if [ -z "${FILE_ID}" ] && [ -z "${KEY}" ]; then
	echo "ERROR: issues with params specified.  Please specify a fileId, key to perform delete."
	exit
fi

access_token=$(cat "${HOME}/.google_token_config" | awk -F= '/ACCESS_TOKEN/{print $2}')

curl "https://www.googleapis.com/drive/v2/files/${FILE_ID}/properties/${KEY}?access_token=${access_token}" \
	-XDELETE
