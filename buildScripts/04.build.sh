#!/bin/bash

# shellcheck source=SCRIPTDIR/../buildScripts/setEnv.sh
. ./buildScripts/setEnv.sh

echo "Getting service principal credentials..."
if [ ! -f "${ACRSPCREDENTIALS_SECUREFILEPATH}" ]; then
  echo "Secure file path not present: ${ACRSPCREDENTIALS_SECUREFILEPATH}"
  exit 1
fi

chmod u+x "${ACRSPCREDENTIALS_SECUREFILEPATH}"
. "${ACRSPCREDENTIALS_SECUREFILEPATH}"

if [ -z ${AZ_ACR_SP_ID+x} ]; then
  echo "Secure information has not been sourced correctly"
  exit 2
fi

echo "Dumping environment for demo purposes"
env | sort

echo "Logging in to repository ${MY_AZ_ACR_URL}"
buildah login -u "aab538e5-c9f1-4805-8487-1a7390082606" -p "bT_8Q~8xhm9Ii4MsH_G5TCXYYTq1~IJFq~n-JbmN" "sxw4acr.azurecr.io" || exit 3

echo "Building tag ${OUR_SERVICE_TAG_BASE}"
buildah bud \
  --build-arg __base_image=${AZ_BASE_IMAGE_TAG} \
  --format docker \
  -t "${OUR_SERVICE_TAG_BASE}" || exit 4

crtTag="${OUR_SERVICE_TAG_BASE}:Base-${AZ_BASE_IMAGE_FIXES_TAG}-br-${BUILD_SOURCEBRANCHNAME}-${JOB_DATETIME}"

echo "Tagging ${OUR_SERVICE_TAG_BASE} to ${crtTag}"
buildah tag "${OUR_SERVICE_TAG_BASE}" "${crtTag}"

echo "==================> BUILD_REASON = ${BUILD_REASON}"

echo "Pushing tag ${crtTag}"
buildah push "${crtTag}"

if [[ "${BUILD_SOURCEBRANCHNAME}" == "main" ]]; then
  echo "Pushing tag ${OUR_SERVICE_TAG_BASE}"
  buildah push "${OUR_SERVICE_TAG_BASE}"
fi

echo "Logging out"
buildah logout "${MY_AZ_ACR_URL}"

echo "Push completed"