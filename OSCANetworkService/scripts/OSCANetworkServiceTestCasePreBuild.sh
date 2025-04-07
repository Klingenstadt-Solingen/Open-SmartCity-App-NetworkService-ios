#!/bin/bash
# Type a script or drag a script file from your workspace to insert its path.
# https://stackoverflow.com/questions/9850936/what-permissions-are-required-for-run-script-during-a-build-phase
# path to oscanetworkservice-ios root dir
# Emit log message
#echo "This is just a log message"
#
## Emit warning
#echo "warning: This is a warning message"
#
## Emit error
#echo "error: This is an error message"


# first argument: "SPM" for SPM package test
echo 'First arg: ' $1
# second argument: osca secrets from user HOME
echo 'Second arg: ' $2

# path to library project root dir
LIBRARY_ROOT_PATH=$PROJECT_DIR/OSCATestCaseExtension/Resources
# base name:
CONFIG_FILE_BASE_NAME="API"
# release name "API_Release.plist"
CONFIG_FILE_NAME_RELEASE=${CONFIG_FILE_BASE_NAME}_Release.plist
# debug name "API_Develop.plist"
CONFIG_FILE_NAME_DEBUG=${CONFIG_FILE_BASE_NAME}_Develop.plist
# sample release name "API_Release-Sample.plist
SAMPLE_CONFIG_FILE_NAME_RELEASE=${CONFIG_FILE_BASE_NAME}_Release-Sample.plist
# sample debug name "API_Develop-Sample.plist"
SAMPLE_CONFIG_FILE_NAME_DEBUG=${CONFIG_FILE_BASE_NAME}_Develop-Sample.plist

if [ "$1" = "SPM" ]; then
  echo "run script from SPM"
  echo "SCHEME_NAME: $SCHEME_NAME"
  #cleanup build folder
  echo "Build cleanup at ${BUILT_PRODUCTS_DIR}"
  rm -rvf ${BUILT_PRODUCTS_DIR}
  
  if [[ -n "$2" ]]; then
    OSCA_SECRETS_PATH=$HOME/$2
    echo "OSCA_SECRETS_PATH: ${OSCA_SECRETS_PATH}"
    SOURCE_PACKAGE_ROOT_PATH=${WORKSPACE_PATH%.swiftpm*}
    echo "SOURCE_PACKAGE_ROOT_PATH: ${SOURCE_PACKAGE_ROOT_PATH}"
    
    # reset package
    cd ${SOURCE_PACKAGE_ROOT_PATH}
    echo "reset package at: ${SOURCE_PACKAGE_ROOT_PATH}"
    /usr/bin/xcrun --sdk macosx swift package reset
    
    # update package
    cd ${SOURCE_PACKAGE_ROOT_PATH}
    echo "update package at: ${SOURCE_PACKAGE_ROOT_PATH}"
    /usr/bin/xcrun --sdk macosx swift package update
    
    
    # SOURCE
    # debug source file path
    CONFIG_DEBUG_SOURCE_FILE_PATH=$OSCA_SECRETS_PATH/$CONFIG_FILE_NAME_DEBUG
    # release source file path
    CONFIG_RELEASE_SOURCE_FILE_PATH=$OSCA_SECRETS_PATH/$CONFIG_FILE_NAME_RELEASE
    # sample release file path ".../API_Release-Sample.plist"
    SAMPLE_CONFIG_RELEASE_FILE_PATH=$OSCA_SECRETS_PATH/$SAMPLE_CONFIG_FILE_NAME_RELEASE
    # sample debug file path ".../API_Develop-Sample.plist"
    SAMPLE_CONFIG_DEBUG_FILE_PATH=$OSCA_SECRETS_PATH/$SAMPLE_CONFIG_FILE_NAME_DEBUG
    # DESTINATION
    # debug file path ".../API_Develop.plist"
    # CONFIG_DEBUG_FILE_PATH=$SRCROOT/$PRODUCT_NAME/$CONFIG_FILE_NAME_DEBUG
    CONFIG_DEBUG_FILE_PATH=${BUILT_PRODUCTS_DIR%/Build*}/SourcePackages/checkouts/oscatestcaseextension-ios/OSCATestCaseExtension/OSCATestCaseExtension/Resources/$CONFIG_FILE_NAME_DEBUG
    # release file path ".../API_Release.plist"
    CONFIG_RELEASE_FILE_PATH=${BUILT_PRODUCTS_DIR%/Build*}/SourcePackages/checkouts/oscatestcaseextension-ios/OSCATestCaseExtension/OSCATestCaseExtension/Resources/$CONFIG_FILE_NAME_RELEASE
  else
    echo "🔴 error: Missing secrets Path"
  fi
else
  echo "run script from non SPM"
  if [[ -n "$1" ]]; then
    DESTINATION=$1
    echo "DESTINATION: ${DESTINATION}"
    if [[ -n "$2" ]]; then
      OSCA_SECRETS_PATH=$HOME/$2
      echo "OSCA_SECRETS_PATH: ${OSCA_SECRETS_PATH}"
      SOURCE_PACKAGE_ROOT_PATH=${WORKSPACE_PATH%.swiftpm*}
      echo "SOURCE_PACKAGE_ROOT_PATH: ${SOURCE_PACKAGE_ROOT_PATH}"
      
      # reset package
      cd ${SOURCE_PACKAGE_ROOT_PATH}
      echo "reset package at: ${SOURCE_PACKAGE_ROOT_PATH}"
      /usr/bin/xcrun --sdk macosx swift package reset
      
      # update package
      cd ${SOURCE_PACKAGE_ROOT_PATH}
      echo "update package at: ${SOURCE_PACKAGE_ROOT_PATH}"
      /usr/bin/xcrun --sdk macosx swift package update
      
      # SOURCE
      # debug source file path
      CONFIG_DEBUG_SOURCE_FILE_PATH=$OSCA_SECRETS_PATH/$CONFIG_FILE_NAME_DEBUG
      # release source file path
      CONFIG_RELEASE_SOURCE_FILE_PATH=$OSCA_SECRETS_PATH/$CONFIG_FILE_NAME_RELEASE
      # sample release file path ".../API_Release-Sample.plist"
      SAMPLE_CONFIG_RELEASE_FILE_PATH=$OSCA_SECRETS_PATH/$SAMPLE_CONFIG_FILE_NAME_RELEASE
      # sample debug file path ".../API_Develop-Sample.plist"
      SAMPLE_CONFIG_DEBUG_FILE_PATH=$OSCA_SECRETS_PATH/$SAMPLE_CONFIG_FILE_NAME_DEBUG
      # DESTINATION
      # debug file path ".../API_Develop.plist"
      # CONFIG_DEBUG_FILE_PATH=$SRCROOT/$PRODUCT_NAME/$CONFIG_FILE_NAME_DEBUG
      CONFIG_DEBUG_FILE_PATH=${SOURCE_PACKAGE_ROOT_PATH}/OSCANetworkService/OSCANetworkServiceTests/Resources/$CONFIG_FILE_NAME_DEBUG
      # release file path ".../API_Release.plist"
      CONFIG_RELEASE_FILE_PATH=${SOURCE_PACKAGE_ROOT_PATH}/OSCANetworkService/OSCANetworkServiceTests/Resources/$CONFIG_FILE_NAME_RELEASE
    else
      echo "🔴 error: Missing secrets Path"
    fi
  else
    echo "🔴 error: Missing destination Path"
  fi
fi

# copy phase release
if [ -f "$CONFIG_RELEASE_SOURCE_FILE_PATH" ]; then
  echo "🟢$CONFIG_RELEASE_SOURCE_FILE_PATH exists."
  if [ -f "$CONFIG_RELEASE_FILE_PATH" ]; then
    rm -v "${CONFIG_RELEASE_FILE_PATH}"
  fi
  cp -v "${CONFIG_RELEASE_SOURCE_FILE_PATH}" "${CONFIG_RELEASE_FILE_PATH}"
  echo "$CONFIG_FILE_NAME_RELEASE copied to $CONFIG_RELEASE_FILE_PATH"
else
  echo "🔴 error: $CONFIG_RELEASE_SOURCE_FILE_PATH does not exist!"
fi
# copy phase debug
if [ -f "$CONFIG_DEBUG_SOURCE_FILE_PATH" ]; then
  echo "🟢 $CONFIG_DEBUG_SOURCE_FILE_PATH exists."
  if [ -f "$CONFIG_DEBUG_FILE_PATH" ]; then
    rm -v "${CONFIG_DEBUG_FILE_PATH}"
  fi
  cp -v "${CONFIG_DEBUG_SOURCE_FILE_PATH}" "${CONFIG_DEBUG_FILE_PATH}"
  echo "$CONFIG_FILE_NAME_DEBUG copied to $CONFIG_DEBUG_FILE_PATH"
else
  echo "🔴 error: $CONFIG_DEBUG_SOURCE_FILE_PATH does not exist!"
fi

# if release file path exists
if [ -f "$CONFIG_RELEASE_FILE_PATH" ]; then
  # then echo
  echo "🟢 $CONFIG_RELEASE_FILE_PATH exists."
else
  # else copy sample release file
  echo "🔴 error: $CONFIG_RELEASE_FILE_PATH does not exist, copying sample"
  cp -v "${SAMPLE_CONFIG_RELEASE_FILE_PATH}" "${CONFIG_RELEASE_FILE_PATH}"
fi
# if debug file path exists
if [ -f "$CONFIG_DEBUG_FILE_PATH" ]; then
  echo "🟢 $CONFIG_DEBUG_FILE_PATH exists."
else
  # else copy sample debug file
  echo "🔴 error: $CONFIG_DEBUG_FILE_PATH does not exist, copying sample"
  cp -v "${SAMPLE_CONFIG_DEBUG_FILE_PATH}" "${CONFIG_DEBUG_FILE_PATH}"
fi

if [ "$1" = "SPM" ]; then
 # update package
  cd ${SOURCE_PACKAGE_ROOT_PATH}
  echo "resolve package at: ${WORKSPACE_PATH%.swiftpm/xcode/package.xcworkspace}"
  /usr/bin/xcrun --sdk macosx swift package resolve
fi



