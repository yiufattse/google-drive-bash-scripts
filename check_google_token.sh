#! /bin/bash

access_token=$(cat "${HOME}/.google_token_config" | awk -F= '/ACCESS_TOKEN/{print $2}')

output=$(curl -s "https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=$access_token")
scope=$(echo "${output}" | jq -r .scope)
expires_in=$(echo "${output}" | jq -r .expires_in)

if [ "${scope}" != "https://www.googleapis.com/auth/drive" ]; then
        echo "There's an an issue with the validity of the access token.  Please check the token in the cofig file ($HOME/.google_token_config)"
        exit
fi

echo
echo "Output:"
echo "${output}"
echo
echo "Response: Token appears to be valid"
echo
echo "Token ${access_token}"
echo
echo "Time Left (seconds): ${expires_in}"
echo
