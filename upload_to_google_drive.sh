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

access_token=$(cat ~/.google_token_config | awk -F= '/ACCESS_TOKEN/{print $2}')

echo 1
scope=$(curl -s "https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=$access_token" | jq -r .scope)

if [ "${scope}" != "https://www.googleapis.com/auth/drive" ]; then
	echo "There's an an issue with the validity of the access token.  Please check the access token in the cofig file ($HOME/.google_token_config)"
	exit
fi

metadata_content='{"title": "'"$file_name"'"}';
metadata_size=$(echo -n "${metadata_content}" | wc -c)

upload_url=$( curl "https://www.googleapis.com/upload/drive/v2/files?access_token=${access_token}&uploadType=resumable" \
	-XPOST  \
	-H 'Content-Type: application/json; charset=UTF-8' \
	-H "Content-Length: ${metadata_size}" \
	-d "${metadata_content}" \
	-v 2>&1 | awk '/Location/{print $3}' | sed -e 's|\r$||' )

curl "${upload_url}" \
	-XPUT \
	-H 'Content-Type: application/octet-stream' \
	-H "Content-Length: ${file_size}" \
	--data-binary "@${file_path}" \
	--progress-bar
