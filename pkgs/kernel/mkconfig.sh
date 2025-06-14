#!/usr/bin/env bash

set -euo pipefail

configfile=$1
optionsfile=$2
mode=$3

configscript="./scripts/config"

function set_val() {
    file="$1"
    option="$2"
    val="$3"
    echo "set: option=$option; val=$val"
    case $val in
	"m")
	    if [ "x$NOMODULES" == "x1" ]; then
		$configscript --file "$file" --enable "$option"
	    else
		$configscript --file "$file" --module "$option"
	    fi
	    ;;
	"y")
	    $configscript --file "$file" --enable "$option"
	    ;;
	"n")
	    $configscript --file "$file" --disable "$option"
	    ;;
	*)
	    if [[ $1 =~ ^[0-9a-fA-Fx]+$ ]]; then
		$configscript --file "$file" --set-val "$option" "$val"
	    else
		$configscript --file "$file" --set-str "$option" "$val"
	    fi
	    ;;
    esac
}

function set_config() {
    IFS=' ' cat "$optionsfile" | while read -r option val; do
	set_val "$configfile" "${option//'?'}" "$val"
    done
}

function check_val() {
    file="$1"
    option="$2"
    val="$3"
    actual_val=$($configscript --file "$file" --state "$option")
    case $actual_val in
	"$val")
	    #echo "$option is set correctly to $actual_val"
	    ;;
	"y")
	    if [ "x$NOMODULES" == "x1" ] && [ "x$val" = "xm" ]; then
		#echo "$option is built-in but we have a module-less kernel, ok"
		return 0
	    else
		echo "$option is built-in but we wanted module"
		return 1
	    fi
	    ;;
	*)
	    echo "$option is $actual_val but we expected $val"
	    return 1
	    ;;
    esac
    return 0
}

function check_config() {
    wrongOptions=()
    allOk=0
    IFS=' '
    while read -r option val; do
	if [[ $option = *'?' ]]; then
	    #echo "${option//'?'} is optional, skipping"
	    continue
	else
	    check_val "$configfile" "$option" "$val" || allOk=1
	fi
    done <<< $(cat "$optionsfile")
    echo $allOk
    if [ $allOk == 1 ]; then
	echo "invalid kernel config"
	exit 1
    fi
}

case "$mode" in
    "set")
	set_config
	;;
    "check")
	check_config
	;;
    *)
	echo "What do you want from me??"
	exit 1
	;;
esac
