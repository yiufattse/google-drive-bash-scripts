#! /bin/bash

CONFIG_FILE=${HOME}/.google_token_config
LOG_FILE=${HOME}/.google_token_generator_log

default_scope="https://www.googleapis.com/auth/drive"
default_redirect_uri="http://localhost/etc"

noconfig=1
if [ -f "${CONFIG_FILE}" ]; then
	config_client_id=$(cat "${CONFIG_FILE}"     | awk -F= '/CLIENT_ID/{print $2}'     | sed -e 's|\ $||g' )
	config_client_secret=$(cat "${CONFIG_FILE}" | awk -F= '/CLIENT_SECRET/{print $2}' | sed -e 's|\ $||g' )
	config_code=$(cat "${CONFIG_FILE}"          | awk -F= '/CODE/{print $2}'          | sed -e 's|\ $||g' )
	config_access_token=$(cat "${CONFIG_FILE}"  | awk -F= '/ACCESS_TOKEN/{print $2}'  | sed -e 's|\ $||g' )
	noconfig=0
fi

echo '=================================================='
echo '|'
echo '| Google Token Generator'
echo '=================================================='
echo
echo "Step 0) If you already have a Project, Client ID and Client Secret, skip to Step 10."
echo
echo -n "Skip (y/n) [n]: "
read skip
if [ "$skip" == "y" ]; then
	echo
	echo "Steps 1-9 skipped"
else
	echo
	echo "To begin, you will need to create a Project."
	echo
	echo "Step 1) visit https://console.cloud.google.com/cloud-resource-manager"
	echo
	echo "Step 2) Click Create Project button, enter a Project Name (i.e. mythtv-file-sharing) and click Create button."
	echo
	echo "Once your project has been created, you will then need to set up a Product name."
	echo
	echo "To set up a Product name, go to the OAuth Consent screen:"
	echo
	echo "Step 3) visit https://console.cloud.google.com/apis/credentials/consent"
	echo
	echo "Step 4) you should now be lead to the 'OAuth consent screen', you'd need to select External and then click Create"
	echo
	echo "Step 5) In this second page of 'OAuth consent screen', enter a 'Application name' (i.e. mythtv-file-sharing), scroll down and click Save button."
	echo
	echo "You will now need to set up a set of Client ID and Client Secret to be used with Project and Application."
	echo
	echo "Step 6) visit https://console.cloud.google.com/apis/credentials (should redirect to Credentials page of the default project)"
	echo
	echo "Step 7) Click on Create credentials and select OAuth client ID"
	echo
	echo "Step 8) Select Web application and add ${default_redirect_uri} to Authorized redirect URIs"
	echo
	echo "Note: Don't forget to add ${default_redirect_uri} as the Redirect URI!!"
	echo
	echo "Step 9) Click Create"
fi

echo
echo "Step 10) Once you have the credentials generated in your Browser window, enter those credentials here now."
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

> "${CONFIG_FILE}"
echo "CLIENT_ID=$client_id"         | sed -e 's|\ $||g' >> "${CONFIG_FILE}"
echo "CLIENT_SECRET=$client_secret" | sed -e 's|\ $||g' >> "${CONFIG_FILE}"

echo '=================================================='
echo
echo "We will now need to assemble the URL that will be used to generate an authorization code."
echo
echo "-You will also have to visit this URL through a browser"
echo
echo "-The authorization code will then be passed into another request to generate the access token."
echo
echo "-This authorization code cannot be used to perform API requests and is only for generating the access token, which is used for API requests."
echo

scope=$(       echo $default_scope        | sed -e 's|:|%3A|g' | sed -e 's|/|%2f|g')
redirect_uri=$(echo $default_redirect_uri | sed -e 's|:|%3A|g' | sed -e 's|/|%2f|g')

access_permit_url="https://accounts.google.com/o/oauth2/auth?scope=${scope}&redirect_uri=${redirect_uri}&response_type=code&client_id=${client_id}&access_type=offline&approval_prompt=force"

echo "If this is the first time using this credential set, you will need to manually visit the following URL (with a browser window) to permit (pre-authorize) the particular scope access for the token (note: token generation could only take place after this step is complete.)"
echo
echo "Step 11) Visit this Access Permit URL with a browser (one time only):"
echo
echo "${access_permit_url}"
echo

echo -n "Visit the above URL now and Click 'Allow' to authorize the scope access of the token and hit Enter when done."
echo
echo -n "-with a browser logged into multiple Google accounts, you will need to select the correct profile you want to connect to the Project/Application."
echo
echo -n "-with a browser like Firefox, you will see an error page 'This app isn't verified'. Here, you will need to click on the Advanced option (left) in order to proceed to Allow the authorization. Then click on newly revealed option 'Go to <project-name> (unsafe)'."
echo
echo -n "-then, the popup pane 'Grant <project-name> permission' would show up, please click 'Allow'"
echo
echo -n "-then, the next page 'Confirm your choices' would show up, click 'Allow' again"
echo
echo -n "-then, the confirmation page would disappear and the browser would be lead to a broken page.  Please don't close this page."
echo
echo -n ": "
read
echo

echo "Step 12) Please take the URL from the location bar and then paste URL here"
echo "(e.g. http://localhost/etc?code=4/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX&scope=https://www.googleapis.com/auth/yyyyy): "

if [ $noconfig -eq 1 ]; then
	echo -n "#: "
	read generated_redirect_uri
	code=$(echo $generated_redirect_uri | sed -e 's|^.*code=\([^&]\+\)&.*|\1|')
else
	echo -n "# [http://localhost/etc?code=${config_code}]: "
	read generated_redirect_uri
	code=$(echo $generated_redirect_uri | sed -e 's|^.*code=\([^&]\+\)&.*|\1|')
	if [ -z "$generated_redirect_uri" ]; then
		code="${config_code}"
	fi
fi
echo "CODE=${code}" | sed -e 's|\ $||g' >> "${CONFIG_FILE}"

if [ -z "$(echo $code | grep 4/ )" ]; then
	echo
	echo "ERROR: There was an issue with retrieving the authorization code. There was likely an issue with the Authorization Code.  Please generate another one and rerun the script with the new code."
	echo
	exit
fi

echo
echo "Complete: Authorization Code acquired."
echo
echo "Authorization Code: ${code}"
echo

echo "Using the authorization code above, we will now assemble the URL that will be used to lease a Google Access Token.  Typically, the access tokens last an hour (3600 seconds)."
echo
echo -n "Hit Enter when ready: "
read
echo

echo "Requesting Token..."
echo
echo "Request output:"
curl -s -H "Content-Type: application/x-www-form-urlencoded" -d "code=${code}&client_id=${client_id}&client_secret=${client_secret}&redirect_uri=${redirect_uri}&grant_type=authorization_code" "https://accounts.google.com/o/oauth2/token" | tee "${LOG_FILE}"
access_token=$(cat "${LOG_FILE}" | jq -r .access_token)
refresh_token=$(cat "${LOG_FILE}" | jq -r .refresh_token)
echo
echo

if [ $(echo $access_token | wc -c ) -lt 30 ]; then
	echo "ERROR: There was an issue acquiring the access token. Please rerun the script with a new set of credentials."
	echo
	exit
fi
echo "ACCESS_TOKEN=${access_token}" >> "${CONFIG_FILE}"

if [ ! -z "$refresh_token" ]; then
	echo "REFRESH_TOKEN=${refresh_token}" >> "${CONFIG_FILE}"
fi

echo ===================================================================
echo
echo "Your Access Token: $access_token"
echo
echo ===================================================================

echo
echo "Output of Token Info:"
echo
echo "curl -s 'https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=$access_token'"
curl -s "https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=$access_token"
echo

echo ===================================================================
echo "Sample Uses:"
echo

echo "To access drive list, issue the following command"
echo "curl -s 'https://www.googleapis.com/drive/v3/files?access_token=${access_token}'"
echo

echo "To access a file from Google Drive, issue the drive list command above and copy down the FILE_ID and replace it into the following URL and run the command: "
echo "curl -s 'https://www.googleapis.com/drive/v3/files/FILE_ID?access_token=${access_token}&alt=media' -L"
echo
echo "We took the liberty to save the issued access token into a config file, so you should also be able to access the drive list with the following command:"
echo 'curl -s "https://www.googleapis.com/drive/v3/files?access_token=$(cat '${CONFIG_FILE}' | awk -F= '"'"'/ACCESS_TOKEN/{print $2}'"'"')"'
echo
echo "If these show commands show "Access Not Configured" error message, don't forget to go to the particular API console under https://console.developers.google.com/apis and click on the Enable button (Step 5)"
echo
echo "for Google Drive, you'd visit the Google Drive API Library (i.e. https://console.cloud.google.com/apis/library/drive.googleapis.com) and click Enable. Then, click on the project name and then click Open."
echo
echo ===================================================================
echo
