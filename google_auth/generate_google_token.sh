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
echo "Step 0) If you already have a Project, Client ID and Client Secret, skip to Step 17."
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
	echo "Once your project has been created, you may see a notification about the project creation. You will now need to select it so you can set up an App name for this project. Find this new project and select it first."
	echo
	echo "Once this new project is selected, go to the OAuth Consent screen:"
	echo
	echo "Step 3) visit https://console.cloud.google.com/apis/credentials/consent"
	echo
	echo "Step 4) you should now be lead to the 'OAuth consent screen', you'd need to select External and then click Create"
	echo
	echo "Step 5) In this second page of 'OAuth consent screen', enter a 'App name' (i.e. mythtv-file-sharing)"
	echo
	echo "Step 6) Enter the user support email address in the field right below App Name"
	echo
	echo "Step 7) Then scroll down and enter the Developer contact info email address in the field right above the Save and Continue button"
	echo
	echo "Step 8) Now click Save and Continue button."
	echo
	echo "Once you've clicked Save and Continue button, you will see that you've left the OAuth consent screen in the Edit app registration wizard and have moved onto step 2 (Scopes). You don't need to add a Scope manually. So you can proceed onto the next step in the wizard."
	echo
	echo "Step 9) Make no changes to Scopes and click Save and Continue button to arrive in the Test users screen."
	echo
	echo "Now that you have reached the Test users screen, enter the email address of the Google account that you will use as your (first) test user to test the App with. You will need to add test user(s) so they can be allowed to be issued the credentials to interact with the resources of the App. Note that test users are allowed to interact with the App resources before the App is published."
	echo
	echo "Step 10) Click Add Users"
	echo
	echo "Step 11) In the pane that opened, type in the email address of the test user and then click Add."
	echo
	echo "Now that you've left the Add users pane and returned to Test users screen,"
	echo
	echo "Step 12) click Save and Continue."
	echo
	echo "The next steps involves setting up a set of Client ID and Client Secret to be used with Project and Application."
	echo
	echo "Step 13) visit https://console.cloud.google.com/apis/credentials (should redirect to Credentials page of the default project)"
	echo
	echo "Step 14) Click on Create credentials and select OAuth client ID"
	echo
	echo "Step 15) Select Web application and add ${default_redirect_uri} to Authorized redirect URIs"
	echo
	echo "Note: Don't forget to add ${default_redirect_uri} as the Redirect URI!!"
	echo
	echo "Step 16) Click Create"
fi

echo
echo "Step 17) Once you have the credentials generated in your Browser window, enter those credentials here now."
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


echo '=================================================='
echo
echo "Let's now choose a scope that you want the token to work for."
echo
echo -n "scope [${default_scope}]: "
read scope_answer
scope_answer=${scope_answer:-$default_scope}

scope=$(       echo $scope_answer         | sed -e 's|:|%3A|g' | sed -e 's|/|%2f|g' | sed -e 's|\ |%20|g')
redirect_uri=$(echo $default_redirect_uri | sed -e 's|:|%3A|g' | sed -e 's|/|%2f|g')

access_permit_url="https://accounts.google.com/o/oauth2/auth?scope=${scope}&redirect_uri=${redirect_uri}&response_type=code&client_id=${client_id}&access_type=offline&approval_prompt=force"

echo
echo "If this is the first time using this credential set, you will need to manually visit the following URL (with a browser window) to permit (pre-authorize) the particular scope access for the token (note: token generation could only take place after this step is complete.)"
echo
echo "Step 18) Visit this Access Permit URL with a browser (one time only):"
echo
echo "${access_permit_url}"
echo

echo "Visit the above URL now and Click 'Allow' to authorize the scope access of the token and hit Enter when done."
echo
echo "-with a browser logged into multiple Google accounts, you will need to select the correct profile you want to connect to the Project/Application."
echo
echo "-with a browser like Firefox, you will see an error page 'This app isn't verified'. Here, you will need to click \"Continue\" button on the left hand side (the option might also be called \"Advanced\") in order to proceed to Allow the authorization. Then click on newly revealed option 'Go to <project-name> (unsafe)'."
echo
echo "-the following screen will say that the app wants access to your Google Account and to make sure you trust the app. Click Continue here."
echo
echo "(previous versions of Firefox/Google Chrome may appear more like the following)"
echo
echo "-then, the popup pane 'Grant <project-name> permission' would show up, please click 'Allow'"
echo
echo "-then, the next page 'Confirm your choices' would show up, click 'Allow' again"
echo
echo
echo "After confirming the access properly, by the end this will happen."
echo
echo -n "-after allowing the access, the confirmation page would disappear and the browser would be lead to what would appear as a broken page (In firefox, the page would say \"Unable to connect.\")  !!!Please don't close this page.!!!"
echo
echo -n ": "
read
echo

echo "Step 19) Please take the URL from the location bar and then paste URL here"
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
echo curl -s -H "Content-Type: application/x-www-form-urlencoded" -d "code=${code}&client_id=${client_id}&client_secret=${client_secret}&redirect_uri=${redirect_uri}&grant_type=authorization_code" "https://accounts.google.com/o/oauth2/token" | tee "${LOG_FILE}"
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

if [ "${scope}" == "${default_scope}" ]; then
	echo "To access drive list, issue the following command"
	echo "curl -s 'https://www.googleapis.com/drive/v3/files?access_token=${access_token}'"
	echo

	echo "To access a file from Google Drive, issue the drive list command above and copy down the FILE_ID and replace it into the following URL and run the command: "
	echo "curl -s 'https://www.googleapis.com/drive/v3/files/FILE_ID?access_token=${access_token}&alt=media' -L"
	echo
	echo "We took the liberty to save the issued access token into a config file, so you should also be able to access the drive list with the following command:"
	echo 'curl -s "https://www.googleapis.com/drive/v3/files?access_token=$(cat '${CONFIG_FILE}' | awk -F= '"'"'/ACCESS_TOKEN/{print $2}'"'"')"'
	echo
fi

echo "If the above commands give "Access Not Configured" error message, try to go through the above steps again. If all else fails, visit the IAM & Admin Settings page and Shut Down this App/Project and start over again."
echo
echo "for Google Drive, you'd visit the Google Drive API Library (i.e. https://console.cloud.google.com/apis/library/drive.googleapis.com) and click Enable. Then, click on the project name and then click Open."
echo
echo ===================================================================
echo
