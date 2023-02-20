#! /bin/bash

access_token=$(cat "${HOME}/.google_token_config" | awk -F= '/ACCESS_TOKEN/{print $2}')

curl -s -X DELETE "https://www.googleapis.com/drive/v2/files/trash?access_token=$access_token"
