#!/usr/bin/env bash

####################
# GLOBAL VARIABLES #
####################

# Web dispatcher ACL file
WEBDISPTAB="/usr/sap/WD2/whitelist/webdisptab_test"

# SAP router ACL file
SAPROUTTAB="/usr/sap/WD2/whitelist/saprouttab_test"

# Temporary file to store extracted webdisptab entries
TMP_WEBDISPTAB="/tmp/acltocsv.sh-webdisptab.temp"

# Tell the script when to start reading data from the file
READ_DATA="no"

#############
# FUNCTIONS #
#############

function _extract_webdisptab() { #quickdoc: Extracts the required data block(s) from the web dispatcher ACL file.

    # LOCAL: Line read from ACL file
    local _line
    
    while read _line
    do
	if [[ "$_line" =~ ^(##-- .*: .* --##)$ ]]
	then
	    READ_DATA="yes"
	fi

	if [[ "$_line" =~ ^(# Deny all other)$ ]]
	then
	    READ_DATA="no"
	fi

	if [ "$READ_DATA" = "yes" ]
	then
	    if [[ "$_line" =~ ^(##-- .*: .* --##)$ ]]
	    then
		echo "$_line" | sed -e 's/[0-9]*[:]//g'
	    else
		echo "$_line"
	    fi
	fi
    done < "$WEBDISPTAB"
}

function _convert_webdisptab() { #quickdoc: Converts the webdisptab file to a CSV file.
    echo &> /dev/null # Don't do anything for now
}

function _convert_saprouttab() { #quickdoc: Converts the saprouttab file to a CSV file.
    echo &> /dev/null # Don't do anything for now
}
