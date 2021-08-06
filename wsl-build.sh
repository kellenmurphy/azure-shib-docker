#!/bin/bash
source secrets/azure.secrets
source VERSIONS
./install
./upload_azure.sh
./build
docker tag shibboleth-idp:$JETTY_VERSION $AZURE_CR/shibboleth-idp
docker push $AZURE_CR/shibboleth-idp