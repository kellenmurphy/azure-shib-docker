#!/bin/bash
# requires azcopy https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10?toc=/azure/storage/files/toc.json

AZCOPY_PATH=/mnt/d/bin

if ! [ -e ./secrets/azure.secrets ]; then
  echo 'no azure.secrets' >&2
  exit 1
else 
  . ./secrets/azure.secrets
fi

AZ_STRING="${AZURE_FILE_ENDPOINT}"
AZ_STRING+="${JETTY_SHARE_NAME}"
AZ_STRING+="${AZURE_SAS}"
$AZCOPY_PATH/azcopy make --quota-gb 1 $AZ_STRING

AZ_STRING="${AZURE_FILE_ENDPOINT}"
AZ_STRING+="${IDP_SHARE_NAME}"
AZ_STRING+="${AZURE_SAS}"
$AZCOPY_PATH/azcopy make --quota-gb 2 $AZ_STRING

FILES="./shibboleth-idp/*"
for f in $FILES; do
  if [[ "$f" == "./shibboleth-idp/doc" ]]; then
    continue
  fi
  echo "Uploading: " $f
  $AZCOPY_PATH/azcopy copy --recursive $f $AZ_STRING > /dev/null 2>&1
done