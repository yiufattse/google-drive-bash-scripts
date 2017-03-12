#! /bin/bash

PARAM="$1"

ACCESS_TOKEN=$(cat "${HOME}/.google_token_config" | awk -F= '/ACCESS_TOKEN/{print $2}')

QUOTA_JSON=$( curl -s "https://www.googleapis.com/drive/v2/about?access_token=${ACCESS_TOKEN}" | jq -r '"{\"quotaBytesUsed\": \(.quotaBytesUsed), \"quotaBytesUsedAggregate\": \(.quotaBytesUsedAggregate), \"quotaBytesTotal\": \(.quotaBytesTotal)}"' )

if [ ! -z "$PARAM" ] && [ "$PARAM"=="--free" ]; then
	USED=$(echo $QUOTA_JSON | jq .quotaBytesUsedAggregate)
	TOTAL=$(echo $QUOTA_JSON | jq .quotaBytesTotal)

	FREE=$(( $TOTAL - $USED ))
	echo $FREE
else
	echo $QUOTA_JSON | jq .
fi
