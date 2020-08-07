#! /bin/bash

if [ -z "$1" ]; then
	echo No param specified.  Please specify a file to upload.
	exit
fi

file_path="$1"
if [ ! -f "${file_path}" ]; then
	echo The file in the param was not found.  Please specify a file that exists.
	exit
fi

file_name=$( basename "${file_path}" )
file_size=$( stat -c %s "${file_path}" )

GOOGLE_TOKEN_CONFIG=~/.google_token_config
if [ ! -f "${GOOGLE_TOKEN_CONFIG}" ]; then
	echo "The Google Access Token Config file was not found.  Please run generate_google_token.sh and check the contents of the file ${GOOGLE_TOKEN_CONFIG}"
	exit
fi
access_token=$(cat "${GOOGLE_TOKEN_CONFIG}" | awk -F= '/ACCESS_TOKEN/{print $2}')

date=$(date +%Y%m%d%H%M)

scope=$(curl -s "https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=$access_token" | jq -r .scope)

if [ "${scope}" != "https://www.googleapis.com/auth/drive" ]; then
	echo "There's an an issue with the validity of the access token.  Please check the access token in the config file ($HOME/.google_token_config)"
	exit
fi

metadata_content='{"title": "'"$file_name"'"}';
metadata_size=$(echo -n "${metadata_content}" | wc -c)

upload_url=$( curl "https://www.googleapis.com/upload/drive/v2/files?access_token=${access_token}&uploadType=resumable" \
	-XPOST  \
	-H 'Content-Type: application/json; charset=UTF-8' \
	-H "Content-Length: ${metadata_size}" \
	-d "${metadata_content}" \
	-v 2>&1 | awk '/ocation:/{print $3}' | sed -e 's|\r$||' )

UPLOAD_OUTPUT_JSON="upload_${date}.json"
curl "${upload_url}" \
	-XPUT \
	-H 'Content-Type: application/octet-stream' \
	-H "Content-Length: ${file_size}" \
	--data-binary "@${file_path}" > "${UPLOAD_OUTPUT_JSON}"

echo "${UPLOAD_OUTPUT_JSON}" > last_upload_json.txt
