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

# CSV file for sap router entries
CSV_SAPROUTTAB="./saprouttab.csv"

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
    # LOCAL: Line read from ACL file
    local _line

    # LOCAL: Name of the partner for current block of entries
    local _partner_name

    # LOCAL: IP address
    local _ip_address

    # LOCAL: System hostname
    local _hostname

    # LOCAL: System ID (SID)
    local _sid

    # LOCAL: Port
    local _port

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

	if [ "$READ_DATA" = "yes" ]
	then
	    if [[ "$_line" =~ ^(##-- .*: .* --##)$ ]]
	    then
		_partner_name=$(echo "$_line" | sed -e 's/[0-9]*[:]//g' | tr -d '#\-' | xargs)
	    else
		_ip_address=$(echo "$_line" | awk '{print $2}' | xargs)
		_hostname=$(echo "$_line" | awk '{print $3}' | xargs)
		_sid=$(grep -E "(^|\s)${_hostname}($|\s)" "$SAPROUTTAB" | head -n 1 | awk '{print $2}' | tr -d ':' | xargs)
		_port=$(echo "$_line" | awk '{print $4}' | xargs)
		_employee_id=$(echo "$_line" | sed -n -e 's/^.*: //p' | awk -F "|" '{print $1}' | xargs)
		_entry_date=$(echo "$_line" | sed -n -e 's/^.*: //p' | awk -F "|" '{print $2}' | xargs)
		_consultant_name=$(echo "$_line" | sed -n -e 's/^.*: //p' | awk -F "|" '{print $3}' | xargs)
		_consultant_email=$(echo "$_line" | sed -n -e 's/^.*: //p' | awk -F "|" '{print $4}' | xargs)
		echo "$_partner_name,$_ip_address,$_sid,$_hostname,$_employee_id,$_entry_date,$_consultant_name,$_consultant_email" >> "$CSV_SAPROUTTAB"
	    fi
	fi
    done < "$SAPROUTTAB"

    
    sort -o "$CSV_SAPROUTTAB" "$CSV_SAPROUTTAB"

    sed -i '1s/^/\n/' "$CSV_SAPROUTTAB"
    sed -i '1s/^/PARTNER NAME , IP ADDRESS, SYSTEM, HOSTNAME , EMPLOYEE ID , ENTRY DATE , CONSULTANT , EMAIL ID\n/' "$CSV_SAPROUTTAB"
}

function _acl_to_csv() { #quickdoc: Main function that calls all other functions.
    # LOCAL: Choice of ACL file
    local _acl_choice

    while :
    do
	echo "
    Enter your choice of ACL file(s):

    1. Both (webdisptab and saprouttab).
    2. Only web dispatcher (webdisptab).
    3. Only sap router (saprouttab)."

	echo ""
	echo -n "> "
	read -n 1 _acl_choice

	if [[ "$_acl_choice" =~ [123] ]]
	then
	    break
	else
	    echo "Invalid choice."
	fi
    done

    if [ "$_acl_choice" -eq 1 ]
    then
	echo "Generating webdisptab CSV file..."
	_webdisptab_to_csv
	echo "Done."
	echo "Generating saprouttab CSV file..."
	_saprouttab_to_csv
	echo "Done."
    elif [ "$_acl_choice" -eq 2 ]
    then
	echo "Generating webdisptab CSV file..."
	_webdisptab_to_csv
	echo "Done."
    else
	echo "Generating saprouttab CSV file..."
	_saprouttab_to_csv
	echo "Done."
    fi
}

_acl_to_csv
