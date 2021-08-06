#!/bin/bash
if [ -n "$1" ]
then
cp -rp $1/* ./shibboleth-idp
else
    if [ -n "$CONF_REPO" ]
    then 
        cp -rp /mnt/d/repos/$CONF_REPO/* ./shibboleth-idp
    else
        echo "ERROR: please either define CONF_REPO environment var or specify input repository path"
    fi
fi