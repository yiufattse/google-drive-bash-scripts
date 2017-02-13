#! /bin/bash

CONFIG_FILE=${HOME}/.google_token_config
LOG_FILE=${HOME}/.google_token_generator_log

default_scope="https://www.googleapis.com/auth/drive"
default_redirect_uri="http://localhost/etc"

noconfig=1
if [ -f "${CONFIG_FILE}" ]; then
	config_client_id=$(cat "${CONFIG_FILE}" | awk -F= '/CLIENT_ID/{print $2}')
	config_client_secret=$(cat "${CONFIG_FILE}" | awk -F= '/CLIENT_SECRET/{print $2}')
	config_token=$(cat "${CONFIG_FILE}" | awk -F= '/TOKEN/{print $2}')
	noconfig=0
fi

echo '=================================================='
echo '|'
echo '| Google Token Generator'
echo '=================================================='
echo
echo "Step 0) If you already have a Project, Client ID and Client Secret, skip to Step 9."
echo
echo -n "Skip (y/n) [n]: "
read skip
if [ "$skip" == "y" ]; then
	echo
	echo "Steps 1-8 skipped"
else
	echo
	echo "To begin, you will need to create a Project."
	echo
	echo "Step 1) visit https://console.developers.google.com/iam-admin/projects"
	echo
	echo "Step 2) Click Create Project button, enter a Project Name and click Create button."
	echo
	echo "Once your project has been created, you will then need to set up a Product name."
	echo
	echo "To set up a Product name, go to the OAuth Consent screen:"
	echo
	echo "Step 3) visit https://console.developers.google.com/apis/credentials/consent"
	echo
	echo "Step 4) enter a Product Name, scroll down and click Save button."
	echo
	echo "Once your project has been created, you will then need to set up a set of Client ID and Client Secret."
	echo
	echo "Step 5) visit https://console.developers.google.com/apis/credentials (should redirect to default project)"
	echo
	echo "Step 6) Click on Create credentials and select OAuth client ID"
	echo
	echo "Step 7) Select Web application and add ${default_redirect_uri} to Authorized redirect URIs"
	echo
	echo "Note: Don't forget to add ${default_redirect_uri} as the Redirect URI!!"
	echo
	echo "Step 8) Click Create"
fi

echo
echo "Step 9) Once you have the credentials generated in your Browser window, enter those credentials here now."
echo

if [ $noconfig -eq 1 ]; then
	echo -n "Client ID: "
	read client_id
	echo
	echo -n "Client Secret: "
	read client_secret
else
	echo -n "Client ID [${config_client_id}]: "
	read client_id
	if [ -z "$client_id" ]; then
		client_id="${config_client_id}"
	fi
	echo
	echo -n "Client Secret [${config_client_secret}]: "
	read client_secret
	if [ -z "$client_secret" ]; then
		client_secret="${config_client_secret}"
	fi
fi
echo 

echo '=================================================='
echo
echo "Here (again) are your credentials:"
echo
echo -n "Client ID: "
echo $client_id
echo -n "Client Secret: "
echo $client_secret
echo

echo "CLIENT_ID=$client_id
CLIENT_SECRET=$client_secret" > "${CONFIG_FILE}"

echo '=================================================='
echo
echo "We will now need to assemble the URL that will be used to generate an access code."
echo
echo "-You will also have to visit this URL through a browser"
echo
echo "-The access code will then be passed into another request to generate the access token."
echo
echo "-This access code CANNOT be used to perform API requests."
echo

scope=$(       echo $default_scope        | sed -e 's|:|%3A|g' | sed -e 's|/|%2f|g')
redirect_uri=$(echo $default_redirect_uri | sed -e 's|:|%3A|g' | sed -e 's|/|%2f|g')

access_permit_url="https://accounts.google.com/o/oauth2/auth?scope=${scope}&redirect_uri=${redirect_uri}&response_type=code&client_id=${client_id}"

echo "If this is the first time using this credential set, you will need to manually visit the following URL (with a browser window) to permit (pre-authorize) the particular scope access for the token (note: token generation will follow this step.)"
echo
echo "Step 10) Visit this Access Permit URL (one time only):"
echo
echo "${access_permit_url}"
echo

echo -n "Visit the above URL now and Click 'Allow' to authorize the scope access of the token and hit Enter when done: "
read
echo

echo "Step 11) Please paste in the URL of the visited page"
echo "(e.g. http://localhost/etc?code=4/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX): "
echo -n "#: "
read generated_redirect_uri
code=$(echo $generated_redirect_uri | sed -e 's|^.*=||')

if [ -z "$(echo $code | grep 4/ )" ]; then
	echo
	echo "ERROR: There was an issue with retrieving the access code. Please rerun the script with a new set of credentials."
	echo
	exit
fi

echo
echo "Complete: Code acquired."
echo
echo "Code: ${code}"
echo

echo "Using the code above, we will now assemble the URL that will be used to lease a Google Access Token.  Typically, the access tokens last an hour (3600 seconds)."
echo
echo -n "Hit Enter when ready: "
read
echo

echo "Requesting Token..."
echo
echo "Request output:"
curl -s -H "Content-Type: application/x-www-form-urlencoded" -d "code=${code}&client_id=${client_id}&client_secret=${client_secret}&redirect_uri=${redirect_uri}&grant_type=authorization_code" "https://accounts.google.com/o/oauth2/token" | tee "${LOG_FILE}"
token=$(cat "${LOG_FILE}" | jq -r .access_token)
echo
echo

if [ $(echo $token | wc -c ) -lt 30 ]; then
	echo "ERROR: There was an issue acquiring the access token. Please rerun the script with a new set of credentials."
	echo
	exit
fi
echo "TOKEN=${token}" >> "${CONFIG_FILE}"

echo ===================================================================
echo
echo "Your Access Token: $token"
echo
echo ===================================================================

echo
echo "Output of Token Info:"
echo
echo "curl -s 'https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=$token'"
curl -s "https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=$token"
echo

echo ===================================================================
echo "Sample Uses:"
echo

echo "To access drive list, issue the following command"
echo "curl -s 'https://www.googleapis.com/drive/v3/files?access_token=${token}'"
echo

echo "To access a file from Google Drive, issue the drive list command above and copy down the FILE_ID and replace it into the following URL and run the command: "
echo "curl -s 'https://www.googleapis.com/drive/v3/files/FILE_ID?access_token=${token}&alt=media' -L"
echo
echo "We took the liberty to save the issued token into a config file, so you should also be able to access the drive list with the following command:"
echo 'curl -s "https://www.googleapis.com/drive/v3/files?access_token=$(cat '${CONFIG_FILE}' | awk -F= '"'"'/TOKEN/{print $2}'"'"')"'
echo
echo ===================================================================
echo
