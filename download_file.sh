#! /bin/bash

if [ -z "$1" ]; then
	echo No param specified.  Please specify a fileId.
	exit
fi
file_id="$1"

output_file=/tmp/download_file
if [ ! -z "${2:-}" ]; then
	output_file="${2:-}"
fi

access_token=$(cat "${HOME}/.google_token_config" | awk -F= '/ACCESS_TOKEN/{print $2}')

output=$(curl -s  "https://www.googleapis.com/drive/v3/files/${file_id}?alt=media&access_token=${access_token}")

download_url="$( echo $output | sed -e 's|.*\"\(.*\)\">here.*|\1|' )"

echo "File downloading to.... $output_file"

curl -s -o "$output_file" "${download_url}"
