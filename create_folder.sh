#! /bin/bash

set -e
set -u

FOLDER_NAME="$1"
PARENT_ID="${2:-}"

SCRIPT_DIR=$(dirname $0)

access_token=$(cat "${HOME}/.google_token_config" | awk -F= '/ACCESS_TOKEN/{print $2}')

metadata_content='{"title": "'"$FOLDER_NAME"'",
					"mimeType": "application/vnd.google-apps.folder"
}';
metadata_size=$(echo -n "${metadata_content}" | wc -c)

NEW_FOLDER_ID=$( curl "https://www.googleapis.com/drive/v2/files?access_token=${access_token}" \
	-XPOST \
	-H 'Content-Type: application/json; charset=UTF-8' \
	-H "Content-Length: ${metadata_size}" \
	-d "${metadata_content}" \
	-s | jq -r '.id' )

# move new folder into specified PARENT_ID
if [ ! -z "${PARENT_ID}" ]; then
	$SCRIPT_DIR/change_parent_to.sh "${NEW_FOLDER_ID}" "${PARENT_ID}"
fi
