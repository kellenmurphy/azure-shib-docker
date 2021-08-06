#!/bin/bash

for arg in "$@"
do
ARGS+=$arg" "
done
powershell.exe docker exec -it shibboleth-idp-docker_shibboleth-idp bash