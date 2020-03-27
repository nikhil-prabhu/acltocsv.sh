#!/usr/bin/env bash

####################
# GLOBAL VARIABLES #
####################

# Web dispatcher ACL file
WEBDISPTAB="/usr/sap/WD2/whitelist/webdisptab_test"

# SAP router ACL file
SAPROUTTAB="/usr/sap/WD2/whitelist/saprouttab_test"

# CSV file for web dispatcher entries
CSV_WEBDISPTAB="./webdisptab.csv"

# Tell the script when to start reading data from the file
READ_DATA="no"

#############
# FUNCTIONS #
#############

function _webdisptab_to_csv() { #quickdoc: Extracts the required data block(s) from the web dispatcher ACL file.

    # LOCAL: Line read from ACL file
    local _line

    # LOCAL: Name of partner for current block of entries
    local _partner_name

    # LOCAL: IP address
    local _ip_address

    # LOCAL: Employee id
    local _employee_id

    # LOCAL: Date of entry
    local _entry_date

    # LOCAL: Name of partner's technical consultant
    local _consultant_name
    
    # LOCAL: Technical consultant email id
    local _consultant_email

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
		_partner_name=$(echo "$_line" | sed -e 's/[0-9]*[:]//g' | tr -d '#\-' | xargs)
	    else
		_ip_address=$(echo "$_line" | awk '{print $5}')
		_employee_id=$(echo "$_line" | sed -n -e 's/^.*: //p' | awk -F "|" '{print $1}' | xargs)
		_entry_date=$(echo "$_line" | sed -n -e 's/^.*: //p' | awk -F "|" '{print $2}' | xargs)
		_consultant_name=$(echo "$_line" | sed -n -e 's/^.*: //p' | awk -F "|" '{print $3}' | xargs)
		_consultant_email=$(echo "$_line" | sed -n -e 's/^.*: //p' | awk -F "|" '{print $4}' | xargs)
		echo "$_partner_name,$_ip_address,$_employee_id,$_entry_date,$_consultant_name,$_consultant_email" >> "$CSV_WEBDISPTAB"
	    fi
	fi
    done < "$WEBDISPTAB"

    sort -o "$CSV_WEBDISPTAB" "$CSV_WEBDISPTAB"

    sed -i '1s/^/\n/' "$CSV_WEBDISPTAB"
    sed -i '1s/^/PARTNER NAME , IP ADDRESS , EMPLOYEE ID , ENTRY DATE , CONSULTANT , EMAIL ID\n/' "$CSV_WEBDISPTAB"
}

function _saprouttab_to_csv() { #quickdoc: Converts the saprouttab file to a CSV file.
    echo &> /dev/null # Don't do anything for now
}
