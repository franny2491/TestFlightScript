#!/bin/bash
#
 
# Testflightapp.com settings
API_TOKEN="YOUR_API_TOKEN"
TEAM_TOKEN="YOUR_TEAM_TOKEN"
NOTIFY_USERS="True"
DISTRIBUTION_LIST="YOUR_NAME_OF_LIST"
 
# Change these to the correct Name and Folder
PRODUCT_NAME="APP_NAME"

# Output folder this is created at runtime
PRODUCT_FOLDER="${HOME}/Desktop/TestFlightBuild"
 
# Update to the correct Identity and Profile
SIGNING_IDENTITY="iPhone Distribution"
PROVISIONING_PROFILE="${HOME}/Library/MobileDevice/Provisioning Profiles/YOUR_PROVISIONING_PROFILE.mobileprovision"
 
# Calculated locations
OUT_IPA="${PRODUCT_FOLDER}/${PRODUCT_NAME}.ipa"
OUT_DSYM="${PRODUCT_FOLDER}/${PRODUCT_NAME}.dSYM.zip"
 
# Delete product folder directory
rm -rf $PRODUCT_FOLDER
mkdir $PRODUCT_FOLDER
 
# Compile code

WORKSPACE="WORKSPACE_PATH"
SCHEME="APP_NAME"
CONFIG="Release build archive"
SDK="iphoneos6.1"

echo "Compilation Started for ${PRODUCT_NAME}"
xcodebuild -workspace ${WORKSPACE} -scheme ${SCHEME} -sdk ${SDK} -configuration ${CONFIG}
 
echo "Compiled Successfully"
 
# Create IPA
echo "Creating .ipa for ${PRODUCT_NAME}"
 

NOW=$(date +"%Y-%m-%d")

ARCHIVE=$( /bin/ls -t "${HOME}/Library/Developer/Xcode/Archives/${NOW}" | /usr/bin/grep xcarchive | /usr/bin/sed -n 1p )
DSYM="${HOME}/Library/Developer/Xcode/Archives/${NOW}/${ARCHIVE}/dSYMs/${PRODUCT_NAME}.app.dSYM"
APP="${HOME}/Library/Developer/Xcode/Archives/${NOW}/${ARCHIVE}/Products/Applications/${PRODUCT_NAME}.app"

# Packaging IPA with Profile
echo "Packaging IPA with Profile ${APP}"
/usr/bin/xcrun -sdk iphoneos PackageApplication -v "${APP}" -o "${OUT_IPA}" --sign "${SIGNING_IDENTITY}" --embed "${PROVISIONING_PROFILE}"
 
# Zipping dsym file
echo "Zipping .dSYM for ${PRODUCT_NAME}"
/usr/bin/zip -r "${OUT_DSYM}" "${DSYM}"
 
# Preparing build notes
NOTES="Test push to TestFlight"
 
# Uploading to TestFlight
echo "Uploading ${PRODUCT_NAME} to TestFlight"
 
/usr/bin/curl "http://testflightapp.com/api/builds.json" \
-F file=@"${OUT_IPA}" \
-F dsym=@"${OUT_DSYM}" \
-F api_token="${API_TOKEN}" \
-F team_token="${TEAM_TOKEN}" \
-F notes="${NOTES}" \
-F notify="${NOTIFY_USERS}" \
-F distribution_lists="${DISTRIBUTION_LIST}"
